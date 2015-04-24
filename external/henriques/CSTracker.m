function [test_results, metaInfo]=CSTracker(stateInfo)

cd d:/diss/others/henriques/

test_results=[];
metaInfo.targetsTracked=[];

% get scene info
global scenario backwards opt

[F, N]=size(stateInfo.W);
training_length=1;
k=10;

if backwards
    stateInfo.X=flipdim(stateInfo.X,1);
    stateInfo.Y=flipdim(stateInfo.Y,1);
    stateInfo.W=flipdim(stateInfo.W,1);
    stateInfo.H=flipdim(stateInfo.H,1);
    stateInfo.Xi=flipdim(stateInfo.Xi,1);
    stateInfo.Yi=flipdim(stateInfo.Yi,1);
end

for id=1:N
    fprintf('tracking id %d (of %d)...\n',id,N);
    
    sceneInfo=stateInfo.sceneInfo;
    if backwards
        sceneInfo.frameNums=fliplr(sceneInfo.frameNums);
    end
    
    extar = find(stateInfo.W(:,id));
    fprintf('Target %d: %d..%d\n',id,extar(1),extar(end));
    
    if length(extar) < training_length
        fprintf('trajectory too short, skip...\n');
        continue;
    end
    
    if extar(end)==F
        fprintf('trajectory ends at last frame, skip...\n');
        continue;
    end
    
    if opt.track3d
        dist_to_border=dist_to_ta_border(...
            stateInfo.X(extar(end),id),stateInfo.Y(extar(end),id), ...
            sceneInfo);
        dist_to_border_p=dist_to_ta_border(...
            stateInfo.X(extar(end)-1,id),stateInfo.Y(extar(end)-1,id), ...
            sceneInfo);        
    else
        dist_to_border=dist_to_im_border(...
            stateInfo.Xi(extar(end),id),stateInfo.Yi(extar(end),id), ...
            stateInfo.W(extar(end),id),stateInfo.H(extar(end),id), ...
            sceneInfo.imgWidth,sceneInfo.imgHeight);
        dist_to_border_p=dist_to_im_border(...
            stateInfo.Xi(extar(end)-1,id),stateInfo.Yi(extar(end)-1,id), ...
            stateInfo.W(extar(end)-1,id),stateInfo.H(extar(end)-1,id), ...
            sceneInfo.imgWidth,sceneInfo.imgHeight);
    end
    
    
    exiting = dist_to_border<dist_to_border_p;
    fprintf('exiting?... %d\n', exiting);
    fprintf('dist to border: %.2f\n',dist_to_border);
    if  dist_to_border < sceneInfo.targetSize*2 && exiting
        fprintf('trajectory starts/ends close to the border, skip...\n');
        continue;
    end
    
    start_training = extar(end)-training_length+1;
    end_training = extar(end);
    
    frames=start_training:min(F,end_training+k);
    sceneInfo.frameNums=sceneInfo.frameNums(frames);
%     frames
    sceneInfo.frameNums
    % save information about tracked target
    metaInfo.targetsTracked(id,1)=frames(1);
    metaInfo.targetsTracked(id,2)=frames(end);
    
    frgt=(1:training_length)';
    fprintf('Training on...')
    disp(frgt')
    
    % copy images
    delete('tmp/img2/*');
    for t=1:length(frames)
        imfile=[sceneInfo.imgFolder sprintf(sceneInfo.imgFileFormat,sceneInfo.frameNums(t))];
%         imfile=sprintf('d:/acvt/projects/tracker-mot/data/tmp/afl-acf-cs-dco/final/frame_%04d.jpg',t);
        copyfile(imfile,'tmp/img2/');
    end
    pause(.01);
    % if backwards, rename
    if backwards
        imgs=dir('tmp/img2');
        for nim=1:length(imgs)
            if ~imgs(nim).isdir
                [~,f,e]=fileparts(imgs(nim).name);
                oldf=['tmp/img2/' f e];
                newf=['tmp/img2/' sprintf('back_%04d',length(imgs)-nim) e];
                movefile(oldf,newf);
                pause(.01);
            end
        end
    end
    
    % create init box file
    t=end_training;
    xi=stateInfo.Xi(t,id);yi=stateInfo.Yi(t,id);
    w=stateInfo.W(t,id);h=stateInfo.H(t,id);
    bb=[xi-w/2 yi-h w h];
    bb(bb<1)=1; bb(3)=min(bb(3),sceneInfo.imgWidth); bb(4)=min(bb(4),sceneInfo.imgHeight);
    bb=round(bb);
    dlmwrite('tmp/img2/init_gt.txt',bb);
    myCSTracker;
    fdir='f'; if backwards, fdir='b'; end
    bb=load('output/cs.txt');
    bb=[bb(:,2) bb(:,1) bb(:,2)+bb(:,4) bb(:,1)+bb(:,3) bb(:,5)];    
    tr=find(~isnan(bb(:,1)));
    bb=bb(tr,:);
%     metaInfo.targetsTracked(id,1)=frames(1);
    metaInfo.targetsTracked(id,2)=frames(1)+size(bb,1)-1;
%     metaInfo.targetsTracked
%     pause
%     copyfile('_output/tld.txt',sprintf('test_results_loop/%s/%s_%02d.txt',fdir,stateInfo.sceneInfo.sequence,id));
    dlmwrite(sprintf('test_results_loop/%s/%s_%02d.txt',fdir,stateInfo.sceneInfo.sequence,id),bb);
    
%     metaInfo
    
end


end


function d=dist_to_im_border(x,y,w,h,imwidth,imheight)
dist_top=abs(y-h);
dist_left=abs(x-w/2);
dist_bottom=abs(imheight-y);
dist_right=abs(imwidth-x-w/2);
d=min([dist_top, dist_left, dist_bottom, dist_right]);
end

function d=dist_to_ta_border(x,y,sceneInfo)
dist_top=abs(y-sceneInfo.trackingArea(2));
dist_left=abs(x-sceneInfo.trackingArea(1));
dist_bottom=abs(y-sceneInfo.trackingArea(4));
dist_right=abs(x-sceneInfo.trackingArea(3));
d=min([dist_top, dist_left, dist_bottom, dist_right]);
end
