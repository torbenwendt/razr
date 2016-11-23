% CREATE_RIR - Synthesize (binaural) room impulse response for specified room
%
% Usage:
%   [ir, ism_setup, fdn_setup, op] = CREATE_RIR(room, [op])
%
% Input:
%   room        Room structure (see help RAZR)
%   op          Options structure (see help RAZR)
%
% Output:
%	ir          IR structure (see help RAZR)
%   ism_setup   ISM setup (see GET_ISM_SETUP)
%   ism_setup   FDN setup (see GET_FDN_SETUP)
%
% See also: RAZR, GET_DEFAULT_OPTIONS
