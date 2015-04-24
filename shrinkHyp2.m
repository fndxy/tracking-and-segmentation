function newH=shrinkHyp2(H, used, sceneInfo, opt, currentEnergy)

newH=getHypStruct;
F=length(sceneInfo.frameNums);

shrinktail=1; shrinkhead=1;
shrinktail=randi(3); shrinkhead=shrinktail;
minshr=1; maxshr=10;

nCurModels=length(H);
addedShr=0;
nUsed=length(used);

if ~isfield(opt,'maxShrink2')
    opt.maxShrink2=0;     
end

for m=used
    hnew=H(m);
    hold=H(m);
    if addedShr>=opt.maxShrink2, break; end
    trL=hnew.end-hnew.start+1;
    
    if trL<2, continue; end
    
    mmt=[];
    mmh=[];
    for shr=minshr:min(trL-1,maxshr)
        htmp=hnew;        
        htmp.start=htmp.start+shr;
        [mmt(shr), ~]=getHypLabelCost2(htmp,sceneInfo,opt);
        
        htmp=hnew;        
        htmp.end=htmp.end-shr;
        [mmh(shr), ~]=getHypLabelCost2(htmp,sceneInfo,opt);        
    end
    [~,bestTail]=min(mmt);
    [~,bestHead]=min(mmh);
    
    
    if hnew.end-hnew.start>bestTail
        hnew.start=hnew.start+bestTail;
        addedShr=addedShr+1;
        
        [hnew.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
        hnew.lastused=0;
        
        newH(addedShr) = hnew;
    end
    
    hnew=hold;
    if hnew.end-hnew.start>bestHead
        hnew.end=hnew.end-bestHead;
        addedShr=addedShr+1;
        
        [hnew.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
        hnew.lastused=0;
        
        newH(addedShr) = hnew;
    end
       
        
        
end

    
    


allNewLCost=[newH.labelCost];
newH=newH(currentEnergy>allNewLCost);



for m=1:length(newH), newH(m).lastused=0; end
