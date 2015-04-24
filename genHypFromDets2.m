function newH=genHypFromDets2(H, used, detections, labeling, nSP, sceneInfo, opt)
% Generate hypotheses from 'used' detections

newH=getHypStruct;

if ~isfield(opt,'maxFitDet2')
    return;
elseif opt.maxFitDet2==0
    return;
end
F=length(detections);

detsVar=nSP+1:length(labeling);
detLabeling=labeling(detsVar);
nAdded=0;


detPerFrame=zeros(1,F);
for t=1:F, detPerFrame(t)=length(detections(t).sc); end
% detIdxToF=zeros(nalldet,2);
detIdxToF=[];
for t=1:F
    dt=detPerFrame(t);
    curSize=size(detIdxToF,1);
    s=curSize+1;
    e=curSize+dt;
    detIdxToF(s:e,1)=t;
    detIdxToF(s:e,2)=1:dt;
end

for id=used
    if nAdded>=opt.maxFitDet, break; end
    dets=find(detLabeling==id);
    

    xys=[];
    tr=[];
    for d=dets
        t=detIdxToF(d,1);
        det=detIdxToF(d,2);
        xi=detections(t).xi(det);    yi=detections(t).yi(det);
        bw=detections(t).wd(det);    bh=detections(t).ht(det);
        x1=xi-bw/2; y1=yi-bh; x2=xi+bw/2; y2=yi;
        
        thisDet=[xi; yi; bw; bh];
        xys=[xys thisDet];
        tr=[tr t];
    end
      
    if length(unique(tr))>=4
        sfit=splinefit(tr,xys,round(max(opt.minCPs,(tr(end)-tr(1))*opt.ncpsPerFrame )));
%         ts=max(1,t-2); tf=min(t+1,F);
        sfit=adjustHypStruct(sfit, tr(1), tr(end),  F, 0, sceneInfo, opt);
        
        if ~any(isnan(sfit.coefs(:)))
            nAdded=nAdded+1;
            newH(nAdded)=sfit;
        end
    end
        
%     pause
end

for m=1:nAdded, newH(m).lastused=0; end

end