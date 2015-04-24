function newH=breakHyp(hypotheses, used, sceneInfo, opt, currentEnergy, ISall, Q)
%% break at low evidence regions

% id=2;
F=length(sceneInfo.frameNums);
hyps=getBBoxesFromHyps(hypotheses,F);

newH=getHypStruct;
addedBroken=0;
% precomp
% whether a superpixel is inside hypotheses box
% insideany=false(size(ISall,1),length(hypotheses));
% for t=1:F
%     exhyp=find(hyps.Xi(t,:));
%     
%     for dd=exhyp
%         %             if dd~=dett, continue; end
%         bh=hyps.H(t,dd); bw=hyps.W(t,dd);
%         bx=hyps.Xi(t,dd)-bw/2;
%         by=hyps.Yi(t,dd)-bh;
%         
%         insidehyp=find(ISall(:,3)==t & ...
%             ISall(:,4)>=bx & ISall(:,5)>=by & ...
%             ISall(:,4)<=bx+bw & ...
%             ISall(:,5)<=by+bh); % inside hyp box
%         insideany(insidehyp,dd)=1;
%         
%     end
% end

nH=length(hypotheses);
global inanyglob
if size(inanyglob,2) == nH && size(inanyglob,1)==size(ISall,1)
    insideany=inanyglob;
else
%     save('tmploop.mat','ISall','hyps','hypotheses');
%     pause

%     insideany=false(size(ISall,1),length(hypotheses));
%     for t=1:F
%         exhyp=find(hyps.Xi(t,:));
% 
%         for dd=exhyp
%             %             if dd~=dett, continue; end
%             bh=hyps.H(t,dd); bw=hyps.W(t,dd);
%             bx=hyps.Xi(t,dd)-bw/2;
%             by=hyps.Yi(t,dd)-bh;
% 
%             insidehyp=find(ISall(:,3)==t & ...
%                 ISall(:,4)>=bx & ISall(:,5)>=by & ...
%                 ISall(:,4)<=bx+bw & ...
%                 ISall(:,5)<=by+bh); % inside hyp box
%             insideany(insidehyp,dd)=1;
% 
%         end
%     end


    % mex replacement
    W=hyps.W;H=hyps.H;Xi=hyps.Xi;Yi=hyps.Yi;
    insideany=insideAny(ISall,Xi,Yi,W,H);
    insideany=logical(insideany);
    inanyglob=insideany;
end




%%
N=length(hypotheses);
fglik=zeros(N,F);

nUsed=length(used);
if nUsed>1
    for id=randperm(nUsed)
        if addedBroken>=opt.maxBreak, break; end
        % for id=1:N
        %     clf;
        %     hold on
        h=hypotheses(id);
        
        exfr=h.start:h.end;
        for t=exfr
            
            fglik(id,t)=sum(Q(find(insideany(:,id) & ISall(:,3)==t)')');
            
        end
        
        maxval=max(fglik(id,exfr));    minval=min(fglik(id,exfr));
        valrange=maxval-minval;
        lthr=(minval+valrange/3);
        hthr=(minval+2*valrange/3);
        %     col=getColorFromID(id);
        %     plot(exfr,fglik(id,exfr),'color',col);
        %     plot(exfr,mean(fglik(id,exfr))*ones(1,length(exfr)),'--','color',col);
        %     plot(exfr,(minval+valrange/3)*ones(1,length(exfr)),'.-','color',col);
        %     plot(exfr,(minval+2*valrange/3)*ones(1,length(exfr)),'.-','color',col);
        %     plot(exfr,median(fglik(id,exfr))*ones(1,length(exfr)),':','color',col);
        %     xlim([0 51]);
        %     ylim([0 10]);
        %     pause
        
        trst=0;
        t=exfr(1);
        if fglik(id,t)<lthr, trst=-1;
        elseif fglik(id,t)>hthr, trst=1;
            %     else trst=0;
        end
        prtrst=trst;
        conftrack=false(1,F);
        conftrack(t)=trst>0;
        for t=exfr(2:end)
            
            
            if fglik(id,t)<lthr, trst=-1;
            elseif fglik(id,t)>hthr, trst=1;
                %         else trst=0;
            end
            conftrack(t)=trst>0;
            %         [t trst]
            %         pause
            
        end
        %     conffr=find(conftrack);
        %     plot(conffr,fglik(id,conffr),'color',col,'linewidth',3);
        %     pause
        trstarts=find(diff([0 conftrack])==1);
        trends=find(diff([conftrack 0])==-1);
        nconftracks=length(trstarts);
        for n=1:nconftracks
            tt=trstarts(n):trends(n);
            if length(tt)>=4
                xy=ppval(h,tt); %pts on spline
                tr=tt;
                sfit=splinefit(tr,xy,round(max(opt.minCPs,(tr(end)-tr(1))*opt.ncpsPerFrame )));
                sfit=adjustHypStruct(sfit, min(tt), max(tt), F, 0, sceneInfo, opt);
                
                if ~any(isnan(sfit.coefs(:)))
                    addedBroken=addedBroken+1;
                    newH(addedBroken) = sfit;
                end
                
                
            end
            %         plot(tt,fglik(id,tt),'color',rand(1,3),'linewidth',4);
            %         pause
        end
        
        trst=0;
        t=exfr(end);
        if fglik(id,t)<lthr, trst=-1;
        elseif fglik(id,t)>hthr, trst=1;
            %     else trst=0;
        end
        prtrst=trst;
        conftrack=false(1,F);
        conftrack(t)=trst>0;
        for t=exfr(end-1:-1:1)
            
            
            if fglik(id,t)<lthr, trst=-1;
            elseif fglik(id,t)>hthr, trst=1;
                %         else trst=0;
            end
            conftrack(t)=trst>0;
            %         [t trst]
            %         pause
            
        end
        %     conffr=find(conftrack);
        %     plot(conffr,fglik(id,conffr),'color',col,'linewidth',4);
        %     pause
        
        trstarts=find(diff([0 conftrack])==1);
        trends=find(diff([conftrack 0])==-1);
        nconftracks=length(trstarts);
        for n=1:nconftracks
            tt=trstarts(n):trends(n);
            if length(tt)>=4
                xy=ppval(h,tt); %pts on spline
                tr=tt;
                sfit=splinefit(tr,xy,round(max(opt.minCPs,(tr(end)-tr(1))*opt.ncpsPerFrame )));
                sfit=adjustHypStruct(sfit, min(tt), max(tt), F, 0, sceneInfo, opt);
                
                if ~any(isnan(sfit.coefs(:)))
                    addedBroken=addedBroken+1;
                    newH(addedBroken) = sfit;
                end
            end
            %         plot(tt,fglik(id,tt),'color',rand(1,3),'linewidth',4);
            %         pause
        end
        
    end
end

allNewLCost=[newH.labelCost];
newH=newH(currentEnergy>allNewLCost);



for m=1:length(newH), newH(m).lastused=0; end


end
