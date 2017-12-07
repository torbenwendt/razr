function ir = resample_ir(ir, new_fs)
% RESAMPLE_IR - Resample impulse response
%
% Usage:
%   ir = RESAMPLE_IR(ir, new_fs)
%
% Input:
%   ir      RIR structure (see RAZR)
%   new_fs  Desired sampling rate in Hz
%
% Output:
%   ir      RIR structure with resampled time signal and updated field "fs"

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


if ir.fs == new_fs
    return;
end

old_fs = ir.fs;

ir.sig  = resample(ir.sig, new_fs, old_fs);
ir.fs   = new_fs;

if isfield(ir, 'len')
    ir.len  = size(ir.sig, 1);
end

if isfield(ir, 'start_spl')
    ir.start_spl = round(ir.start_spl*new_fs/old_fs);
end
