function dbase = hrtf_params_mk2(dbase, options)
% HRTF_PARAMS_MK2 - Set parameters for mk2 database.
% Articifical head: Cortex MK2
% 
% Database reference:
%   n/a, Database measured at Uni Oldenburg, not published, yet

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


dbase.fs = 44100;       % original sampling rate of database
dbase.len = 400;        % length of HRIRs, read out from the data
dbase.grd = load('hrtf_grid.mat', 'hrtf_grid_deg');
dbase.did_addpath = false;
