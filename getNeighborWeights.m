function nWeights = getNeighborWeights(NB, imsp, im)
% compute cost of pairwise edges (CRF)
%   NB      - sparse neighborhood matrix
%   imsp    - super-pixel segmentation
%   im      - true RGB image

nSeg = size(NB,1);
% nWeights=sparse(size(NB,1),size(NB,2));
nWeights=zeros(size(NB,1),size(NB,2));
npix = numel(imsp);

spind=zeros(nSeg,npix+1);
% spindv=sparse(nSeg,npix);
LABs=zeros(nSeg,3);
for sp1=1:nSeg
    [u1,v1]=find(imsp==sp1);
    imind1=sub2ind(size(imsp),u1,v1);
    nim=length(imind1);
    spind(sp1,1:nim+1)=[nim imind1'];
    
    meanR=mean(im(imind1));
    meanG=mean(im(imind1+npix));
    meanB=mean(im(imind1+2*npix));
    LABs(sp1,:)=squeeze(RGB2Lab(meanR, meanG, meanB));
end

for sp1=1:nSeg
%     [u1,v1]=find(imsp==sp1);
%     imind1=sub2ind(size(imsp),u1,v1);
    imind1=spind(sp1,2:spind(sp1,1)+1)';
%     imind1=find(spind(sp1,:))';
    
    meanR=mean(im(imind1));
    meanG=mean(im(imind1+npix));
    meanB=mean(im(imind1+2*npix));
%     LAB1=squeeze(RGB2Lab(meanR, meanG, meanB));
    LAB1=LABs(sp1,:);
    
    exnb=find(NB(sp1,:));
    for sp2=exnb
        if sp2<=sp1, continue; end
%         if ~NB(sp1,sp2), continue; end
%         [u2,v2]=find(imsp==sp2);
%         imind2=sub2ind(size(imsp),u2,v2);
        imind2=spind(sp2,2:spind(sp2,1)+1)';
%         meanR=mean(im(imind2));
%         meanG=mean(im(imind2+npix));
%         meanB=mean(im(imind2+2*npix));
%         LAB2=squeeze(RGB2Lab(meanR, meanG, meanB));
        LAB2=LABs(sp2,:);
        
        PWCost=1/(1+norm(LAB1-LAB2));

%         clf;
%         imtmp=zeros(size(imsp));
        
%         imtmp(imind1)=.2;
%         imtmp(imind2)=.8;
%         imtight(.5*im+.5*repmat(imtmp,1,1,3))
%         text(20,20,sprintf('%.2f',PWCost),'color','w');
%         pause
        
        nWeights(sp1,sp2)=PWCost;
    end
end

nWeights=nWeights+nWeights';