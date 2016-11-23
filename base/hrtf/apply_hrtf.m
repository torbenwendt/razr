function [out_L, out_R] = apply_hrtf(database, in, azim, elev, fs, options)
% APPLY_HRTF - Convolution of an input matrix with HRIRs along columns
%
% Usage:
%   out = APPLY_HRTF(database, in, azim, elev, fs, [options])
%
% Input:
%   database        HRTF-database key-string. Supported (not case-sensitive):
%       'mk2':      Cortex MK2 dummy head, database measured at Uni Oldenburg, not published yet
%       'BK':       Bruel & Kjaer dummy head [1]
%       'Head':     HEAD acoustics dummy head [1]
%       'KEMAR':    KEMAR dummy head [1]
%       'SP':       Custom dummy head built by the Signal Processing Group, Uni Oldenburg [1]
%       'cipic':    CIPIC database [2]
%       'kayser':   Bruel & Kjaer dummy head, HRTFs measured by Kayser et al. [3]
%       For using unsupported databases, see the section "Using HRTFs" in README.txt.
%   in              input signal matrix, containing time signals in columns
%   azim            azimuth angles,     0: front, 90: left, -90: right, 180: back
%   elev            elevation angles:   0: at ears, 90: above head, -90: below head
%   fs              Sampling rate of input signal in Hz
%   options         Optional struct, which may contain the following fields:
%       limit_range_start_spls  Vector of length size(in,2) containing time samples (for each column
%                               of 'in') at which the channel-wise filtering starts. From this
%                               sample on, filtering is applied on the doubled length of one HRIR.
%                               Using this option saves computation time. Default: filtering on the
%                               whole signal.
%                               (This option is automatically set by CREATE_ISM_OUTPUT.)
%       subject (CIPIC only)    Subject or dummy head for which HRIR is loaded (please see CIPIC
%                               specifications). Examples: 21: KEMAR w/ large pinnae; 165: KEMAR w/
%                               small pinnae. Default: 21
%
% Output:
%   out_L, out_R    Filtered signal matrices for left and right ear, respectively
%
% References:
%   [1] Thiemann, J., et al. (2015): Multiple Model High-Spatial Resolution HRTF Measurements,
%       DAGA 2015.
%   [2] Algazi, V. R., et al. (2001), The CIPIC HRTF Database, Proc. 2001 IEEE Workshop on
%       Applications of Signal Processing to Audio and Electroacoustics
%   [3] Kayser, H., et al. (2009): Database of multichannel in-ear and behind-the-ear head-related
%       and binaural room impulse responses, EURASIP Journal on Advances in Signal Processing

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt, Thomas Biberger
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
% All rights reserved.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------



%% input parameters

[len, numCh] = size(in);

if nargin < 5
    options = struct;
end

if length(azim) ~= numCh || length(elev) ~= numCh
    error('Wrong number of angles.');
end

%% choose database and set db-specific parameters

dbase = lower(database);
cfg = get_razr_cfg;
fldname = sprintf('hrtf_path__%s', dbase);

if isfield(cfg, fldname)
    hrtf_path = cfg.(fldname);
else
    error('Path to HRTF databse "%s" not specified in razr_cfg.m.', database);
end

did_addpath = false;

switch dbase
    case 'mk2'
        %%
        fs_database = 44100;    % original sampling rate of database
        hrir_len = 400;         % length of HRIRs, read out from the data
        
        % angle conversion:
        azim = azim - (sign(azim) - 1)*180;     % -90 -> +270 etc.
        
        load('hrtf_grid.mat', 'hrtf_grid_deg');
        
    case {'bk', 'head', 'kemar', 'sp'}
        %%
        fs_database = 44100;
        %hrir_len = 2205;
        
        % For these databases, hrirs will be truncated below:
        hrir_len = 330;
        flanklen = round(1e-3*fs_database);
        win = hannwin(flanklen*2);
        flank = repmat(win((flanklen + 1):end), 1, 2);
        
        orig_names.bk    = 'BK';
        orig_names.head  = 'Head';
        orig_names.kemar = 'KEMAR';
        orig_names.sp    = 'SP';
        
        % angle conversion:
        azim = -azim;
        
        oldpath = addpath(hrtf_path);
        did_addpath = true;
        
    case 'cipic'
        %%
        fs_database = 44100;
        hrir_len = 200;
        
        % angle conversion:
        [lat, pol] = geo2horpolar(-azim, elev);
        
        % database-specific options:
        if ~isfield(options, 'subject')
            options.subject = 21;   % (21: KEMAR, large pinnae (Default); 165: KEMAR, small pinnae)
        end
        
        % load HRIRs:
        subject_str = sprintf('00%d', options.subject);
        subject_str = subject_str(end-2:end);
        hrir = load(fullfile(hrtf_path, sprintf('subject_%s', subject_str), 'hrir_final.mat'), ...
            'hrir_l','hrir_r','name');
        
        % angle sampling:
        laterals = [-80 -65 -55 -45:5:45 55 65 80];
        polars   = -45 + 5.625*(0:49);
        
    case 'kayser'
        %%
        fs_database = 48000;
        hrir_len = 4800;
        
        % database-specific options:
        if ~isfield(options, 'distance')
            options.distance = 300;         % 80, 300
        end
        
        load('hrtf_grid_kayser.mat', 'hrtf_grid_kayser');
        
    otherwise
        script_name_params = sprintf('hrtf_params_%s', database);
        script_name_pick   = sprintf('pick_hrtf_%s', database);
        if exist(script_name_params, 'file')
            eval(script_name_params);
        else
            error('Script "%s.m" needed for HRTF database "%s" but not found. See README.txt for details.', ...
                script_name_params, database);
        end
        if ~exist(script_name_pick, 'file')
            error('Script "%s.m" needed for HRTF database "%s" but not found. See README.txt for details.', ...
                script_name_pick, database);
        end
end

if fs ~= fs_database
    error('Sampling rate of %g Hz not supported by HRTF database "%s". Must be %g Hz.', ...
        fs, database, fs_database);
end

%% filter-interval

if ~isfield(options, 'limit_range_start_spls')
    sig_range = repmat([1, len], numCh, 1);
elseif length(options.limit_range_start_spls) == numCh
    sig_range = [...
        options.limit_range_start_spls, min(options.limit_range_start_spls + 2*hrir_len, len)];
else
    error('Length of limit_range_start_spls must match the number of columns of in.');
end

%%

out_L = in;
out_R = in;

for n = 1:numCh
    switch dbase
        case 'mk2'
            [Azim, Elev] = GetNearestAngle(azim(n), elev(n), hrtf_grid_deg);
            load(fullfile(hrtf_path, GetSaveStr(Azim, Elev)));  % loads y_hrir
            
        case {'bk', 'head', 'kemar', 'sp'}
            y_hrir = loadHRIRnear(...
                fullfile(hrtf_path, [orig_names.(dbase), '.h5']), azim(n), elev(n))';
            
            % truncate and fade out HRIR:
            y_hrir = y_hrir(1:hrir_len, :);
            y_hrir((hrir_len - flanklen + 1):hrir_len, :) = ...
                y_hrir((hrir_len - flanklen + 1):hrir_len, :) .* flank;
            
        case 'cipic'
            % round angles:
            [ans0, minlatdistarg] = min(abs(laterals - lat(n)));
            [ans0, minpoldistarg] = min(abs(polars - pol(n)));
            y_hrir(:, 1) = squeeze(hrir.hrir_l(minlatdistarg, minpoldistarg, :));
            y_hrir(:, 2) = squeeze(hrir.hrir_r(minlatdistarg, minpoldistarg, :));
            
        case 'kayser'
            [Azim, Elev] = GetNearestAngle(azim(n), elev(n), hrtf_grid_kayser);
            Azim = -Azim;
            hrir = loadHRIR_kayser_for_razr('Anechoic', options.distance, Elev, Azim, 'in-ear');
            y_hrir = hrir.data;
        otherwise
            eval(script_name_pick);
    end
    
    %out_L(sig_range(n, 1):sig_range(n, 2), n) = filter(y_hrir(:, 1), 1, out_L(sig_range(n, 1):sig_range(n, 2), n));
    %out_R(sig_range(n, 1):sig_range(n, 2), n) = filter(y_hrir(:, 2), 1, out_R(sig_range(n, 1):sig_range(n, 2), n));
    
    % fftfilt appears to be faster than filt for tested cases:
    out_L(sig_range(n, 1):sig_range(n, 2), n) = fftfilt(y_hrir(:, 1), out_L(sig_range(n, 1):sig_range(n, 2), n));
    out_R(sig_range(n, 1):sig_range(n, 2), n) = fftfilt(y_hrir(:, 2), out_R(sig_range(n, 1):sig_range(n, 2), n));
end

if did_addpath
    path(oldpath);
end
