% find connected components in TSP

cc=[];
ncc=0;
for t=1:20
    imseg=sp_labels(:,:,t)+1;
    nSeg=getNeighboringSuperpixels(imseg);
    
    for s=seg
        if ~isempty(intersect(s,figureSP))
            % found a target segment
            % what are its neighbors?
            nb = find(nSeg(s,:));
            nb = [nb find(nSeg(:,s))];
            
            % is any of the neighbors in a cluster?
            foundNC=[];
            for nc=1:ncc
                if ~isempty(intersect(cc(nc).ids,nb))
                    foundNC=nc;
                end
            end
            if ~isempty(foundNC)
                cc(foundNC).ids=[cc(foundNC).ids nb s];
            else
                ncc=ncc+1;
                cc(ncc).ids=[cc(ncc).ids nb s];
            end
            
        end
    end
    
end