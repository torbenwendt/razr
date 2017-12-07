function [pos, ang] = scale_isp(isd, room, obj)
% SCALE_ISP - Perform the actual scaling of src- or rec-position according to
% a pattern and a room.
%
% Usage:
%   pos = SCALE_ISP(isd, room, obj)
%
% Input:
%   isd     Output of CREATE_IS_PATTERN
%   room    Room structure (see RAZR)
%   obj     Object whose image positions are to be scaled: 'src' or 'rec'
%
% Output:
%   pos     3-column matrix with [x, y, z] per image object
%   ang     2-column matrix with [azim, elev] per image object
%
% See also: SCALE_IS_PATTERN

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
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


switch obj
    case 'src'
        point = room.srcpos;
        dirctn = room.srcdir;
    case 'rec'
        point = room.recpos;
        dirctn = room.recdir;
end

numSrc = size(isd.pattern, 1);
pos = zeros(numSrc, 3);
ang = zeros(numSrc, 2);

for n = 1:numSrc
    pos(n, 1:3) = isd.pattern(n, :).*room.boxsize + point.*(1 - 2*isd.invert_pos(n, :)) + ...
        isd.invert_pos(n, :).*room.boxsize;
    
    % azimuth:
    ang(n, 1) = (dirctn(1) - isd.invert_pos(n, 1)*180) * (1 - 2*isd.invert_pos(n, 1)) * (1 - 2*isd.invert_pos(n, 2));
    % elevation:
    ang(n, 2) = dirctn(2) * (1 - 2*isd.invert_pos(n, 3));
end
