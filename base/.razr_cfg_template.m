function cfg = razr_cfg
% RAZR_CFG - Returns structure that contains RAZR custom configuration.
% This function is intended to be edited by the user to change the default configuration or to add
% new configuration fields, e.g. new HRTF databases or headphone equalizations.
% Internally, the default config fields from RAZR_CFG_DEFAULT will be overwritten by these user
% config fields.
%
% Usage:
%   cfg = RAZR_CFG
%
% See also: RAZR_CFG_DEFAULT


%% Paths to HRTF databases
% Replace 'path_to_database' below by the path to the HRTF-database location on your harddrive.
% 'path_to_database' can be replaced by get_razr_path if the database folder is located in the RAZR
% main folder.
% Fields have the format "hrtf_path__<KEYSTRING>", where <KEYSTRING> is the key associated with a
% certain database, e.g. cipic. It is used by setting the option op.hrtf_database = '<KEYSTRING>'.
% See also APPLY_HRTF.

% CIPIC database,
% Algazi, V. R., et al. (2001), The CIPIC HRTF Database, Proc. 2001 IEEE Workshop on
% Applications of Signal Processing to Audio and Electroacoustics
cfg.hrtf_path__cipic = ['path_to_database', filesep, ...
    'CIPIC_hrtf_database', filesep, 'standard_hrir_database'];
% If you have unpacked the CIPIC database to ./CIPIC_hrtf_database in the
% RAZR main folder, you can use:
% cfg.hrtf_path__cipic = [get_razr_path, filesep, ...
%     'CIPIC_hrtf_database', filesep, 'standard_hrir_database'];

% Cortex MK2 dummy head, database measured at Uni Oldenburg, not published yet:
cfg.hrtf_path__mk2 = ['path_to_database', filesep, ...
    'TASP_MK2_Results', filesep 'ImpulseResponses', filesep, 'HRIR'];

% Thiemann, J., et al. (2015): Multiple Model High-Spatial Resolution HRTF Measurements, DAGA 2015:
hrtf_path_thiem = ['path_to_database', filesep, 'HRTF_thiemann'];
cfg.hrtf_path__bk    = hrtf_path_thiem;  % Bruel & Kjaer dummy head
cfg.hrtf_path__head  = hrtf_path_thiem;  % HEAD acoustics dummy head
cfg.hrtf_path__kemar = hrtf_path_thiem;  % KEMAR dummy head
cfg.hrtf_path__sp    = hrtf_path_thiem;  % Custom dummy head by the Signal Proc. Group, Uni OL

% Bruel & Kjaer dummy head,
% Kayser, H., et al. (2009): Database of multichannel in-ear and behind-the-ear head-related
% and binaural room impulse responses, EURASIP Journal on Advances in Signal Processing:
cfg.hrtf_path__kayser = ['path_to_database', filesep, ...
    'Kayser_HRIR_Database', filesep, 'HRIR_database_mat', filesep, 'hrir'];

%% Filenames (inlcuding path and extension) for sound samples used by APPLY_RIR

samples_path = ...
    [get_razr_path, filesep, 'base', filesep, 'external', filesep, 'samples'];
cfg.sample__olsa3 = fullfile(samples_path, '06044.wav');
