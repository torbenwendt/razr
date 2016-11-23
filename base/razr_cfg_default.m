function cfg = razr_cfg_default
% RAZR_CFG_DEFAULT - Returns structure that contains RAZR's default configuration.
% DO NOT CHANGE THIS FILE! To change the configuration, edit RAZR_CFG. If RAZR_CFG does
% not exist, run "razr addpath", which will then create it.
%
% Usage:
%   cfg = RAZR_CFG_DEFAULT
%
% See also: RAZR_CFG

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
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



%% Filenames (inlcuding path and extension) for sound samples used by APPLY_RIR

samples_path = ...
    [get_razr_path, filesep, 'base', filesep, 'external', filesep, 'samples'];
cfg.sample__olsa1 = fullfile(samples_path, '40938.wav');
cfg.sample__olsa2 = fullfile(samples_path, '84616.wav');

%% Headphone equalization files
% Fieldnames must have the following format:
% hp_eq__<headphone_key>_<samplingrate>

cfg.hp_eq__hd650_44100 = fullfile(get_razr_path, 'analysis_tools', 'headphone_eq', 'hd650_44k.mat');
cfg.hp_eq__hd650_48000 = fullfile(get_razr_path, 'analysis_tools', 'headphone_eq', 'hd650_48k.mat');

% Key string for default headphone equalization (used by APPLY_RIR):
cfg.default_headphone = 'none';  % supported up to now: 'none', 'hd650'
