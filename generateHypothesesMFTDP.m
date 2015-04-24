%% function generateHypothesesMFT
% generate hypotheses from a model free tracker


clear MFTHypsDP
MFTHypsDP.Xi=[];MFTHypsDP.Yi=[];MFTHypsDP.W=[];MFTHypsDP.H=[];
MFTHypsDP.frameNums=sceneInfo.frameNums;
maxDPH=opt.maxMFTDPHyp;
DPHAdded=0;
for d=1:size(startPT.Xi,2)
    if DPHAdded>=maxDPH
        break; 
    end
    fprintf('.');
    
    exfr=find(startPT.Xi(:,d));
    
    for frT=[exfr(1), exfr(end)]
        %     if t>1, continue; end
        
        
        
        if frT==F || frT==1, continue; end
        
        [x, y, w, h]=getBBox(startPT,frT,d);
        
        initBox=[x,y,w,h,frT,F];
        
        bb=justTrack(sceneInfo,initBox,[],[]);
        
        %% augment with visual tracker
        bb=bb(2:end,:);
        wt=bb(:,3);    ht=bb(:,4);
        xt=bb(:,1)+wt/2;
        yt=bb(:,2)+ht;
        
        newfr=frT+1:F;
        
        N=size(MFTHypsDP.Xi,2);
        MFTHypsDP.Xi(newfr,N+1)=xt;
        MFTHypsDP.Yi(newfr,N+1)=yt;
        MFTHypsDP.W(newfr,N+1)=wt;
        MFTHypsDP.H(newfr,N+1)=ht;
        
        %%%%%%%%%%%%% backwards
        initBox=[x,y,w,h,frT,1];
        bb=justTrack(sceneInfo,initBox,[],[]);
        bb=flipud(bb);
        bb=bb(2:end,:);
        wt=bb(:,3);    ht=bb(:,4);
        xt=bb(:,1)+wt/2;
        yt=bb(:,2)+ht;
        newfr=1:frT-1;
        
        MFTHypsDP.Xi(newfr,N+1)=xt;
        MFTHypsDP.Yi(newfr,N+1)=yt;
        MFTHypsDP.W(newfr,N+1)=wt;
        MFTHypsDP.H(newfr,N+1)=ht;
        
        N=size(MFTHypsDP.Xi,2);
        DPHAdded=DPHAdded+1;
        
        [maxOL,bestFit]=evaluateHypothesesSet(MFTHypsDP,gtInfo);
    end
    
    
    
end


hypothesesMFTDP=getHypsFromDP(MFTHypsDP,frames,F,sceneInfo,opt);