function out = iscolvec(in)
% ISCOLVEC - Mimics the behaviour of iscolumn (Matlab built-in) for older Matlab versions
% that do not contain that function.
%
% Usage:
%	out = ISCOLVEC(in)
%
% Returns logigal true, if input is a column vector.
%
% See also: ISROWVEC

% Torben Wendt
% 2014-12-03

if ndims(in) == 2 && size(in, 2) == 1
    out = true;
else
    out = false;
end
