function segs = segsPerFrame(sp_labels)


F=size(sp_labels,3);
segs=zeros(F,0);

for t=1:F
    thisF=sp_labels(:,:,t);
    tsegs=unique(thisF(:))';
    nsegs=length(tsegs);
    
    segs(t,1)=nsegs;
    segs(t,2:nsegs+1)=tsegs;

end