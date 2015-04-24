function newH=fitHypToSeg(labeling, bglabel, sp_labels, frames, sceneInfo, opt, IMIND, SPPerFrame)

newH=getHypStruct;
if unique(labeling)==bglabel
    return;
end

% TODO: FIX
if opt.maxFitHyp<1
    return;
end

F=length(frames);

% Icomb=combineSegs2(sp_labels,labeling);
Icomb=combineSegs2(sp_labels,labeling,IMIND, SPPerFrame);
stateInfo=getBBoxesFromLabeling(labeling,Icomb,bglabel,sceneInfo,opt);
newH=getHypsFromDP(stateInfo, frames,F,sceneInfo,opt);

newH=newH(randperm(length(newH)));
newH=newH(1:min(length(newH),opt.maxFitHyp));

for m=1:length(newH), newH(m).lastused=0; end