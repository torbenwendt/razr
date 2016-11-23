function [s, maxlen] = struct_repmat(s)
% STRUCT_REPMAT - For a struct containing vectors of a length 'lenmax' or 1, all vectors of length 1
% are repeated to have length 'lenmax', too.
%
% Usage:
%   [s_out, maxlen] = struct_repmat(s_in)
%
% Input:
%   s_in        Input structure
%
% Output:
%   s_out       Output structure, all fields with adjusted lengths
%   maxlen      Actual lengths of fiels of s_out
%
% Example:
%   If
%   s_in.a = [1 2 3];
%   s_in.b = 5;
%   then the output will be:
%   s_out.a = [1; 2; 3];
%   s_out.b = [5; 5; 5];
%
% Side effect: All vectors will be converted to column vectors.

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------



fldnames = fieldnames(s);

for n = length(fldnames):-1:1
    s.(fldnames{n}) = s.(fldnames{n})(:);
    lens(n) = length(s.(fldnames{n}));
end

maxlen = max(lens);

if ~all(lens == maxlen | lens == 1)
    error('Lengths of vectors in struct must equal 1 or the maximum of all lengths.');
end

% repmat for fields of s, which have length == 1
if maxlen > 1
    for n = find(lens == 1)
        s.(fldnames{n}) = repmat(s.(fldnames{n}), maxlen, 1);
    end
end
