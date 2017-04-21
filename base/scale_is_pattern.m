% SCALE_IS_PATTERN - Scaling of uniform image source pattern according to actual room
%
% Usage:
%   isd = SCALE_IS_PATTERN(isd, room, op, ism_setup, rng_seed)
%
% Input:
%   isd             Output of CREATE_IS_PATTERN.
%   room            Room structure (see RAZR)
%   op              Options structure (see RAZR)
%   ism_setup       Output of GET_ISM_SETUP
%   rng_seed        Seed for random number generator (see also INIT_RNG)
%
% Output:
%   isd             Image source data; structure containing the following additional fields:
%       sor             "Samples of reflection": Times at where reflections arrive at receiver
%       por             "Peaks of reflection": Peaks of these Reflecions, according to
%                       source-receiver distance
%       azim, elev      Azimuth and elevation angles (deg) of image sources, relative to receiver
%                       orientation (angle convention according to CART2SPH)
%       positions       Image source positions in cartesian coordinates (meters)
%       dis             Postions of replacement image sources for diffraction
%       lrscale         Scaling factors (left and right) for ILD panning
%       idx_auralize    Logical indices of image sources to be auralized (in contrast to those,
%                       which are only used for FDN input)
%       b_air, a_air    Air absorption filter coefficients for each image source
%       b_diffr,a_diffr Diffraction filter coefficients for each image source

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
