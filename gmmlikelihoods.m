function [vessellikelihoods, restlikelihoods, vesselprior, restprior] = ...
       gmmlikelihoods(featurefilename, modelfilename, normalizeflag)
% [vessellikelihoods, restlikelihoods, ratiothreshold] = ...
%    gmmlikelihoods(featurefilename, modelfilename, normalizeflag)
%
% [vessellikelihoods, restlikelihoods, ratiothreshold] = ...
%    gmmlikelihoods(featurefilename, modelfilename)
%
% Calculates pixels likelihoods using the gaussian mixture
% models. Returns two images, in which each pixel is the likelihood of
% that pixel for each class. The values are: p(x / vessel) and p(x /
% rest).
%
% "vesselprior" and "restprior" are the estimated class priors.
%
% Receives:
%
% "featurefilename": Pixel features being classified.
% "modelfilename": Gaussian mixture model.
% "normalizeflag": optional. If 0, the same normalization is to be
% used for the training samples and the ones being classified.
%
% See also: gmmcreatemodel, gmmclassifygray, gmmclassify.

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
M = modelfilename.M;
%save('Model.mat','M');
F = featurefilename;
%save('Features.mat','F');
% Normalizes features before classification.
[rows, columns, pages] = size(F.features);
F.features = reshape(F.features, [rows * columns, pages]);
samplematrix = F.features(F.mask(:), :);
%save('sm0.mat','samplematrix');
% Verifies normalizeflag to see if same normalization should be used
% for the training samples and the ones being classified.
if (nargin > 2 & normalizeflag == 0)
  disp('Using same normalization for training and classification.');
  samplematrix = normfeats(samplematrix, M.samplemean, M.samplestd);
else
  samplematrix = normfeats(samplematrix);
end
% If projectionmatrix is present, projects the features.
if (isfield(M, 'projectionmatrix'))
  ndims = M.ndims;
  samplematrix = samplematrix * M.projectionmatrix(:, 1:ndims);
else
  ndims = pages;
end
%save('sm.mat','samplematrix');
nsamples = size(samplematrix, 1);

% Calculates the vessel likelihoods.
vessellikelihoodvector = zeros(1, nsamples);
for k = 1:size(M.vesselgaussians, 2);
  detcov = det(M.vesselgaussians(k).covariance);
  
  invcov =  inv(M.vesselgaussians(k).covariance);
  
  diff = samplematrix - repmat(M.vesselgaussians(k).mean', [nsamples 1]);
  
  factor = (1 / ((2 * pi)^(ndims/2) * detcov^(1/2))) * ...
           M.vesselgaussians(k).weight;
  
  vessellikelihoodvector = vessellikelihoodvector + ...
                     factor * exp( (-1/2) * sum(diff * invcov .* diff, 2)' );

  disp(['Calculated vessel-likelihood for gaussian ' num2str(k)]);
end

vessellikelihoods = zeros(size(F.mask));
vessellikelihoods(F.mask(:)) = vessellikelihoodvector;
vesselprior = M.vesselprior;

% Calculates the rest likelihoods.
restlikelihoodvector = zeros(1, nsamples);
for k = 1:size(M.restgaussians, 2);
  detcov = det(M.restgaussians(k).covariance);
  
  invcov =  inv(M.restgaussians(k).covariance);
  
  diff = samplematrix - repmat(M.restgaussians(k).mean', [nsamples 1]);
  
  factor = (1 / ((2 * pi)^(ndims/2) * detcov^(1/2))) * ...
           M.restgaussians(k).weight;
  
  restlikelihoodvector = restlikelihoodvector + ...
                   factor * exp( (-1/2) * sum(diff * invcov .* diff, 2)' );

  disp(['Calculated rest-likelihood for gaussian ' num2str(k)]);
end

restlikelihoods = zeros(size(F.mask));
restlikelihoods(F.mask(:)) = restlikelihoodvector;
restprior = M.restprior;