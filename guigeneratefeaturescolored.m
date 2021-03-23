function [features, mask] = guigeneratefeaturescolored(img, featurestype)
% [features, mask] = guigeneratefeaturescolored(image, imagetype, featurestype)
%
% Recieves a colored image, and a cell of structs defining the
% features to be created (featurestype). The features are generated
% and returned in a cell of structs "features". The function also
% return the mask defining the image's region of interest.
%

%
% Copyright (C) 2006  João Vitor Baldini Soares
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301, USA.
%

% Creates the aperture mask, with the image's region of interest.
% Open the image
I = img;
% Get each color band
if (size(I,3)>1)
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
else
    R = I;
    G = I;
    B = I;
end

% Get the CIELab color representation
[L,a,b] = RGB2Lab(R,G,B);
L = L./100;
    
% Threshold it
threshold = 0.15;
mask = logical((1- (L < threshold)) > 0);
    
% If the resulting mask has only ones, then sum up the RGB bands and
% threshold it
if length(unique(mask(:)))==1
    mask = sum(I, 3) > 150;
end
    
% Fill holes and apply median filter
mask = imfill(mask,'holes');
mask = medfilt2(mask, [5 5]);
    
% Get connected components
CC = bwconncomp(mask);
    
% The largest connected component is the mask
componentsLength = cellfun(@length, CC.PixelIdxList);
[~, indexes] = sort(componentsLength, 'descend');
mask = bwareaopen(mask,componentsLength(indexes(1))-1);
% Generates the features.
img = double(img) / 255;

green = img(:,:,2);

% Uses only the green channel
img = 1 - green;
%save('img.mat','img');
% Makes the image larger before creating artificial extension, so the
% wavelet doesn't have border effects
[sizey, sizex] = size(img);

bigimg = zeros(sizey + 100, sizex + 100);
bigimg(51:(50+sizey), 51:(50+sizex)) = img;

bigmask = logical(zeros(sizey + 100, sizex + 100));
bigmask(51:(50+sizey), (51:50+sizex)) = mask;

% Creates artificial extension of image.
paderosionsize = round((sizex + sizey) / 250);
bigimg = fakepad(bigimg, bigmask, paderosionsize, 50);
%save('bigimg0.mat','bigimg');
disp('Using CLAHE here');
%bigimg = adapthisteq(bigimg,'NumTiles',[12,12],'ClipLimit',0.005);
bigimg = adapthisteq(bigimg);
%save('bigimg.mat','bigimg');

fimg = fft2(bigimg);
save('fimg.mat','fimg');

features = featurestype;

for i=1:length(features)
    switch features{i}.type
        case 'Inverted green channel'
            features{i}.data = bigimg(51:(50+sizey), (51:50+sizex));
            features{i}.name = 'Inverted green channel';
            features{i}.shortname = 'green';
        case 'Gabor processed inverted green channel'
            k0x = 0;
            % Maximum transform over angles.
            trans = maxmorlet(fimg, features{i}.parameters.scale, ...
                features{i}.parameters.epsilon, [k0x features{i}.parameters.k0y], 10);
            trans = trans(51:(50+sizey), (51:50+sizex));
            %save(['trans' num2str(i) '.mat'],'trans');
            %disp('Using CLAHE here');
            %trans = adapthisteq(trans);
            
            % Adding to features
            features{i}.data = trans;
            features{i}.name = ['Gabor processed inverted green channel: a = ' ...
                    num2str(features{i}.parameters.scale) ' eps = ' ...
                    num2str(features{i}.parameters.epsilon) ' k0y = ' ...
                    num2str(features{i}.parameters.k0y)];
            features{i}.shortname = ['gabor-a' num2str(features{i}.parameters.scale) ...
                    '-eps' num2str(features{i}.parameters.epsilon) ...
                    '-k0y' num2str(features{i}.parameters.k0y)];
    end
end
save('feat.mat','features');
