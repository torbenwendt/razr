% SCALE_IS_PATTERN - Scaling of uniform image source pattern according to actual room
%
% Usage:
%   [isd, ism_setup, distc, idx_auralize, rng_state] = SCALE_IS_PATTERN(...
%       ISpattern, room, op, ism_setup, rng_seed)
%
% Input:
%   ISpattern       Output of CREATEISPATTERN.
%   room            Room structure (see RAZR)
%   op              Options structure (see RAZR)
%   ism_setup       Output of GET_ISM_SETUP
%   rng_seed        Seed for random number generator
%
% Output:
%   isd             Image source data; structure containing the following fields:
%       sor             "samples of reflection": Times at where reflections arrive at receiver
%       por             "peaks of reflection": Peaks of these Reflecions, according to
%                       source-receiver distance
%       azim            Azimuth angle of image sources, relative to receiver orientation
%                       (angle convention according to CART2SPH)
%       elev            Elevation angle of image sources, relative to receiver orientation
%       pos             Image source positions in cartesian coordinates (meters)
%                       (angle convention according to CART2SPH)
%       lrscale         Scaling factors (left and right) for ILD panning
%   ism_setup       See input parameters, diffraction filter coefficients added
%   distc           Source-receiver distances in m
%   idx_auralize    Logical indices of image sources to be auralized (in contrast to those, which
%                   are only used for FDN input)
%   rng_state       State of random number generator
