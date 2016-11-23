function plotAbscoeff(materials)
% PLOTABSCOEFF - Plot absorption coefficients, that are available via GETABSCOEFF.
%
% Usage:
%   PLOTABSCOEFF([materials])
%
% Input:
%   materials       Materialien als String-Cell-Array, siehe getAbscoeff();
%                   (optional, default: all available materials)

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



if nargin==0
    materials = getAbscoeff;
end

if isrowvec(materials)
    materials = materials';
end

[abscoeff, freq] = getAbscoeff(materials);

numm = length(materials);

figure;
cmap = lines(numm);
lmap = {'s-', 'o:', 'd-.', '*--'};
lmap_rep = repmat(lmap, 1, ceil(numm/length(lmap)));

for n = 1:numm
    
    h(n) = semilogx(freq, abscoeff(n,:), ...
        lmap_rep{n}, ...
        'color', cmap(n,:), ...
        'markerfacecolor', 'w');
    hold on
end

legend(h,materials, 'interpreter', 'none');
set(gca,'xtick',freq,'xticklabel',num2str(freq'))
xlabel('Frequency (Hz)')
ylabel('Absorption coefficient')
