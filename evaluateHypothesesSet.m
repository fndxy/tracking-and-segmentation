function [maxOL,bestFit]=evaluateHypothesesSet(hyps,gtInfo)
% evaluate hypotheses set agains ground truth

if isempty(gtInfo)
	maxOL=0;
	bestFit=0;
	return;
end

[Fgt,Ngt]=size(gtInfo.W);

d=getTrackOverlap3(hyps,gtInfo);
[maxOL,bestFit]=max(d,[],1);

keepIDs=unique(bestFit);

% fprintf('-----------------------\n');
fprintf('Best Hyp Fit: %.1f %%\n',100*sum(maxOL)/Ngt);

fields={'X','Y','Xi','Yi','W','H','Xgp','Ygp'};
for f=fields
    cf=char(f);
    if isfield(hyps,cf)
        newField=getfield(hyps,cf);
        newField=newField(:,keepIDs);
        hyps=setfield(hyps,cf,newField);
        
    end
end


hyps.X=hyps.Xi;hyps.Y=hyps.Yi;
% [metrics2d, metrNames2d]=CLEAR_MOT(gtInfo,hyps);
% printMetrics(metrics2d);
% fprintf('-----------------------\n');
