function [metrics2d, metrics3d]= ...
    printSTUpdate(itcnt,stStartTime,energy,sceneInfo,opt,hypotheses,used,nAdded,nRemoved)

global gtInfo

gtheader='';
metheader='';
metrics2d=zeros(1,14);
metrics3d=zeros(1,14);
% if nargin<10
%     itType='';
% end

F=length(sceneInfo.frameNums);

showm2d=0; showm3d=0;
if ~mod(itcnt,2), showm2d=1; end

if sceneInfo.gtAvailable && opt.verbosity>=3
    
    gtheader=''; metheader='';
    
    if howToTrack(sceneInfo.scenario)
        showm3d=1;
        gtheader='  ----------- M E T R I C S (3D)---------- |||';
        metheader=' MOTA  MOTP  GT  MT  ML|  FP   FN IDs  FM  |||';
        if showm2d
            gtheader=[gtheader '  ----------- M E T R I C S (2D)--------- '];
            metheader=[metheader ' MOTA  MOTP  GT  MT  ML|  FP   FN IDs  FM|'];
        end
    else
        if showm2d
            gtheader='  ----------- M E T R I C S (2D)---------- |||';
            metheader=' MOTA  MOTP  GT  MT  ML|  FP   FN IDs  FM |';
        end
    end
    
end

if ~mod(itcnt,10)
    printMessage(2,'\n -- S: %3d, (%3d : %3d) -|| ------------- ENERGY  VALUES -------- ||%s',sceneInfo.scenario,sceneInfo.frameNums(1), sceneInfo.frameNums(end),gtheader);
    printMessage(2,'\n  it| time|*to|*ac|*ad|*rm||     Energy|      Data|  Smooth|  Lcost||%s\n',metheader);
end

[totEn, D, S, L, PL, lc]= getEnergyValues(energy);
N=length(hypotheses);
nActive=length(used);

printMessage(2,' %3i|%5.1f|%3i|%3i|%3i|%3i||%11.1f|%10.1f|%8.1f|%7.1f||%6.1f|%6.1f|%6.1f||\n', ...
    itcnt, toc(stStartTime)/60,N,nActive,nAdded,nRemoved, ...
    totEn,D,S,L); %%% iter output

if sceneInfo.gtAvailable && opt.verbosity>=3
    stateInfo=getBBoxesFromHyps(hypotheses(used),F);
    stateInfo.X=stateInfo.Xi; stateInfo.Y=stateInfo.Yi;
    if howToTrack(sceneInfo.scenario)
        [stateInfo.Xgp, stateInfo.Ygp]=projectToGroundPlane(stateInfo.Xi, stateInfo.Yi,sceneInfo);
        stateInfo.X=stateInfo.Xgp;stateInfo.Y=stateInfo.Ygp;
    end
            
    
    % cut state to tracking area if needed
    if opt.cutToTA,  stateInfo=cutStateToTrackingArea(stateInfo);     end
    
    % compute 3d metrics
    if showm3d
        [metrics3d, metrNames3d]=CLEAR_MOT_HUN(gtInfo,stateInfo,struct('eval3d',1));
        printMetrics(metrics3d,metrNames3d,0,[12 13 4 5 7 8 9 10 11]);
        printMessage(3,'|||');
    end
    
    % compute 2d metrics
    if showm2d
        stateInfo.X=stateInfo.Xi; stateInfo.Y=stateInfo.Yi;        
        [metrics2d, metrNames2d]=CLEAR_MOT_HUN(gtInfo,stateInfo,struct('eval3d',0));
        printMetrics(metrics2d,metrNames2d,0,[12 13 4 5 7 8 9 10 11]);
    end
    
end
printMessage(2,'\n');

