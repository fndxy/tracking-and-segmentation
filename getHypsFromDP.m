function hyps=getHypsFromDP(stateInfo,frames,T,sceneInfo, opt)
% TODO, comment


newmods=0;

hyps=getHypStruct;

X=stateInfo.Xi;
Y=stateInfo.Yi;
W=stateInfo.W;
H=stateInfo.H;

[Fgt, Ngt]=size(X);
if length(frames)<Fgt
    X=X(frames,:); Y=Y(frames,:); W=W(frames,:);H=H(frames,:);
end

exttail=5;
exthead=5;
for id=1:Ngt
    
    
    cptimes=find(X(:,id));
    if length(cptimes)>3
        %% extend to first and last frame
        ff=cptimes(1);  lf=cptimes(end); trl=lf-ff;
        ncps=max(opt.minCPs,round(trl*opt.ncpsPerFrame));
%         ncps=4;
        
        torig=cptimes';
        xys=[X(cptimes,id) Y(cptimes,id) W(cptimes,id) H(cptimes,id)]';

        
        ttail=cptimes(1:4);
        xystail=[X(ttail,id) Y(ttail,id) W(ttail,id) H(ttail,id)]';
        
%         if length(unique(ttail))>2
%             tailline=splinefit(ttail,xystail,1,4);
%             taillinepts=ppval(tailline,torig(1)-exttail);
%             
%             xys=[taillinepts xys];
%             cptimes=[cptimes(1)-exttail; cptimes];
%         end
%         thead=cptimes(end-3:end);
%         xyshead=[X(thead,id) Y(thead,id) W(thead,id) H(thead,id)]';
%         
%         if length(unique(thead))>2
%             headline=splinefit(thead,xyshead,1,4);
%             headlinepts=ppval(headline,torig(end)+exthead);
%             
%             xys=[xys headlinepts];
%             cptimes=[cptimes; cptimes(end)+exthead];
%         end
        
%         cptimes=find(X(:,id));
        % cptimes
        
        %     cps
        newmods=newmods+1;
        %     cptimes'
        sfit=splinefit(cptimes,xys,ncps);        
        sfit=adjustHypStruct(sfit, ff, lf,  T, 0, sceneInfo, opt);
        
        hyps(newmods)=sfit;

    end
end

for m=1:length(hyps), hyps(m).lastused=0; end

end