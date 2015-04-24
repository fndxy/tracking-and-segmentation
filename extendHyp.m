function newH=extendHyp(H, used, sceneInfo, opt, currentEnergy)

newH=getHypStruct;
F=length(sceneInfo.frameNums);

exttail=1; exthead=1;
nCurModels=length(H);
addedExt=0;
nUsed=length(used);

for m=used
    hnew=H(m);
    if addedExt>=opt.maxExtend, break; end
    if hnew.start>exttail
        hnew.start=hnew.start-exttail;
        addedExt=addedExt+1;
        
        [hnew.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
        hnew.lastused=0;
        
        newH(addedExt) = hnew;
        
        % extend linear
        hnew=H(m);
        xy=ppval(hnew,hnew.start:hnew.start+3); %pts on spline                
%         xy=xy(1:2,:);
        t=[hnew.start:hnew.start+3];tr=t;
        linfit=splinefit(tr,xy,3,2);
        ttnew=hnew.start-exttail;
        newval=ppval(linfit,ttnew);
        % fit through new pt
        ttold=hnew.start:hnew.end;
        xy=ppval(hnew,ttold);
        xy=[newval xy];
        t=[ttnew,ttold]; tr=t;
        sfit=splinefit(tr,xy,round(max(opt.minCPs,(tr(end)-tr(1))*opt.ncpsPerFrame )));
        sfit=adjustHypStruct(sfit, min(t), max(t), F, 0, sceneInfo, opt);
                
        if ~any(isnan(sfit.coefs(:)))
            addedExt=addedExt+1;
            [sfit.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
            sfit.lastused=0;
            
            newH(addedExt) = sfit;
        end
        
        
        
        

% % %         % also extend to first frame
% % %         if hnew.start>exttail+1
% % %             hnew=H(m);
% % %             hnew.start=1;
% % %             addedExt=addedExt+1;
% % % 
% % %             newH(addedExt) = hnew;
% % %         end
        
    end
    hnew=H(m);
    if hnew.end <= F-exthead
        hnew=H(m);
        
        hnew.end=hnew.end+exthead;
        addedExt=addedExt+1;
        
        [hnew.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
        hnew.lastused=0;

        newH(addedExt) = hnew;
        
        hnew=H(m);
        headtimes=hnew.end-3:hnew.end;
        xy=ppval(hnew,headtimes); %pts on spline        
        t=headtimes;tr=t;
        linfit=splinefit(tr,xy,3,2);
        ttnew=hnew.end+exthead;
        newval=ppval(linfit,ttnew);
        % fit through new pt
        ttold=hnew.start:hnew.end;
        xy=ppval(ttold,hnew);
        xy=[xy newval];
        t=[ttnew,ttold]; tr=t;
        sfit=splinefit(tr,xy,round(max(opt.minCPs,(tr(end)-tr(1))*opt.ncpsPerFrame )));
        sfit=adjustHypStruct(sfit, min(t), max(t), F, 0, sceneInfo, opt);
                
        if ~any(isnan(sfit.coefs(:)))
            addedExt=addedExt+1;
            [sfit.labelCost, ~]=getHypLabelCost2(hnew,sceneInfo,opt);
            sfit.lastused=0;
            
            newH(addedExt) = sfit;
        end        

% % %         % also extend to last frame
% % %         if hnew.end<F-exthead
% % %             hnew=H(m);
% % %             hnew.end=F;
% % %             addedExt=addedExt+1;
% % % 
% % %             newH(addedExt) = hnew;
% % %         end
    end
    
    
end


allNewLCost=[newH.labelCost];
newH=newH(currentEnergy>allNewLCost);



for m=1:length(newH), newH(m).lastused=0; end
