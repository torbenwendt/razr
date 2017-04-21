function [b, a, h] = getAbsfiltCoeff(room, fdn_setup, op)
% GETABSFILTCOEFF - Get absorption filter coefficients for FDN
%
% Usage:
%   [b, a, h] = GETABSFILTCOEFF(room, fdn_setup, op)
%
% Input:
%   room        room structure (see RAZR)
%   fdn_setup   Output of GET_FDN_SETUP
%   op          Options structure (see RAZR)
%
% Output:
%   b, a        Filter coefficients as matrix; rows: channels
%   h           Frequency responses

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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


%% test call

if nargin == 0
    room.boxsize  = [5, 4, 3];
    
    % materials for walls {-z; -y; -x; x; y; z}:
    %room.materials = {'block_p';'windowglass';'block_p';'block_p';'block_p';'carp_conc'};
    %room.materials = {'block_p';'draperies';'block_p';'block_p';'block_p';'carp_conc'};
    room.materials = {'block_p';'block_p';'block_p';'block_p';'block_p';'block_p'};
    
    [room.abscoeff, room.freq] = getAbscoeff(room.materials, octf(250, 4e3));
    fdn_setup.delays = [900; 1200; 1400];
    
    fdn_setup.b_bp = 1;
    fdn_setup.a_bp = 1;
    
    op.fs = 44100;
    op.filtCreatMeth = 'cq';
    op.plot_absFilters = true;
    
    [b, a, h] = getAbsfiltCoeff(room, fdn_setup, op);
    
    return;
end

%%

numFrq  = size(room.freq,2);
numCh   = length(fdn_setup.delays);
b_bplen = length(fdn_setup.b_bp);
a_bplen = length(fdn_setup.a_bp);

if isfield(room, 't60')  % room.materials had their chance in complement_room()
    rt = room.t60;
else
    rt = estimate_rt(room, op.rt_estim);
end

% frequency responses according to Jot and Chaigne (1991) (linear scale):
h = 10.^(-3/op.fs./rt(:)*fdn_setup.delays(:)')';

switch op.filtCreatMeth
    case 'cq'
        % currently still without prealloc:
        %b = zeros(numCh, 2*numFrq-1);
        %a = b;
        bb = cell(numCh,1);
        aa = cell(numCh,1);
        
        for ch = 1:numCh
            [ans0, ans0, bb{ch}, aa{ch}] = composedPEQ(room.freq, h(ch,:), op.fs, true);
        end
        blen = cellfun(@length, bb);
        maxblen = max(blen);
        b = zeros(numCh, maxblen);
        a = zeros(numCh, maxblen);
        
        for ch = 1:numCh
            b(ch,:) = [bb{ch}, zeros(1, maxblen-blen(ch))];
            a(ch,:) = [aa{ch}, zeros(1, maxblen-blen(ch))];
        end
        
        if any(fdn_setup.b_bp ~= 1) || any(fdn_setup.a_bp ~= 1)
            fprintf('Warning in %s: global bandpass in FDN not implemented for method cq\n', mfilename);
        end
        
    case 'cs'
        % prealloc:
        b = zeros(numCh, numFrq*2+1 + b_bplen-1);
        a = zeros(numCh, numFrq*2+1 + a_bplen-1);
        
        for ch = 1:numCh
            [bb, aa] = composedShelving(h(ch,:), room.freq, op.fs, 'peak', 1, 1);
            b(ch,:) = conv(bb, fdn_setup.b_bp);
            a(ch,:) = conv(aa, fdn_setup.a_bp);
        end
        
    case 'yw'
        % prealloc:
        M = 1;
        b = zeros(numCh, numFrq*M+1 + b_bplen-1);
        a = zeros(numCh, numFrq*M+1 + a_bplen-1);
        
        [bb, aa] = getFiltCoeff_yulewalk(room.freq, h, op.fs, M*length(room.freq), 0);
        for ch = 1:numCh
            b(ch,:) = conv(bb(ch,:), fdn_setup.b_bp);
            a(ch,:) = conv(aa(ch,:), fdn_setup.a_bp);
        end
        
    case 'sh'
        % prealloc:
        b_c = cell(numCh,1);
        a_c = b_c;
        flens = zeros(1,numCh);			% filter lengths
        
        for ch = 1:numCh
            [bb, aa] = shEQ(room.freq, h(ch,:), op.fs, 1);
            b_c{ch} = conv(bb, fdn_setup.b_bp);
            a_c{ch} = conv(aa, fdn_setup.a_bp);
            flens(ch) = length(b_c{ch});
        end
        
        % write coefficients into matrix (pad rows with zeros)
        maxflen = max(flens);
        b = zeros(numCh, maxflen);
        a = b;
        
        for ch = 1:numCh
            b(ch,:) = [b_c{ch}, zeros(1,maxflen-flens(ch))];
            a(ch,:) = [a_c{ch}, zeros(1,maxflen-flens(ch))];
        end
        
    otherwise
        error('Method not available: %s.', op.filtCreatMeth);
end

if op.plot_absFilters
    figure
    han = semilogx(room.freq, 20*log10(h), 's', 'linewidth', 2);
    hold on
    hf = plot_freqrsp(b, a, 'ax', gca, 'fs', op.fs, 'disp_mode', 'sgl');
    
    for n = 1:numCh
        hf.plot(n).Color = han(n).Color;
    end
    
    hold off
    title(sprintf('FDN absorption filters; Synth. method: %s', op.filtCreatMeth));
    %ylim([-10 0])
end
