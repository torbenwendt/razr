function ism_setup = get_ism_setup(room, op)
% GET_ISM_SETUP - Calculation of internal ISM parameters (i.e. not to be controlled by the user - in
% contrast to options).
%
% Usage:
%   ism_setup = GET_ISM_SETUP(room, op)
%
% Input:
%   room        Room structure (see RAZR)
%   op          Options structure (see RAZR)
%
% Output:
%   ism_setup   Struct containing ISM parameters

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


% This file will be released as a p file.


%% signal length

% estimation for the latest early reflection:
maxdist = max(room.boxsize)*(max(op.ism_order) + 1);
maxdelay = ceil(maxdist/speedOfSound(room)*op.fs) + op.ism_filtlen;
ism_setup.len = maxdelay;

%% for coupled rooms

[ism_setup.src_outside, discd_dir_src] = treat_outside_positions(room, room.srcpos);
[ism_setup.rec_outside, discd_dir_rec] = treat_outside_positions(room, room.recpos);

ism_setup.do_diffraction = ism_setup.src_outside || ism_setup.rec_outside;

ism_setup.discd_directions = sort(unique(...
    [op.ism_discd_directions(:); discd_dir_src; discd_dir_rec]));

%% global bandpass ISM

if op.ism_enableBP
    [ism_setup.b_bp, ism_setup.a_bp] = get_ism_bp(room, op);
else
    ism_setup.b_bp = 1;
    ism_setup.a_bp = 1;
end

%% reflection filter coefficients

if op.ism_enableReflFilt
    [ism_setup.b_refl, ism_setup.a_refl] = getReflFiltCoeff(room.freq, room.absolRefl, ...
        ism_setup.b_bp, ism_setup.a_bp, op.fs, op.filtCreatMeth, op.plot_reflFilters);
else
    ism_setup.b_refl = num2cell(ones(6, 1));
    ism_setup.a_refl = ism_setup.b_refl;
end

%% Smearing

if op.enableSR(1)
    normalvec_dir = [-3 -2 -1 1 2 3];
    strDelays = (room.boxsize(abs(normalvec_dir)).*room.strSize)/speedOfSound(room);
    
    % sort them such that they are in line with order of walls as stored
    % in ISpattern (might be neutral operation due to choice of
    % normalvec_dir):
    strDelays = strDelays(normdir2idx(normalvec_dir));
    
    % apply random factor:
    init_rng(razr_get_seed(103, op));
    rand_factor = 0.1;
    strDelays = strDelays.*(1 + rand_factor*(2*rand(1, 6) - 1));
    strDelays = round(strDelays*op.fs);
    
    gain = sqrt(2)/2;
    eta = pi;
    
    for idx = 1:length(strDelays)
        [ism_setup.b_sr{idx}, ism_setup.a_sr{idx}, ism_setup.grpD(idx)] = ...
            getAllpassCascade(strDelays(idx), gain, eta, op.typeSR);
    end
end


%% Diffuse reflection filter coefficients and time spreading (NICO)

if op.ism_enable_scattering
    [ism_setup.b_diffu, ism_setup.a_diffu, ism_setup.b_specu, ism_setup.a_specu] = ...
        get_diffuse_filtcoeff(room, op);
    
    if op.ism_enable_timespread
        gain_Rev = sqrt(2)/2;
        eta_Rev = pi;
        mDist = mean([room.recpos, (room.boxsize - room.recpos)]);
        decay_time_spreading = 0.0205 * mDist;
        
        [ism_setup.b_tspr, ism_setup.a_tspr] = getAllpassCascade(...
            decay_time_spreading*op.fs, gain_Rev, eta_Rev, 6);
    end
end

%% IS orders and rng seeds for scale_is_pattern()

if any(op.ism_order) < 0
    error('Image source orders must be non-negative.');
end

if length(op.ism_order) == 1
    op.ism_order = [0, op.ism_order];
elseif length(op.ism_order) > 2
    error('op.ism_order must have length 1 or 2.');
else
    op.ism_order = sort(op.ism_order);
end

% orders above will be calculated as in the former single-order mode
% (must equal 1 for consistent rng seeds per order, which is equivalent to single-order-mode):
max_ord_common_calc = 1;

orders = op.ism_order(1):op.ism_order(2);

if op.ism_order(1) == op.ism_order(2)
    ism_setup.orders_from_to = op.ism_order(:)';
    
elseif op.ism_order(1) > max_ord_common_calc
    ism_setup.orders_from_to = repmat(orders', 1, 2);
    
else
    idx_start = find(orders > 0, 1);
    idx_end = find(orders == min(max_ord_common_calc, op.ism_order(2) - 1));
    
    ism_setup.orders_from_to = [...
        repmat(orders(1:idx_start-1)', 1, 2); ...
        orders(idx_start), orders(idx_end); ...
        repmat(orders(idx_end+1:end)', 1, 2)];
    
    % exclude invalid rows:
    ism_setup.orders_from_to(diff(ism_setup.orders_from_to, 1, 2) < 0, :) = [];
end

seed_tmp = razr_get_seed(5489, op);

% fixed seed for each IS order:
ism_setup.rng_seeds = seed_tmp + ism_setup.orders_from_to(:, 1);

end

function [isout, discd_direction] = treat_outside_positions(room, pos)

[isout, isout_neg, isout_pos] = isoutside(room, pos);

if isout
    if ~isfield(room, 'door')
        error('Receiver or source lies outside room but no door is specified.');
    end
    
    if size(room.door, 1) ~= 1
        error('room must contain not more than one door.');
    end
    
    wall_idx_door = room.door(1, 1);  % Just for the moment; more doors are not supported, yet
    discd_direction = wall_idx_door;
    
    % Only 1st order diffraction can be handled -> check the following criterion for all doors:
    if ...
            wall_idx_door > 0 && ~isout_pos(wall_idx_door) || ...
            wall_idx_door < 0 && ~isout_neg(abs(wall_idx_door))
        error(['Receiver or source lies on such a position outside room that 2nd order diffraction ', ...
            sprintf('would occur.\nOnly 1st order diffraction can be simulated.')]);
    end
else
    discd_direction = [];
end

end
