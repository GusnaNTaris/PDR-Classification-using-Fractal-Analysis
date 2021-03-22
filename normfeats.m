function mat = normfeats(feat, usedmean, usedstd)
% mat = normfeats(feat, usedmean, usedstd)
% 
% Normalizes the features in "feats" using the "usedmean" and
% "usedstd", subtracting the mean and then diciding by the standard
% deviation deviation.
%
% mat = normfeats(feat)
%
% Normalizes using the mean and standard deviation of the received
% samples in "feats".

%
% Copyright (C) 2000  Roberto Marcondes Cesar Junior
%               2006  João Vitor Baldini Soares
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

[nsamp,nfeat] = size(feat); 

% normalizacao f' = (f-mean)/stdeviation
if ( nargin == 1 )
  usedmean = mean(feat);
  usedstd = std(feat);
end

mat = (feat - usedmean(ones(nsamp, 1), :)) ./ usedstd(ones(nsamp, 1), :);