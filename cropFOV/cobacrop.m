%buat cropping FOV
root_folder = 'F:/mvessel/cobata/cropFOV/images';

% Output folder where files will be saved
output_folder = 'F:/mvessel/cobata/cropFOV';

% We always set this in true to avoid computing outside the FOV
perform_cropping = true;

%% now, generate fov masks
root = fullfile(output_folder, 'Nurulhuda');
threshold = 0.15;
GenerateFOVMasks;

%% crop every mask

if perform_cropping

    % cropping training data set
    fprintf('Cropping data set...\n');
    % - path where the images to crop are
    sourcePaths = { ...
        fullfile(output_folder, 'Nurulhuda', 'images'), ...
    };
    % - paths where the images to be cropped will be saved
    outputPaths = { ...
        fullfile(output_folder, 'Nurulhuda', 'images'), ...   
    };
    % - masks to be used to crop the images
    maskPaths = fullfile(output_folder, 'Nurulhuda', 'masks');
    % crop!!
    script_cropFOVSet;
    
end