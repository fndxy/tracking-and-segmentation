function Icomb=combineSegs2(TSP,labeling,IMIND, SPPerFrame)
% combine into consistent labeling sequence

[imgH, imgW, F]=size(TSP);
Icomb=zeros(size(TSP));
scnt=0;
for t=1:F
    %     fprintf('.');
    if isempty(IMIND)
        thisF=TSP(:,:,t);
    end
    %     npix=prod(size(thisF));
    %     exseg=unique(thisF(:));
    %     exseg=reshape(exseg,1,length(exseg));
    
    
    Itmp=zeros(imgH,imgW);
    %     Itmpc=repmat(zeros(size(thisF)),1,1,3);
    %     for seg=exseg
    for seg=1:SPPerFrame(t)
        scnt=scnt+1;
        id=labeling(scnt);
        
        if isempty(IMIND)
            [u,v]=find(thisF==seg);
            imind=sub2ind(size(thisF),u,v);
        else
            imind=IMIND(scnt,2:IMIND(scnt,1)+1)';
        end
        %         isequal(imind,imind_)
        
        Itmp(imind)=id;
    end
    
    pause(.01);
    Icomb(:,:,t)=Itmp;
    
end


% fprintf('\n');