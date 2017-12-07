function [b, a] = comb(m, g)
% comb - coefficients for comb filter
% 
% [b, a] = comb(m, g)
% 
% Input:
%	m		delay
%	g		gain factor
% 
% Output:
%	b, a	filter coefficients


% Torben Wendt
% edited last: 08.01.2015


%          1 + g*z^(-m)
% H(z) = --------------
%              1


b = zeros(1, m + 1);

b(1)     = 1;
b(m + 1) = g;

a = 1;
