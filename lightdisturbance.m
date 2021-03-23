% program buat light tranmission disturbance

% Specify the folder where the files live.
myFolder = 'F:\mvessel\cobata\images';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.tif'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    img = imread(fullFileName);
    
    %buat blur
    %x0 = clip (a(GL (rL; sigmaL) * J + x) + b; s) ;
    %clipping function
    %a contrast
    %b brightness
    %s saturation
    
    width = 909; %fix
    
    %nilai r
    %r = width; 
    r = floor(0.75.*width);%biar integer
    
    %sigma B = 0.03w
    sigma = 2./3*0.5*r;
    
    %kernel gaussian
    vGl = exp(-([-r:r] .^ 2) / (2 * sigma * sigma));
    vGl = vGl / sum(vGl);
    
    %tambah si J
    J = ones(width);
    J = a*J;
    
    imgpad   = padarray(img, [r, r], 'replicate', 'both');
    imblur(:,:,1) = conv2(vGl, vGl.', imgpad(:,:,1), 'valid');
    imblur(:,:,2) = conv2(vGl, vGl.', imgpad(:,:,2), 'valid');
    imblur(:,:,3) = conv2(vGl, vGl.', imgpad(:,:,3), 'valid');
    
    %a = contrast
    a = 0.63;
    %a = 0.56
    imblur = a*imblur;
    
    %clipping function
    %> a = [0.203 0.506 0.167 0.904 1.671 5.247 0.037 0.679];
    %a(a>1)=1
    %A = min(A,1); ato bisa gini

    %save gambar
    filename = baseFileName(1:end-4);%length('.tif') = 4
    %imwrite(gray, ['F:/mvessel/cobata/pprob/',filename,'.png'], 'png');  % Save image
    imwrite(imblur, ['F:/mvessel/cobata/lightdisturbance/',filename,'.tif'], 'tif');  % Save image
end