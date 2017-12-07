function sig_buf = hannbuf(sig, framelen, ramplen)
% HANNBUF - Buffer and hann-window a signal
%
% Usage:
%	sig_buf = HANNBUF(sig, framelen, [ramplen])
%
% Input:
%	sig         Signal matrix of size "len x numChannels"
%	framelen	Frame length in samples
%	ramplen     Half of window length in samples
%               (signals will be faded in and out by hann ramps with full overlap).
%               If ramplen is an odd value, it will subtracted by 1 in order to obtain
%               equal lengths of in- and out-fading ramps
%               Optional parameter, default: framelen/2
%
% Output:
%   sig_buf     Bufferered and windowed signal

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


if nargin < 3
    ramplen = framelen/2;
end

if ramplen > framelen/2
    error('ramplen must be smaller that framelen/2');
end

ramplen_rd = round(ramplen);
if ramplen_rd ~= ramplen
    warning('ramplen rounded to nearest integer.');
end

overlap = floor(ramplen_rd);

[len, numCh] = size(sig);
numFrames = ceil(len/(framelen - overlap));
sig_buf = zeros(numCh, framelen, numFrames);
win = repmat(hannwin(ramplen_rd*2)', 1, 1, numFrames);
idx_win = [1:ramplen_rd, (framelen - ramplen_rd + 1):framelen];

for n = 1:numCh
    sig_buf(n, :, :) = buffer(sig(:, n), framelen, overlap);
    sig_buf(n, idx_win, :) = win .* sig_buf(n, idx_win, :);
end
