function newState=appendState(newState,stInfo2,newfr1,newfr2,matchToPrev,matchFromNext)
fields={'X','Y','Xi','Yi','W','H','Xgp','Ygp'};

for f=fields
    cf=char(f);
    if isfield(newState,cf)
        f1=getfield(newState,cf);
        f2=getfield(stInfo2,cf);
        f1(newfr1,matchToPrev)=f2(newfr2,matchFromNext);
        newState=setfield(newState,cf,f1);
    end
end
end