function [labelCost, lcComponents] = getHypLabelCost2(H, sceneInfo, opt)
% compute a cost for each hypothesis (Sec. 5)

% fprintf('Computing label cost for %d hypotheses\n',length(H));

nH=length(H);                       % number of hypotheses
labelCost=zeros(1,nH);              % vector containing result cost
maxNCComp=6;                        % we have six components (cf. Eq. 11)
lcComponents=zeros(maxNCComp,nH);   % breackdown (debug info)

% if no hypotheses, return zeros
if ~nH,    return; end

F=length(sceneInfo.frameNums);

% global htobj
htobj=sceneInfo.htobj;
global ISallglob Qglob inanyglob
ISall=ISallglob;
Q=Qglob;

% get boxes from splines
hyps=getBBoxesFromHyps(H,F);

%% constant label cost (psi reg)
nC=1; % component id
lcComponents(nC,:)=opt.labelCost;

%% height prior (psi hgt)
nC=2;
hF=opt.heightFactor; % w_h
idHeights=feval(htobj,hyps.Xi,hyps.Yi); % expected heights
for id=1:nH
    hyp=H(id);
    s=hyp.start; e=hyp.end;
    tmp=0;
    for t=s:e
        idealHeight=idHeights(t,id);        
        actualHeight=hyps.H(t,id);
        tmp=tmp+abs(idealHeight-actualHeight); % Eq (12)
    end
    lcComponents(nC,id)=hF*tmp;
end

%% persistence (psi per)
nC=3;

global detections
imtoplimit=min([detections(:).yi]);
% imtoplimit=0;

pF=opt.persistenceFactor; % w_p

% tracking area
sceneInfo.imOnGP= [...
    1 sceneInfo.imgHeight ...
    1 imtoplimit ...
    sceneInfo.imgWidth,imtoplimit ...
    sceneInfo.imgWidth,sceneInfo.imgHeight];
        
for h=1:nH
    hyp=H(h);
    s=hyp.start; e=hyp.end;
    
    Ps=0; Pt=0;
    if s>1.5
        [dms,~,~,~]=min_dist_im(hyps.Xi(s,h),hyps.Yi(s,h),sceneInfo.imOnGP);
        Ps=abs(dms)>idHeights(s,h)/4;
    end
    
    if e<F-0.5
        [dms,~,~,~]=min_dist_im(hyps.Xi(e,h),hyps.Yi(e,h),sceneInfo.imOnGP);
        Pt=abs(dms)>idHeights(s,h)/4;        
    end
    persCost=Ps+Pt;
    lcComponents(nC,h)=pF * persCost;

end


%% aspect ratio  (psi ar)
nC=4;

aF=opt.arFactor; % w_a
% aF=0;
aR=zeros(1,nH);
for h=1:nH
    hyp=H(h);
    s=hyp.start; e=hyp.end;
    fr=s:e;    
    aR(h)=mean(hyps.W(fr,h)./hyps.H(fr,h));    
end
% aR
opt.aspectRatio=1/3+(1/2-1/3)/2;
rho=opt.aspectRatio; % average person height

ratioCost=(aR-rho).^2;
lcComponents(nC,:)=aF * ratioCost;

%% bbox size REMOVE
nC=5;
sF=.0001;
sF=0;
bS=zeros(1,nH);
d=1/3+(1/2-1/3)/2;

for h=1:nH
    hyp=H(h);
    s=hyp.start; e=hyp.end;
    fr=s:e;    
%     aR(h)=mean(hyps.W(fr,h)./hyps.H(fr,h));
    
    % expected height
%     eH=feval(htobj,hyps.Xi(fr,h),hyps.Yi(fr,h));
    eH=idHeights(fr,h);
    
    % expected width
    eW=eH*d;
    
    % expected area    
    eA=eH.*eW;
    
%     h
%     eA'
    rA=(hyps.W(fr,h).*hyps.H(fr,h));
%     eA'
%     rA'
    bS(h)=mean(abs(eA-rA));
%     eA'-rA'
%     [eH eW]'
%     [hyps.H(fr,h) hyps.W(fr,h)]'
%     pause
end
% aR
% d=(1/2-1/3)/2;
% ratioCost=max(0,abs((aR-(1/3+d)))-d);
% ratioCost=(aR-(1/3+d)).^2;
bS=bS.^2;
lcComponents(nC,:)=sF * bS;

%% linear velocity (psi dyn)
nC=6;
avF=opt.linVelocityFactor;
av=zeros(1,nH);
canvel=0;
if isfield(opt,'canvel'),
    canvel=opt.canvel;
end

if avF>0    
    
    for h=1:nH
        hyp=H(h);
        slp=getSplineSlope(hyp);
        if canvel>0
            av(h)=sum(abs(slp-canvel));
        else
            av(h) = sum(slp);
        end

    end
end
lcComponents(nC,:)=avF * av.^2;


%% object likelihood (psi lik)
nC=7;
olF=opt.olikFactor;
% precomp
% whether a superpixel is inside hypotheses box
if size(inanyglob,2) == nH && size(inanyglob,1)==size(ISall,1)
    insideany=inanyglob;
%     fprintf('yay 2\n'); pause
else
%     fprintf('nay 2\n'); pause
    insideany=false(size(ISall,1),length(H));
    for t=1:F
        exhyp=find(hyps.Xi(t,:));

        for dd=exhyp
            %             if dd~=dett, continue; end
            bh=hyps.H(t,dd); bw=hyps.W(t,dd);
            bx=hyps.Xi(t,dd)-bw/2;
            by=hyps.Yi(t,dd)-bh;

            insidehyp=find(ISall(:,3)==t & ...
                ISall(:,4)>=bx & ISall(:,5)>=by & ...
                ISall(:,4)<=bx+bw & ...
                ISall(:,5)<=by+bh); % inside hyp box
            insideany(insidehyp,dd)=1;

        end
    end
    inanyglob=insideany;
end

fglik=zeros(1,nH);
allOnesQ=ones(size(Q));
for h=1:nH
    
    fins=find(insideany(:,h))';
    trL=H(h).end-H(h).start+1;

    fglik(h)=sum(allOnesQ(fins)'-Q(fins)')/(numel(fins)+0.001);           

end
if isfield(opt,'sqfglik')
    lcComponents(nC,:)=olF .* fglik.^2;
else
    lcComponents(nC,:)=olF .* fglik;
end
 
%% masked olik


if isfield(opt,'newolik')


    load(opt.objMaskFile);

    [mH,mW]=size(objMask);
    fglik=zeros(1,nH);
    for h=1:nH

        fins=find(insideany(:,h))';
        trL=H(h).end-H(h).start+1;

%         fglik(h)=sum(allOnesQ(fins)'-Q(fins)')/(numel(fins)+0.001);

        hyp=H(h);
        s=hyp.start; e=hyp.end;
        
        
%         fr=s:e; 
%         thisH=0;
        
%         save('tmploop.mat','ISall','insideany','hyps','objMask','fr','Q');
%         pause
%         for t=fr        
%             finsT=find(insideany(:,h) & ISall(:,3)==t)';
% 
%             for l=finsT
% 
% 
%                 bw=hyps.W(t,h);bh=hyps.H(t,h);
%                 x1=hyps.Xi(t,h)-bw/2;
%                 y1=hyps.Yi(t,h)-bh;
% 
%                 mu=ISall(l,5);mv=ISall(l,4);
% 
%                 mvR = round((mv-x1)/bw * mW);
%                 muR = round((mu-y1)/bh * mH);
%                 mvR = max(1,mvR); mvR = min(mW,mvR);
%                 muR = max(1,muR); muR = min(mH,muR);
%                 w=objMask(muR,mvR);
% 
%                 if opt.newolik==1
%                     thisH=thisH+abs(w-Q(l));
%                 elseif opt.newolik==2
%                     thisH=thisH+w*abs(w-Q(l));
%                 elseif opt.newolik==3
%                     thisH=thisH+w*(w-Q(l))^2;
%                 end
% 
%             end
% 
%         end      
        
        % mex replacement for block above
        thisH = maskCost([s,e,h],insideany,ISall,hyps.Xi,hyps.Yi,hyps.W,hyps.H,objMask,Q);


        fglik(h)=thisH/trL;

    end
    lcComponents(nC,:)=olF .* fglik;
end



%% background label is last one
% lcComponents(:,end+1)=0;

% TODO REMOVE SANITY CHECK
lcComponents(lcComponents>1e5)=1e5;
%% just sum up all components
labelCost=sum(lcComponents,1);

end


function [dm, distances, ci, si]=min_dist_im(x,y,imOnGP)
% min distance of a point to the image border

    % left
    x0=imOnGP(1);y0=imOnGP(2);
    x1=imOnGP(3);y1=imOnGP(4);
    dl = p2l(x,y,x0,x1,y0,y1);

    % top
    x0=imOnGP(3);y0=imOnGP(4);
    x1=imOnGP(5);y1=imOnGP(6);
    du = p2l(x,y,x0,x1,y0,y1);

    % right
    x0=imOnGP(5);y0=imOnGP(6);
    x1=imOnGP(7);y1=imOnGP(8);
    dr = p2l(x,y,x0,x1,y0,y1);

    % bottom
    x0=imOnGP(7);y0=imOnGP(8);
    x1=imOnGP(1);y1=imOnGP(2);
    dd = p2l(x,y,x0,x1,y0,y1);
    distances=[dl dr du dd];
    % distances=abs(distances); % absolute
    % distances=sqrt(1+(distances.^2))-1; % psudo huber




    % choose the closest one
    [dm, ci]=min(distances);
    % distances=distances/1000;

    si=1;
end

function dl=p2l(x,y,x0,x1,y0,y1)
% point to line
    dl = ((y0-y1)*x + (x1-x0)*y + (x0*y1-x1*y0) ) / (sqrt((x1-x0)^2 + (y1-y0)^2) );
end