% paramEQ -  - Parametric EQ with matching gain at Nyquist frequency
% using Orfanidis, J. Audio Eng. Soc., vol.45, p.444, June 1997 peq.m
% 
%
% Usage:  [b, a] = paramEq(w0, G, Q)
%
% w0 = center frequency in rads/sample ( = 2*pi*f0/fc)
% G  = boost/cut gain at w0 in dB
% Q = if > 0 quality factor -3dB bandwidth for large gains equals f0/Q
%     if < 0 -bandwidth in rads/sample
%
% b  = [b0, b1, b2] = numerator coefficients
% a  = [1,  a1, a2] = denominator coefficients
