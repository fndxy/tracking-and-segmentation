function stateInfo=getStateForEmptySolution(sceneInfo,opt)
% fill in stateInfo struct for trivial solution

% zero metrics
F=length(sceneInfo.frameNums);
stateInfo.F=F;
stateInfo.Xi=[];stateInfo.Yi=[];stateInfo.W=[];stateInfo.H=[];
%stateInfo.Xgp=[];stateInfo.Ygp=[];
stateInfo.X=[];stateInfo.Y=[];
stateInfo.opt=opt;
stateInfo.bglabel=0;    
stateInfo.splabeling=[]; 
stateInfo.detlabeling=[];
stateInfo.frameNums=sceneInfo.frameNums;
stateInfo.hypotheses=[];

end
