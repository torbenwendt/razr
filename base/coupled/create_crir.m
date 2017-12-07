% CREATE_CRIR - Create BRIR for two coupled rooms.
%
% Usage:
%   [ir, ism_data, ism_setup, fdn_setup] = CREATE_CRIR(rooms, adjacencies, [op])
%
% Input:
%   rooms           Vector of room structures. If it contains more than two rooms, those with src
%                   and rec will be picked automatically. If src and rec are within the same room,
%                   that adjacent room with highest T60 will be taken into account.
%   adjacencies     Adjacency specifications for rooms. Syntax example:
%                   adjacencies = {...
%                       'roomA', door_idx1_roomA, 'roomB', door_idx1_roomB, 1.0; ...
%                       'roomA', door_idx2_roomA, 'roomC', door_idx1_roomC, 0.5}
%                   The 1st row means that roomA and roomB are connected via the 1st specified
%                   door of roomA and the 1st specified door of roomB. This door is open ("1.0").
%                   The 2nd row means that roomA and roomC are connected via the 2nd specified
%                   door of roomA and the 1st specified door of roomC. The door is half open ("0.5")
%   op              Options structure (some defaults or passed options will be overwritten due to
%                   the algorithm definition)
%
% Output:
%   ir              Room impulse response structure (see RAZR)
%   ism_data        ISM metadata for receiver (rec) and neighbor (ngb) room
%   ism_setup       ISM setup (see GET_ISM_SETUP)
%   fdn_setup       FDN setup (see GET_FDN_SETUP)
%
% See also: RAZR, GET_DEFAULT_OPTIONS

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
