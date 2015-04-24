%% function generateHypothesesMFT
% generate hypotheses from a model free tracker

[alldetscores, scidx]=sort(alldpoints.sp,'descend');

remDets=alldpoints;

clear MFTHyps

MFTHyps.Xi=zeros(F,0);MFTHyps.Yi=zeros(F,0);MFTHyps.W=zeros(F,0);MFTHyps.H=zeros(F,0);
MFTHyps.frameNums=sceneInfo.frameNums;
maxMFT=opt.maxMFTHyp;


MAXHYPLENGTH=F; % x 2 (forw. + backw.)

    
% for d=1:min(maxMFT,round(length(alldetscores)/2))
for dd=1:maxMFT
    fprintf('.');
    if length(scidx)<length(alldpoints.xp)/10, break; end
    d=1;
    t=remDets.tp(scidx(d));
    
    frT=t;
    %     if t>1, continue; end
%     allt=find(remDets.tp==t);
%     dett=find(detections(t).xp==remDets.xp(scidx(d)));
%     if length(dett)>1, dett=dett(1); end

%     x=detections(t).bx(dett);
%     y=detections(t).by(dett);
%     w=detections(t).wd(dett);
%     h=detections(t).ht(dett);
    bestIdx=scidx(1);
    x=remDets.bx(bestIdx);
    y=remDets.by(bestIdx);
    w=remDets.wd(bestIdx);
    h=remDets.ht(bestIdx);
    
%     if t==F || t==1, continue; end
    
    FF=min(F,frT+MAXHYPLENGTH);
    initBox=[x,y,w,h,frT,FF];
    bb=justTrack(sceneInfo,initBox,[],[]);
    
    %% augment with visual tracker
%     bb=bb(2:end,:);
    wt=bb(:,3);    ht=bb(:,4);
    xt=bb(:,1)+wt/2;
    yt=bb(:,2)+ht;
    
    newfr=frT:FF;
    
    N=size(MFTHyps.Xi,2);
    MFTHyps.Xi(newfr,N+1)=xt;
    MFTHyps.Yi(newfr,N+1)=yt;
    MFTHyps.W(newfr,N+1)=wt;
    MFTHyps.H(newfr,N+1)=ht;

    %%%%%%%%%%%%% backwards
    ff=max(1,frT-MAXHYPLENGTH);
    initBox=[x,y,w,h,frT,ff];
    bb=justTrack(sceneInfo,initBox,[],[]);
    bb=flipud(bb);
    bb=bb(2:end,:);
    wt=bb(:,3);    ht=bb(:,4);
    xt=bb(:,1)+wt/2;
    yt=bb(:,2)+ht;
    
    
    newfr=ff:frT-1;
    
    MFTHyps.Xi(newfr,N+1)=xt;
    MFTHyps.Yi(newfr,N+1)=yt;
    MFTHyps.W(newfr,N+1)=wt;
    MFTHyps.H(newfr,N+1)=ht;
    
    N=size(MFTHyps.Xi,2);
    
    
    
    remDets=rmOlDets(MFTHyps,remDets);
    
%     [maxOL,bestFit]=evaluateHypothesesSet(MFTHyps,gtInfo);
    MFTHyps=trimHyp(MFTHyps,N,sceneInfo);    
    [maxOL,bestFit]=evaluateHypothesesSet(MFTHyps,gtInfo);
    
    
    [alldetscores, scidx]=sort(remDets.sp,'descend');
    fprintf('Dets left: %d\n',length(remDets.xp));
    detNew=detStructToArray(remDets,F);
%     displayDetectionBBoxes(sceneInfo,detNew);

%     pause
    

end
hypothesesMFTH=getHypsFromDP(MFTHyps,frames,F,sceneInfo,opt);