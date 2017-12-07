% GET_DIFFR_FILTCOEFF_GRIMM - Filter coefficients for simulating difraction of a plane wave though
% a spherical hole. Code snippets copied from Giso Grimm's diffraction.m
%
% Usage:
%   [B, A] = get_diffr_filtcoeff_grimm(width, height, arr, fs, c, do_distce_atten)
%
% Input:
%   radius          Radius of the spherical hole
%   angle_deg       Observation angle in deg (may be vector of several angles)
%   fs              Sampling rate
%
% Output:
%   [B, A]          Filter coefficient vectors
