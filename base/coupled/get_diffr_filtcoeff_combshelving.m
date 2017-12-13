% get_diffr_filtcoeff_huygens - Get filter coefficients for a model for wave diffraction through a
% rectangular opening. The model is based on a comb filter and a low pass shelving, which fit
% frequency responses of a numeric simulation based on Huygens' principle.
%
% Usage:
%   [B, A] = get_diffr_filtcoeff_combshelving(width, height, arr, fs, c, do_distce_atten)
%
% Input:
%   width, height   Width and height of opening, respectively
%   arr             Arrangement of source and receiver. Struct containing the following fields:
%                   azim_in     Azimuth angle (deg) of incident wave
%                   azim_out    Azimuth angle (deg) of evaluation point
%                   elev_in     Elevation angle (deg) of incident wave
%                   elev_out    Elevation angle (deg) of evaluation point
%                   distce_in   Distance (in m) of sound source to opening
%                   distce_out  Distance (in m) of evaluation point to opening
%   fs              Sampling rate in Hz
%   c               Speed of sound in m/s
%   do_distce_atten If true, apply 1/distance factor to nominator filter coefficients (optional,
%                   default: true)
%
% Output:
%   B, A            Filter coefficients for all filter components

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
