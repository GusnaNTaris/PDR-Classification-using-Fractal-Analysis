% program buat ngeblur

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
    %konvolusi gambar dengan gaussian filter dengan (rb, sigmab)
    %disini set sigma B = 0,03w, dan rB antara 0,01w dengan 0,015w
    %w adalah width dari image
    width = 909; %fix
    
    %sigma B = 0.03w
    sigma = 0.03*width;
    
    %nilai r
    %r = floor(0.01*width); %biar integer
    r = floor(0.015*width);
        
    %pertama-tama buat gambar dari gaussian filter
    imgblur = imgaussfilt(img,sigma,'FilterSize',r);
    
    %save gambar
    filename = baseFileName(1:end-4);%length('.tif') = 4
    %imwrite(gray, ['F:/mvessel/cobata/pprob/',filename,'.png'], 'png');  % Save image
    imwrite(imgblur, ['F:/mvessel/cobata/blur/',filename,'.tif'], 'tif');  % Save image
end