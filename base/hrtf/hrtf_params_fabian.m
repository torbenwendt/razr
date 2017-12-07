function dbase = hrtf_params_fabian(dbase, options)
% HRTF_PARAMS_FABIAN - Set parameters for FABIAN database.
% 
% Available options:
%   hato:   Head-to-torso orientation, see database for available values.
%           Default: 0
% 
% Databse reference:
%   Brinkmann, F., Lindau, A., Weinzierl, S., Geissler, G., & van de Par, S.
%   (2013). A high resolution head-related transfer function database including
%   different orientations of head above the torso. In Proceedings of the
%   AIA-DAGA 2013 Conference on Acoustics.

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


dbase.fs = 44100;
dbase.len = 256;

if isfield(options, 'hato')
    dbase.hato = options.hato;
else
    dbase.hato = 0;
end

% get nearest hato:
hato = -44:2:44;
[val, idx] = min(abs(dbase.hato - hato));
nearest_hato = hato(idx);

dbase.hrir = load(fullfile(dbase.path, ...
    sprintf('HATO_%d_1x1_64442_HRIRs_top_pole.mat', nearest_hato)));

dbase.did_addpath = false;
