function newH=mergeHyp(H, used, sceneInfo, opt, currentEnergy)
% TODO comment

newH=getHypStruct;
F=length(sceneInfo.frameNums);

% global opt
normfac=1;
thr1=25;
thr2=5;
thr3=50;
tg1=-3;
tg2=20;
if isfield(opt,'mergeTG1')
    tg1=opt.mergeTG1;
end
if isfield(opt,'mergeTG2')
    tg2=opt.mergeTG2;
end
% if opt.track3d
%     normfac=1000;
%     thr1=.5;
%     thr2=2;
%     thr3=1;
% end

%% merge close ones only

nMaxAddMerged=10;
% nMaxAddMerged=opt.nMaxAddMerged;
nCurModels=length(H);
addedMerged=0;
nUsed=length(used);
if nUsed>1
    for m1=randperm(nUsed)
        mod1=used(m1);
        mh1=H(mod1);
        s1=mh1.start;
        e1=mh1.end;
        for  m2=randperm(nUsed)
            
            if addedMerged>=opt.maxMerge, break; end
            
            mod2=used(m2);
            mh2=H(mod2);
            s2=mh2.start;
            e2=mh2.end;
            
            timegap=s2-e1;
            if mod1==mod2 || timegap < tg1 || timegap > tg2, continue; end
            xyend=ppval(mh1,e1);
            xystart=ppval(mh2,s2);
            xe=xyend(1); ye=xyend(2);
            xs=xystart(1); ys=xystart(2);
            spacegap=norm(xystart-xyend)/normfac;
%             spacegap=norm([xs ys]-[xe ye])/normfac;
%             [m1 m2]
%             spacegap
%             pause
            if ~timegap, timegap=1; end
            speedpf=abs(spacegap/timegap);
            %                                          speedpf
            if speedpf < thr1 || (abs(timegap) <= thr2 && speedpf < thr3)
                
%                 [m1 m2]
%                 [s1 e1 s2 e2]
                % fit through splines
                xt1=ppval(mh1,s1:e1); %pts on spline
                xt2=ppval(mh2,s2:e2);
                xy=[xt1 xt2];
                t=[s1:e1 s2:e2];tr=t;
                
                % avoid singular fit
                if numel(unique(tr))<4
                    continue;
                end
                
                sfit=splinefit(tr,xy,round(max(opt.minCPs,(tr(end)-tr(1))*opt.ncpsPerFrame )));
                sfit=adjustHypStruct(sfit, min(t), max(t), F, 0, sceneInfo, opt);
                
%                 tr
%                 xy
%                 pause
%                 
                if ~any(isnan(sfit.coefs(:)))
                    addedMerged=addedMerged+1;
                    newH(addedMerged) = sfit;
                end
%                 addedMerged
%                             disp([mod1 mod2])
            end
        end
    end
    
end

allNewLCost=[newH.labelCost];
newH=newH(currentEnergy>allNewLCost);



for m=1:length(newH), newH(m).lastused=0; end

end