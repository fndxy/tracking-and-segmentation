function avgMinDetDistF = avgMinDetDist(detections)
%% average min distance between detections for each frame

% [alldetscores, scidx]=sort(alldpoints.sp,'descend');
% thresh=alldetscores(round(length(alldetscores)/2));
thresh=-Inf;

F=length(detections);
meanMinD=zeros(1,F);
for t=1:F
    ndet=length(detections(t).bx);
    alld=Inf*ones(ndet,ndet);
    for d1=1:ndet
        sizeD1=mean([detections(t).wd(d1),detections(t).ht(d1)]);
        if detections(t).sc(d1)<thresh, continue; end
        for d2=d1+1:ndet            
            if detections(t).sc(d2)<thresh, continue; end
            sizeD2=mean([detections(t).wd(d2),detections(t).ht(d2)]);
            
            meanSize=mean([sizeD1,sizeD2]);
            alld(d1,d2)=norm([detections(t).bx(d1) detections(t).by(d1)]- ...
                [detections(t).bx(d2) detections(t).by(d2)]) / meanSize;
            
        end
    end
    allMinDInFrame=min(alld);
    allMinDInFrame=allMinDInFrame(~isinf(allMinDInFrame));
    meanMinD(t)=mean(allMinDInFrame);
end
meanMinD=meanMinD(~isnan(meanMinD));
avgMinDetDistF=mean(meanMinD);
% alld


%
% v1=[detections(1).bx; detections(1).by];
% v2=[detections(1).bx; detections(1).by];
% Wd=bsxfun(@plus,full(dot(v1,v1,1)),full(dot(v2,v2,1))')-full(2*(v2'*v1));
% Wd=sqrt(Wd)