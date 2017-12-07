function sig = apply_diffr_filter(B, A, sig, ranges)
% APPLY_DIFFRACTION_FILTER - Apply diffraction filter to multichannel signal
%
% Usage:
%   out = apply_diffr_filter(B, A, in, [ranges])
%
% Input:
%   B, A    Filter coefficients, same format as output of GET_DIFFR_FILTCOEFF
%   in      Input signal matrix, number of columns must match length of B, A
%   ranges  Restrict filtering to specified signal intervals in order to save computation,
%           must be matrix of the form [start_ch1, end_ch1, ...; start_chN, end_chN] or
%           [start, end], if the range is the same for all channels
%           Optional; default: use full signal length
%
% Output:
%   out     Filtered signal matrix

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


% Torben Wendt
% 2016-02-04

if nargin < 4
    ranges = [];
end

numCh = size(sig, 2);

if length(B) == 1 && numCh ~= 1
    B = repmat(B, 1, numCh);
    A = repmat(A, 1, numCh);
end

if isempty(ranges)
    % if the whole signal is to be filtered, for some reason this is faster than using ranges:
    for n = 1:numCh
        for k = 1:length(B{n})
            sig(:, n) = filter(B{n}{k}, A{n}{k}, sig(:, n));
        end
    end    
else
    if size(ranges, 1) == 1
        ranges = repmat(ranges, numCh, 1);
    end
    
    for n = 1:numCh
        for k = 1:length(B{n})
            sig(ranges(n, 1):ranges(n, 2), n) = filter(...
                B{n}{k}, A{n}{k}, sig(ranges(n, 1):ranges(n, 2), n));
        end
    end
end
