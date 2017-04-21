% CREATE_ISM_OUTPUT - Calculation of image source signals
%
% Uasge:
%   [signalout, signalmat, signalmat_diffuse, filter_ranges] = ...
%       CREATE_ISM_OUTPUT(isd, ism_setup, op)
%
% Input:
%   isd             Image source data; output of SCALE_IS_PATTERN
%   ism_setup       Output of GET_ISM_SETUP
%   op              Options structure (see GET_DEFAULT_OPTIONS)
%
% Output:
%   signalout       Two-channel time signal of image source pulses (contains only those specified by
%                   idx_auralize)
%   signalmat       Time signals of specular reflections without HRIR and -- if
%                   op.ism_diffr_mc_output = false -- without diffraction applied (one image source
%                   per column)
%   signalmat_diffuse  Time signals of diffuse reflections, same format as signalmat
%   filter_ranges   Restriction of filtering to specified signal intervals in order to save
%                   computation. Matrix of the form [start_ch1, end_ch1, ...; start_chN, end_chN].
%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt, Nico Goessling, Oliver Buttler
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
