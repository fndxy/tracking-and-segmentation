function stateInfo=segTracking(sceneFile,opt)
% This code accompanies the publication
%
% Joint Tracking and Segmentation of Multiple Targets
% A. Milan, L. Leal-Taixe, K. Schindler and I. Reid 
% CVPR 2015
%

% addpath(genpath('./motutils'))
% addpath(genpath('./external'))
% addpath(genpath('./opengm'))
% addpath(genpath('./mex'))



% global scenario gtInfo opt detections stStartTime htobj labdet
global sceneInfo detections gtInfo

%% prepare
stStartTime=tic;

% scenario=25;
scenario=sceneInfo.scenario;

% parameters
% if nargin>0, scenario=scen; end
% frames=1:30;

if ~isfield(opt,'frames'), opt.frames = 1:length(sceneInfo.frameNums); end
frames=opt.frames;



F=length(frames);
% opt.maxRemove=0;
% opt.canvel=3;

% set random seed for deterministic results
rng(1); 

% get info about sequence
sceneInfo = parseScene(sceneFile);
sceneInfo.frameNums=sceneInfo.frameNums(frames);


% now parse detection for specified frames
[detections, nPoints]=parseDetections(sceneInfo,opt);
fprintf('%d detections read\n',nPoints);
alldpoints=createAllDetPoints(detections);

% estimate ground plane based on detections (Sec. 5, Height.)
htobj=estimateTargetsSize(detections);
sceneInfo.htobj = htobj;

sceneInfo.targetSize = mean(alldpoints.wd)/2;


% opt=readSTOptions('config/default2d.ini');
sceneInfo.imTopLimit=0;


% remove unnecessary frames from GT
if sceneInfo.gtAvailable
    gtInfo=convertTXTToStruct(sceneInfo.gtFile);
    gtInfo.frameNums=1:size(gtInfo.W,1);
    gtInfo=cropFramesFromGT(sceneInfo,gtInfo,frames,opt);
end

K= opt.nSP;
fprintf('Approx. %d superpixels per frame\n',K);
avgMinDetDistF=avgMinDetDist(detections);
% avgMinDetDistF;

%% all ims, all flows
fprintf('Precomputing helper structures\n');
[~, iminfo, sp_labels, ISall, IMIND, seqinfo, SPPerFrame] = ...
    precompAux(scenario,sceneInfo,K,frames);

% TODO: MOVO TO PRECOMP
sPerFrame=segsPerFrame(sp_labels);


meanFlow=mean(sqrt(ISall(:,9).^2 + ISall(:,10).^2),1);

% modify unary cost parameter according to min dist
if isfield(opt,'ucostpar')
    detDensity=numel(alldpoints.xp)/F;
    ufac=1/avgMinDetDistF; ufac=min(ufac,10); ufac=max(ufac,0.1);
    opt.unaryFactor = opt.unaryFactor * ufac;
end



opt.objMaskFile='objMask.mat';
if isfield(opt,'omask')
    if opt.omask==1
        opt.objMaskFile='objMaskU.mat';
    end
end


opt.ofmask=0;   
opt.nolog=0;

if ~isfield(opt,'maxSPF')
    opt.maxSPF=60;
end

if ~isfield(opt,'aspectRatio')
    opt.aspectRatio=5/12;
end

%% print initial infos
printHeader(sceneInfo,scenario,1);
printParams(opt);



%% perform foreground background segmentation
detSeg;
svmSeg;


global ISallglob Qglob inanyglob
ISallglob=ISall; Qglob=Q;
%% generate initial set of trajectory hypotheses
generateHypotheses;

saveiters=0; smiter=0;

% hypotheses=getHypStruct;

%
hyps=getBBoxesFromHyps(hypotheses,F);

% unaries
totalNSegs=length(Q);
tatalNDets=length(alldpoints.sp);
DcostS=getSegUnaries(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,opt,sPerFrame);
DcostD=getDetUnaries(detections,hypotheses,hyps,alldpoints,opt);
Dcost=int32(opt.unaryFactor*[DcostS DcostD]);

labdet=opt.labdet;

uf=opt.unaryFactor;
[nLabels,nVars]=size(DcostS);

% construct pairwies potentials
[Scost, SN, TN, DN, Nhood, NB]= ...
    buildPairwisePotentials(DcostS, DcostD, F, SPPerFrame, sceneInfo, seqinfo, sp_labels, ISall, opt, detections);
% buildDetSPConnections;
% ndet1=7; ndet2=19;
% DN(nVars+ndet1,nVars+ndet2)=10;
% DN(nVars+ndet2,nVars+ndet1)=10;
% Nhood.SN=SN; 
% Nhood.TN=TN; 
% Nhood.SN=SN;
% Nhood.DN=DN;

% label cost
LCost=getHypLabelCost2(hypotheses, sceneInfo, opt);
LCost=[LCost 0]; % background
% pause

nCurModels=length(hypotheses); nLabels=nCurModels+1; bglabel=nLabels;  
% [E, D, S, L, labeling]=doAlphaExpansion(uf*Dcost, Scost, LCost, NB);
% labeling=double(labeling); used=setdiff(unique(labeling),bglabel);
% energy=printEnergies(0,labeling, hypotheses, Dcost, Nhood, sceneInfo, opt);
labeling=bglabel*ones(1,size(Dcost,2)); used=[];
energy=evaluateEnergy(labeling, hypotheses, Dcost, Nhood, sceneInfo, opt);
[metrics2d, metrics3d]= ...
    printSTUpdate(0,stStartTime,energy,sceneInfo,opt,hypotheses,used,0,0);

% main optimization loop
labeling(:)=nLabels;
hypBeforeHSM=hypotheses;
labbeforeHSM=labeling; % labeling before modifying hypotheses space
bglabelBeforeHSM=nLabels;
nAdded=0;nRemoved=0;
    
bestE=Inf;
used=[];
maxIter=opt.maxItCount; 
% maxIter=2; warning('maxiter overridden');
iter=0;
while 1
    iter=iter+1;
    oldN=length(hypotheses);
    
%     fprintf('Removing old hypotheses...');
    % update info about when each hypothesis was last used (active)
    for m=1:length(hypotheses)
        if ~isempty(intersect(m,used))
            hypotheses(m).lastused=0;
        else
            hypotheses(m).lastused=hypotheses(m).lastused+1;
        end
    end
    
    hypotheses_=hypotheses;
    tokeep=find([hypotheses.lastused]<opt.keepHistory);
    hypotheses=hypotheses(tokeep);
    
    nRemoved=oldN-length(tokeep);
    nCurModels=length(hypotheses); nLabels=nCurModels+1; bglabel=nLabels;
        
    % rearrange labeling, hacky --> improve TODO
    ul=setdiff(unique(labeling),length(hypotheses_)+1);
    for cl=ul
        newl=find(tokeep==cl);
        labeling(labeling==cl)=newl;
        used(used==cl)=newl;
    end
    labeling(labeling==length(hypotheses_)+1)=bglabel;
%     fprintf('%d. Remaining: %d\n',nRemoved,nCurModels);
    
    
    energyBeforeDO=energy;
    labelingBeforeDO=labeling;
    
    % discrete optimization
    hyps=getBBoxesFromHyps(hypotheses,F);
    DcostS=getSegUnaries(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall,opt,sPerFrame);
    DcostD=getDetUnaries(detections,hypotheses,hyps,alldpoints,opt);
    Dcost=int32(opt.unaryFactor*[DcostS DcostD]);


    LCost=getHypLabelCost2(hypotheses, sceneInfo, opt);
    LCost=[LCost, 0]; % background
    Scost=1-1*eye(nLabels);
%     [Enew, D, S, L, labeling]=doAlphaExpansion(uf*Dcost, Scost, LCost, NB);
    [Enew, labeling]= alphaExpansion(Dcost,Scost,LCost, labelingBeforeDO, Nhood, hypotheses, sceneInfo, opt);
    
    labeling=double(labeling);
    
    %% Try removing trajectories (labels), one by one
%     energy=printEnergies(0,labeling, hypotheses, Dcost, Nhood, sceneInfo, opt);
    energy=evaluateEnergy(labeling, hypotheses, Dcost, Nhood, sceneInfo, opt);
    
%     energy.value
%     [Eogm, logm]= alphaExpansion(uf*Dcost,Scost,LCost, labelingBeforeDO, Nhood, hypotheses, sceneInfo, opt);
%     logm=double(logm);
%     energyogm=evaluateEnergy(logm, hypotheses, Dcost, Nhood, sceneInfo, opt);
%     energyogm.value
%     pause

%     pause
    ticGreedy=tic;
    [labeling, used]=...
        greedyRemoval(hypotheses, labeling, bglabel, Nhood, opt, sceneInfo, energy, Dcost);
    tocGreedy=toc(ticGreedy);

    
    
    % What is the energy after discrete optimization?
    energy=evaluateEnergy(labeling, hypotheses, Dcost, Nhood, sceneInfo, opt);
    [metrics2d, metrics3d]= ...
        printSTUpdate(iter,stStartTime,energy,sceneInfo,opt,hypotheses,used,nAdded,nRemoved);
%     pause
    Enew=energy.value;
    
    % if new energy worse than before or maxiter reached, or max time reached, terminate
    SPF = toc(stStartTime)/F;
    termCrit = [Enew >= bestE, iter>=maxIter, SPF >= opt.maxSPF];
    termCritStr = {'Converged','Max iter. reached','Max optimization time reached'};
    if any(termCrit)
        
        % if energy is higher than before, restore
        if termCrit(1)
            labeling=labelingBeforeDO;
            energy=energyBeforeDO;
        end
        
        nCurModels=length(hypotheses); nLabels=nCurModels+1; bglabel=nLabels;
        
%         oldUsed=used;
        used=setdiff(unique(labeling),bglabel);        
        
        fprintf('done\n');
        
        % print out reason for termination
        for tc = 1:length(termCrit)
            if termCrit(tc),   disp(termCritStr{tc});       end
        end
        break;
    end
    
    if saveiters
        smiter=smiter+1;
        save(sprintf('tmp/suppmat/state-%02d.mat',smiter),'labeling','bglabel','hypotheses');
    end
    
    % otherwise adjust models
    bestE=energy.value;

    bglabel=nLabels;
    used=setdiff(unique(labeling),bglabel);
    
%     fprintf('Active Hypotheses: %d\n',length(used));
%     pause
    
%     hyps=getBBoxesFromHyps(hypotheses,F);
%     finallab=setdiff(labeling,bglabel);
%     visResult2    
%     
    hypBeforeHSM=hypotheses;
    labbeforeHSM=labeling; % labeling before modifying hypotheses space
    bglabelBeforeHSM=bglabel;
    
%     fprintf('Adding new hypotheses...');
    % Expand the hypothesis space
    if nCurModels<opt.maxModels
        nModelsBeforeAdded=nCurModels;
        
        
      hypotheses = modifyHypothesisSpace( ...
        sceneInfo, opt, detections, hypotheses, used, energy, ...
        labeling, bglabel, sp_labels, ISall, Q, IMIND, SPPerFrame, size(DcostS,2));
        %
        hyps=getBBoxesFromHyps(hypotheses,F);
        
    end
%     [maxOL,bestFit]=evaluateHypothesesSet(hyps,gtInfo);
%     hypsAfterHSM=getBBoxesFromHyps(hypotheses,F);
    
    nCurModels=length(hypotheses); nLabels=nCurModels+1; bglabel=nLabels;    
    nAdded=nCurModels-length(hypBeforeHSM);
%     fprintf('%d. Total: %d\n',nAdded,nCurModels);
    
    newl=labeling; newl(newl==nModelsBeforeAdded+1)=bglabel;
    labeling=newl;    
    oldUsed=unique(labeling);


    pause(.01);
end
hyps=getBBoxesFromHyps(hypotheses,F);

%% enumerate labeling to 1:N
newLabeling=zeros(1,nVars);
for l=used, newLabeling(labeling==l)=find(used==l); end

% special handling of bglabel
lo=find(labeling==bglabel);
bglabel=length(used)+1;
if ~isempty(lo),    newLabeling(lo)=bglabel; end

oldHyp=hypotheses;
hypotheses=hypotheses(used);
labeling=newLabeling;

hyps=getBBoxesFromHyps(hypotheses,F);

%% vis boxes
finallab=setdiff(labeling,bglabel);
newlab=labeling(end-size(DcostD,2)+1:end);

stateInfo=hyps;
stateInfo.Xi=stateInfo.Xi(:,finallab);
stateInfo.Yi=stateInfo.Yi(:,finallab);
stateInfo.W=stateInfo.W(:,finallab);
stateInfo.H=stateInfo.H(:,finallab);
stateInfo.frameNums=sceneInfo.frameNums;
stateInfo.F=length(stateInfo.frameNums);
% spl=splines(unique(finallab));
% startPT.F=F;
% if isfield(startPT,'Xgp'), startPT=rmfield(startPT,'Xgp');startPT=rmfield(startPT,'Ygp'); end
% stateInfo=getStateFromSplines(spl,startPT,1);
% stateInfo=postProcessState(stateInfo);
stateInfo.opt=opt;
% stateInfo.labeling=labeling;
stateInfo.splabeling=labeling(1:size(DcostS,2));
stateInfo.bglabel=bglabel;
stateInfo.hypotheses=hypotheses;
stateInfo.detlabeling=newlab;
stateInfo.sceneInfo = sceneInfo;

% displayTrackingResult(sceneInfo,stateInfo);

printMessage(1,'All done (%.2f min = %.2fh = %.2f sec per frame)\n', ...
    toc(stStartTime)/60,toc(stStartTime)/3600,toc(stStartTime)/stateInfo.F);

stateInfo.X=stateInfo.Xi;stateInfo.Y=stateInfo.Yi;
if howToTrack(scenario)
    [stateInfo.Xgp, stateInfo.Ygp]=projectToGroundPlane(stateInfo.Xi, stateInfo.Yi, sceneInfo);
    stateInfo.X=stateInfo.Xgp;stateInfo.Y=stateInfo.Ygp;    
end


try
    [metrics2d, metrics3d, addInfo2d, addInfo3d]= ...
        printFinalEvaluation(stateInfo, gtInfo, sceneInfo, struct('track3d',char(howToTrack(scenario))));
catch err
    fprintf('Evaluation failed: %s\n', err.message);
end

%% vis
% bglabel=nLabels;

% uncoment to visualize
visResult2(stateInfo,sp_labels,iminfo)


% allens=0;

% end
