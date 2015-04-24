function detections = detStructToArray(alldet,F)

% F=max(alldet.tp);

detections=[];

for t=1:F
    allt=find(alldet.tp==t);
    detections(t).bx=alldet.bx(allt);
    detections(t).by=alldet.by(allt);
    detections(t).xp=alldet.xp(allt);
    detections(t).yp=alldet.yp(allt);
    detections(t).xi=alldet.xp(allt);
    detections(t).yi=alldet.yp(allt);
    detections(t).xw=alldet.xp(allt);
    detections(t).yw=alldet.yp(allt);
    detections(t).ht=alldet.ht(allt);
    detections(t).wd=alldet.wd(allt);
    detections(t).sc=alldet.sp(allt);
    
end


end