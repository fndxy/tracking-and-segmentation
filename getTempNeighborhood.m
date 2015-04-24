function TN=getTempNeighborhood(TSP, ISall)
% connect sp in t -- t+1  with same label from TSP

[imgH, imgW, F]=size(TSP);

nVars=size(ISall,1);
vardone=true(1,nVars);

TN=sparse(nVars,nVars);

while any(vardone)
    v=find(vardone,1);
    vTSP=ISall(v,1);
    nb=find(ISall(:,1)==vTSP)';
    nbchain=nb;
%     nbchain
%     pause
    for n=1:length(nbchain)-1
%         [v n]
        LAB1=ISall(nbchain(n),6:8);
        LAB2=ISall(nbchain(n+1),6:8);
        PWCost=1/(1+norm(LAB1-LAB2));
        TN(nbchain(n),nbchain(n+1))=PWCost;
    end
    vardone(nbchain)=0;
end
TN=TN'+TN;

% % % SPPerFrame=zeros(1,F);
% % % for t=1:F,    SPPerFrame(t)=numel(unique(TSP(:,:,t))); end
% % % 
% % % nVars=sum(SPPerFrame);
% % % TN=sparse(nVars,nVars);
% % % 
% % % scnt=0;
% % % for t=1:F-1
% % %     fprintf('.');
% % %     thisF=TSP(:,:,t);
% % %     nextF=TSP(:,:,t+1);
% % %     exseg=unique(thisF(:));
% % %     exseg=reshape(exseg,1,length(exseg));
% % %     for seg=exseg
% % %         scnt=scnt+1;
% % %         [u,v]=find(thisF==seg,1);
% % %         if nextF(u,v)==seg        
% % %             TN(scnt,scnt+min(SPPerFrame(t:t+1)))=1;
% % %         end
% % %     end
% % %     
% % % end
% % % fprintf('\n');
% % % 
% % % TN=TN'+TN;

end