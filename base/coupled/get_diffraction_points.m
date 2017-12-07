% get_diffraction_points - For a room containing a source and a receiver being outside this room,
% points on the door wall surface are calculated which represent the shortest connections (through
% the door) between all image sources and the receiver. For image sources which are visible to the
% receiver, these points will lie within the door opening surface. For invisible image sources,
% these points will lie on one of the four door edges.
%
% Usage:
%   [diffpoints, arr, isondoorsurf] = ...
%       get_diffraction_points(room, door_idx, srcpos, recpos, [do_plot])
%
% Input:
%   room            room structure, containing also the receiver outside the room
%   door_idx        Index of door to be regarded
%   srcpos          Positions of image sources (rows = sources, columns = dimensions)
%   recpos          Positions of receiver(s). May be one or the same number as ISpos
%   do_plot         If true, plot call scene() and add image sources and diffraction points
%                   (optional, default: false)
%
% Output:
%   diffpoints      Diffraction points, either within the door opening surface or on a door edge
%                   (depending on the output of get_intsecpoints())
%   arr             Arrangement of source(s) and receiver(s). Structure containing the following
%                   fields:
%       azim_in         Azimuth angles (deg) between image-source connection to diffpoints and
%                       negative wall normal
%       azim_out        Azimuth angles (deg) between diffpoint-receiver connection and wall normal
%       elev_in         Elevation angles (deg) between image-source connection to diffpoints and
%                       negative wall normal
%       elev_out        Elevation angles (deg) between diffpoint-receiver connection and wall normal
%       angles_src_rec  180 - angle(diffpoints->src, diffpoints->rec)
%       distce_in       Distances from image sources to diffpoints
%       distce_out      Distances from diffpoints to receiver

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
