function [nSeg,nSeg2]=getNeighboringSuperpixels(imseg)
% compute neighboring superpixels (4-neighborhood)

% npix=prod(size(imseg));
segs=unique(imseg(:))';


% nSeg=sparse(length(segs),length(segs));
nSeg=zeros(length(segs));
% length(segs)
% tic
% naive double loop
for y=1:size(imseg,1)-1 % for each row
    for x=1:size(imseg,2)-1 % for each col
        thiss=imseg(y,x);
        rights=imseg(y,x+1);
        bots=imseg(y+1,x);
%         disp([y x thiss rights bots])
%         pause
        if thiss~=rights
            nSeg(thiss,rights)=1; 
        end
        
        if thiss~=bots
            nSeg(thiss,bots)=1;
        end
    end
end

nSeg=nSeg+nSeg';
nSeg=~~nSeg;
% toc
nSeg2=[];
% nSeg2=sparse(length(segs),length(segs));

% % % tic
% scanline search
% % % 
% % % % horizontal lines
% % % for y=1:size(imseg,1) % for each row
% % %     rowSP=unique(imseg(y,:),'stable');
% % %     rowSP=reshape(rowSP,1,length(rowSP));
% % % %     rowSP
% % % %     pause
% % %     for s=1:length(rowSP)-1        
% % %         nSeg2(rowSP(s),rowSP(s+1))=1;
% % %     end
% % % end
% % % 
% % % % vertical lines
% % % for x=1:size(imseg,2) % for each column
% % %     colSP=unique(imseg(:,x),'stable');
% % %     colSP=reshape(colSP,1,length(colSP));
% % %     for s=1:length(colSP)-1        
% % %         nSeg2(colSP(s),colSP(s+1))=1;
% % %     end
% % % end
% % % 
% % % size(nSeg)
% % % size(nSeg2)
% % % nSeg2=nSeg2+nSeg2';
% % % % nSeg2=~~nSeg2;
% % % 
% % % toc
% % % 
% % % assert(isequal(nSeg,nSeg2));
end