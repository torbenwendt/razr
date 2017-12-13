function isp = create_is_pattern(orders, discd_directions, discd_dir_ords)
% CREATE_IS_PATTERN - Get positions and other informations of image sources for a 1x1x1 shoebox room
%
% Usage:
%   isp = CREATE_IS_PATTERN(orders, [discd_direction], [discd_dir_ords])
%
% Input:
%   orders              Maximum image source order or vector [min, max] Order
%   discd_directions    Directions (indices [-3, -2, -1, +1, +2, +3] <-> [-z, -y, -x, +x, +y, +z]),
%                       for which all image sources will be discarded
%                       (optional parameter, default: empty vector)
%   discd_dir_ords      Orders for which all image sources of specified directions
%                       ('discd_directions') are discarded. Set empty, if all orders (i.e. N0 to N1)
%                       shall be specified. Optional parameter, default: [].
%
% Output:
%   isp                 Structure with the following fields:
%       pattern         Positions of image sources in coordinates of image rooms
%       invert_pos      Flag indicating if image source position component (x,y,z) within image
%                       room is given by the source position in the actual room (0) or if it is inverted
%                       by the room dimension (x,y,z) (1). This will help for the calculation of the actual
%                       image source positions depending on room dimensions.
%       num_refl        Number of reflections at wall [-z -y -x +x +y +z]
%       order           Image source order

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
%
% Author(s): Torben Wendt
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


if nargin < 3
    discd_dir_ords = [];
    if nargin < 2
        discd_directions = [];
    end
end

if any(orders) < 0
    isp = struct;
    warning('No negative ISM orders allowed. Empty struct returned.')
    return;
end

N2 = max(orders);

if length(orders) == 1
    N1 = 0;
else
    N1 = min(orders);
end

if isempty(discd_dir_ords)
    discd_dir_ords = N1:N2;
end

isp.pattern = create_room_pattern(N1, N2);

% IS position/direction flags:
% say whether i-th IS component is loacated at position x(i) or boxsize(i)-p(i)
isp.invert_pos = mod(isp.pattern, 2);

% number of reflections at walls [-z -y -x] (order: [1 2 3] <-> [-z -y -x]):
isp.num_refl = zeros(size(isp.pattern, 1), 6);
isp.num_refl(:, 3:-1:1) = floor(abs(isp.pattern/2)) ...
    + min(abs(min(sign(isp.pattern), 0)), isp.invert_pos);

% number of reflections at walls [+x +y +z]:
isp.num_refl(:, 4:6) = floor(abs(isp.pattern/2)) ...
    + min(abs(max(sign(isp.pattern), 0)), isp.invert_pos);

isp.order = sum(abs(isp.pattern), 2);

for n = 1:length(discd_directions)
    sgndim = sign(discd_directions(n));
    absdim = abs(discd_directions(n));
    
    idx_discd_direction = sgndim*isp.pattern(:, absdim) > 0;
    idx_discd_orders = ismember(isp.order, discd_dir_ords);
    idx_keep = ~(idx_discd_direction & idx_discd_orders);
    
    isp = structfun(@(x) (x(idx_keep, :)), isp, 'UniformOutput', false);
end
