% GETSCHROEDERREVERBERATOR - Calculates the filter coefficients for a
% Schroeder reverberator consisting of four cascaded allpass filters.
%
% Usage:
%   [b, a] = GETSCHROEDERREVERBERATOR(T, [fs], [g], [eta])
%
% Input:
%   T           Reverberation time / s
%   fs          Sample rate / Hz (default: 44100)
%   g           Feedback gain (default: sqrt(2)/2)
%   eta         Delay ratio (default: pi)
%
% Output:
%   b, a        Filter coefficients
