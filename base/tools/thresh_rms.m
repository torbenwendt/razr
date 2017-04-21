function in_rms = thresh_rms(in, thresh)
% THRESH_RMS - Calculate RMS of signal vector, but using only the subset of samples larger than
% a specified threshold in dB re peak.
%
% Usage:
%   out = THRESH_RMS(in, [thresh])
%
% Input:
%   in      Input signal (1-dim array)
%   thresh  Level threshold in dB re peak; optional, default: -40
%
% Output:
%   out     RMS of partial input vector

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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


if nargin == 1
	thresh = -40;
end

thresh = -abs(thresh);

in_db = 20*log10(abs(in/max(max(abs(in)))));	% (linear maximum = 1)
in_rms = rootmeansq(in(in_db >= thresh), 1);
