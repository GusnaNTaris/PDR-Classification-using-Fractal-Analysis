%%Program TA GNT 24 Juli 2020

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
    
    %generate feature
    load('featurestype.mat'); %specific feature mengikuti di mlvessel
    [features, mask] = guigeneratefeaturescolored(img, featurestype);
    
    %gmmlikelihood
    load('F.mat');
    featurefilename.mask = mask;
    featurefilename.description = fff.description;
    featurefilename.features = cat(3,features{1,5}.data,features{1,4}.data,features{1,3}.data,features{1,2}.data,features{1,1}.data);
    modelfilename = load('Modelfilename.mat'); %model mengikuti mlvessel
    
    %posterior probabilities
    gray = gmmclassifygray(featurefilename, modelfilename);
    
    %processing setelah classify
    %se = strel('disk',1);
    %gray = imopen(gray,se);
    
    %classify
    class = gray >= 0.5;
    
    %save gambar
    filename = baseFileName(1:end-4);%length('.tif') = 4
    %imwrite(gray, ['F:/mvessel/cobata/pprob/',filename,'.png'], 'png');  % Save image
    imwrite(class, ['F:/mvessel/cobata/segmentasi/',filename,'.png'], 'png');  % Save image
end
