function cfg = get_razr_cfg
% GET_RAZR_CFG - Choose the RAZR configuration to be used.
%
% Usage:
%   cfg = GET_RAZR_CFG
%
% See also: RAZR_CFG_DEFAULT, RAZR_CFG_USER

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


try
    user_cfg = select_razr_cfg;
catch exc
    if strcmp(exc.identifier, 'MATLAB:UndefinedFunction')
        error('Config file not found. Check <strong>select_razr_cfg.m</strong>.');
    else
        error(exc.message)
    end
end

cfg = overwrite_merge(user_cfg, razr_cfg_default, 1, 1);
