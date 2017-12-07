function [out, outmat] = feedback_delay_network(insig, fdn_setup, op)
% FEEDBACK_DELAY_NETWORK
%
% Usage:
%   [out, outmat] = FEEDBACK_DELAY_NETWORK(in, fdn_setup, op)
%
% Input:
%   in          Input signal (1 or length(m) channels, i.e. columns)
%   fdn_setup   Structure containg FDN setup specifications returned by GET_FDN_SETUP.
%   op          Options struct (complete, i.e. custom options already merged with defaults!)
%
% Output:
%   out         Output signal
%   outmat      Output signal (monaural, multichannel)

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

%% allpass cascade

if op.fdn_enable_apc
    % fdn_setup.max_filtrange_input was written in gen_fdn_input:
    if isfield(fdn_setup, 'max_filtrange_input')
        rnge = fdn_setup.max_filtrange_input(1):fdn_setup.max_filtrange_input(2);
    else
        rnge = 1:size(insig, 1);
    end
    insig(rnge, :) = filter(fdn_setup.b_apc, fdn_setup.a_apc, insig(rnge, :));
end

%% adjust matrix size

[len, numCh] = size(insig);

if ~(numCh == 1 || numCh == fdn_setup.numDel)
    error('Input signal must have either 1 column or length(m) columns.');
elseif numCh == 1
    insig = repmat(insig, 1, fdn_setup.numDel);
end

if len < fdn_setup.len
    insig = [insig; zeros(fdn_setup.len - len, fdn_setup.numDel)];
else
    insig = insig(1:fdn_setup.len, :);
end

if isfield(fdn_setup, 'num_pre_zeros')  % set in gen_fdn_input
    insig = [insig; zeros(fdn_setup.num_pre_zeros, fdn_setup.numDel)];
end

%%

if any(size(fdn_setup.fmatrix) ~= fdn_setup.numDel)
    error('Feedback matrix must be quadratic.')
end

%% main loop

try
    [outmat] = fdn_mainloop(...
        insig, fdn_setup.delays, fdn_setup.b_abs, fdn_setup.a_abs, fdn_setup.fmatrix);
catch
    warning(['Mex file ''fdn_mainloop'' either not found or not executable. ', ...
        'fdn_mainloop_m is called instead.']);
    [outmat] = fdn_mainloop_m(...
        insig, fdn_setup.delays, fdn_setup.b_abs, fdn_setup.a_abs, fdn_setup.fmatrix);
end

%% pre-trunc

if isfield(fdn_setup, 'num_pre_zeros')  % set in gen_fdn_input
    outmat = outmat((fdn_setup.num_pre_zeros + 1):end, :);
end

%% reflection filters

if op.fdn_enableReflFilt
    if size(fdn_setup.b_refl, 1) == fdn_setup.numDel && ...
            size(fdn_setup.a_refl, 1) == fdn_setup.numDel
        for ch = 1:fdn_setup.numDel
            outmat(:, ch) = filter(fdn_setup.b_refl{ch}, fdn_setup.a_refl{ch}, outmat(:, ch));
        end
    else
        error('Number of reflection filters must be equal to length(m).');
    end
end

%% spatialization

out = spatialize(outmat, fdn_setup, op);

% security check:
if any(any(isnan(out)))
    error('nan detected in FDN output.');
end
