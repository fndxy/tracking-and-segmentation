function MFTHyps=trimHyp(MFTHyps,id, sceneInfo)
% remove hypotheses boxes close to borders

imH=sceneInfo.imgHeight;
imW=sceneInfo.imgWidth;

[F,~]=size(MFTHyps.W);

W=MFTHyps.W(:,id);
H=MFTHyps.H(:,id);
X1=MFTHyps.Xi(:,id)-W/2;
Y1=MFTHyps.Yi(:,id)-H;
X2=MFTHyps.Xi(:,id)+W/2;
Y2=MFTHyps.Yi(:,id);

bufferMargin=10; % px margin

% find removal candidates
toRem = find(X1<0 | ...
    Y1<0 | ...
    X2>imW | ...
    Y2>imH);

MFTHyps.Xi(toRem,id)=0;
MFTHyps.Yi(toRem,id)=0;
MFTHyps.W(toRem,id)=0;
MFTHyps.H(toRem,id)=0;