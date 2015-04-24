%%

%% aux nodes


nH=length(hypotheses);
hyps=getBBoxesFromHyps(hypotheses,F);

maxVal=max(Dcost(:));
[nLabels,nVars]=size(Dcost);

DcostH=zeros(nLabels,0);
% DcostH(1:nLabels+1:nLabels*nLabels)=0;

hcnt=0;
for t=1:F
    exh=find(hyps.Xi(t,:));     
    for id=exh
        hcnt=hcnt+1;
        DcostH(:,hcnt)=maxVal;
        DcostH(id,hcnt)=0;
    end
end

newDcost=[Dcost DcostH];
newVars=size(DcostH,2);


%%

load(opt.objMaskFile);
[mH,mW]=size(objMask);


hcnt=nVars;
HN=sparse(size(SN,1),size(SN,2));
for t=1:F
    exh=find(hyps.Xi(t,:));
    clf;    imtight(getFrame(sceneInfo,t));     hold on
     
    for id=exh
        bw=hyps.W(t,id);
        bh=hyps.H(t,id);
        bx=hyps.Xi(t,id)-bw/2;
        by=hyps.Yi(t,id)-bh;                
        
        insidedet=find(ISall(:,3)==t & ...
            ISall(:,4)>bx & ISall(:,5)>by & ...
            ISall(:,4)<bx+bw & ...
            ISall(:,5)<by+bh); % inside det box
        
        col=getColorFromID(id);
        rectangle('Position',[bx,by,bw,bh],'EdgeColor',col);
        
        hvarC=[bx+bw/2, by-20];
        plot(hvarC(1),hvarC(2),'o','color',col,'MarkerSize',25);
        
        hcnt=hcnt+1;
        for idet=insidedet'
            mv=ISall(idet,4);
            mu=ISall(idet,5);
            
            col=getColorFromID(id);
            if labeling(idet)==21, col=[0 0 0]; end
            
            %where are we relative in mask?
            mvR = round((mv-bx)/bw * mW);
            muR = round((mu-by)/bh * mH);
            mvR = max(1,mvR); mvR = min(mW,mvR);
            muR = max(1,muR); muR = min(mH,muR);
            w=objMask(muR,mvR);

            
%             line([mv hvarC(1)],[mu hvarC(2)]);
%             w
            plot(mv,mu,'.','color',col,'MarkerSize',25*(w+.1));

            

            HN(idet,hcnt)=w;
            HN(hcnt,idet)=w;
%             sum(HN(:))
            
%             pause
        end

%         pause
        
        
    end
end

newNVars=size(HN,1);


SN(nVars+1:newNVars,nVars+1:newNVars)=0; % empty connections for hyps
TN(nVars+1:newNVars,nVars+1:newNVars)=0; % empty connections for hyps
DN(nVars+1:newNVars,nVars+1:newNVars)=0; % empty connections for hyps


Nhood.SN=SN; Nhood.TN=TN; Nhood.DN=DN; Nhood.HN=HN;

NB=floor(opt.pwSSP*Nhood.SN + opt.pwTSP*Nhood.TN + opt.pwDetSP*Nhood.DN + 100*Nhood.HN);
