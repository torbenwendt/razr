function create_user_cfg
% CREATE_USER_CFG - Check for files razr_cfg_user.m and select_razr_cfg.m and
% create them if they do not exist.

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


fnames = {'razr_cfg_user.m', 'select_razr_cfg.m'};

% Create files by getting them as a copy of hidden files in base:
for n = 1:length(fnames)
    if ~exist(fullfile(get_razr_path, fnames{n}), 'file')
        copyfile(...
            fullfile(get_razr_path, 'base', ['.', fnames{n}]), ...
            fullfile(get_razr_path, fnames{n}));
    end
end
