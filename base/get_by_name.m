function [strct, idx] = get_by_name(strcts, name)
% GET_BY_NAME - From a vector of structures, pick that struct that has specified
% name, stored under a field named "name".
%
% Usage:
%   [strct, idx] = GET_BY_NAME(strcts, name)

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


% If required, this function could be extended to use an arbitrary fieldname.

if ~isfield(strcts, 'name')
    error('Structs must contain a field named "name".');
end

names = {strcts.name};

iseq = strcmp(names, name);

switch sum(iseq)
    case 1
        strct = strcts(iseq);
        idx = find(iseq);
        return;
    case 0
        error('Vector of structs doesn''t contain a struct named "%s".', name);
    otherwise
        error('Vector of rooms contains more than one room named "%s".', name);
end
