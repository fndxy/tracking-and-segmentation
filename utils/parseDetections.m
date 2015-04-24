function [detections, nDets]=parseDetections(sceneInfo, opt, confthr)
% read detection file and create a struct array

% global opt scenario

nDets=0;

detFile=sceneInfo.detFile;
% first determine the type
[pathstr, filename, fileext]=fileparts(detFile);
% is there a .mat file available?
matfile=fullfile(pathstr,[filename '.mat']);

if      strcmpi(fileext,'.idl'); detFileType=1;
elseif  strcmpi(fileext,'.xml'); detFileType=2;
elseif  strcmpi(fileext,'.txt'); detFileType=3; % our benchmark
else    error('Unknown type of detections file.');
end

%% now parse

if detFileType==3

    detRaw=dlmread(detFile);
    
    F = length(sceneInfo.frameNums);
    frToParse=1:F;
%     if nargin==2, frToParse=frames; end
%     frToParse
    
    for t=frToParse
        detections(t).bx=[];
        detections(t).by=[];
        detections(t).xi=[];
        detections(t).yi=[];
        detections(t).xp=[];
        detections(t).yp=[];
        detections(t).wd=[];
        detections(t).ht=[];
        detections(t).sc=[];
    end
    
    % first defined frame and shift
    ff = sceneInfo.frameNums(1);
    fshift = ff-1;
    
    for d=1:size(detRaw,1)
        t=detRaw(d,1);
        if isempty(intersect(t,sceneInfo.frameNums))
            continue;
        end
        
        w=detRaw(d,5);
        h=detRaw(d,6);
        bx=detRaw(d,3);
        by=detRaw(d,4);
        xi=detRaw(d,3)+w/2;
        yi=detRaw(d,4)+h;
        sc=detRaw(d,7);
%         sc(:)=1./(1+exp(-sc));
% sc
	% scale to 0-1
        sc=(sc-min(detRaw(:,7))) / (max(detRaw(:,7)-min(detRaw(:,7))));

        
        tshft = t-fshift;
        
        detections(tshft).bx=[detections(tshft).bx bx];
        detections(tshft).by=[detections(tshft).by by];
        detections(tshft).xi=[detections(tshft).xi xi];
        detections(tshft).yi=[detections(tshft).yi yi];
        detections(tshft).xp=[detections(tshft).xp xi];
        detections(tshft).yp=[detections(tshft).yp yi];
        detections(tshft).wd=[detections(tshft).wd w];
        detections(tshft).ht=[detections(tshft).ht h];
        detections(tshft).sc=[detections(tshft).sc sc];
    end        
end



%% if we want to track in 3d, project onto ground plane
% detections=projectToGP(detections,sceneInfo);

%% set xp and yp accordingly
detections=setDetectionPositions(detections,opt,sceneInfo);

nDets=numel([detections(:).xp]);
% save detections in a .mat file
% if nargin<2
%     save(matfile,'detections');
% end

end

function detections=setDetectionPositions(detections,opt,sceneInfo)
% set xp,yp to xi,yi if tracking is in image (2d)
% set xp,yp to xw,yi if tracking is in world (3d)
F=length(detections);
if opt.track3d
    assert(isfield(detections,'xw') && isfield(detections,'yw'), ...
        'for 3D tracking detections must have fields ''xw'' and ''yw''');
    
    for t=1:F,  detections(t).xp=detections(t).xw;detections(t).yp=detections(t).yw;        end
else
    for t=1:F,  
        detections(t).xp=detections(t).xi;
        detections(t).yp=detections(t).yi;  
        % YSHIFT
        if sceneInfo.yshift
            detections(t).yp=detections(t).yi-detections(t).ht/2;        
        end
    end
end

% do we have direction?
if isfield(detections(1),'dirxi')
    if opt.track3d
        assert(isfield(detections,'dirxw') && isfield(detections,'diryw'), ...
            'for 3D tracking detections must have fields ''dirxw'' and ''diryw''');

        for t=1:F,  detections(t).dirx=detections(t).dirxw;detections(t).diry=detections(t).diryw;        end
    else
        for t=1:F,  detections(t).dirx=detections(t).dirxi;detections(t).diry=detections(t).diryi;        end
    end    
end

end

function detections=removeWeakOnes(detections,confthr)
    % remove weak ones
    
    fnames=fieldnames(detections(1));
    for t=1:length(detections)
        tokeep=detections(t).sc>confthr;
        for fn=1:length(fnames)
            fnstr=fnames{fn};
            replstr=sprintf('detections(t).%s=detections(t).%s(tokeep);',fnstr,fnstr);
            eval(replstr);
            
        end
    end

end

function [dirxi diryi]=getDirFromIndex(dirind)
dirxi=1; diryi=0;

one_div_sqrt2=1/sqrt(2);
switch(dirind)
    case 1
        dirxi=1; diryi=0;
    case 2
        dirxi=one_div_sqrt2; diryi=-one_div_sqrt2;
    case 3
        dirxi=0; diryi=-1;
    case 4
        dirxi=-one_div_sqrt2; diryi=-one_div_sqrt2;
    case 5
        dirxi=-1; diryi=0;
    case 6
        dirxi=-one_div_sqrt2; diryi=one_div_sqrt2;
    case 7
        dirxi=0; diryi=1;
    case 8
        dirxi=one_div_sqrt2; diryi=one_div_sqrt2;
end

end

function res = comp_gauss(x, mu, sigma)

  res = exp(-0.5 * (x - mu).^2 / sigma^2) / (sqrt(2*pi) * sigma);
end

function detections=sigmoidify(detections,opt)
if isfield(opt,'detScale')
    sigA=opt.detScale.sigA;    sigB=opt.detScale.sigB;
    for t=1:length(detections)
        detections(t).sc=1./(1+exp(-sigB*detections(t).sc+sigA*sigB));
    end 
end
end

function detections=rescaleConfidence(detections,opt)

if isfield(opt,'detScale')
    
%     if ~isempty(intersect(scenario,[24 26]))
%     % desigmoidify
%     
    sigA=0;    sigB=1;
    for t=1:length(detections)
        detections(t).sc= (sigA - log(1./detections(t).sc - 1)/sigB);
    end    
%     
%         SIG.mean_tp= 2.5170;    SIG.std_tp= 6.7671;
%     SIG.mean_fp= -11.4631;    SIG.std_fp= 6.5885;
%     for t=1:length(detections)
%         g1 = comp_gauss(detections(t).sc, SIG.mean_tp, SIG.std_tp);
%         g2 = comp_gauss(detections(t).sc, SIG.mean_fp, SIG.std_fp);
%         detections(t).sc= g1 ./ (g1+g2);
%     end    
% 
%     % resigmoidify
    sigA=opt.detScale.sigA;    sigB=opt.detScale.sigB;
    for t=1:length(detections)
        detections(t).sc=1./(1+exp(-sigB*detections(t).sc+sigA*sigB));
    end
end
%     end

end