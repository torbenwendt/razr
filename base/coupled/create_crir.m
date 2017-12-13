% CREATE_CRIR - Create BRIR for two coupled rooms.
%
% Usage:
%   [ir, ism_data, ism_setup, fdn_setup] = CREATE_CRIR(rooms, adj, [op])
%
% Input:
%   rooms   Vector of room structures. If it contains more than two rooms, those
%           with src and rec will be picked automatically. If src and rec are
%           inside the same room, that adjacent room with highest estimated
%           reverberation will be taken into account.
%   adj     Adjacency specifications for rooms. See razr help.
%   op      Options structure (some defaults or passed options will be
%           overwritten due to the algorithm design)
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
