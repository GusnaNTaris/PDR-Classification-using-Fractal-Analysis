%%Program mask
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
    imageArray = imread(fullFileName);
    % Open the image
    I = imageArray;
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
    filename = baseFileName(1:end-4);%length('.tif') = 4
    %imwrite(gray, ['F:/mvessel/cobata/pprob/',filename,'.png'], 'png');  % Save image
    imwrite(mask, ['F:/mvessel/cobata/masks/',filename,'.gif'], 'gif');  % Save image
end