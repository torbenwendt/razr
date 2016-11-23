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

% Torben Wendt
% 2014-12-03

if ndims(in) == 2 && size(in, 1) == 1
    out = true;
else
    out = false;
end
