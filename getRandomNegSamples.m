%% get some random negatives
NWords=[];

nPointsn=5000;
nPCollected=0;
% sUsed=zeros(F,1000);
randcnt=0;
randorder=randperm(size(ISall,1));
allnegrand=false(size(ISall,1),1);

% whether a superpixel is inside any detection
spSize = sqrt(opt.nSP); % quick estimate of sp diameter
insideany=false(size(ISall,1),1);
for t=1:F
    ndet=length(detections(t).sc);
    for dd=1:ndet
        %             if dd~=dett, continue; end
        bx=detections(t).bx(dd); by=detections(t).by(dd);
        bh=detections(t).ht(dd); bw=detections(t).wd(dd);
        insidedet=find(ISall(:,3)==t & ...
            ISall(:,4)+spSize>bx & ISall(:,5)+spSize>by & ...
            ISall(:,4)-spSize<bx+bw & ...
            ISall(:,5)-spSize<by+bh); % inside det box
        insideany(insidedet)=1;

    end
end


% speed up by precomputing
thisFs=[];
for t=1:F
    thisFs(t).data=uint16(sp_labels(:,:,t));
end
nAllSP=size(ISall,1);
while nPCollected<nPointsn
    if ~mod(nPCollected,1000), fprintf('.'); end
%     if all([SPPicked(:).picked]), fprintf('ALL PIXELS SAMPLED!!!\n'); break; end
    
    
    
%     t=randi(length(frames));
    
    randcnt=randcnt+1;
    
    if randcnt>=nAllSP,  fprintf('ALL PIXELS SAMPLED!!!\n'); break; end
    
    randpick=randorder(randcnt);
% % %     t=ISall(randpick,3);
% % %     
% % % %     thisF=sp_labels(:,:,t);
% % %     thisF=thisFs(t).data;
% % % %     segF=unique(thisF(:));
% % % 
% % %     segF=seqinfo(t).segF;
% % %     nSegF=length(segF);
% % % %     randinSegF=randi(nSegF); 
% % %     randinSegF=ISall(randpick,2)+1;
% % %     
% % % %     randSeg=segF(randinSegF);
% % %     randSeg=uint16(ISall(randpick,1));    
% % %     
% % %     
% % % %     if SPPicked(t).picked(randinSegF), a=1, continue; end
% % %     

    
    
% % %     [u,v]=find(thisF==randSeg);
% % %     if isempty(u), continue; end %BUG? TODO
% % %     
% % %     imind=sub2ind(size(thisF),u,v);
% % %     
% % %     
% % %     SPPicked(t).picked(randinSegF)=1;
% % % %     imind_=IMIND(randSeg+1,2:IMIND(randSeg+1,1)+1)';
% % % 
% % % 
% % %     % check for overlap with each detection
% % %     % conservatively with SP's axis-aligned bounding box
% % %     overlap=0;
    
% % % %     if numel(u)<detections(t).wd(1)*detections(t).ht(1)
% % %         left=min(v);right=max(v);
% % %         top=min(u); bottom=max(u);
% % %         
% % %         ndet=length(detections(t).sc);
% % %         for d=1:ndet
% % %             bx=detections(t).bx(d); by=detections(t).by(d);
% % %             bh=detections(t).ht(d); bw=detections(t).wd(d);
% % %             
% % %             vertOL = (left>bx && left<bx+bw) || (right>bx && right<bx+bw);
% % %             horzOL = (top>by && top<by+bh) || (bottom>by && bottom<by+bh);
% % %             if vertOL && horzOL
% % %                 overlap=1;
% % %                 break;
% % %             end
% % %         end
% % % %     end
    if insideany(randpick), continue; end
    
    % if overlap with a detection, ignore superpixel
%     if overlap, continue;  end
    
    % otherwise create new word
%     [u,v]=find(thisF==randSeg);
%     imind=sub2ind(size(thisF),u,v);
%     imind=IMIND(randSeg+1,2:IMIND(randSeg+1,1)+1)';

%     im=getFrame(sceneInfo,t);
    
    
%     sUsed(t,randinSegF)=sUsed(t,randinSegF)+1;
    
%     im=iminfo(t).img;
%         imol=im;
%         imol(imind)=1;
%         imol(imind+npix)=0;
%         imol(imind+npix*2)=0;
%         imtight(imol);
%         pause

    allnegrand(randpick)=1;

    nPCollected=nPCollected+1;
end
fprintf('\n');



fprintf('%d collected\n',nPCollected);
