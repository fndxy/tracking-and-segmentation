function hyps=getBBoxesFromHyps(hypotheses,F)
% get bounding boxes (volumetric tubes)
% from spline structs

global sceneInfo
%
hyps.Xi=zeros(F,0);hyps.Yi=zeros(F,0);
hyps.H=zeros(F,0);hyps.W=zeros(F,0);

 for h=1:length(hypotheses)
     hyp=hypotheses(h);
     fr=hyp.start:hyp.end;
     xys=ppval(hyp,fr);
     hyps.Xi(fr,h)=xys(1,:);
     hyps.Yi(fr,h)=xys(2,:);
     hyps.W(fr,h)=xys(3,:);
     hyps.H(fr,h)=xys(4,:);
 end
 
 hyps.frameNums=sceneInfo.frameNums;