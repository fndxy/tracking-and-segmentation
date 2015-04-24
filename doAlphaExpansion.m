function [E, D, S, L, labeling] = ...
    doAlphaExpansion(Dcost, Scost, Lcost, Neighborhood)

% minimize E(f,T) wrt. f by alpha expansion
% Note: This only works for submodular energies
% 
% The gco code is available at
% http://vision.csd.uwo.ca/code/
global opt
prune=opt.prune;

[nLabels, nPoints]=size(Dcost);
labelingall=nLabels*ones(1,nPoints);

if prune
    [Dcost,Neighborhood,ukept]=pruneGraph(Dcost,Neighborhood);
end
[nLabels, nPoints]=size(Dcost);


% trivial case for one label
if nLabels==1
    D=sum(Dcost);    S=0; L=Lcost;    E=D+S+L;
    labeling=ones(1,nPoints);
    return;
end



% set up GCO structure

h=setupGCO(nPoints,nLabels,Dcost,Lcost,Scost,Neighborhood);

% GCO_SetLabelOrder(h,1:nLabels);
% GCO_SetLabelOrder(h,randperm(nLabels));
GCO_Expansion(h);
labeling=GCO_GetLabeling(h)';
labeling=double(labeling);

[E, D, S, L] = GCO_ComputeEnergy(h);

if prune, labelingall(ukept)=labeling; labeling=labelingall; end
% clean up
GCO_Delete(h);
end