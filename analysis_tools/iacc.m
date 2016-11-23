function [iacc_matrix, freq, ranges] = iacc(ir, varargin)
% IACC - Calculate interaural cross correlation coefficient of BRIR
%
% Usage:
%   [iacc_matrix, freq, ranges] = IACC(ir, Name, Value)
%
% Input:
%   ir          RIR structure (see RAZR)
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   parts       ('w') Character array specifying which RIR parts shall be taken into account. Keys:
%               'w': whole RIR (0 ms to upperbound),
%               'e': early part (0 to 80 ms),
%               'l': late part (80 ms to upperbound).
%               Examples: parts = 'el', parts = 'w'.
%   upperbound  ('irlen') Upper integration limit, in sec. or as key string. Has only an effect if
%               the whole RIR or the late part is taken into account (see argument 'parts').
%               Possible key strings:
%               'irlen': take full ir length
%               'lundeby': calculation using LUNDEBY_CROSSPOINT
%   freq        (0) Vector of octave band center frequencies. 0 indicates broadband. Can also be
%               specified as string 'e3': In that case the IACC_E3 will be calculated, which is the
%               mean value of early-part IACCs for [500, 1e3, 2e3] Hz. parts will then also be
%               overwritten to 'e'
%   trim        (false) If true, use the field ir.start_spl (if it exists) to remove the first
%               samples before the direct sound
%
% Output:
%   iacc_matrix Matrix of calculated IACCs; frequencies along rows, time frames along columns
%   freq        Octave band center frequencies (0 represents broadband)
%
% See also: LUNDEBY_CROSSPOINT

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


%% input parameters

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'parts', 'w');
addparam(p, 'upperbound', 'irlen');
addparam(p, 'freq', 0);
addparam(p, 'trim', 0);

parse(p, varargin{:});

if ischar(p.Results.upperbound)
    switch p.Results.upperbound
        case 'irlen'
            upperbound = size(ir.sig, 1)/ir.fs;
        case 'lundeby'
            upperbound = lundeby_crosspoint(ir);
        otherwise
            error('Unknown upperbound specification: %s', p.Results.upperbound);
    end
else
    upperbound = p.Results.upperbound;
end

%% remove silence before direct sound

if p.Results.trim && isfield(ir, 'start_spl')
    ir.sig = ir.sig(ir.start_spl:end,:);
    trimmed = true;
else
    trimmed = false;
end

len = size(ir.sig, 1);

%% frequencies

if ischar(p.Results.freq)
    if strcmp(p.Results.freq, 'e3')
        freq = [500, 1e3, 2e3];
        do_e3 = true;
    else
        error('Unknown frequency specification: %s', p.Results.freq);
    end
else
    freq = p.Results.freq;
    do_e3 = false;
end

numFreq = length(freq);
idx_bb = freq == 0;

[b, a] = oct_filterbank(freq(~idx_bb), ir.fs, false);

B = zeros(numFreq, size(b, 2));
A = zeros(numFreq, size(a, 2));
B(~idx_bb, :) = b;
A(~idx_bb, :) = a;
B(idx_bb, 1) = 1;
A(idx_bb, 1) = 1;

%% ranges

if ~ischar(p.Results.parts)
    error('''parts'' must be a character array.');
end

if do_e3
    parts = 'e';
else
    parts = p.Results.parts;
end

ranges = [...
    0,     80e-3; ...   % early
    80e-3, upperbound;  % late
    0,     upperbound]; % whole

% indices of parts in ranges-matrix:
parts_idx.e = 1;
parts_idx.l = 2;
parts_idx.w = 3;

for n = length(parts):-1:1
    limit_idx(n) = parts_idx.(parts(n));
end

ranges = ranges(limit_idx, :);
numRanges = size(ranges, 1);
ranges = floor(ranges*ir.fs);  % sec2spl
ranges = max(ranges, 1);       % 0. sample -> 1. sample

if trimmed
    idx = (ranges >= len + ir.start_spl - 1);
    ranges(idx) = ranges(idx) - ir.start_spl + 1;
end

idx = ranges > len;

if any(any(idx))
    warning(['iacc: upperbound is larger than signal length. ', ...
        'The whole signal will be taken into account.']);
    ranges(idx) = len;
end

%% iacc matrix

iacc_matrix = zeros(numRanges, numFreq);

maxlags = round(1e-3*ir.fs);  % 1 ms

for k = 1:numFreq
    sig_filtered = filter(B(k, :), A(k, :), ir.sig);
    
    for n = 1:numRanges
        iacf = xcorr(...
            sig_filtered(ranges(n, 1):ranges(n, 2), 1), ...
            sig_filtered(ranges(n, 1):ranges(n, 2), 2), ...
            maxlags, 'coeff');
        
        iacc_matrix(n, k) = max(iacf);
    end
end

if do_e3
    iacc_matrix = mean(iacc_matrix);
end

freq = freq(:)';
