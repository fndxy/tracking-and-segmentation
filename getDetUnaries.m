function Dmat=getDetUnaries(detections,hypotheses,hyps,allpoints,opt)

if opt.nolog
    Dmat=getDetUnariesNOLOG(detections,hypotheses,hyps,allpoints,opt);
    return;
end


dphi=opt.detOutlierCost;
uF=opt.detUnaryFactor;

maxCost=1000;
nLabels=length(hypotheses);
falseAlarmLabel=nLabels+1;
Dmat=zeros(falseAlarmLabel,length(allpoints.xp));
% Dmat=maxCost*ones(falseAlarmLabel,length(allpoints.xp));

% boxcnt=0;
for l=1:nLabels
    h=hypotheses(l);
    splstart=h.start;
    splend=h.end;
    
    for t=splstart:splend
        w1=hyps.W(t,l);        h1=hyps.H(t,l);
        x1=hyps.Xi(t,l)-w1/2;        y1=hyps.Yi(t,l)-h1;
        ndet=length(detections(t).sc);        
        for dd=1:ndet
%             boxcnt=boxcnt+1;
            bx=detections(t).bx(dd); by=detections(t).by(dd);
            bh=detections(t).ht(dd); bw=detections(t).wd(dd);
%             boxcnt=find(allpoints.xp==detections(t).xp(dd));
%             boxcnt
%             boxcnt=find(allpoints.tp==t);
%             boxcnt
            boxcnt=find(allpoints.xp==detections(t).xp(dd) & allpoints.tp==t);
%             boxcnt
%             pause

%             vertOL = (xc>bx && xc<bx+bw);
%             horzOL = (yc>by && yc<by+bh);
%             if vertOL && horzOL
                x2=bx; y2=by; w2=bw; h2=bh;
                
                % quick overlap check
                if x1+w1<x2, biou=0;
                elseif x2+w2<x1, biou=0;
                elseif x1>x2+w2, biou=0;
                elseif x2>x2+w2, biou=0; %%%
                elseif y1+h1<y2, biou=0;
                elseif y2+h2<y1, biou=0;
                elseif y1>y2+h2, biou=0;
                elseif y2>y2+h2, biou=0;
                else
                    
%                 [l t boxcnt]
                    biou=boxiou(x1,y1,w1,h1,x2,y2,w2,h2);
                end
                
%                 if biou>0
                    Dmat(l,boxcnt)=biou;
                    
%                 end
%                 biou
%                 -log(biou)
%                 Dmat(l,boxcnt)
%                 pause
%             end

        end
        
    end
end
Dmat=-uF * log(Dmat);

Dmat(falseAlarmLabel,:)=-dphi* log((1-allpoints.sp));
Dmat(Dmat>1000)=1000;