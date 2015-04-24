function hypotheses = modifyHypothesisSpace( ...
    sceneInfo, opt, detections, hypotheses, used, energy, ...
    labeling, bglabel, sp_labels, ISall, Q, IMIND, SPPerFrame, nSP)
% modify hypothesis space

frames=opt.frames;

% extend existing
        newH=extendHyp(hypotheses, used, sceneInfo,opt, energy.value);        
        hypotheses=[hypotheses newH];
%         fprintf('Extend: %d new added\n',length(newH));

        % shrink existing
        newH=shrinkHyp(hypotheses, used, sceneInfo,opt, energy.value);        
        hypotheses=[hypotheses newH];
%         fprintf('Shrink: %d new added\n',length(newH));

        % shrink existing
        newH=shrinkHyp2(hypotheses, used, sceneInfo,opt, energy.value);        
        hypotheses=[hypotheses newH];
%         fprintf('Shrink: %d new added\n',length(newH));


        % merge existing
        newH=mergeHyp(hypotheses, used, sceneInfo,opt, energy.value);
        hypotheses=[hypotheses newH];
%         fprintf('Merge: %d new added\n',length(newH));
        
        % fit onto segmentation
%         newH=fitHypToSeg(labeling, sp_labels);
        newH=fitHypToSeg(labeling, bglabel, sp_labels, frames, sceneInfo, opt, IMIND, SPPerFrame);
        hypotheses=[hypotheses newH];
%         fprintf('From Seg: %d new added\n',length(newH));
        
        % from 'unused' detections
        newH=genHypFromDets(hypotheses, used, detections, sceneInfo, opt);
        hypotheses=[hypotheses newH];
%         fprintf('From Dets: %d new added\n',length(newH));

        % from 'used' detections
        newH=genHypFromDets2(hypotheses, used, detections, labeling, nSP, sceneInfo, opt);
        hypotheses=[hypotheses newH];
%         fprintf('From Dets: %d new added\n',length(newH));

        % break apart
        newH=breakHyp(hypotheses, used, sceneInfo, opt, energy.value, ISall, Q);
        hypotheses=[hypotheses newH];
%         fprintf('Broken: %d new added\n',length(newH));  