function w=getGaussMasks(im,dets)
%%
% x=size(im,1)/2;
% y=size(im,2)/2;

nDet=length(dets.sc);

w=zeros(size(im,1),size(im,2));
for det=1:nDet
    wd=dets.wd(det);
    ht=dets.ht(det);
    x=dets.yi(det)-ht/2;
    y=dets.xi(det);
    sco=dets.sc(det);
    bx=dets.bx(det);
    by=dets.by(det);

    SIG=[(ht/4)^2*2 0; 0 (wd/4)^2/2];
    sa=SIG(1,1); sb=SIG(2,1); sc=SIG(1,2); sd=SIG(2,2);
    detSIG=sa*sd - sb*sc;
    oneOverDetSIG=1/detSIG;
    normfac=1/(2*pi*sqrt(detSIG));
    SIGINV=oneOverDetSIG * [SIG(4) -SIG(3); -SIG(2) SIG(1)];
    sia=SIGINV(1); sid=SIGINV(4);
    x1 = 1:size(im,1);
    x2 = 1:size(im,2);
    
    xx = x1(:).'; % Make sure x is a full row vector.
    yy = x2(:);   % Make sure y is a full column vector.
    nx = length(xx); ny = length(yy);
    X1 = xx(ones(ny, 1),:);
    X2 = yy(:,ones(1, nx));
    X1=X1'; X2=X2';
    
    % speed up mvnpdf. only valid for matrices with offdiagonal = 0 !!!
    xlessm=X1(:)-x;
    ylessm=X2(:)-y;
    
    xlmsq=sia*xlessm.^2;
    ylmsq=sid*ylessm.^2;
    expon=-0.5*(xlmsq+ylmsq);
    
    expterm=exp(expon);
%     expterm = expterm * normfac;
    expterm = expterm * sco;
    expterm=reshape(expterm,length(x1),length(x2));
    
    w=w+expterm;
%     imtight(w);
%     pause
end
% imshow(w);
% pause
% sum(w(:))