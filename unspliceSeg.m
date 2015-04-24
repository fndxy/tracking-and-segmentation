function I=unspliceSeg(imseg)
% take a multi-frame segmentation and
% create a unique one for each frame

I=zeros(size(imseg));

[imgH, imgW, F]=size(imseg);

for t=1:F    
    fprintf('.');
    thisF=imseg(:,:,t);
    exseg=unique(thisF(:));
    exseg=reshape(exseg,1,length(exseg));
    
    scnt=0;
    Itmp=zeros(size(thisF));
    for id=exseg
        
        [u,v]=find(thisF==id);
        imind=sub2ind(size(thisF),u,v);
        Itmp(imind)=scnt;
        scnt=scnt+1;
    end
%     u=unique(Itmp)'; u(1)
    I(:,:,t)=Itmp;
end
fprintf('\n');