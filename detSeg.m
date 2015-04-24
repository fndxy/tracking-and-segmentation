%% get segments from center regions of confident detections (Top 50%)
[alldetscores, scidx]=sort(alldpoints.sp,'descend');
thresh=alldetscores(round(length(alldetscores)/2));
% thresh=-Inf;
fprintf('Confident detections are above %.2f\n',thresh);
clf;

    featidx=[6:8];
    if isfield(opt,'spfeat2')
        featidx=[opt.spfeat2];
    end
    
showsamples=0;
allpos=false(1,size(ISall,1));
allneg=false(1,size(ISall,1));

getRandomNegSamples;
allneg(allnegrand)=1;

% whether a superpixel is inside any detection
insideany=false(size(ISall,1),1);
for t=1:F
    ndet=length(detections(t).sc);
    for dd=1:ndet
        %             if dd~=dett, continue; end
        bx=detections(t).bx(dd); by=detections(t).by(dd);
        bh=detections(t).ht(dd); bw=detections(t).wd(dd);
        insidedet=find(ISall(:,3)==t & ...
            ISall(:,4)>bx & ISall(:,5)>by & ...
            ISall(:,4)<bx+bw & ...
            ISall(:,5)<by+bh); % inside det box
        insideany(insidedet)=1;

    end
end

for d=1:round(length(alldetscores)/2)
    fprintf('.');
    insidethis=[];
    
    t=alldpoints.tp(scidx(d));
    frT=t;
    %     if t>1, continue; end
    allt=find(alldpoints.tp==t);
    dett=find(detections(t).xp==alldpoints.xp(scidx(d)));
    if length(dett)>1, dett=dett(1); end
    
    if showsamples
        im=iminfo(t).img;
        imtight(im);
        hold on
    end
    
    bxi=detections(t).bx(dett);
    byi=detections(t).by(dett);
    wi=detections(t).wd(dett);
    hi=detections(t).ht(dett);
    
    bxo=bxi-wi/2;    byo=byi-wi/2;    wo=wi*2;    ho=hi*3/2;
    brd=min(wi,hi);
    bxo=bxi-brd;    byo=byi-brd;    wo=wi+2*brd;    ho=hi+2*brd;
    %     bxo=1; byo=1; wo=sceneInfo.imgWidth; ho=sceneInfo.imgHeight;
    
    if showsamples
        rectangle('Position',[bxi,byi,wi,hi],'linewidth',2);
        rectangle('Position',[bxo,byo,wo,ho],'EdgeColor','w','linewidth',2);
    end
    
    insideib=find(ISall(:,3)==t & ISall(:,4)>bxi & ISall(:,5)>byi & ISall(:,4)<bxi+wi & ISall(:,5)<byi+hi); % inside inner box
    insideob=find(ISall(:,3)==t & ISall(:,4)>bxo & ISall(:,5)>byo & ISall(:,4)<bxo+wo & ISall(:,5)<byo+ho); % inside outer box
    if length(insideib)<2 || length(insideob)<5, continue; end
    
    % straight forward
    keep=setdiff(insideob,insideib);
    
    % discard others
% % %     keep=insideob;
% % %     keepl=false(size(ISall,1),1);
% % %     keepl(insideob)=1;
% % %     for qc=insideob'
% % %         xc=ISall(qc,4);
% % %         yc=ISall(qc,5);
% % %         ndet=length(detections(t).sc);
% % %         for dd=1:ndet
% % %             %             if dd~=dett, continue; end
% % %             bx=detections(t).bx(dd); by=detections(t).by(dd);
% % %             bh=detections(t).ht(dd); bw=detections(t).wd(dd);
% % %             
% % %             vertOL = (xc>bx && xc<bx+bw);
% % %             horzOL = (yc>by && yc<by+bh);
% % %             if vertOL && horzOL
% % % %                 keep=setdiff(keep,qc);
% % %                 keepl(qc)=0;
% % %                 %                             break;
% % %             end
% % %             if dd==dett && vertOL && horzOL
% % %                 %                 insidethis=[insidethis qc];
% % %                 
% % % %                 keep=setdiff(keep,qc);
% % %                 keepl(qc)=0;
% % %             end
% % %             if showsamples
% % %                 rectangle('Position',[bx,by,bw,bh]);
% % %             end
% % %         end
% % %         %         plot(ISall(keep,4),ISall(keep,5),'o');
% % %         %         pause
% % %         
% % %         
% % %     end
% % %     
% % %     if showsamples
% % %         plot(ISall(keep,4),ISall(keep,5),'o');
% % %         pause
% % %     end
% % %     
% % %     keep=find(keepl);
    keepn=false(size(ISall,1),1);
    keepn(insideob)=1;
    keepn(insideany)=0;
    keep=find(keepn);
%     isequal(keep,keepn)
%     pause
    
    % TODO FIX
    if length(keep)<5
        continue;
    end
    
    
    NWords=ISall(keep,featidx);
    Fean=ISall(keep,featidx)';
    nPointsn = size(Fean,2);
    allneg(keep)=1;
    
    %% Cluster negatives
    Mn=min(nPointsn,5);
    [CXn, sse] = vgg_kmeans(Fean, Mn,'maxiters',100,'verbose',0);
    
    
    
    % Compute distance
%     Wd=zeros(nPointsn,Mn);
%     for p = 1:nPointsn
%         for c = 1:Mn
%             Wd(p,c) = norm(CXn(:,c) - Fean(:,p));
%         end
%     end
    
    Wd = sqrt(bsxfun(@plus,full(dot(CXn,CXn,1)),full(dot(Fean,Fean,1))')-full(2*(Fean'*CXn)));
%     absdiff=abs(Wd-Wdd); sum(absdiff(:))
    
    % Now find the closest center for each point
    [mindis, IDXn] = min(Wd,[],2);
    
    % determine prior
    % clpriorc=histc(IDXn,linspace(.5,Mn-.5,Mn))';
    clprior=zeros(1,Mn);
    for c = 1:Mn
        findIDX=find(IDXn==c);
        
        
        clprior(c) = numel(findIDX);
        %     clprior(c) = mean(NWords(findIDX,6))/1000;
    end
    
    % TODO: Can a cluster end up empty?
    clprior(find(~clprior))=1;
    
    %%
    % vectorized
    % Copyright (c) 2009, Michael Chen
    % All rights reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted provided that the following conditions are
    % met:
    %
    %     * Redistributions of source code must retain the above copyright
    %       notice, this list of conditions and the following disclaimer.
    %     * Redistributions in binary form must reproduce the above copyright
    %       notice, this list of conditions and the following disclaimer in
    %       the documentation and/or other materials provided with the distribution
    %
    % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    % AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    % IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    % ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
    % LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    % CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    % SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    % INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    % CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    % ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    % POSSIBILITY OF SUCH DAMAGE.
    Feap=ISall(:,featidx)';
    
    W1 = bsxfun(@plus,full(dot(CXn,CXn,1)),full(dot(Feap,Feap,1))')-full(2*(Feap'*CXn));
    
    W2=sqrt(W1);
    prM=repmat(-1./clprior,size(W2,1),1);
    W=exp(prM .* W2);
    
    
    % loop
    % W=zeros(nPointsp,Mn);
    % for pi = 1:nPointsp
    %     for pj = 1:Mn
    %         W(pi,pj) = exp(-1/clprior(pj) * 1*norm(Feap(1:3,pi) - CXn(1:3,pj)));
    %         %         W(pi,pj) = exp(-1 * norm(Feap(1:3,pi) - CXn(1:3,pj)));
    %     end
    % end
    
    %
    QC=1-max(W'); QC=QC';
    
    QD=ones(size(QC));
    % superTubeWeighting;
    QC=QC.*QD;
    
    % QC=QC./max(QC(:));
    % Q=1./(1+exp(-10*Q+5));
    sigA=.5; sigB=10;
    % QC=1./(1+exp(-sigB*Q+sigA*sigB));
    % [min(QC(:)) max(QC(:))]
    
    % Q=.5*(Q+QM);
    % Q=max(QC,QM);
    Q=QC;
    % Q=Q.*QM;
    
    % Qsrt=sort(Q,'descend');
    % [Qsrt, srtIdx]=sort(Q,'ascend');
    % perc=50; % upper percent to consider
    % thr=Qsrt(round((100-perc)/100*length(Qsrt))); % highest
    % lower=Q<thr; higher=Q>thr;
    % allpos=higher;
    %
    % thr=Qsrt(round(perc/100*length(Qsrt))); % lowest
    % lower=Q<thr; higher=Q>thr;
    % allneg=lower;
    
    % Q(:)=.5;Q(allpos)=1; Q(allneg)=0;
    
    % sort sp inside current det and take best n % as pos
    [Qsrt, srtIdx]=sort(Q(insideib),'ascend');
    thr=Qsrt(round(.95*length(Qsrt)));
    
    outsidethis=setdiff(1:size(ISall,1),insideib);
    Q(outsidethis)=0;
    Q(Q<thr)=0;
    % allpos=[allpos find(Q>thr)'];
    
    allpos(find(Q>=thr))=1;
    % Q(Q>thr)=1;
    % Q(:)=0;
    % Q(insidethis)=1;
    
    
    
    % tmpdetSegCRF
    
    %%
    if 1 && showsamples
        tt=frT;
        cnt=0;
        for t=1:tt%F
            clf
            fprintf('.');
            thisF=sp_labels(:,:,t);
            ndet=length(detections(t).sc);
            %     im=getFrame(sceneInfo,t);
            im=iminfo(t).img;
            npix=size(im,1)*size(im,2);
            segs=unique(thisF(:))';
            
            
            %     w=getGaussMasks(im,detections(t));
            Itmpc=rgb2gray(zeros(size(im)));
            Itmp=rgb2gray(zeros(size(im)));
            
            %     Itmp=im;
            for s=segs
                cnt=cnt+1;
                if t~=tt, continue; end
                
                [u,v]=find(thisF==s);
                spLH=Q(cnt);
                %         spLH=spLH*QD(cnt);
                %         spLH=Q(cnt)*w(round(mean(u)),round(mean(v)));
                %         spLH
                %         spLH=Q(cnt)+w(round(mean(u)),round(mean(v)));
                imind=sub2ind(size(thisF),u,v);
                Itmp(imind)=spLH;
                %         Itmpc(imind)=QC(cnt);
                %         Q(cnt)=spLH;
                %         imtight(Itmp);
                %         Q(cnt)
                %         pause
            end
            Ifin=.2*rgb2gray(im)+.8*Itmp;
            imtight(Ifin,[0 1]);
            %     imwrite(Itmpc,sprintf('tmp/hyp/s%02d-f%04d-lhco.jpg',scenario,sceneInfo.frameNums(t)));
            imwrite(Ifin,sprintf('tmp/detseg/s%02d-f%04d-lh.jpg',scenario,sceneInfo.frameNums(t)));
            
            pause(.01);
            %     pause
        end
        pause
        fprintf('\n');
    end
end
fprintf('\n');