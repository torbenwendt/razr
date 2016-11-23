function h = plot_ir(ir, opts)
% PLOT_IR - Plot impulse response time signal into a new figure.
%
% Usage:
%   h = plot_ir(ir, [opt])
%
% Input:
%   ir          ir structure (see RAZR) or vector of ir structures
%   opt         Optional string containing key characters:
%               'd': plot direct sound (if separately available),
%               'e': plot early reflections  (if separately available),
%               'l': plot late reverberation  (if separately available),
%               'g': plot RIR on logarithmic scale
%               'r': set xlim to whole range of RIR (otherwise set range to [-20, 500] ms)
%               's': use grayshades instead of colors
%
% Output:
%   handles     Structure containing graphic handles
%
% See also: PLOT_IRSPEC

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
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



%% input

if nargin < 2
    opts = '';
end

num_ir = length(ir);
[nrows, ncols] = get_panel_dims(num_ir);

do_logplot = ismember('g', opts);
do_zoomx = ~ismember('r', opts);
do_grayshades = ismember('s', opts);

figure;

for ii = num_ir:-1:1
    ir_tmp = ir(ii);
    
    do_direct = isfield(ir_tmp, 'sig_direct') && ismember('d', opts);
    do_early  = isfield(ir_tmp, 'sig_early')  && ismember('e', opts);
    do_late   = isfield(ir_tmp, 'sig_late')   && ismember('l', opts);
    do_whole  = (~do_direct && ~do_early && ~do_late);
    
    len = size(ir_tmp.sig, 1);
    
    %%
    
    lw = 1.5;
    ysym = 1;           % ylim symmetric around 0?
    
    if do_grayshades
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
    
    if do_zoomx
        xrange = [-20, 5e2];
    else
        xrange = [0, (len - 1)/ir_tmp.fs*1e3];
    end
    
    %%
    
    t_ms = timevec(len, ir_tmp.fs)*1e3;
    
    ifs      = [do_whole, do_direct, do_early, do_late];
    fldnames = {'sig', 'sig_direct', 'sig_early', 'sig_late'};
    colflds  = {'whole_', 'direct_', 'early_', 'late_'};
    leg_str  = {'Left', 'Right', 'Direct L', 'Direct R', 'Early L', 'Early R', 'Late L', 'Late R'};
    
    num = length(ifs);
    
    use_gobjects = exist('gobjects', 'file');       % feature of newer Matlab versions
    
    if use_gobjects
        hplot = gobjects(1, 2*num);
    else
        hplot = nan(1, 2*num);
    end
    
    hax(ii) = subplot(nrows, ncols, ii);
    
    for n = 1:num
        if ifs(n)
            if do_logplot
                signal = 20*log10( abs(ir_tmp.(fldnames{n})) / max(max(abs(ir_tmp.sig))) );
            else
                signal = ir_tmp.(fldnames{n});
            end
            
            if size(signal, 2) == 2
                hplot(ii, 2*n) = plot(t_ms, signal(:, 2), ...
                    'color', col.(sprintf('%sR', colflds{n})), 'Linewidth', lw);
                hold on
            end
            hplot(ii, 2*n - 1) = plot(t_ms, signal(:, 1), ...
                'color', col.(sprintf('%sL', colflds{n})), 'Linewidth', lw);
        end
    end
    
    if do_logplot
        ylabel('Normalized energy level (dB)')
        ylim([-140, 0])
    else
        ylabel('Amplitude')
        if ysym
            ymax = max(abs(get(gca, 'ylim')));
            ylim([-1, 1]*ymax);
        end
    end
    
    xlabel('Time (ms)')
    
    if num_ir > 1
        title(ii)
    else
        if isfield(ir_tmp, 'name')
            title(ir_tmp.name, 'Interpreter', 'none')
        end
    end
    
    xlim(xrange)
    set(gca, 'Linewidth', lw);
    
    if use_gobjects
        phandle_idx = ishandle(hplot);
    else
        phandle_idx = ~isnan(hplot);
    end
    
    if ii == 1
        hleg = legend(hplot(ii, phandle_idx), leg_str(phandle_idx));
        legend('boxoff')
    end
end

if nargout > 0
    h.fig = gcf;
    h.ax = hax;
    h.plot = hplot;
    h.leg = hleg;
end
