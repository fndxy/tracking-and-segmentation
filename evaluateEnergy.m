function energy=evaluateEnergy(labeling, hyps, Dcost, Nhood, sceneInfo, opt, precomp)

energy.value=0;

if nargin<7
    precomp=[];
end

% nVars=length(labeling);
% nLabels=length(hyps)+1;
[nLabels, nVars]=size(Dcost);

b=labelcount(labeling,nLabels);
labelUsed=~~b;
labelUsed=double(labelUsed);
lu= find(labelUsed(1:end-1));

%% unaries
% multiplication slow. TODO Move to other place
% UCost=int32(opt.unaryFactor*Dcost); 
UCost = Dcost;

% UCost=round(opt.unaryFactor*Dcost);
% uF=opt.unaryFactor;
% UCost=uF*Dcost;
tmp=cumsum(nLabels*ones(1,nVars))-nLabels;
labinds=tmp+labeling;
Eun= sum(UCost(labinds));

%% Potts for temporal smoothness
% NB=triu(opt.pairwiseFactor *(Nhood.SN+Nhood.TN));
NB=triu(opt.pwSSP*Nhood.SN + opt.pwTSP*Nhood.TN + opt.pwDetSP*Nhood.DN);

[pwu, pwv]=find(NB);
diffLab=labeling(pwu)~=labeling(pwv); % 1xN
wind=sub2ind([nVars,nVars],pwu,pwv);
pwWeight=floor(full(NB(wind))); % Nx1
% Epw= (int32(diffLab).*pwWeight) /2; 
Epw=sum(pwWeight(diffLab));

%% pariwise label cost
pwlc=0;
% if opt.PWLcost>0
%     if ~isempty(precomp) && isfield(precomp,'proxcost')
%         proxcost=precomp.proxcost;
%         if size(precomp.proxcost,1) > length(lu)
%             proxcost=precomp.proxcost(lu',:);
%             proxcost=proxcost(:,lu);
%         end
%     else
%         hboxes=getBBoxesFromHyps(hyps(lu),length(sceneInfo.frameNums));
%         proxcost=getTrackOverlap4(hboxes);    
%     end
%     pwlc=opt.PWLcost*sum(proxcost(:));
% end



%% Labelcost
if ~isempty(precomp) && isfield(precomp,'LCost')
    labelCost=precomp.LCost.labelCost;
    lcComponents=precomp.LCost.lcComponents;
else
    [labelCost, lcComponents] = getHypLabelCost2(hyps, sceneInfo, opt);
end
labelCost=[labelCost 0]; lcComponents(:,end+1)=0; % TODO, FIX BG LABEL HACK
nC=size(lcComponents,1);
lcComponents=repmat(labelUsed,nC,1) .* lcComponents;
Ela=xdotyMex(labelUsed,labelCost);
Elc=sum(lcComponents,2);



energy.data=Eun;
energy.smoothness=Epw;
energy.lC=Ela;
energy.labelCost=Elc;
energy.pwLC=pwlc;


E=Eun+Epw+pwlc+Ela;

energy.value=E;