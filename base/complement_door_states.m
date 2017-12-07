function adj = complement_door_states(adj)
% COMPLEMENT_DOOR_STATES - Check whether door states are specified within adjacency cell array.
% If not, initialize them with 1 (i.e. "open").
%
% Usage:
%   adj = COMPLEMENT_DOOR_STATES(adj)
%
% Input
%   adj         Adjacency specification (cell array, see ADJ2IDX)
%
% See also: ADJ2IDX

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


numAdj = size(adj, 1);

if size(adj, 2) == 4
    adj = [adj, num2cell(ones(numAdj, 1))];
end
