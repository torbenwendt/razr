function [azi,ele]=hor2geo(lat,pol)
% HOR2GEO converts coordinates in horizontal polar format to geodetic ones
% Usage:  [azi,ele]=hor2geo(lat,pol)
% Input arguments:
%       lat:        lateral angle   (-90 <= lat <= 90)
%       pol:        polar angle     (-90 <= pol < 270)
% Output arguments:
%       azi:        azimuth angle   (  0 <= azi < 360)
%       ele:        elevation angle (-90 <= ele <= 90)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robert Baumgartner, OEAW Acoustical Research Institute
% latest update: 2010-08-23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit Torben Wendt, 2016-07-15: Replaced rad2deg by rd2dg and deg2rad by dg2rd

if lat==90
    azi=lat;
    ele=0;
    azi=mod(azi+360,360);
else
    lat=dg2rd(mod(lat+360,360));
    pol=dg2rd(mod(pol+360,360));
    ele=asin(cos(lat)*sin(pol));
    if cos(ele)==0
        azi=0;
    else
        azi=real(rd2dg(asin(sin(lat)/cos(ele))));
    end
    ele=rd2dg(ele);
    if pol > pi/2 && pol< 3*pi/2
        azi=180-azi;
    end
    azi=mod(azi+360,360);
end
end
