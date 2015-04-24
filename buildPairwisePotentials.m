function [Scost, SN, TN, DN, Nhood, NB]= ...
    buildPairwisePotentials(DcostS, DcostD, F, SPPerFrame, sceneInfo, seqinfo, sp_labels, ISall, opt, detections)

% build spatial and temporal pairwise neighborhood

[nLabels,nVars]=size(DcostS);


Scost=1-1*eye(nLabels);
SN=sparse(nVars,nVars);

for t=1:F
%     fprintf('.');
    if t==1, lbegin=1;
    else lbegin=sum(SPPerFrame(1:t-1))+1;
    end
    lend=sum(SPPerFrame(1:t));
    
    im=getFrame(sceneInfo,t);
    %     nSeg=getNeighboringSuperpixels(Iunsp(:,:,t)+1);
    nSeg=seqinfo(t).nSegUnsp;
    %     nWeights = getNeighborWeights(nSeg,Iunsp(:,:,t)+1,im);
    nWeights = seqinfo(t).nWeights;
    SN(lbegin:lend,lbegin:lend)=nWeights;
    
end
fprintf('\n');

% pause
TN=getTempNeighborhood(sp_labels,ISall);
% TN(:)=0;

SN(end+1:end+size(DcostD,2),end+1:end+size(DcostD,2))=0; % empty connections for dets
TN(end+1:end+size(DcostD,2),end+1:end+size(DcostD,2))=0;


DN=buildDetSPConnections(SN, DcostS, detections, F, ISall);

Nhood.SN=SN; Nhood.TN=TN; Nhood.DN=DN;


NB=floor(opt.pwSSP*Nhood.SN + opt.pwTSP*Nhood.TN + opt.pwDetSP*Nhood.DN) ;


% NB(end+1:end+size(DcostD,2),end+1:end+size(DcostD,2))=0;
% NB(~NB)=opt.pairwiseFactor;
