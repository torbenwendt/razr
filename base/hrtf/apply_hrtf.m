function [out_L, out_R] = apply_hrtf(dbase, in, azim, elev, fs, options)
% APPLY_HRTF - Convolution of an input matrix with HRIRs along columns
%
% Usage:
%   out = APPLY_HRTF(database, in, azim, elev, fs, [options])
%
% Input:
%   dbase       HRTF-database key-string or output of GET_HRTF_DBASE (structure)
%   in          Input signal matrix, containing time signals in columns
%   azim        Azimuth angles,     0: front, 90: left, -90: right, 180: back
%   elev        Elevation angles:   0: at ears, 90: above head, -90: below head
%   fs          Sampling rate of input signal in Hz
%   options     Optional struct, which will be passed to HRTF_PARAMS_<database>
%
% Output:
%   out_L, out_R    Filtered signal matrices for left and right ear, respectively

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


%% input parameters

[len, numCh] = size(in);

if nargin < 6
    options = struct;
end

if length(azim) ~= numCh || length(elev) ~= numCh
    error('Wrong number of angles.');
end

%% get database informations

% dbase is passed as string for standalone usage of this function.
% In razr, get_hrtf_dbase is called earlier, and dbase is set as a field of op.
if ischar(dbase)
    dbase = get_hrtf_dbase(dbase, options);
end

if fs ~= dbase.fs
    error('Sampling rate of %g Hz not supported by HRTF database "%s". Must be %g Hz.', ...
        fs, dbase.input_string, dbase.fs);
end

%% do the filtering

out_L = in;
out_R = in;

try
    hrir = dbase.pick_hrir_func(azim, elev, dbase, options);
catch exc
    if strcmp(exc.identifier, 'MATLAB:UndefinedFunction')
        error(['Function "%s" not found but needed to support the HRTF', ...
            ' database "%s".\nSee the RAZR README for details.'], ...
            dbase.fname_pick, dbase.input_string);
    else
        error(exc.message);
    end
end

out_L = fftfilt(hrir(:, :, 1), out_L);
out_R = fftfilt(hrir(:, :, 2), out_R);
