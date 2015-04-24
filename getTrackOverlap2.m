function d=getTrackOverlap2(stateInfo1, stateInfo2, ol)
% compute bounding box overlap for temporal window stitching
% ol is the temporal overlap

[F1,N1]=size(stateInfo1.X);
[F2,N2]=size(stateInfo2.X);

% no overlap
if ~ol, d=[]; return; end


d=Inf*ones(N1,N2);


% targetsExist=getTracksLifeSpans(stateInfo.X);

for id1=1:N1
    for id2=1:N2
        
        locd=0;
        for t2=1:ol
            t1=F1-ol + t2;
%             [id1 id2 t1 t2]
            if stateInfo1.X(t1,id1) && stateInfo2.X(t2,id2)
                w1=stateInfo1.W(t1,id1); h1=stateInfo1.H(t1,id1);
                x1=stateInfo1.Xi(t1,id1)-w1/2; y1=stateInfo1.Yi(t1,id1)-h1;

                w2=stateInfo2.W(t2,id2); h2=stateInfo2.H(t2,id2);
                x2=stateInfo2.Xi(t2,id2)-w2/2; y2=stateInfo2.Yi(t2,id2)-h2;
                                
                iou=boxiou(x1,y1,w1,h1,x2,y2,w2,h2);
                locd=locd+iou;
            end
        end
        
        % if a slightest overlap exists, fuse
        if locd > 0.
            d(id1,id2)=1-(locd/ol);
        end
   
    end
end

% d=1-d;