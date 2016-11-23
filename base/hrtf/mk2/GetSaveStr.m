function fname = GetSaveStr(az,el)

if el<0
    fname = ['ElM' num2str(abs(el))];
else
    fname = ['ElP' num2str(abs(el))];
end

fname = [fname '_Az' num2str(az) ];
