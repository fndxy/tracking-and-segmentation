%%
maxSamples=5000;
% addpath(genpath('../../external/liblinear-1.94'));

%%
newallneg=find(allneg);
allnegperm=newallneg(randperm(length(newallneg)));
newallneg=allneg;
newallneg(allnegperm(maxSamples+1:end))=0;
allneg=newallneg;

newallpos=find(allpos);
allposperm=newallpos(randperm(length(newallpos)));
newallpos=allpos;
newallpos(allposperm(maxSamples+1:end))=0;
allpos=newallpos;

%%
nPos=length(find(allpos)); 
% nPos=numel(find(QGT==1));
% nNeg=size(NWords,1);
nNeg=length(find(allneg));
tr_lab_vec=[-1*ones(nNeg,1); ones(nPos,1)];

fprintf('Neg Samples: %d\n',nNeg);
fprintf('Pos Samples: %d\n',nPos);

if nPos>0
    featidx=[6:8];
    if isfield(opt,'spfeat')
        featidx=[opt.spfeat];
    end
% featidx=[6:10];
featmat=ISall(:,featidx);
% featmat=[featmat abs(ISall(:,4)-ISall(:,9))];
% featmat=[featmat abs(ISall(:,5)-ISall(:,10))];

% det scores
% featmat=spscores;
% featmat=[featmat spscores];

%% flow variance
% cnt=0;
% for t=1:F
%     fprintf('.');
%     thisF=sp_labels(:,:,t);
%     ndet=length(detections(t).sc);
% %     im=getFrame(sceneInfo,t);
%     im=iminfo(t).img;
%     imrgb=rgb2gray(im);
%     npix=size(im,1)*size(im,2);
%     segs=unique(thisF(:))';
% 
%     Itmp=rgb2gray(zeros(size(im)));
%     
%     % flow %%%    
%     if t==1
%         flow2=flowinfo(t+1);
%         meanflowX=flow2.flow.fvx;
%         meanflowY=flow2.flow.fvy;
%         
%     elseif t==F
%         flow1=flowinfo(t);
%         meanflowX=-flow1.flow.bvx;
%         meanflowY=-flow1.flow.bvy;        
%     else
%         flow1=flowinfo(t);
%         flow2=flowinfo(t+1);
%         
%         meanflowX=.5*(-flow1.flow.bvx+flow2.flow.fvx);
%         meanflowY=.5*(-flow1.flow.bvy+flow2.flow.fvy);
%     end
%     %%% flow %%%
%     
% %     meanflowY01=(meanflowY-min(meanflowY(:)))/(max(meanflowY(:)) - min(meanflowY(:)));
%     
%     for s=segs
%         cnt=cnt+1;
% %         if t~=2, continue; end
%         [u,v]=find(thisF==s);
%         imind=sub2ind(size(thisF),u,v);
%                 
%         spvarX(cnt)=var(meanflowX(imind));
%         spvarY(cnt)=var(meanflowY(imind));
%     end
% end

%%
if max(featidx)>8, featmat(:,end-1:end)=abs(featmat(:,end-1:end)); end
% featmat(:,4)=sqrt(featmat(:,4).^2 + featmat(:,5).^2); featmat=featmat(:,1:4);
% negidx=NWords(:,7);

% featmat=[featmat spvarX' spvarY'];

% sp BBox
% spBoxFeatures;
% zfeat=zeros(size(featmat));
% zfeat(end,:)=LabBB1(end,:);
% LabFeat=[];
% LabFeat=[LabBB1 LabBB2 LabBB3];
% featmat=[featmat LabFeat];
% featmat=[LabD1 LabD2 LabD3 LabD4];

%detDistFeatures;
% featmat=[featmat spOffsetToBB];
if any(sum(featmat)==0), error; end

% feature scaling
% rescaling [0,1]


% high-order emulation
if isfield(opt,'featavg')
    featAveraging;
    featmat=[featmat augfeat]; 
end

featmat=(featmat - repmat(min(featmat),size(featmat,1),1)) ./ repmat(max(featmat)-min(featmat),size(featmat,1),1);
% featmat(:,4)=featmat(:,4)*.00001;
% featmat=featmat(:,[1:3]);
% rescaling ||x||
% featmat=sqrt(sum(featmat.^2,2));
if isfield(opt,'featavg')
    featmat(:,4:end)=featmat(:,4:end) * opt.featavg(1);
end

negidx=find(allneg);
posidx=find(allpos);
% posidx=(find(QGT==1));


tr_inst_mat=featmat(negidx,:);
tr_inst_mat=[tr_inst_mat; featmat(posidx,:)];

% ONE CLASS
% NEG ONLY
% negidx=NWords(:,7);
% tr_inst_mat=featmat(negidx,:);
% tr_lab_vec=-1*ones(nNeg,1);
%
% POS ONLY
% tr_inst_mat=featmat(posidx,:);
% tr_lab_vec=ones(nPos,1);





% tr_inst_mat=ISall([find(allneg);find(allpos)],6:8);


svm_type=0;     % 0 C-SVC (multiclass)
kernel_type=0;  % 0 linear,  1 polynomial, 2 rbf
epsilon=.5;     % tolerance of termination criterion
shrinking=0;    % shrinking heuristic
loss_cost=1000; % C parameter
posWeighting=1;
negWeighting=nPos/nNeg;


%%%%%%%%%
% lib svm
% lsvm_opt='-s 0 -t 0 -e .1 -h 0 -c 1000 -w-1 .1 -w1 1';
% lsvm_opt=sprintf('-s %d -t %d -e %f -h %d -c %f -w-1 %f -w1 %d', ...
%     svm_type, kernel_type, epsilon, shrinking, loss_cost, negWeighting, posWeighting);
% lsvm_opt='-s 0 -t 0 -v 10';
% model = svmtrain(tr_lab_vec,tr_inst_mat,lsvm_opt);

%%%%%%%%%%%%
% lib linear
ll_opt=sprintf('-s %d -e %f -c %f -w-1 %f -w1 %d', ...
    0, epsilon*.01, loss_cost*100, negWeighting, posWeighting);

modelliblin = train(tr_lab_vec, sparse(tr_inst_mat),ll_opt);

test_inst_mat=featmat;
test_lab_vec=rand(size(ISall,1),1);
% [pr_lab, acc, dec_val]=svmpredict(test_lab_vec,test_inst_mat,model);
[pr_lab_liblin, acc_liblin, dec_val_liblin]=predict(test_lab_vec, sparse(test_inst_mat), modelliblin);
dec_val = dec_val_liblin;
% dec_val=-dec_val;
% sigA=5; sigB=.5;
sigA=0; sigB=1;
sigA=0; sigB=2;
% QC=1./(1+exp(-sigB*Q+sigA*sigB));
Q=1./(1+exp(-sigB*dec_val+sigA*sigB));
% Q=dec_val./max(dec_val(:));
% Q=pr_lab; Q(Q<0)=0;

else
    Q=zeros(size(ISall,1),1);
end

%%
if 1 && usejava('desktop')
cnt=0;
for t=1
    fprintf('.');
    thisF=sp_labels(:,:,t);
    ndet=length(detections(t).sc);
%     im=getFrame(sceneInfo,t);
    im=iminfo(t).img;
    npix=size(im,1)*size(im,2);
    segs=unique(thisF(:))';

    w=getGaussMasks(im,detections(t));
    Itmpc=rgb2gray(zeros(size(im)));
    Itmp=rgb2gray(zeros(size(im)));
%     Itmp=im;
    for s=segs
        cnt=cnt+1;
        [u,v]=find(thisF==s);
        spLH=Q(cnt);        
%         spLH=spLH*QD(cnt);
%         spLH=Q(cnt)*w(round(mean(u)),round(mean(v)));
%         spLH
%         spLH=Q(cnt)+w(round(mean(u)),round(mean(v)));
        imind=sub2ind(size(thisF),u,v);
        Itmp(imind)=spLH;
%         Itmp(imind)=featmat(cnt);
        Itmpc(imind)=QC(cnt);
%         Q(cnt)=spLH;
%         imtight(Itmp);
%         Q(cnt)
%         pause
    end
    figure(1);
    imtight(Itmp,[0 1]);
%     imwrite(Itmpc,sprintf('tmp/hyp/s%02d-f%04d-lhco.jpg',scenario,sceneInfo.frameNums(t)));
    imwrite(Itmp,sprintf('tmp/hyp/s%02d-f%04d-lh.jpg',scenario,t));

    pause(.01);
end
end

% 
% fgbg=Itmp;[pr,rc]=evalFGBG(gt,fgbg);
% figure(2); 
% clf; hold on
% plot(rcO,prO,'r','linewidth',2); 
% plot(rcL,prL,'g','linewidth',2); 
% plot(rc,pr); 
% box on
% xlabel('recall'); ylabel('precision');
% legend('Classic','Laura','new');
% figure(1);