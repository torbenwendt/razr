function dbase = hrtf_params_kayser(dbase, options)
% HRTF_PARAMS_KAYSER - Set parameters for Kayser database.
% Articifial head: Bruel & Kjaer.
% 
% Available options:
%   distance:   80, 300; distance source to listener in cm. Default: 300
% 
% Database reference:
%   Kayser, H., et al. (2009): Database of multichannel in-ear and behind-the-
%   ear head-related and binaural room impulse responses, EURASIP Journal on
%   Advances in Signal Processing

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
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


dbase.fs = 48000;
dbase.len = 4800;

if isfield(options, 'distance')
    dbase.distance = options.distance;
else
    dbase.distance = 300;
end

dbase.grd = load('hrtf_grid_kayser.mat', 'hrtf_grid_kayser');

dbase.did_addpath = false;
