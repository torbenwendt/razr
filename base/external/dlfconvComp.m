% dlfconv.m - fast convolution via double-length radix-2 fft -
%
% Usage c = dlfconv(a,b)
%
% c = convolution between a and b
% a,b = both column vectors or both row vectors

%------------------------------------------------------------------------------
% PlugInChain for Mathwork’s MATLAB
% Version 1.00.0
%
% Author(s): Medi
%
% Copyright © 2008-2011, Medizinische Physik, 
% Carl-von-Ossietzky Universität Oldenburg. 
% Some rights reserved.
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-
% NoDerivs 3.0 Unported License. To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative
% Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
%------------------------------------------------------------------------------


function c=dlfconvComp(a,b);

transp = false;

if size(a,1) == 1
    a = a';
    b = b';
    transp = true;
end

len = length(b);
difflen = len - length(a); 

if difflen < 0
   b = [b; zeros(-difflen,1)];
   len = len - difflen;
elseif difflen > 0
   a = [a; zeros(difflen,1)];
end

np2=2^(nextpow2(len));

tmp=[b;zeros(2*np2-len,1)];
c=[a;zeros(2*np2-len,1)];

c=ifft((fft(tmp)).*(fft(c)));

c=c(1:len);

if transp
    c = c';
end