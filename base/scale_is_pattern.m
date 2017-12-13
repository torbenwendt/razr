function isd = scale_is_pattern(isd, room, op, ism_setup, rng_seed)
% SCALE_IS_PATTERN - Scaling of uniform image source pattern according to actual room
%
% Usage:
%   isd = SCALE_IS_PATTERN(isd, room, op, ism_setup, rng_seed)
%
% Input:
%   isd             Output of CREATE_IS_PATTERN.
%   room            Room structure (see RAZR)
%   op              Options structure (see RAZR)
%   ism_setup       Output of GET_ISM_SETUP
%   rng_seed        Seed for random number generator (see also INIT_RNG)
%
% Output:
%   isd             Image source data; structure containing the following additional fields:
%       sor             "Samples of reflection": Times at where reflections arrive at receiver
%       por             "Peaks of reflection": Peaks of these Reflecions, according to
%                       source-receiver distance
%       azim, elev      Azimuth and elevation angles (deg) of image sources, relative to receiver
%                       orientation (angle convention according to CART2SPH)
%       positions       Image source positions in cartesian coordinates (meters)
%       dis             Postions of replacement image sources for diffraction
%       lrscale         Scaling factors (left and right) for ILD panning
%       idx_auralize    Logical indices of image sources to be auralized (in contrast to those,
%                       which are only used for FDN input)
%       b_air, a_air    Air absorption filter coefficients for each image source
%       b_diffr,a_diffr Diffraction filter coefficients for each image source

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


numSrc = size(isd.pattern, 1);
use_image_receivers = ism_setup.src_outside;

%% scale img-src/rec positions, incl. angles and orientation

if use_image_receivers
    isd.positions = scale_isp(isd, room, 'rec');
    recpos = isd.positions;
    srcpos = repmat(room.srcpos, numSrc, 1);
else
    isd.positions = scale_isp(isd, room, 'src');
    recpos = repmat(room.recpos, numSrc, 1);
    srcpos = isd.positions;
end

%% check visibility ("img src behind open door")

if ~ism_setup.src_outside && ~ism_setup.rec_outside && isfield(room, 'door')
    isd.idx_auralize = check_visibility(isd, room);
else
    isd.idx_auralize = true(numSrc, 1);
end

% don't calc direct sound for ngb-room ir:
if ~op.ism_drct_snd_rec_outs && ism_setup.rec_outside
    isd.idx_auralize(isd.order == 0) = false;
end

%% diffraction parameters

if op.ism_enableDiffrFilt && ~isempty(isd.positions) && ism_setup.do_diffraction
    [isd.b_diffr, isd.a_diffr, diffr_arr, srcpos] = get_diffr_filtcoeff(...
        room, 1, srcpos, recpos, op.fs, false, op.diffrFiltMeth, ...
        op.plot_diffr_points_ism);
    distce_add = diffr_arr.distce_in;
else
    isd.b_diffr = [];
    isd.a_diffr = [];
    distce_add = 0;
end

%% coordinate transformations, random jitter

if ism_setup.do_diffraction && op.ism_norand_if_diffr
    op.ism_jitter_factor = 0;
end

if length(op.ism_jitter_factor) > 1
    error('op.ism_jitter_factor must be a scalar.');
end

init_rng(rng_seed);
randmat = 2*rand([3, numSrc])' - 1;  % random numbers from interval ]-1, +1[
randmat(isd.order < op.ism_rand_start_order, :) = 0;

srcpos_orig = srcpos;

% apply random jitter, if specified for cart. coo. (sph. coo.: below):
if strcmp(op.ism_jitter_type, 'cart')
    % factor 0.3 to obtain similar excursions than for 'cart_legacy':
    srcpos = srcpos .* (1 + op.ism_jitter_factor*bsxfun(@times, randmat, 0.3*isd.order));
    if ~(ism_setup.do_diffraction && op.ism_norand_if_diffr)
        srcpos = limit_jitter(srcpos, srcpos_orig, recpos, room);
    end
end

isd.relpos = srcpos - recpos;

% apply old random jitter:
if strcmp(op.ism_jitter_type, 'cart_legacy')
    isd.relpos = isd.relpos .* (1 + op.ism_jitter_factor*randmat);
end

if use_image_receivers
    isd.relpos = isd.relpos .* (1 - 2*isd.invert_pos);
end

[isd.azim, isd.elev, distc] = ...
    cart2sph(isd.relpos(:, 1), isd.relpos(:, 2), isd.relpos(:, 3));  % az: -pi:pi, el: (-pi:pi)/2

distc = distc + distce_add;
isd.azim = rd2dg(isd.azim);
isd.elev = rd2dg(isd.elev);

% If src and rec are in the same room and the src has been placed in the door
% to calculate img-src of the ngb-room, an additional distance must be applied:
if isfield(room, 'srcpos_orig')
    distce_add2 = sqrt(sum((room.srcpos - room.srcpos_orig).^2));
    distc = distc + distce_add2;
end

% account for receiver orientation:
isd.azim = isd.azim - room.recdir(1);
isd.elev = isd.elev - room.recdir(2);

% apply random jitter, if specified for sph. coo.:
if strcmp(op.ism_jitter_type, 'sph')
    isd.azim  = isd.azim  + randmat(:, 1)*op.ism_jitter_factor.*distc;
    isd.elev  = isd.elev  + randmat(:, 2)*op.ism_jitter_factor.*distc;
    distc     = distc     + randmat(:, 3)*op.ism_jitter_factor.*distc;
    distc = limit_jitter_sph(distc, room);
end

[isd.azim, isd.elev] = wrap_angles([isd.azim, isd.elev], true);

isd.lrscale = panscale(room, isd.relpos);

%% attenuation and delay due to source-receiver distance

isd.por = distce_atten(distc);
isd.por(isd.order ~= 0) = isd.por(isd.order ~= 0) * 10^(op.ism_refl_gain/20);
isd.sor = max(round(distc/speedOfSound(room)*op.fs), 1);

% scaling factor for calibration:
isd.por = isd.por * 10^((op.SPL_source - op.SPL_at_0dBFS)/20);

%% air absorption filter coefficients

if op.ism_enableAirAbsFilt
    if op.ism_enableAirAbsFilt == -1
        dstnc = 10*distc.^(0.7);
    else
        dstnc = distc;
    end
    [isd.b_air, isd.a_air] = getAirAbsfiltCoeff(dstnc, op.fs, speedOfSound(room));
else
    isd.b_air = [];
    isd.a_air = [];
end

end

function srcpos = limit_jitter(srcpos, srcpos_orig, recpos, room)
% For jittered img src that are closer to receiver than direct src, the jitter
% is attenuated.

src_rec_dist2 = sum((bsxfun(@minus, room.srcpos, recpos)).^2, 2);
img_rec_dist2 = sum((srcpos - recpos).^2, 2);
is_closer = img_rec_dist2 < src_rec_dist2;

if any(is_closer)
    for idx = find(is_closer)
        jittervec = srcpos(idx, :) - srcpos_orig(idx, :);
        J2 = dot(jittervec, jittervec);
        ImR = srcpos_orig(idx, :) - recpos(idx, :);
        JR = dot(jittervec, ImR);
        ImR2 = dot(ImR, ImR);
        DmR = room.srcpos - recpos(idx, :);
        DmR2 = dot(DmR, DmR);
        
        % "p-q equation" as a result from calc on paper:
        jittergain = [-1, 1] * sqrt((JR/J2)^2 - (ImR2 - DmR2)/J2) - JR/J2;
        jittergain = min(jittergain);
        %assert(jittergain > 0 && jittergain < 1);
        
        % un-comment for debugging:
        %jittered_before = srcpos(idx, :);
        srcpos(idx, :) = srcpos_orig(idx, :) + jittergain*jittervec;
        %jittered_after = srcpos(idx, :);
        
        %% plot for debugging:
        if 1
            scene(room, 'topview', 1);
            hold on
            plot3(srcpos_orig(idx, 1), srcpos_orig(idx, 2), srcpos_orig(idx, 3), 'd')
            plot3(jittered_before(1), jittered_before(2), jittered_before(3), '*')
            plot3(...
                [srcpos_orig(idx, 1), jittered_before(1)], ...
                [srcpos_orig(idx, 2), jittered_before(2)], ...
                [srcpos_orig(idx, 3), jittered_before(3)], '-')
            plot3(jittered_after(1), jittered_after(2), jittered_after(3), '+')
            keyboard
        end
    end
end

end

function distc = limit_jitter_sph(distc, room)
% Same as limit_jitter but for spherical coordinates

src_rec_dist = sqrt(sum((room.srcpos - room.recpos).^2));
distc = max(distc, src_rec_dist);

end
