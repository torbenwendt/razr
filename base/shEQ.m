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
