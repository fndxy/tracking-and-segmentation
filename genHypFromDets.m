function newH=genHypFromDets(H, used, detections, sceneInfo, opt)
% Generate hypotheses from 'unused' detections

newH=getHypStruct;
F=length(detections);

hyps=getBBoxesFromHyps(H(used),F);

global alldpoints
nMaxAddFromDets=10;

detPerFrame=zeros(1,F);
for t=1:F, detPerFrame(t)=length(detections(t).sc); end


allsc=[detections(:).sc];
[sortedsc, sscidx]=sort(allsc,'descend');

nalldet=length(allsc);
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

nAdded=0;
nH=size(hyps.W,2);
for d=sscidx
    if nAdded>=opt.maxFitDet, break; end
    
    t=detIdxToF(d,1);
    det=detIdxToF(d,2);
    xi=detections(t).xi(det);    yi=detections(t).yi(det);
    bw=detections(t).wd(det);    bh=detections(t).ht(det);
    x1=xi-bw/2; y1=yi-bh; x2=xi+bw/2; y2=yi;
    
    exH=find(hyps.W(t,:));
    ol=0;
%     im=getFrame(sceneInfo,t);
%     clf;
%     imtight(im);
%     hold on
    
%     rectangle('Position',[x1,y1,bw,bh],'EdgeColor','w');
    for dh=exH
        xi_=hyps.Xi(t,dh);        yi_=hyps.Yi(t,dh);
        bw_=hyps.W(t,dh);        bh_=hyps.H(t,dh);
        
        x1_=xi_-bw_/2; y1_=yi_-bh_; x2_=xi_+bw_/2; y2_=yi_;
        
        iou=boxiou(x1,y1,bw,bh,x1_,y1_,bw_,bh_);
%         rectangle('Position',[x1_,y1_,bw_,bh_],'EdgeColor','b');
%         [t det dh]
%         iou

        if iou>.5
            ol=1;
            break;
        end
    end
%     pause
% ff=find(alldpoints.sp==detections(t).sc(det));
% if ff==14
%     ol
%     nAdded
%     pause
% end


    % detection not covered by any hypothesis
    if ~ol
%         rectangle('Position',[x1,y1,bw,bh],'EdgeColor','w');
%         pause
        olthr=0.5;
        ts=t; tf=t;
        xys=repmat([xi,yi,bw,bh]',1,4);
%         xys
        % collect close dets for better velocity estimation
        % two steps back
        
        if t<F
            xi_=xys(1,3);        yi_=xys(2,3);
            bw_=xys(3,3);        bh_=xys(4,3);

            x1_=xi_-bw_/2; y1_=yi_-bh_; x2_=xi_+bw_/2; y2_=yi_;

            tt=t+1;
            ndet=length(detections(tt).xp);
            ious=zeros(1,ndet);
            for det=1:ndet
                xi=detections(tt).xi(det);    yi=detections(tt).yi(det);
                bw=detections(tt).wd(det);    bh=detections(tt).ht(det);
                x1=xi-bw/2; y1=yi-bh; x2=xi+bw/2; y2=yi;

                ious(det)=boxiou(x1,y1,bw,bh,x1_,y1_,bw_,bh_);
            end
            [maxol, det]=max(ious);
            
            if maxol>olthr
                xi=detections(tt).xi(det);    yi=detections(tt).yi(det);
                bw=detections(tt).wd(det);    bh=detections(tt).ht(det);

                xys(:,4)=[xi,yi,bw,bh];
                tf=tt;
            end            
        end
        
        if t>1
            xi_=xys(1,3);        yi_=xys(2,3);
            bw_=xys(3,3);        bh_=xys(4,3);

            x1_=xi_-bw_/2; y1_=yi_-bh_; x2_=xi_+bw_/2; y2_=yi_;

            tt=t-1;
            ndet=length(detections(tt).xp);
            ious=zeros(1,ndet);
            for det=1:ndet
                xi=detections(tt).xi(det);    yi=detections(tt).yi(det);
                bw=detections(tt).wd(det);    bh=detections(tt).ht(det);
                x1=xi-bw/2; y1=yi-bh; x2=xi+bw/2; y2=yi;

                ious(det)=boxiou(x1,y1,bw,bh,x1_,y1_,bw_,bh_);
            end
            [maxol, det]=max(ious);
            
            if maxol>olthr
                xi=detections(tt).xi(det);    yi=detections(tt).yi(det);
                bw=detections(tt).wd(det);    bh=detections(tt).ht(det);

                xys(:,2)=[xi,yi,bw,bh];
                ts=tt;
            end
        end
        
        if t>2
            xi_=xys(1,2);        yi_=xys(2,2);
            bw_=xys(3,2);        bh_=xys(4,2);

            x1_=xi_-bw_/2; y1_=yi_-bh_; x2_=xi_+bw_/2; y2_=yi_;

            tt=t-2;
            ndet=length(detections(tt).xp);
            ious=zeros(1,ndet);
            for det=1:ndet
                xi=detections(tt).xi(det);    yi=detections(tt).yi(det);
                bw=detections(tt).wd(det);    bh=detections(tt).ht(det);
                x1=xi-bw/2; y1=yi-bh; x2=xi+bw/2; y2=yi;

                ious(det)=boxiou(x1,y1,bw,bh,x1_,y1_,bw_,bh_);
            end
            [maxol, det]=max(ious);
            
            if maxol>olthr
                xi=detections(tt).xi(det);    yi=detections(tt).yi(det);
                bw=detections(tt).wd(det);    bh=detections(tt).ht(det);

                xys(:,1)=[xi,yi,bw,bh];
                ts=tt;
            end            
        end
        
        
        
        sfit=splinefit(t-2:t+1,xys,1);
%         ts=max(1,t-2); tf=min(t+1,F);
        sfit=adjustHypStruct(sfit, ts, tf,  F, 0, sceneInfo, opt);
        nAdded=nAdded+1;
        newH(nAdded)=sfit;
        
    end
    
end

for m=1:nAdded, newH(m).lastused=0; end
