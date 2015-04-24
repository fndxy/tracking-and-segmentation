function [labeling, used]= ...
    greedyRemoval(hypotheses, labeling, outlierLabel, Nhood, opt, sceneInfo, energy, Dcost)
% Remove a complete label one by one if it reduces the overall energy

used=setdiff(unique(labeling),outlierLabel);

% nLabels=length(hypotheses)+1; nPoints=length(alldpoints.xp);

% hyps=getBBoxesFromHyps(hypotheses,F);
% DcostS=getSegUnaries(Q,hypotheses,hyps,sp_labels,iminfo,F,ISall);
% DcostD=getDetUnaries(detections,hypotheses,hyps,alldpoints,opt);
% Dcost=[DcostS DcostD];
% 
% LCost=getHypLabelCost2(hypotheses, sceneInfo, opt);
% LCost=[LCost 0]; % background
% Scost=1-1*eye(nLabels);

[labelCost, lcComponents] = getHypLabelCost2(hypotheses, sceneInfo, opt); 

precomp.LCost.labelCost=labelCost;
precomp.LCost.lcComponents=lcComponents;


mcnt=0;
rmvd=0;
for labtorem=used(randperm(length(used)))    
    if rmvd>=opt.maxRemove
        break;
    end
    Enew=energy.value;
    
    mcnt=mcnt+1;
    trylab=labeling;
    trylab(trylab==labtorem)=outlierLabel;    
    energy_r=evaluateEnergy(trylab, hypotheses, Dcost, Nhood, sceneInfo, opt, precomp);
    Er=energy_r.value;
    
    trylab2=labeling;
    varsToReplace=find(trylab2==labtorem);
    [minv, minl]=min(Dcost(:,varsToReplace));
    trylab2(varsToReplace)=minl;
    unused=setdiff(1:length(hypotheses),used);
    torem=find(ismember(trylab2,[unused labtorem]));
%     torem=[torem labtorem];
%     numel(torem)
    trylab2(torem)=outlierLabel;
%     unique(trylab)
%     unique(trylab2)
%     isequal(trylab,trylab2)
    
    energy_r2=evaluateEnergy(trylab2, hypotheses, Dcost, Nhood, sceneInfo, opt, precomp);
    
    %         assert(isequal(energy_r,energy_r2));
    Er2=energy_r2.value;



% Enew
% Eogmr
% pause

    % if new energy is indeed lower ...
    if Er < energy.value || Er2 < energy.value        
        [totEn, D, S, L, PL, lc]= getEnergyValues(energy);
        fprintf('before removal: %22.1f|%11.1f|%7.1f|%8.1f||\n', ...
                        totEn,D,S,L);
                    
        if Er < Er2
            [totEn, D, S, L, PL, lc]= getEnergyValues(energy_r);
            fprintf('1 %4i removed: %22.1f|%11.1f|%7.1f|%8.1f||\n',labtorem,totEn,D,S,L);
            energy=energy_r;
            labeling=trylab;

        else
            [totEn, D, S, L, PL, lc]= getEnergyValues(energy_r2);
            fprintf('2 %4i removed: %22.1f|%11.1f|%7.1f|%8.1f||\n',labtorem,totEn,D,S,L);
            energy=energy_r2;
            labeling=trylab2;

        end
%         pause
% pause
        % ... set new energy value, labeling, and active trajectories
        used=setdiff(used,labtorem);
        rmvd=rmvd+1;
    end
end
% if rmvd>0
%     fprintf('\n');
% end

end