function [s, maxlen] = struct_zeropad(s, fldnames)
% STRUCT_ZEROPAD - For a struct containing vectors and/or matrices zeropad all of
% them to match size along first dimension.
%
% Usage:
%   [s_out, maxlen] = STRUCT_ZEROPAD(s_in, [fldnames])
%
% Input:
%   s_in        Input structure
%   fldnames    Names of fields to be zeropadded. Optional; default: all fields
%
% Output:
%   s_out       Output structure, all fields with adjusted lengths
%   maxlen      Actual lengths of fiels of s_out
%
% See also: STRUCT_REPMAT

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


if nargin < 2
    fldnames = fieldnames(s);
end

for n = length(fldnames):-1:1
    [lens(n), numCols(n)] = size(s.(fldnames{n}));
end

maxlen = max(lens);

for n = find(lens < maxlen)
    s.(fldnames{n}) = [s.(fldnames{n}); zeros(maxlen - lens(n), numCols(n))]; 
end
