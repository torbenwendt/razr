
%Written by Daniyal Amir @2012

% A structure problem I came across doing a Project, thought might be
% helpful to other users

% Functionality

% An Overwrite and Merge function : 'If it doesnot already exist in Matlab'

% Overwrite fields in x to fields in y , add fields in y if they do not
% exist , return overwritten and/or merged structure. 

% 1-The function can be also used as only-overwrite and only-merge 
% 2-The order of inputs is only relevant when overwrite=1
% 3-Non struct based inputs result in output=y

% Input : x and y of (un)equal  lengths containing structure fields
%       : merge 1 or 0 
%       : overwrite 1 or 0
% Output: par , is (not/an)overwritten and (not/a)merged version of y

% Note : comparisons are case-sensitive  

function par= overwrite_merge(x,y,overwrite,merge)

if (isstruct(x)&& isstruct(y))
fieldsx=fields(x);
fieldsy=fields(y);
length_x=numel(fieldsx);
length_y=numel(fieldsy);

for fieldx=1:length_x
    fieldnamex= fieldsx{fieldx};
    found=0;
    
     for fieldy=1:length_y
         fieldnamey=fieldsy{fieldy};
         if (strcmp(fieldnamex,fieldnamey))      
             found=1;
             if(overwrite==1)
              y.(fieldnamey)=x.(fieldnamex);
             end
         end % first if
     end %second for
     
     if ( merge==1 && found==0 )
         y.(fieldnamex)=x.(fieldnamex);
                   
     end        
        
end % first for
end % struct-check if

par=y;

end
