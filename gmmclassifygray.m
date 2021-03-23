function classgray = gmmclassifygray(featurefilename, modelfilename)
% classgray = gmmclassifygray(featurefilename, modelfilename)
%
% Classifies the pixels in "featurefilename" using the gaussian
% mixture models in "modelfilename". Returns "classgray", an image
% with each pixel's posterior probability of being vessel.
%
% See also: gmmclassify, gmmlikelihoods, gmmcreatemodel.

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

% Calculates pixels likelihoods and class priors.
[vessellikelihoods, restlikelihoods, vesselprior, restprior] = ...
    gmmlikelihoods(featurefilename, modelfilename);

disp('Using gmmclass here');
% Calculates posterior probabilies.
vesselprob = vessellikelihoods * vesselprior;
restprob = restlikelihoods * restprior;

classgray = (vesselprob) ./ (restprob + vesselprob);
classgray((vesselprob + restprob) == 0) = 0;
