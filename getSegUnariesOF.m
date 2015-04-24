function Dcost=getSegUnariesOF(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,sPerFrame,insideany,opt)
% unaries according to optic flow (super-tubes)

nVars=length(Q);
nLabels=length(hypotheses)+1;
bglabel=nLabels;
maxEn=1000;

Dcost=maxEn*ones(nLabels,nVars);
cnt=0;
% fprintf('Unaries');

% clear dHyps
dHyps=getHypStruct;
for h=1:length(hypotheses), dHyps(h)=ppdiff(hypotheses(h)); end
dhyps=getBBoxesFromHyps(dHyps,F);


                W=hyps.W;H=hyps.H;
                Xi=hyps.Xi;Yi=hyps.Yi;
                X1=hyps.Xi-W./2;
                Y1=hyps.Yi-H;
                X2=hyps.Xi+W./2;
                Y2=hyps.Yi;
                
allnorms=sqrt(ISall(:,9).^2+ISall(:,10).^2);

% global opt
load(opt.objMaskFile);

[mH,mW]=size(objMask);

% save('tmploop.mat','F','sPerFrame','ISall','insideany','dhyps','opt','hyps','Q','sPerFrame','objMask');
% pause
% % % for t=1:F
% % % %     fprintf('.');
% % %     thisF=sp_labels(:,:,t);
% % % %     im=getFrame(sceneInfo,t);
% % %     im=iminfo(t).img;
% % %     npix=size(im,1)*size(im,2);
% % % %     segs=unique(thisF(:))';
% % %         nsegs=sPerFrame(t,1);
% % %     segs=sPerFrame(t,2:nsegs+1);
% % % 
% % %     for s=segs
% % %         cnt=cnt+1;
% % % %         [u,v]=find(thisF==s);
% % % %         imind=sub2ind(size(thisF),u,v);
% % % %         mu=mean(u); mv=mean(v);
% % % %         thisT=ISall(cnt,3);
% % % %         thisSP=ISall(cnt,1);
% % % %         nextQ=find(ISall(:,1)==thisSP & ISall(:,3)==t+1);
% % % %         if isempty(nextQ)
% % % %             Dcost(bglabel,cnt)=1-Q(cnt);
% % % %             continue;
% % % %         end
% % %           
% % %         mu=ISall(cnt,5);mv=ISall(cnt,4);
% % % %         mu2=ISall(nextQ,5);mv2=ISall(nextQ,4);
% % % %         vy=mu2-mu; vx=mv2-mv;
% % % 
% % % 
% % %         vx=ISall(cnt,9); vy=ISall(cnt,10);
% % %         
% % %         
% % % 
% % %         relevantSP=find(insideany(cnt,:));
% % % %         for l=1:nLabels-1
% % % 
% % %         for l=relevantSP
% % % %             if l==nLabels
% % % %                 Dcost(l,cnt)=1-Q(cnt);
% % % %                 Dcost(l,cnt)=norm([vx vy]);
% % %                 
% % % %             else
% % % %                 bw=hyps.W(t,l);bh=hyps.H(t,l);
% % % %                 bw=W(t,l); 
% % % %                 xi=Xi(t,l);yi=Yi(t,l);
% % % %                 x1=Xi(t,l)-bw/2;
% % % %                 if mv>=x1
% % % %                     x2=Xi(t,l)+bw/2;                    
% % % %                     if mv<=x2
% % % %                         bh=H(t,l);
% % % %                         y1=Yi(t,l)-bh;
% % % %                         if mu>=y1
% % % %                             y2=Yi(t,l);
% % % %                             if mu<=y2
% % %                 
% % %                 
% % %                 
% % % %                 xi=hyps.Xi(t,l);yi=hyps.Yi(t,l);
% % % %                 x1=hyps.Xi(t,l)-bw/2;
% % % %                 y1=hyps.Yi(t,l)-bh;
% % % %                 x2=hyps.Xi(t,l)+bw/2;
% % % %                 y2=hyps.Yi(t,l);
% % % %                 xc=xi; yc=yi-bh/2;
% % % 
% % %                 
% % %                 
% % % %                 if mv>=x1 && mv<=x2 && mu>=y1 && mu<=y2
% % %                     
% % % %                         dhyp=[0 1];
% % % %                 dhyp=ppval(ppdiff(hypotheses(l)),t);
% % % %                 vxh=dhyp(1);vyh=dhyp(2);
% % %                     vxh=dhyps.Xi(t,l);
% % %                     vyh=dhyps.Yi(t,l)-dhyps.H(t,l)/2;
% % % %                     vxh=0; vyh=0;
% % %                     
% % % %                     bw2=hyps.W(t+1,l);bh2=hyps.H(t+1,l);
% % % %                     x12=hyps.Xi(t+1,l)-bw2/2;
% % % %                     y12=hyps.Yi(t+1,l)-bh2;
% % % %                     xc2=hyps.Xi(t+1,l); yc2=hyps.Yi(t+1,l)-bh2/2;
% % %                     
% % % %                     vyh=y12-y1; vxh=x12-x1;
% % % %                     vyh=yc2-yc; vxh=xc2-xc;
% % %                     
% % %                     vdiff=norm([vx vy]-[vxh vyh]);
% % % %                         vdiff=0;
% % % %                     [cnt l]
% % % %                     [vx vy]
% % % %                     [vxh vyh]
% % % %                     vdiff
% % % %                     pause
% % % 
% % % 
% % %                     w=1;
% % %                     
% % %                     if opt.ofmask
% % %                         %where are we relative in mask?                    
% % %                         bw=W(t,l); bh=H(t,l);
% % %                         x1=Xi(t,l)-bw/2; y1=Yi(t,l)-bh;
% % % 
% % %                         mvR = round((mv-x1)/bw * mW);
% % %                         muR = round((mu-y1)/bh * mH);
% % %                         mvR = max(1,mvR); mvR = min(mW,mvR);
% % %                         muR = max(1,muR); muR = min(mH,muR);
% % %                         w=objMask(muR,mvR);
% % %                     end
% % %                     
% % %                     Dcost(l,cnt)=w*vdiff;   
% % % %                             end
% % % %                         end
% % % %                     end
% % % %                 end
% % %                 
% % % 
% % % %                 end
% % %                 
% % % %             end
% % %         end
% % %         Dcost(nLabels,cnt)=allnorms(cnt);
% % %     end
% % % end

% mex replacement
dX = dhyps.Xi;
dY = dhyps.Yi - dhyps.H ./ 2;
Dcost = unariesOF(ISall,insideany,Xi,Yi,W,H,dX,dY,objMask,allnorms,[opt.ofmask,maxEn]);
% absdiff=abs(Dcost-Dcost2);assert(sum(absdiff(:)) < 1e-5);

Dcost(Dcost>maxEn)=maxEn;
% fprintf('\n');