function [h, absspec, freq] = plot_irspec(ir, varargin)
% PLOT_IRSPEC - Calculate and plot normalized frequency response representation of RIR into a new
% figure.
%
% Usage:
%   [h, absspec, freq] = PLOT_IRSPEC(ir, Name, Value)
%
% Required input:
%   ir          ir structure (see RAZR) or vector of ir structures
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   smo         ('none') Frequency response smoothing. Possible values:
%               'none': no smoothing
%               'oct': octave smoothing
%               '3rd': third octave smoothing
%               If specified as a scalar number, it specifies the smoothing constant in octaves.
%   parts       ('w') Character array specifying which parts of RIR (if available separately) shall
%               be plotted. Keys are:
%               'w': whole RIR, 'd': direct sound, 'e': early reflections, 'l': late reverb.
%               Examples: parts = 'del', parts = 'w'.
%   winlen      ([]) Time in sec. at which the IR is faded out (50-ms Hann flank) before fft
%               calculation. If set to empty, no fading is applied.
%   plot        (true) If true, plot frequency response.
%   shift       (0) Amount in dB by which the curves are shifted against each other to increase
%               readability
%   grayshades  (false) If true, plot frequency response in grayshades, otherwise colored
%
% Output:
%   h           Structure containing graphic handles
%   absspec     Frequency response(s) in dB, normalized to maximum
%   freq        Frequency vector for absspec
%
% See also: PLOT_IR

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


%% input

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'smo', 'none');
addparam(p, 'parts', 'w');
addparam(p, 'winlen', []);
addparam(p, 'plot', true);
addparam(p, 'shift', 0);
addparam(p, 'grayshades', false);
parse(p, varargin{:});

do_fade = ~isempty(p.Results.winlen);

if p.Results.plot
    num_ir = length(ir);
    [nrows, ncols] = get_panel_dims(num_ir);
    hfig = figure;
end

for ii = num_ir:-1:1
    ir_tmp = ir(ii);
    
    do_direct = isfield(ir_tmp, 'sig_direct') && ismember('d', p.Results.parts);
    do_early  = isfield(ir_tmp, 'sig_early')  && ismember('e', p.Results.parts);
    do_late   = isfield(ir_tmp, 'sig_late')   && ismember('l', p.Results.parts);
    do_whole  = ismember('w', p.Results.parts)   || (~do_direct && ~do_early && ~do_late);
    
    ifs      = [do_whole, do_direct, do_early, do_late];
    fldnames = {'sig', 'sig_direct', 'sig_early', 'sig_late'};
    colflds  = {'whole_', 'direct_', 'early_', 'late_'};
    leg_str  = {'Left', 'Right', 'Direct L', 'Direct R', 'Early L', 'Early R', 'Late L', 'Late R'};
    
    num = length(ifs);
    
    %% calc spectrum
    
    if do_fade
        ir_tmp = cutnwin(ir_tmp, [0, 0, p.Results.winlen, 50e-3], true);
    end
    
    freq = linspace(1, ir_tmp.fs, size(ir_tmp.sig, 1));
    
    for n = 1:num
        if ifs(n) || n == 1
            absspec.(fldnames{n}) = 20*log10(abs(fft(ir_tmp.(fldnames{n}))));
            %absspec.(fldnames{n}) = absspec.(fldnames{n}) - max(max(absspec.sig));  % normalization
        end
    end
    
    %% smoothing
    
    if ischar(p.Results.smo)
        switch p.Results.smo
            case 'none'
                smoothing = [];
            case 'oct'
                smoothing = 12/12;
            case '3rd'
                smoothing = 4/12;
            otherwise
                error('Unknown smoothing specification: %s', p.Results.smo);
        end
    else
        smoothing = p.Results.smo;
    end
    
    numCh = size(ir_tmp.sig, 2);
    
    if ~isempty(smoothing)
        for fl = 1:num
            if ifs(fl)
                for n = numCh:-1:1
                    absspec.(fldnames{fl})(:, n) = ...
                        smoothnew3(absspec.(fldnames{fl})(:, n), smoothing);
                end
            end
        end
    end
    
    %% plot
    
    if p.Results.plot
        use_gobjects = exist('gobjects', 'file');  % feature of newer Matlab versions
        
        if use_gobjects
            hplot = gobjects(2*num, 1);
        else
            hplot = nan(2*num, 1);
        end
        
        if p.Results.grayshades
            col.direct_L = [0 0 0];
            col.direct_R = [1 1 1]*0.4;
            col.early_L  = [0 0 0];
            col.early_R  = [1 1 1]*0.4;
            col.late_L   = [1 1 1]*0.6;
            col.late_R   = [1 1 1]*0.8;
        else
            col = brir_colors;
        end
        
        col.whole_L = [0 0 0];
        col.whole_R = [1 1 1]*0.5;
        
        lw = 2.0;
        
        hax(ii) = subplot(nrows, ncols, ii);
        
        for fl = 1:num
            if ifs(fl)
                if numCh == 2
                    hplot(2*fl) = semilogx(...
                        freq, absspec.(fldnames{fl})(:, 2) - (sum(ifs(1:fl)) - 1)*p.Results.shift, ...
                        'color', col.(sprintf('%sR', colflds{fl})), 'Linewidth', lw);
                    hold on;
                end
                hplot(2*fl - 1) = semilogx(...
                    freq, absspec.(fldnames{fl})(:, 1) - (sum(ifs(1:fl)) - 1)*p.Results.shift, ...
                    'color', col.(sprintf('%sL', colflds{fl})), 'Linewidth', lw);
            end
        end
        
        xlabel('Frequency (Hz)')
        ylabel('Energy level (dB)')
        
        if num_ir > 1
            title(ii)
        else
            if isfield(ir_tmp, 'name')
                title(ir_tmp.name, 'Interpreter', 'none')
            end
        end
        
        xlim([16 ir_tmp.fs/2]);
        grid on;
        
        set(hax(ii), ...
            'Xtick', ...
            [16,22,32,45,63,90,125,180,250,350,500,700,1e3,1.4e3,2e3,2.8e3,4e3,5.6e3,8e3,11.2e3,16e3],...
            'XTickLabel', ...
            {'','','32','','63','','125','','250','','500','','1k','','2k','','4k','','8k','','16k'});
        
        %set(gca, 'Linewidth', lw);
        
        if use_gobjects
            phandle_idx = ishandle(hplot);
        else
            phandle_idx = ~isnan(hplot);
        end
        
        if ii == 1
            hleg = legend(hplot(phandle_idx), leg_str(phandle_idx), 'Location', 'Southwest');
        end
    else
        hplot = [];
        hfig = [];
        hax = [];
        hleg = [];
    end
end

if nargout > 0
    h.fig = hfig;
    h.ax = hax;
    h.plot = hplot;
    h.leg = hleg;
end
