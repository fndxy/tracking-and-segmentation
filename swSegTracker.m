function stateInfo=swSegTracker(varargin)
% This code accompanies the publication
%
% Joint Tracking and Segmentation of Multiple Targets
% A. Milan, L. Leal-Taixé, K. Schindler and I. Reid
% CVPR 2015
%

% parse input parameters
p = inputParser;
addOptional(p,'scene','config/scene.ini');
addOptional(p,'params','config/params.ini');

parse(p,varargin{:});


% add paths
addpath(genpath('./utils'))
addpath(genpath('./external'))

% get scene information and parameters
sceneFile = p.Results.scene;
sceneInfo = parseScene(sceneFile);
opt=parseOptions(p.Results.params);

stateInfo = [];


% do entire sequence in small batches (default 50)
allframeNums=sceneInfo.frameNums;
FF=length(allframeNums);
fromframe=1; toframe=min(FF,opt.winSize);
wincnt=0;allwins=[];
allstInfo=[];
while toframe<=FF
    wincnt=wincnt+1;
    fprintf('Working on subwindow... from %4d to %4d = %4d frames\n',fromframe,toframe,length(fromframe:toframe));
    
    opt.frames=fromframe:toframe;
    
    % DO TRACKING ON SUBWINDOR HERE
    stateInfo=segTracking(sceneFile,opt);
    
    allstInfo=[allstInfo stateInfo];
    allwins(wincnt,:)=[fromframe, toframe];
    
    
    % now adjust new time frame
    % if already at end, break
    if toframe==FF,        break;    end
    
    % otherwise slide window and make bigger if needed
    % at the end
    fromframe=fromframe+opt.winSize-opt.winOverlap;
    newend=toframe+opt.winSize-opt.winOverlap;
    if newend > FF-opt.minWinSize
        toframe=FF;
    else
        toframe=newend;
    end
end

%% finish up
sceneInfo = parseScene(sceneFile);
detections=parseDetections(sceneInfo,opt);
K= opt.nSP;

% superpixel info
spfile=sprintf('sp-K%d.mat',K);
load(fullfile(sceneInfo.imgFolder,spfile));

stateInfo=stitchTempWins(allstInfo,allwins,detections,sp_labels);
stateInfo.frameNums=uint16(stateInfo.frameNums);
stateInfo.splabeling=uint16(stateInfo.splabeling);
stateInfo.detlabeling=uint16(stateInfo.detlabeling);

