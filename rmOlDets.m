function remDets=rmOlDets(MFTHyps,remDets)
% remove detections already covered by hypotheses


[F,N]=size(MFTHyps.Xi);

tokeep=true(1,length(remDets.xp));

id1=N;
exfr=find(MFTHyps.Xi(:,id1))';
for t=exfr
    
    %                 [t id1 id2]
    w1=MFTHyps.W(t,id1); h1=MFTHyps.H(t,id1);
    x1=MFTHyps.Xi(t,id1)-w1/2; y1=MFTHyps.Yi(t,id1)-h1;
    
    dt=find(remDets.tp==t);
    for d=dt
        w2=remDets.wd(d); h2=remDets.ht(d);
        x2=remDets.xp(d)-w2/2; y2=remDets.yp(d)-h2;
        
        iou=boxiou(x1,y1,w1,h1,x2,y2,w2,h2);

        if iou>.5
            tokeep(d)=false;
        end
    end
    
end

kpidx=find(tokeep);

fields=fieldnames(remDets)';
for f=fields
    cf=char(f);
    
    newField=getfield(remDets,cf);
    newField=newField(kpidx);
    remDets=setfield(remDets,cf,newField);
        
end