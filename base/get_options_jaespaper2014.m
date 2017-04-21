function op = get_options_jaespaper2014
% GET_OPTIONS_JAESPAPER2014 - Returns options structure for BRIR synthesis according to the method
% described in
% Wendt, van de Par, and Ewert (2014): A Computationally-Efficient and Perceptually-Plausible
% Algorithm for Binaural Room Impulse Response Simulation, JAES vol. 62.
%
% Usage:
%   op = GET_OPTIONS_JAESPAPER2014
%
% Output:
%   op      Options structure (see RAZR)

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


op = get_default_options;

%% general options

op.hrtf_database = 'mk2';
op.filtCreatMeth = 'cs';

%% ism

op.ism_enableAirAbsFilt = 0;
op.ism_enableToneCorr = 0;
op.ism_enableBP = 1;

op.ism_ISposRandFactor = [1 1 1]*0.2;
op.ism_randFactorsInCart = 0;
op.ism_rand_start_order = 1;

%% fdn

op.fdn_enableBP = 1;
op.fdn_delays_choice = 'roomdim2014';
