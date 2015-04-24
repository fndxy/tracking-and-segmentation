function Dcost=getSegUnariesCol(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,sPerFrame,insideany,opt)

% global opt

if opt.nolog
    Dcost=getSegUnariesColNOLOG(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,sPerFrame,insideany);
    return;
end

nVars=length(Q);
nLabels=length(hypotheses)+1;
bglabel=nLabels;
Dcost=zeros(nLabels,nVars);
cnt=0;
maxEn=1000;
% fprintf('Unaries');

% length(hypotheses)
% hyps


load(opt.objMaskFile);

[mH,mW]=size(objMask);

% save('tmploop.mat','F','sPerFrame','ISall','insideany','opt','hyps','Q','sPerFrame','objMask');
% pause
% % % for t=1:F
% % % %     fprintf('.');
% % %     thisF=sp_labels(:,:,t);
% % % %     im=getFrame(sceneInfo,t);
% % %     im=iminfo(t).img;
% % %     npix=size(im,1)*size(im,2);
% % % %     segs=unique(thisF(:))';
% % %     nsegs=sPerFrame(t,1);
% % %     segs=sPerFrame(t,2:nsegs+1);
% % % 
% % %     for s=segs
% % %         cnt=cnt+1;
% % % %         [u,v]=find(thisF==s);
% % % %         imind=sub2ind(size(thisF),u,v);
% % % %         mu=mean(u); mv=mean(v);
% % %         mu=ISall(cnt,5);mv=ISall(cnt,4);
% % % 
% % %         relevantSP=find(insideany(cnt,:));
% % % %         for l=1:nLabels-1
% % %         for l=relevantSP
% % % %             if l==nLabels
% % %                 
% % % %             else
% % % %                 bw=hyps.W(t,l);bh=hyps.H(t,l);
% % % %                 x1=hyps.Xi(t,l)-bw/2;
% % % %                 y1=hyps.Yi(t,l)-bh;
% % % %                 x2=hyps.Xi(t,l)+bw/2;
% % % %                 y2=hyps.Yi(t,l);
% % % %                 
% % % %                 if mv>=x1 && mv<=x2 && mu>=y1 && mu<=y2
% % % %                 if insideany(cnt,l)
% % %                                     bw=hyps.W(t,l);bh=hyps.H(t,l);
% % %                 x1=hyps.Xi(t,l)-bw/2;
% % %                 y1=hyps.Yi(t,l)-bh;
% % % 
% % %                     %% gauss weighting
% % % %                     SIG=[(bh/2)^2*2 0; 0 (bw/2)^2/2];
% % % %                     MU=[y1+bh/2 x1+bw/2];
% % % %                     x=[mu mv];
% % %                     
% % % %                     sa=SIG(1,1); sb=SIG(2,1); sc=SIG(1,2); sd=SIG(2,2);
% % % 
% % % %                     detSIG=sa*sd - sb*sc;                    
% % % %                     normfac=1/(2*pi*sqrt(detSIG));
% % %                     
% % % %                     w=mvnpdf(x,MU,SIG)/normfac;
% % % 
% % %                     %% prior mask weighting
% % %                     w=1;
% % %                     %where are we relative in mask?
% % %                     mvR = round((mv-x1)/bw * mW);
% % %                     muR = round((mu-y1)/bh * mH);
% % %                     mvR = max(1,mvR); mvR = min(mW,mvR);
% % %                     muR = max(1,muR); muR = min(mH,muR);
% % %                     w=objMask(muR,mvR);
% % % %                     pause
% % %                     
% % %                     
% % % 
% % %                     Dcost(l,cnt)=Q(cnt)*w;
% % % %                 end
% % %                 
% % % %             end
% % %         end
% % %         Dcost(nLabels,cnt)=1-Q(cnt);        
% % %     end
% % % end

% mex replacement
W=hyps.W;H=hyps.H;Xi=hyps.Xi;Yi=hyps.Yi;
Dcost = unariesCol(ISall,insideany,Xi,Yi,W,H,objMask,Q);
% absdiff=abs(Dcost-Dcost2); sum(absdiff(:))

Dcost=-log(Dcost);Dcost(Dcost>maxEn)=maxEn;
% fprintf('\n');