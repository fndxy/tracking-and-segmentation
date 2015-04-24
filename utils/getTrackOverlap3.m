function d=getTrackOverlap3(stateInfo1, stateInfo2)
% compute track overlap (for determining goodness of fit)
% stateInfo1 = hyps
% stateInfo2 = GT

[F1,N1]=size(stateInfo1.W);
[F2,N2]=size(stateInfo2.W);

ids1=1:N1;
ids2=1:N2;

% allSt=[];
% fields={'X','Y','Xi','Yi','W','H','Xgp','Ygp'};
% for f=fields
%     cf=char(f);
%     if isfield(hyp,cf) && isfield(gtInfo,cf)
%         newfield=[getfield(gtInfo,cf),getfield(hyp,cf)];
%         allSt=setfield(allSt,cf,newfield);        
%     end
% end


N1=length(ids1);
N2=length(ids2);
% ollength=F;

if ~N1 || ~N2 , d=[]; return; end


d=0*ones(N1,N2);


% targetsExist=getTracksLifeSpans(stateInfo1.X);

for id1=ids1
    for id2=ids2
        
        locd=0;
        exfr=find(stateInfo2.W(:,id2))';
        Fi=length(exfr);
        for t=exfr
            if stateInfo1.W(t,id1)
%                 [t id1 id2]
                w1=stateInfo1.W(t,id1); h1=stateInfo1.H(t,id1);
                x1=stateInfo1.Xi(t,id1)-w1/2; y1=stateInfo1.Yi(t,id1)-h1;

                w2=stateInfo2.W(t,id2); h2=stateInfo2.H(t,id2);
                x2=stateInfo2.Xi(t,id2)-w2/2; y2=stateInfo2.Yi(t,id2)-h2;
                                
%                 [x1,x2,w1,h1,x2,y2,w2,h2]
                iou=boxiou(x1,y1,w1,h1,x2,y2,w2,h2);
                locd=locd+iou;
%                 [t id1 id2]
%                 locd
%                 pause
            end
        end
        
        % if a slightest overlap exists, try to connect
        if locd
            
            d(id1,id2)=(locd/Fi);
        end
   
    end
end

% d=1-d;