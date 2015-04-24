function [Eogm, logm]= ...
    alphaExpansion(Dcost,Scost,Lcost, labeling, Nhood, hypotheses, sceneInfo, opt)
% alpha expansion with openGM as inference engine



% TNeighbors=Nhood.TN;
% SNeighbors=Nhood.SN;


% PottsNeighbors=Nhood.TN+Nhood.SN;
% PottsNeighbors=floor(opt.pairwiseFactor*(Nhood.TN+Nhood.SN) );
PottsNeighbors=floor(opt.pwSSP*Nhood.SN + opt.pwTSP*Nhood.TN + opt.pwDetSP*Nhood.DN);
opt.pairwiseFactor=opt.pwSSP;

% if ~opt.PWLcost
    [Eogm, D, S, L, logm] = ...
        doAlphaExpansion(Dcost, Scost, Lcost, triu(PottsNeighbors));
    return;
% end

% PottsNeighbors(:)=0;


% what is the LabelSpace?
Dcost=round(Dcost);Lcost=round(Lcost);Scost=round(Scost);
[nLabels, nPoints]=size(Dcost);
outlierLabel=nLabels;   % the highest label is used for the outlier model

% ordering for alpha expansion
labelOrder=1:nLabels;
% labelOrder=randperm(nLabels);


% precompute energy values that remain constant
[labelCost, lcComponents] = getHypLabelCost2(hypotheses, sceneInfo, opt); 

precomp.LCost.labelCost=labelCost;
precomp.LCost.lcComponents=lcComponents;

hboxes=getBBoxesFromHyps(hypotheses,length(sceneInfo.frameNums));
proxcost=getTrackOverlap4(hboxes);
proxcost=opt.PWLcost*proxcost;

precomp.proxcost=proxcost;


% initial labeling energy
energy=evaluateEnergy(labeling, hypotheses, Dcost, Nhood, sceneInfo, opt, precomp);
E=energy.value;
bestE=energy.value;
logm=labeling;
Eogm=E;



% maximum number of alpha expansion iterations
maxIt=5;
converged=0;
alphaExpIt=0;

newupLabeling=labeling;

% main alpha expansion loop
while ~converged && alphaExpIt<maxIt
    alphaExpIt=alphaExpIt+1;
    thisbest=bestE;
    for expOnAlpha=labelOrder
        expLab=expOnAlpha;                      % our current alpha
%         fprintf('Expand on: %d\n',expLab);
        
        % prune TODO
        pLabeling=labeling;
        pDcost=Dcost;
        pPottsNeighbors=PottsNeighbors;
%         pTN=TNeighbors;
        keeppts=1:nPoints;
        
%         size(pDcost)
        [pDcost,pPottsNeighbors,keeppts]=pruneGraph(Dcost,PottsNeighbors);        
        pLabeling=pLabeling(keeppts);
%         size(pDcost)
%         pause
        
        alpInds=find(pLabeling==expLab);         % which nodes are alpha
        notAlphasInd=find(pLabeling~=expLab);    % which are not alpha
        numNotAlphaNodes=numel(notAlphasInd);   % how many not alphas
        
        alphasIndicator=zeros(size(pLabeling));  % put a one on all alphas
        alphasIndicator(alpInds)=1;
        
        newLabeling=pLabeling;
        
        % nothing to do if all nodes are alpha already
        if ~isempty(notAlphasInd)
            
            %%
            % quick check
            curInds=sub2ind(size(pDcost),double(pLabeling),1:size(pDcost,2));
            
            % set up GCO structure
            [nLabels, nPoints]=size(Dcost);
            
            labeling_=labeling;
            
            % evaluate the enegy before expansion
%             Pw=TNeighbors;
%             Ex=SNeighbors;
            %             ecost=opt.exclusionFactor;
            energy_=evaluateEnergy(labeling, hypotheses, Dcost, Nhood, sceneInfo, opt, precomp);
            
            E_=energy_.value;
%                         E_
%                         pause
            
            E=E_;
            
            % energy before expansion
            beforeExpEn=E;
            if beforeExpEn<bestE
                bestE=beforeExpEn;
            end
%             pause
            
            %
            newInds=sub2ind(size(pDcost),expLab*ones(1,size(pDcost,2)),1:size(pDcost,2));
            DcostAlpha=[pDcost(curInds); pDcost(newInds)];
            
            % which labels are not alpha?
%             [notAlphas, m, n]=unique(pLabeling(notAlphasInd),'stable');            
%             notAlphasUnique=notAlphas;

            [notAlphas, m, n]=unique(pLabeling(notAlphasInd));
            notAlphasUnique=notAlphas;
            [~, sm]=sort(m);
            notAlphas=notAlphas(sm);
            
            
            naoidx=find(notAlphasUnique==outlierLabel);
            notAlphasNoOutlier2=notAlphasUnique;
            if ~isempty(naoidx)
                notAlphasNoOutlier2=notAlphasNoOutlier2([1:naoidx-1 naoidx+1:end]);
            end
            
            notAlphasNoOutlier=notAlphasNoOutlier2;
            nAux=numel(notAlphas); % we need nAux auxisiliary nodes
            
            % keep only those that are not alphas
            DcostAlpha=DcostAlpha(:,notAlphasInd);
            DcostAlphaAux=DcostAlpha;
            
            
            % add auxiliary unaries
            DcostAlphaAux(:,end+1:end+nAux)=[zeros(1,nAux);Lcost(notAlphas)];
            
            Auxmat=zeros(2,0);
            LcostInd=[];
            
            trLabeling=pLabeling(notAlphasInd);
            tmp=numNotAlphaNodes;
            
            % add a pairwise term for each label to the auxiliary variable
            for na=notAlphas
                tmp=tmp+1;
                tmp2=find(trLabeling==na);
                
                % loop implementation
                %                 for nn=1:length(tmp2)
                %                     Auxmat=[Auxmat [tmp2(nn); tmp]];
                %                     LcostInd=[LcostInd tmp-numNotAlphaNodes];
                %                 end
                
                % Matrix implementation
                Auxmat=[Auxmat [tmp2; tmp*ones(1,length(tmp2))]];
                LcostInd=[LcostInd (tmp-numNotAlphaNodes)*ones(1,length(tmp2))];
                
            end
            
            % PAIRWISE SMOOTHNESS (FAST)?
            Dpw=[];
            Dpwi=[]; % indicater whether equal or different
            UnAux=zeros(size(DcostAlphaAux));
            
            if opt.pairwiseFactor
                TNeighborsAux=full(pPottsNeighbors);
                [UnAux2, Dpwa, Dpwb, Dpwi2]= ...
                    constructPairwise(TNeighborsAux,alphasIndicator,pLabeling,-1);
                Dpw2=[Dpwa-1;Dpwb-1];
                Utmp=zeros(size(DcostAlphaAux));
                Utmp(2,1:numNotAlphaNodes)=-UnAux2*opt.pairwiseFactor;
                UnAux2=Utmp;
                
                UnAux=UnAux2;
                Dpw=Dpw2; Dpwi=Dpwi2;
            end
            
            % EXCLUSIONS (Supermodular)
            Expw=[];
            Expwi=[]; % indicater whether equal or different
            UnAuxE=zeros(size(DcostAlphaAux));
            
            % now add to unaries
            DcostAlphaAux=DcostAlphaAux+UnAux;
            DcostAlphaAux=DcostAlphaAux+UnAuxE;
            
            %% c code is 0 based
            Auxmatcl=Auxmat-1;
            LcostInd=LcostInd-1;
            
            
            LcostWithProxcost=Lcost;
            
            % add proximity cost to label cost            
            if expLab~=outlierLabel
                tmpproxcost=proxcost+proxcost';
                tmpproxcost=tmpproxcost(expLab,:);
                LcostWithProxcost(1:end-1)=LcostWithProxcost(1:end-1)+tmpproxcost;
            end
            
            Lcostcl=LcostWithProxcost(notAlphas);
            
            % TODO: PAIRWISE LABEL COST???
            
            binLabeling=ones(1,size(DcostAlphaAux,2));
%             notAlphas
%             Lcostcl
%             pause
            try
                [Eogm, directLabeling]= ...
                    binaryInference(DcostAlphaAux,Auxmatcl,opt.pairwiseFactor, Lcostcl,LcostInd, ...
                    0,binLabeling,Dpw,Dpwi,Expw,Expwi, notAlphasNoOutlier, opt.PWLcost, nAux, ...
                    0,0,0);            
            catch err
                error('binary inference failed: %s, %s', err.identifier,err.message);
            end            
            if ~all(directLabeling==round(directLabeling))
                directLabeling
            end            
%             fprintf('All zeros: %d\n',all(directLabeling==0));
%             fprintf('All ones:  %d\n',all(directLabeling==1));
            if any(directLabeling ~= round(directLabeling))
                whaat=1
            end
            unique(directLabeling);
            labogm=directLabeling;
            labogm=labogm(1:numNotAlphaNodes);
            newLabeling(notAlphasInd(labogm==1))=expLab;
            
            newupLabeling=labeling_;
            newupLabeling(keeppts(notAlphasInd(labogm==1)))=expLab;
            
            % check energy
            %             energy=evaluateFG(double(newupLabeling), Dcost, Lcost, Pw, dcOpt.pairwiseFactor, Ex, ecost, tmpState);
            energy=evaluateEnergy(double(newupLabeling), hypotheses, Dcost, Nhood, sceneInfo, opt, precomp);
            E=energy.value;
%             E
%             save('inferparams.mat', 'opt','Dcost*','Aux*','Lcost*','binLabeling','Dp*','Exp*','notAlphas*','nAux','new*','direct*');
            
%             pause
            
            afterExpEn=E;
            
            % take the new one if it is lower
            minEnLab=newLabeling;
            if beforeExpEn<=afterExpEn
%                                 fprintf('Expansion on %i did NOT improve energy\n',expLab);
%                                 pause
                newLabeling=pLabeling;
            else
%                                 fprintf('Expansion on %i DID improve energy\n',expLab);
                pLabeling=newLabeling;
                labeling=newupLabeling;
                bestE=afterExpEn;
            end
%             display(unique(pLabeling))
%             display(unique(newupLabeling))
%             display(unique(labeling))
            
        end % if ~isempty(notAlphasInd)
        
    end  %for expOnAlpha
    
    
    % we are done if energy did not change after trying to expand on all
    % labels
    if bestE>=thisbest
        converged=1;
    end
end

logm=newupLabeling;
% unique(logm)