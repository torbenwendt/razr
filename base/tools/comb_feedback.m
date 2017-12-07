function [b, a] = comb_feedback(m, g)
% comb_feedback - coefficients for comb filter in feedback form
% 
% [b, a] = comb_feedback(m, g)
% 
% Input:
%	m		delay
%	g		gain factor
% 
% Output:
%	b, a	filter coefficients


% Torben Wendt
% 2015-06-10


%              1
% H(z) = --------------
%         1 - g*z^(-m)


a = zeros(1, m + 1);

a(1)     = 1;
a(m + 1) = g;

b = 1;
