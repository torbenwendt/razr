function [lat,pol]=geo2horpolar(azi,ele)

% geo2horpolar        - Convert geodesic coordinates to horizontal-polar system
% [lat,pol]=geo2horpolar(azi,ele)
%
% Input:
%  azi; azimuth in deg
%  ele: elevation in deg
% Output:
%  lat: lateral angle in deg, [-90°..+90°]
%  pol: polar angle in deg, [-90°..270°]
%
% Piotr Majdak, 29.09.2006
% Edit Torben Wendt:
%   2016-06-08: Commented out the line "warning('off');"
%   2016-07-15: Replaced deg2rad by dg2rd and rad2deg by rd2dg

%warning('off');

azi=mod(azi+360,360);
ele=mod(ele+360,360);

razi = dg2rd(azi);
rele = dg2rd(ele);
rlat=asin(sin(razi).*cos(rele));
rpol=asin(sin(rele)./cos(rlat));
idx=find(cos(rlat)==0);
rpol(idx)=0;
pol = rd2dg(rpol);
lat = rd2dg(rlat);

idx = find(razi>pi/2 & razi < 3*pi/2 & (rele < pi/2 | rele > 3*pi/2));
pol(idx)=180-pol(idx);
idx = find(~(razi>pi/2 & razi < 3*pi/2) & rele > pi/2 & rele < 3*pi/2);
pol(idx)=180-pol(idx);
