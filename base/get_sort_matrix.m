function S_delta = get_sort_matrix(angles, valid_angles)
% GET_SORT_MATRIX - Calculates the best fitting channel mapping for the
% diffuse part, so that the used hrtf best fits with the azimuth and
% elevation of the given image source direction.
%
% Usage:
%   S_delta = GET_SORT_MATRIX(angles, valid_angles)
%
% Input:
%   angles          Matrix with azimuth in first and elevation in second column
%   valid_angles    Matrix with valid azimuth in first and valid elevation in second column
%
% Output:
%   S_delta         Sort matrix for best mapping to the valid_angles

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
%
% Author(s): Nico Goessling, Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% University Oldenburg, Germany.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


distance = zeros(size(valid_angles,1),1);
bestFit = zeros(size(angles,1),1);

% find best fitting cube hrtf
for k = 1:size(angles,1)
    for kk = 1:size(valid_angles,1)
        distance(kk) = norm(angles(k,:) - valid_angles(kk,:));
    end
    [~, bestFit(k)] = min(distance);
end

% build the sort matrix
S_delta = zeros(size(angles,1), 12);
for kkk = 1:size(angles,1)
    S_delta(kkk, bestFit(kkk)) = 1;
end

S_delta = sparse(S_delta);
