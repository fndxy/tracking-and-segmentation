function [ISall,IMIND]=combineAllIndices(TSP,Iunsp,sceneInfo,flowinfo,iminfo)
% a helper lookup table
% ISall(k,1) = TSP
% ISall(k,2) = Iunsp
% ISall(k,3) = frame
% ISall(k,4) = mean x (v)
% ISall(k,5) = mean y (u)
% ISall(k,6) = mean L
% ISall(k,7) = mean a
% ISall(k,8) = mean b
% ISall(k,9) = mean flowX
% ISall(k,10) = mean flowY
% ISall(k,11) = size
% ISall(k,12-20) = LabBB
% where k is the k-th variable (super-pixel)

[imh, imw, F]=size(TSP);
npix=imw*imh;
nVars=0;
for t=1:F
    nVars=nVars+numel(unique(TSP(:,:,t)));
end
ISall=zeros(nVars,11);
IMIND=zeros(nVars,0,'uint32'); % size of largest SP unknown

toolarge=0;
maxMB=200;

scnt=0;
for t=1:F
    fprintf('.');
    
    thisF1=TSP(:,:,t);
    exseg=unique(thisF1(:));
    exseg=reshape(exseg,1,length(exseg));

    thisF2=Iunsp(:,:,t);
    exseg2=unique(thisF2(:));
    exseg2=reshape(exseg2,1,length(exseg2));
    
    assert(length(exseg)==length(exseg2),'Hmm... TSP, Iunspl');

    % flow %%%    
    if t==1
        flow2=flowinfo(t+1);
        meanflowX=flow2.flow.fvx;
        meanflowY=flow2.flow.fvy;
        
    elseif t==F
        flow1=flowinfo(t);
        meanflowX=-flow1.flow.bvx;
        meanflowY=-flow1.flow.bvy;        
    else
        flow1=flowinfo(t);
        flow2=flowinfo(t+1);
        
        meanflowX=.5*(-flow1.flow.bvx+flow2.flow.fvx);
        meanflowY=.5*(-flow1.flow.bvy+flow2.flow.fvy);
    end
    %%% flow %%%
    
    im=getFrame(sceneInfo,t);
    for seg=1:length(exseg)
        scnt=scnt+1;
        ISall(scnt,1)=exseg(seg);
        ISall(scnt,2)=exseg2(seg);
        ISall(scnt,3)=t;
        
        [u1,v1]=find(thisF1==exseg(seg));
        imind1=sub2ind(size(thisF1),u1,v1);
        
        tableSize=nVars*(length(imind1)+1); % number of entries
        tsMB=tableSize*4/1024/1024; % table size in MB
        if tsMB>maxMB
            toolarge=1;
        end
        
        if toolarge
            IMIND=[];
        else
            IMIND(scnt,1)=length(imind1);
            IMIND(scnt,2:length(imind1)+1)=imind1;
        end

        ISall(scnt,4:5) = [mean(v1); mean(u1)];
        meanR=mean(im(imind1));
        meanG=mean(im(imind1+npix));
        meanB=mean(im(imind1+2*npix));
        ISall(scnt,6:8)=reshape(squeeze(RGB2Lab(meanR, meanG, meanB)),1,3);

        ISall(scnt,9)=mean(meanflowX(imind1));
        ISall(scnt,10)=mean(meanflowY(imind1));
        
        ISall(scnt,11)=numel(imind1);

    end
    
    
end
fprintf('\n');

%%% EXPERIMENTAL
% spBoxFeatures;
% ISall=[ISall LabBB1 LabBB2 LabBB3];


end