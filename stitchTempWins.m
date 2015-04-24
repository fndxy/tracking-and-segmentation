%% new way for stitching
function stateInfo=stitchTempWins(allstInfo,allwins,detections,sp_labels)

fprintf('stitching temporal windows...\n');

% newState gradually grows to include all temp. windows
newState=allstInfo(1);
newState.detlabeling(newState.detlabeling==newState.bglabel)=0;
newState.splabeling(newState.splabeling==newState.bglabel)=0;

nWins=size(allwins,1);
for w=1:nWins-1
    % DEBUG OUTPUT
    
%     global gtInfo
%     sceneInfo=getSceneInfo(71);
%     size(newState.X,1)
%     sceneInfo.frameNums=sceneInfo.frameNums(1:size(newState.X,1));
%     gtInfo=cropFramesFromGT(sceneInfo,gtInfo,1:size(newState.X,1));
%     displayTrackingResult(sceneInfo,newState);

    
    stInfo1=allstInfo(w);    stInfo2=allstInfo(w+1);
    [F1,N1]=size(newState.X);    [F2,N2]=size(stInfo2.X);
    

    % length of temp. win. overlap (assumes no frame jumping)
    winolap=length(intersect(newState.frameNums,stInfo2.frameNums));
    fr1=F1-winolap+1:F1; fr2=1:winolap; % relative frames
   
    % similarity matrix
    d=getTrackOverlap2(newState, stInfo2, winolap);
    
    % Compute best matching with Hungarian algo
    [Matching,Cost]=Hungarian(d);
    
    [u,v]=find(Matching);
    tomerge=[u v];
    if isempty(tomerge), tomerge=[]; end % to prevent 1-by-0 error below
%     Matching
    tomerge
% tomerge=[];

    
    mergepairs(w).tomerge=[u v];
%     Matching
    
    % all up to current window
%     tmpState=newState;
    
    % now 'attach' new window
    [F1,N1]=size(newState.X);
    [F2,N2]=size(stInfo2.X);
    
    % first take care of those that merge
    newTargetsTakenCareOf=false(1,N2);
    fprintf('fusing... ')
    for tm=1:size(tomerge,1)        
        matchToPrev=tomerge(tm,1);
        matchFromNext=tomerge(tm,2);
        fprintf('(%d,%d), ',matchToPrev,matchFromNext);
%         if matchToPrev==17 && matchFromNext==10
%             global ns si2 g1 g2
%             ns=newState; si2=stInfo2; g1=fr1; g2=fr2;
%             pause
%         end
        newState=fuseTracks(newState, stInfo2, matchToPrev, matchFromNext, fr1,fr2);
        newTargetsTakenCareOf(matchFromNext)=1;
    end
    fprintf('done\n');
    
    % now just append the rest
    newfr1=fr1(end)+1:fr1(end)+F2-winolap;
    newfr2=fr2(end)+1:F2;

    fprintf('adding... ')
    matchToPrev=N1;
    for id2=find(~newTargetsTakenCareOf)
        % append rest
        
        matchToPrev=matchToPrev+1;
        fprintf('(%d,%d), ',matchToPrev,id2);

        assert(length(newfr1)==length(newfr2),'overlap must be equal in both windows');
        newState=appendState(newState,stInfo2,newfr1,newfr2,matchToPrev,id2);
    end
    fprintf('done\n');
    
    % special case, new window is empty solution, fill previous with zeros
    if ~N2
        fields={'X','Y','Xi','Yi','W','H','Xgp','Ygp'};        
        for f=fields
            cf=char(f);
            if isfield(newState,cf)
                eval(sprintf('newState.%s(newfr1,:)=0;',cf));
            end
        end
    end
    
    % continuous state has been merged
    % now the other stuff
    
    newState.frameNums=[newState.frameNums stInfo2.frameNums(newfr2)];
    newState.opt.frames=[newState.opt.frames stInfo2.opt.frames(newfr2)];
    
    % detection labeling
    newDetTimes=allwins(w+1,1)+newfr2-1;
    windetAll=length(stInfo2.detlabeling);  % number of all dets in window
    windetNew=length([detections(newDetTimes).xp]);% number of new (not temp. overlapped detections)
    
    winSPAll=length(stInfo2.splabeling);
    winSPNew=0;
    for t=newDetTimes
        winSPNew=winSPNew+numel(unique(sp_labels(:,:,t)));
    end

    % negative trick to prevent double switching
    newDetLabeling=stInfo2.detlabeling;
    newSPLabeling=stInfo2.splabeling;
%     newDetLabeling(newDetLabeling==stInfo2.bglabel)=newbglabel;
    newDetLabeling(newDetLabeling==stInfo2.bglabel)=0;
    newSPLabeling(newSPLabeling==stInfo2.bglabel)=0;
     matchToPrev=N1;
   for id2=find(~newTargetsTakenCareOf)                
        matchToPrev=matchToPrev+1;
        newDetLabeling(newDetLabeling==id2)=-matchToPrev;
        newSPLabeling(newSPLabeling==id2)=-matchToPrev;
    end
    for tm=1:size(tomerge,1)
        matchToPrev=tomerge(tm,1);
        matchFromNext=tomerge(tm,2);
        newDetLabeling(newDetLabeling==matchFromNext)=-matchToPrev;
        newSPLabeling(newSPLabeling==matchFromNext)=-matchToPrev;
    end

    
    % bg label    
    
    newDetLabeling=abs(newDetLabeling(windetAll-windetNew+1:windetAll));    
    newSPLabeling=abs(newSPLabeling(winSPAll-winSPNew+1:winSPAll));    
%     
    newState.detlabeling=[newState.detlabeling newDetLabeling];
    newState.splabeling=[newState.splabeling newSPLabeling];
    
    % refit hypotheses start/end
    for id2=1:length(stInfo2.hypotheses)        
        stInfo2.hypotheses(id2).start=stInfo2.hypotheses(id2).start+allwins(w+1,1)-1;
        stInfo2.hypotheses(id2).end=stInfo2.hypotheses(id2).end+allwins(w+1,1)-1;
        stInfo2.hypotheses(id2).breaks=stInfo2.hypotheses(id2).breaks+allwins(w+1,1)-1;
        stInfo2.hypotheses(id2).bspline.knots=stInfo2.hypotheses(id2).bspline.knots+allwins(w+1,1)-1;
    end
    newState.hypotheses=[newState.hypotheses stInfo2.hypotheses];
    
end

% bg label
newState.bglabel=size(newState.X,2)+1;
newState.detlabeling(newState.detlabeling==0)=newState.bglabel;
newState.splabeling(newState.splabeling==0)=newState.bglabel;
newState.F=size(newState.X,1);
newState.allwins=allwins;
newState.allstInfo=allstInfo;  % REMOVE! ONLY FOR DEBUG

% stitcheddetlab=newState.detlabeling;
stateInfo=newState;
% stateInfo.detlabeling=stitcheddetlab;
fprintf('done\n');

% remove negative width boxes
minH=0;
stateInfo=fixStateInfo(stateInfo,minH);