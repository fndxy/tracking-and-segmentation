function newH=shrinkHyp(H, used, sceneInfo, opt, currentEnergy)

newH=getHypStruct;
F=length(sceneInfo.frameNums);

shrinktail=1; shrinkhead=1;
nCurModels=length(H);
addedShr=0;
nUsed=length(used);

for m=used
    hnew=H(m);
    hold=H(m);
    if addedShr>=opt.maxShrink, break; end
    if hnew.end-hnew.start>1
        hnew.start=hnew.start+shrinktail;
        addedShr=addedShr+1;
        
        [hnew.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
        hnew.lastused=0;
        
        newH(addedShr) = hnew;
        
        hnew=hold;

        hnew.end=hnew.end-shrinkhead;
        addedShr=addedShr+1;
        
        [hnew.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
        hnew.lastused=0;
        
        newH(addedShr) = hnew;
        
        
    end

    
    
end


allNewLCost=[newH.labelCost];
newH=newH(currentEnergy>allNewLCost);



for m=1:length(newH), newH(m).lastused=0; end
