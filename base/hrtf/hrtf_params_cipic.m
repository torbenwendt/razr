function dbase = hrtf_params_cipic(dbase, options)
% HRTF_PARAMS_CIPIC - Set parameters for cipic database
% 
% Available options:
%   subject     Subject or dummy head for which HRIR is loaded (please see CIPIC
%               specifications). Examples: 21: KEMAR with large pinnae;
%               165: KEMAR with small pinnae. Default: 21
% 
% Database reference:
%   Algazi, V. R., et al. (2001), The CIPIC HRTF Database, Proc. 2001 IEEE
%   Workshop on Applications of Signal Processing to Audio and Electroacoustics

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


dbase.fs = 44100;
dbase.len = 200;

% database-specific options:
if ~isfield(options, 'subject')
    options.subject = 21;   % (21: KEMAR, large pinnae (Default); 165: KEMAR, small pinnae)
end

% load HRIRs:
subject_str = sprintf('00%d', options.subject);
subject_str = subject_str(end-2:end);
dbase.hrir = load(fullfile(dbase.path, sprintf('subject_%s', subject_str), 'hrir_final.mat'), ...
    'hrir_l','hrir_r','name');

% angle sampling:
dbase.laterals = [-80 -65 -55 -45:5:45 55 65 80];
dbase.polars   = -45 + 5.625*(0:49);

dbase.did_addpath = false;
