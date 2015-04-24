function Dcost=getSegUnaries(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,opt,sPerFrame)

% precomp
% whether a superpixel is inside hypotheses box

global inanyglob

if size(inanyglob,2) == length(hypotheses) && size(inanyglob,1)==size(ISall,1)
    insideany=inanyglob;
%     fprintf('yay 1\n'); pause
else
%     fprintf('nay 1\n'); pause
%         save('tmploop.mat','ISall','hyps','hypotheses');
%     pause
%     insideany=false(size(ISall,1),length(hypotheses));
%     for t=1:F
%         exhyp=find(hyps.Xi(t,:));
%         %     t
%         %     exhyp
%         %     pause
%         for dd=exhyp
%             %             if dd~=dett, continue; end
%             bh=hyps.H(t,dd); bw=hyps.W(t,dd);
%             bx=hyps.Xi(t,dd)-bw/2;
%             by=hyps.Yi(t,dd)-bh;
%             
%             insidehyp=find(ISall(:,3)==t & ...
%                 ISall(:,4)>=bx & ISall(:,5)>=by & ...
%                 ISall(:,4)<=bx+bw & ...
%                 ISall(:,5)<=by+bh); % inside hyp box
%             insideany(insidehyp,dd)=1;
%             
%         end
%     end

    % mex replacement
    W=hyps.W;H=hyps.H;Xi=hyps.Xi;Yi=hyps.Yi;
    insideany=insideAny(ISall,Xi,Yi,W,H);
    insideany=logical(insideany);
%     isequal(insideany,insideany2)
    
    inanyglob=insideany;
end

% save('tmploop.mat','ISall','insideany','hyps','sp_labels','iminfo','Q','F','sPerFrame','hypotheses');
% pause
DcostOF=getSegUnariesOF(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,sPerFrame,insideany);
DcostCol=getSegUnariesCol(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,sPerFrame,insideany);

lambda=opt.unaryOFFactor;
% TODO: this is actually a free parameter

Dcost=(1-lambda)*DcostCol + lambda*DcostOF;
Dcost=DcostCol + lambda*DcostOF;

% Dcost=DcostCol;