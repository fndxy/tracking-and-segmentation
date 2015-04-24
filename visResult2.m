function visResult2(stateInfo, sp_labels, iminfo)
%% vis result
alphablend=0.5;
cnt=0;
if usejava('desktop'), clf; end



F=size(stateInfo.Xi,1);
labeling=stateInfo.splabeling;
bglabel=stateInfo.bglabel;
finallab=setdiff(labeling,bglabel);
sceneInfo=stateInfo.sceneInfo;

detcnt=0;
for t=1:F
    thisF=sp_labels(:,:,t);
    %     im=getFrame(sceneInfo,t);
    im=iminfo(t).img;
    npix=size(im,1)*size(im,2);
    segs=unique(thisF(:))';
    Itmp=zeros(size(im));
    Itmp=im;
    
    tpos=[];
    Io=zeros(size(im(:,:,1)));
    for s=segs
        cnt=cnt+1;
        l=labeling(cnt);
        col=getColorFromID(l);
        if l==bglabel, continue; end
        
        [u,v]=find(thisF==s);
        imind=sub2ind(size(thisF),u,v);
        Io(imind)=l;
        
        Itmp(imind)=col(1);        Itmp(imind+npix)=col(2);        Itmp(imind+npix*2)=col(3);
        
        %         tpos(seg,1)=mean(v);
        %         tpos(seg,2)=mean(u);
    end
    
    edges=getEdges(Io,1);
    [u,v]=find(edges);imind=sub2ind(size(edges),u,v);
    Ifin=(1-alphablend)*Itmp+alphablend*im;
    Ifin(imind)=1;    Ifin(imind+npix)=1;    Ifin(imind+npix*2)=1;
    
    %     for seg=segs
    %         if seg==1, continue; end
    %         text(tpos(seg,1),tpos(seg,2),sprintf('%d',seg-1),'color','w','FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
    %     end
    
    if usejava('desktop')
        %         clf;
        imtight(Ifin);
        
        segs=unique(Io(:))';
        for s=segs
            if s==0, continue; end
            [u,v]=find(Io==s);
            imind=sub2ind(size(Io),u,v);
            mx=mean(v);        my=mean(u);
%             text(mx,my,sprintf('%d',s),'color','w','FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
        end
        
        for l=finallab
            bw=stateInfo.W(t,l);bh=stateInfo.H(t,l);
            if ~bw, continue; end
            x1=stateInfo.Xi(t,l)-bw/2;
            y1=stateInfo.Yi(t,l)-bh;
            x2=stateInfo.Xi(t,l)+bw/2;
            y2=stateInfo.Yi(t,l);
            col=getColorFromID(l);
            %         l
            %         col
            %         pause
            if bw<0, warning('negative width'); end
            bw=abs(bw)+.1; bh=abs(bh)+.1;
            rectangle('Position',([x1,y1,bw,bh]),'EdgeColor',col,'linewidth',1);
            
            %         gaitFreq=1;
            %         xc=stateInfo.Xi(t,l); yc=stateInfo.Yi(t,l)-bh/2;
            %         legLength=bh/2;
            %         maxDeg=15*pi/180;
            %
            %         gait=sin(gaitFreq*(t+l)/pi);
            %         xe=legLength*sin(gait*maxDeg)+xc;        ye=+legLength*cos(gait*maxDeg)+yc;
            %         xe2=-legLength*sin(gait*maxDeg)+xc;
            %
            %         line([xc xe],[yc, ye],'color',col)
            %         line([xc xe2],[yc, ye],'color',col)
            
            %         rectangle('Position',abs([x1,y1-20,30,20]),'EdgeColor',col,'linewidth',3);
            text(x1+4,y1+10,sprintf('%d',l),'color',col,'FontWeight','bold');
            %         pause
        end
        
        %% detections boxes
        
%         ndet=length(detections(t).sc);        
%         for dd=1:ndet
%             detcnt=detcnt+1;
% %             if dd~=dett, continue; end
%             bx=detections(t).bx(dd); by=detections(t).by(dd);
%             bh=detections(t).ht(dd); bw=detections(t).wd(dd);
%             
%             detID=newlab(detcnt);
%             col=getColorFromID(newlab(detcnt));
%             ls='--';
%             if detID==bglabel, col=zeros(1,3); ls=':'; end
%             
% %             rectangle('Position',[bx,by,bw,bh],'EdgeColor',col,'LineStyle',ls);            
% %             text(bx+4,by-10,sprintf('%d',detcnt),'color',col,'FontWeight','bold');
%         end
        
        
        im2save=getframe(gcf);
        im2save=im2save.cdata;
        if t==1, im2save(1:50,1:50,:)=0; end % new batch
        if t==F, im2save(1:50,1:50,:)=255; end % end batch
        imwrite(im2save,sprintf('tmp/res/s%02d-f%04d.jpg',sceneInfo.scenario,sceneInfo.frameNums(t)));
        %     end
    else
        lw=0; % in each dir
        for l=finallab
            bw=stateInfo.W(t,l);bh=stateInfo.H(t,l);
            if ~bw, continue; end
            x1=stateInfo.Xi(t,l)-bw/2;
            y1=stateInfo.Yi(t,l)-bh;
            x2=stateInfo.Xi(t,l)+bw/2;
            y2=stateInfo.Yi(t,l);
            col=getColorFromID(l);
            x1=abs(x1);x2=abs(x2);y1=abs(y1);y2=abs(y2);
            
            x1=max(1+lw,round(x1)); x2=min(round(x2)-lw,size(Ifin,2));
            y1=max(1+lw,round(y1)); y2=min(round(y2)-lw,size(Ifin,1));
            vertIdx=y1:y2; horIdx=x1:x2;
            vertIdx=vertIdx(vertIdx>0);
            vertIdx=vertIdx(vertIdx<size(Ifin,1));
            horIdx=horIdx(horIdx>0);
            horIdx=horIdx(horIdx<size(Ifin,2));
            
            %             rectangle('Position',([x1,y1,bw,bh]),'EdgeColor',col,'linewidth',3);
            if ~isempty(vertIdx) && ~isempty(horIdx)
                for c=1:3
                    Ifin(vertIdx,x1-lw:x1+lw,c)=col(c);
                    Ifin(vertIdx,x2-lw:x2+lw,c)=col(c);
                    Ifin(y1-lw:y1+lw,horIdx,c)=col(c);
                    Ifin(y2-lw:y2+lw,horIdx,c)=col(c);
                end
            end
        end
        if t==1, Ifin(1:50,1:50,:)=0; end % new batch
        if t==F, Ifin(1:50,1:50,:)=1; end % end batch
        imwrite(Ifin,sprintf('tmp/res/s%02d-f%04d.jpg',scenario,sceneInfo.frameNums(t)));
    end
    pause(.01);
end