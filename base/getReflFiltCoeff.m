function [bRefl, aRefl] = getReflFiltCoeff(freq, absolRefl, b_bp, a_bp, fs, method, makePlot)
% GETREFLFILTCOEFF - Get reflection filter coefficients
%
% Usage:
%   [bRefl, aRefl] = GETREFLFILTCOEFF(freq, absolRefl, b_bp, a_bp, fs, method, makePlot)
%
% Input:
%   absolRefl           Absorption coefficients as matrix; rows: walls
%   freq                Frequency base
%   b_bp, a_bp          Coefficients for global bandpass filter, applied as last step
%   method              Method for filter synthsis
%                       'cs': composedShelving,
%                       'sh': shEQ,
%                       'cq': compodesPEQ (recommended),
%                       'yw': getFiltCoeff_yulewalk
%   makePlot            If true, make test plot
%
% Output:
%   bRefl, aRefl        Filter coefficients as cell array
%                       (for method 'sh' filter length may vary)

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



bRefl = cell(6,1);
aRefl = bRefl;

switch method
    case 'cq'
        for w = 1:6
            [ans0, ans0, bRefl{w}, aRefl{w}] = composedPEQ(freq, absolRefl(w,:), fs, true);
            bRefl{w} = conv(bRefl{w}, b_bp);
            aRefl{w} = conv(aRefl{w}, a_bp);
        end
        
    case 'cs'
        for w = 1:6
            [bb, aa] = composedShelving(absolRefl(w,:), freq, fs, 'peak', 1, 1);
            bRefl{w} = conv(bb, b_bp);
            aRefl{w} = conv(aa, a_bp);
        end
        
    case 'yw'
        [bb, aa] = getFiltCoeff_yulewalk(freq, absolRefl, fs, 1*length(freq), 0);
        for w = 1:6
            bRefl{w} = conv(bb(w,:), b_bp);
            aRefl{w} = conv(aa(w,:), a_bp);
        end
        
    case 'sh'
        for w = 1:6
            [bb, aa] = shEQ(freq, absolRefl(w,:), fs, 1, 0);
            bRefl{w} = conv(bb, b_bp);
            aRefl{w} = conv(aa, a_bp);
        end
        
    otherwise
        error('Method not available: %s.', method);
end

% test plot:
if makePlot
    figure
    for w = 1:6
        p1 = semilogx(freq,20*log10(absolRefl(w,:)),'s','Color',[1/w 0.5 w/6]);
        hold on
        p2(w) = plotFrqRsp(bRefl{w}, aRefl{w}, fs, 'mode', 'sgl', 'color', get(p1,'Color'));
        hold on
    end
    hold off
    title(sprintf('Reflection factors; Filter synth. method: %s', method), 'interpreter', 'none')
    ylim([-6 0])
    legend show;
    legend('location', 'best')
end
