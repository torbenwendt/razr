function [signalout, signalmat, signalmat_diffuse, filter_ranges] = create_ism_output(...
    ISpattern, isd, ism_setup, op, idx_auralize)
% CREATE_ISM_OUTPUT - Calculation of image source signals
%
% Uasge:
%   [signalout, signalmat, signalmat_diffuse, filter_ranges] = CREATE_ISM_OUTPUT(...
%       ISpattern, isd, ism_setup, op, idx_auralize)
%
% Input:
%   ISpattern       Output of CREATEISPATTERN
%   isd             Image source data; structure containing the following fields:
%       sor             "samples of reflection": times (in samples), at which sound reflections
%                       arrive at the receiver
%       por             "peaks of reflection": peaks of these reflections due to distance to
%                       receiver
%       azim            Azimuth angles of image sources, relative to receiver orientation
%                       (angle convention according to cart2sph())
%       elev            Elevation angles of image sources, relative to receiver orientation
%                       (angle convention according to cart2sph())
%       lrscale         Scaling factors for ILD panning (only required, if op.spat_mode == 'ild')
%   ism_setup       Structure containg ISM setup specifications returned by GET_ISM_SETUP.
%                   Additionally required fields:
%       b_air, a_air    Filter coefficients for air absorption filtering as matrix
%       b_diffr,a_diffr Filter coefficients for diffraction filtering
%   op              Options structure (see GET_DEFAULT_OPTIONS)
%   idx_auralize    Indices of image sources to be auralized (in contrast to those, which are only
%                   used for FDN input)
%
% Output:
%   signalout       Two-channel time signal of image source pulses (contains only those specified by
%                   idx_auralize)
%   signalmat       Time signals of specular reflections without HRIR and -- if
%                   op.ism_diffr_mc_output = false -- without diffraction applied (one image source
%                   per column)
%   signalmat_diffuse  Time signals of diffuse reflections, same format as signalmat
%   filter_ranges   Restriction of filtering to specified signal intervals in order to save
%                   computation. Matrix of the form [start_ch1, end_ch1, ...; start_chN, end_chN].

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt, Nico Goessling
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



%% input parameters

if strcmp(op.spat_mode{1}, 'ild') && ~isfield(isd, 'lrscale')
    error('lrscale required for ILD panning.');
end

%% prealloc

numSrc = size(ISpattern, 1);
signalmat = zeros(ism_setup.len, numSrc);

%% reflection filtering

short_ir_len = 4410;    % IR der Filter effektiv auf diese Laenge begrenzen, um Rechnung zu sparen
ir_end = min(isd.sor + short_ir_len, ism_setup.len);
filter_ranges = [isd.sor, ir_end];

% don't process pulses with isp.sor => len:
idx_all = 1:numSrc;
idx = idx_all(isd.sor < ism_setup.len);

for n = idx
    % write isp.por into signal matrix:
    signalmat(isd.sor(n), n) = isd.por(n);
    
    % loop over all wall indices:
    for w = 1:6
        % 1:(number of applications of filter coefficients of the w-th wall):
        for k = 1:ISpattern(n, 6 + w)
            signalmat(isd.sor(n):ir_end(n), n) = filter(...
                ism_setup.b_refl{w}, ism_setup.a_refl{w}, signalmat(isd.sor(n):ir_end(n), n));
        end
    end
end

%% diffuse reflection filtering (NG)

if op.ism_enable_diffusion
    signalmat_diffuse = signalmat;
    
    for n = idx
        % ignore the direct sound:
        if norm(ISpattern(n, 1:3), 1) == 0
            signalmat_diffuse(isd.sor(n):ir_end(n), n) = 0;
        else
            % loop over all wall indices:
            for w = 1:6
                % 1:(number of applications of filter coefficients of the w-th wall):
                for k = 1:ISpattern(n, 6 + w)
                    signalmat_diffuse(isd.sor(n):ir_end(n), n) = filter(...
                        ism_setup.b_diffu{w}, ism_setup.a_diffu{w}, ...
                        signalmat_diffuse(isd.sor(n):ir_end(n), n));
                    
                    signalmat(isd.sor(n):ir_end(n), n) = filter(...
                        ism_setup.b_specu{w}, ism_setup.a_specu{w}, ...
                        signalmat(isd.sor(n):ir_end(n), n));
                end
            end
        end
    end
else
    signalmat_diffuse = [];
end

%% air absorption

if op.ism_enableAirAbsFilt
    for n = 1:numSrc
        signalmat(isd.sor(n):ir_end(n), n) = filter(...
            ism_setup.b_air(n, :), ism_setup.a_air(n, :), signalmat(isd.sor(n):ir_end(n), n));
    end
end

%% tone correction

if op.ism_enableToneCorr
    [b_tc, a_tc] = get_tc_filtcoeff;
    for n = 1:numSrc
        if sum(abs(ISpattern(n, 1:3))) ~= 0
            signalmat(isd.sor(n):ir_end(n), n) = ...
                filter(b_tc, a_tc, signalmat(isd.sor(n):ir_end(n), n));
        end
    end
end

%% diffraction and removal of not directly auralized image sources

do_diffr = op.ism_enableDiffrFilt && ~isempty(ism_setup.b_diffr) && ~isempty(ism_setup.a_diffr);

signalmat_diffr = signalmat;

if do_diffr
    signalmat_diffr = apply_diffr_filter(...
        ism_setup.b_diffr, ism_setup.a_diffr, signalmat_diffr, filter_ranges);
    signalmat_l = signalmat_diffr(:, idx_auralize);
else
    signalmat_l = signalmat(:, idx_auralize);
end

if op.ism_diffr_mc_output
    signalmat = signalmat_diffr;
end

% remove corresponding entries from isd:
isd = structfun(@(A)(A(idx_auralize, :)), isd, 'UniformOutput', false);
numSrc = size(signalmat_l, 2);

%% HRIR filtering

signalmat_r = signalmat_l;

switch op.spat_mode{1}
    case 'shm'
        signalmat_l = hsfilterMod(isd.azim, isd.elev, 90, op.shm_warpMethod, ...
            op.fs, signalmat_l, isd.sor);
        signalmat_r = hsfilterMod(isd.azim, isd.elev, -90, op.shm_warpMethod, ...
            op.fs, signalmat_r, isd.sor);
    
    case 'hrtf'
        hrtf_options = op.hrtf_options;
        hrtf_options.limit_range_start_spls = isd.sor;
        
        [signalmat_l, signalmat_r] = apply_hrtf(...
            op.hrtf_database, signalmat_l, isd.azim, isd.elev, op.fs, hrtf_options);
        
    case 'ild'
        for n = 1:numSrc
            signalmat_l(:, n) = isd.lrscale(n, 1)*signalmat_l(:, n);
            signalmat_r(:, n) = isd.lrscale(n, 2)*signalmat_r(:, n);
        end
    case 'diotic'
        % nothing to do
    otherwise
        error('Spatialization for ISM unknown: %s', op.spat_mode{1});
end

%% output signal

signalout = [sum(signalmat_l, 2), sum(signalmat_r, 2)];
