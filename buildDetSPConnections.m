function DN=buildDetSPConnections(SN, DcostS, detections, F, ISall,opt)

%%

% global opt
load(opt.objMaskFile);

[mH,mW]=size(objMask);

DN=sparse(size(SN,1),size(SN,2));
detCnt=size(DcostS,2);
for t=1:F
    ndet=length(detections(t).sc);
    
%     clf; 
%     imtight(getFrame(sceneInfo,t));
%     hold on;
    for dd=1:ndet
        %             if dd~=dett, continue; end
        bx=detections(t).bx(dd); by=detections(t).by(dd);
        bh=detections(t).ht(dd); bw=detections(t).wd(dd);
        sc=detections(t).sc(dd); 
        
        
        insidedet=find(ISall(:,3)==t & ...
            ISall(:,4)>bx & ISall(:,5)>by & ...
            ISall(:,4)<bx+bw & ...
            ISall(:,5)<by+bh); % inside det box
        
        detCnt=detCnt+1;
        for idet=insidedet'
            
            mv=ISall(idet,4);
            mu=ISall(idet,5);
            
            %where are we relative in mask?
            mvR = round((mv-bx)/bw * mW);
            muR = round((mu-by)/bh * mH);
            mvR = max(1,mvR); mvR = min(mW,mvR);
            muR = max(1,muR); muR = min(mH,muR);
            w=objMask(muR,mvR);
            
            %     if w>.5, w=10; else, w=0; end
            %     w
            
%                 plot(mv,mu,'.','MarkerSize',40,'color',w*ones(1,3));
%                 text(mv,mu,sprintf('%d',idet));
%                 drawnow
%                 pause
%             DN(idet,detCnt)=1;
%             DN(detCnt,idet)=1;
            
            DN(idet,detCnt)=w*sc;
            DN(detCnt,idet)=w*sc;
                
        end
%         pause
        
    end
end
% hold on


