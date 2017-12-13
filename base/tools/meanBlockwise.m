function [out, t] = meanBlockwise(x, blocklen, fs)
% MEANBLOCKWISE - Average the rows of a matrix in blocks of specified length.
%
% Usage:
%	[out, t] = MEANBLOCKWISE(x, blocklen, [fs])
%
% Input:
%	x           Input signal, matrix of size 'length x numChannels'
%	blocklen	Averaging blocklength (if input parameter 'fs' is specified, 'blocklen' is
%               treated as in seconds, otherwise in samples)
%   fs          Sampling rate in Hz (optional, default: no sampling rate specified, blocklen
%               treated as being specified in samples)
%
% Output:
%	out         Output signal matrix
%	t           Time base vector (if fs specified)
%
% If size(x,1) <= blocklen: out = mean(x,1)

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


%% input

% sec2samples:
if nargin == 3
    blocklen = round(blocklen*fs);
end

[len, numCh] = size(x);

%%

meanlen = floor(len/blocklen);

out = zeros(meanlen, numCh);

if len <= blocklen
    out = mean(x,1);
    return;
end

% trim x to length divisible by 'blocklen':
x = x(1:(end - mod(len, blocklen)), :);
len = size(x, 1);

% time base vector:
if nargin == 3
    t = (0:blocklen:len-1)/fs*1e3;
else
    t = [];
end

% average over all 'blocklen' samples:
for m = 1:numCh
    out(:, m) = reshape(...
        mean(reshape(x(:,m), blocklen, meanlen) ,1),...
        meanlen, 1);
end
