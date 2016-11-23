function [b, a, f1, f2] = get_ism_bp(room, op)
% GET_ISM_BP - Get filter coefficients and edge frequencies for ISM global bandpass.
%
% Usage:
%   [b, a, f1, f2] = GET_ISM_BP(room, op)

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



% Original edge freqs from master's thesis: f1 = 20; f2 = 14e3;
f1 = 20;%63;
%f2 = 14e3;
%f2 = max(room.freq)^(0.2) * (op.fs/2)^(0.8);       % weighted mean
f2 = max(room.freq)^(0.1) * (op.fs/2)^(0.9);        % changed weights (2015-03-07)

[b, a] = butter(1, [f1 ,f2]/op.fs*2);
