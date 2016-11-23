function freq = octf(f1, f2)
% OCTF - Standard octave band center frequencies in Hz
% 
% Usage:
%	freq = OCTF([f1], [f2])
% 
% Input:
%	f1, f2		Between these frequencies, all standard octave band freqiencies are returned
%				(optional, default: f1 = 250, f2 = 4e3).
%				Minimally/maximally allowed values: 15.625, 32e3.

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



if nargin<2
	f1 = 250;
	f2 = 4e3;
end


f0 = [15.625, 31.25, 62.5, 125, 250, 500, 1e3, 2e3, 4e3, 8e3, 16e3, 32e3];

idx = find(f0>=f1, 1, 'first') : find(f0<=f2, 1, 'last');

freq = f0(idx);
