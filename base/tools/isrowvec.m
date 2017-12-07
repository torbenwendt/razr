function out = isrowvec(in)
% ISROWVEC - Mimics the behaviour of isrow (Matlab built-in) for older Matlab versions
% that do not contain that function.
%
% Usage:
%	out = ISROWVEC(in)
%
% Returns logigal true, if input is a row vector.
%
% See also: ISCOLVEC

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


if ndims(in) == 2 && size(in, 1) == 1
    out = true;
else
    out = false;
end
