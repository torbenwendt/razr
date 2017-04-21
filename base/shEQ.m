% SHEQ - x-band-shelving equalizer. Get filter coefficients for composed parametric EQs,
% to approximate specified frequency response. The resulting filter order depends on
% the input data.
%
% Usage:
%	[b, a, B, A] = SHEQ(freq, dGain, fs, linGain, [do_plot])
% 
% Input:
%	freq			Frequency base in Hz, must have the same length as dGain
%	dGain			Desired frequency response, values in dB or linear (specified by input parameter 'linGain')
%	fs				Sampling rate
%	linGain			Set true, if dGain values are linear attenuation factors, false if they are specified in dB
%	do_plot			If true, plot frequency response (optional, default: false)
% 
% Output:
%	b, a			Filter coefficient vectors of the whole EQ
%	B, A			Filter coefficients of the shelving filters as Matrix (each filter in one row)

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
