function ret=getHypStruct()
% Target Hypothesis model struct
% similar to a pmpp object with some extensions:
% - start, end:     temporal start and end points
% - labelCost:      corresponding label cost value
% - lcComponents:   label cost components breakdown
% - lastused:       a counter that states how many iterations ago 
%                   this trajectory was used last time

ret = struct('form',{},'breaks',{},'coefs',{},'pieces',{},'order',{},'dim',{},'bspline',{}, ...
    'start',{},'end',{},'bbox',{},'labelCost',{},'lcComponents',{},'lastused',{});

end