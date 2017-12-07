function recdir = transform_orientation(room, rel_recdir_deg, angle_flag)
% TRANSFORM_ORIENTATION - transform receiver orientation to overall coordinate system if specified
% as relative to src.
%
% Usage:
%   recdir = TRANSFORM_ORIENTATION(room, rel_recdir_deg, [angle_flag])
%
% Input:
%   room            room structure (see RAZR), must contain fields srcpos and recpos
%   rel_recdir_deg  Receiver orientation (deg), relative to source, as vector [azim, elev]
%   angle_flag      Specifies which angles are treated as being specified relative to the source:
%                   'azim': only azimuth, 'elev': only elevation, 'all': both of them.
%                   Optional parameter, default: 'all'. For any other input string none of the
%                   angles will be transformed.
%
% Output:
%   recdir          New vlaues of the field room.recdir

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


if nargin < 3
    angle_flag = 'all';
end

if ~(isfield(room, 'srcpos') && isfield(room, 'recpos'))
    error('transform_orientation: room structure must contain fields srcpos and recpos.');
end

src_rec_conn = room.srcpos - room.recpos;

% azim:
if strcmp(angle_flag, 'azim') || strcmp(angle_flag, 'all')
    recdir(1) = rel_recdir_deg(1) + rd2dg(cart2pol(src_rec_conn(1), src_rec_conn(2)));
else
    recdir(1) = rel_recdir_deg(1);
end

% elev:
if strcmp(angle_flag, 'elev') || strcmp(angle_flag, 'all')
    [az, el] = cart2sph(src_rec_conn(1), src_rec_conn(2), src_rec_conn(3));
    recdir(2) = rel_recdir_deg(2) + rd2dg(el);
else
    recdir(2) = rel_recdir_deg(2);
end
