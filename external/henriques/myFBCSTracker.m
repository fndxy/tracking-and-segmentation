function [mid, mt, bb]=myFBCSTracker(sceneInfo,stInfo,initBox,cid,backwards)

mid=[]; mt=[];
%  Exploiting the Circulant Structure of Tracking-by-detection with Kernels
%
%  Main script for tracking, with a gaussian kernel.
%
%  João F. Henriques, 2012
%  http://www.isr.uc.pt/~henriques/


%choose the path to the videos (you'll be able to choose one with the GUI)
% base_path = './tmp/img2/';
% base_path='d:/diss/others/kalal/_input/';
% base_path='d:/diss/others/fayao/dataset_track/afl4/imgs/';
base_path = sceneInfo.imgFolder;

%parameters according to the paper
padding = 1;					%extra area surrounding the target
output_sigma_factor = 1/16;		%spatial bandwidth (proportional to target)
sigma = 0.2;					%gaussian kernel bandwidth
lambda = 1e-2;					%regularization
interp_factor = 0.075;			%linear interpolation factor for adaptation


[F,N]=size(stInfo.W);
ls=getTracksLifeSpans(stInfo.W);


%notation: variables ending with f are in the frequency domain.

%ask the user for the video
% video_path = choose_video(base_path);
% if isempty(video_path), return, end  %user cancelled
video_path=base_path;
% [img_files, pos, target_sz, resize_image, ground_truth, video_path] = ...
% 	load_video_info(video_path);
% img_files=cellstr(num2str((1:F)','img%05d.png'));
img_files=cellstr(num2str(sceneInfo.frameNums',sceneInfo.imgFileFormat));

% frames=find(stInfo.W(:,cid));
% t1=frames(end);
%set initial position and size
% target_sz = round([stInfo.H(t1,cid) stInfo.W(t1,cid)]);
% pos = floor([stInfo.Yi(t1,cid)-stInfo.H(t1,cid)/2, stInfo.Xi(t1,cid)]);
target_sz=round([initBox(4), initBox(3)]);
pos = round([initBox(2), initBox(1)] + target_sz./2);
pos2=pos;


if sqrt(prod(target_sz)) >= 100,
    resize_image = true;
else
    resize_image = false;
end
%     ground_truth=[];
resize_image=false;

if resize_image
    pos = floor(pos / 2);
    target_sz = floor(target_sz / 2);
end

%window size, taking padding into account
sz = floor(target_sz * (1 + padding));

%desired output (gaussian shaped), bandwidth proportional to target size
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor;
[rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
yf = fft2(y);

%store pre-computed cosine window
cos_window = hann2(sz(1)) * hann2(sz(2))';




frames=initBox(5):F;
if backwards
%     img_files=img_files(end:-1:1);
    frames=initBox(5):-1:1;
end


img_files=img_files(frames);

time = 0;  %to calculate FPS
bb=zeros(numel(img_files),4);
positions = zeros(numel(img_files), 2);  %to calculate precision

for frame = 1:numel(img_files),
%     frame
%     img_files{frame}
    %load image
    
    im = imread([video_path img_files{frame}]);
    if size(im,3) > 1,
        im = rgb2gray(im);
    end
    if resize_image,
        im = imresize(im, 0.5);
    end
    
    tic()
    
    %extract and pre-process subwindow
    x = get_subwindow(im, pos, sz, cos_window);
    
    if frame > 1,
        %calculate response of the classifier at all locations
        k = dense_gauss_kernel(sigma, x, z);
        response = real(ifft2(alphaf .* fft2(k)));   %(Eq. 9)
        
        %target location is at the maximum response
        [row, col] = find(response == max(response(:)), 1);
        pos = pos - floor(sz/2) + [row, col];
        %         response(1:15)
        
% % %         [sorted_response, sort_ind]=sort(response(:),'descend');        
% % %         [row, col] = ind2sub(size(response),sort_ind(1));
% % %         pos = pos - floor(sz/2) + [row, col];
% % %         pos2=pos;
% % %         searchindex=1;
% % %         x1=pos(2); y1=pos(1); w1=sz(2); h1=sz(1);
% % %         lrthr=.4;
% % %         while 1
% % %             searchindex=searchindex+1;
% % %             if searchindex>length(sort_ind)
% % %                 break; 
% % %             end       
% % %             if sorted_response(searchindex)/sorted_response(1) < lrthr
% % %                 break;
% % %             end
% % %             
% % %             [row2, col2] = ind2sub(size(response),sort_ind(searchindex));
% % %             p2 = pos - floor(sz/2) + [row2, col2];
% % %             x2=p2(2); y2=p2(1);
% % %             
% % %             iou=boxiou(x1,y1,w1,h1,x2,y2,w1,h1);
% % %             if iou<.75 
% % %                 pos2 = pos - floor(sz/2) + [row2, col2];
% % %                 break;
% % %             end
% % %             
% % %         end
% % %         
        

        
    end
    
    %get subwindow at current estimated target position, to train classifer
    x = get_subwindow(im, pos, sz, cos_window);
    
    %Kernel Regularized Least-Squares, calculate alphas (in Fourier domain)
    k = dense_gauss_kernel(sigma, x);
    new_alphaf = yf ./ (fft2(k) + lambda);   %(Eq. 7)
    new_z = x;
    
    if frame == 1,  %first frame, train with a single image
        alphaf = new_alphaf;
        z = x;
    else
        %subsequent frames, interpolate model
        alphaf = (1 - interp_factor) * alphaf + interp_factor * new_alphaf;
        z = (1 - interp_factor) * z + interp_factor * new_z;
    end
        
    %save position and calculate FPS
    positions(frame,:) = pos;

    time = time + toc();
    
    %visualization
    rect_position = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
%     if resize_image, rect_position=rect_position*2; end
%     rect_position2 = [pos2([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    bb(frame,:)=rect_position;
    
    imfr=sscanf(img_files{frame},sceneInfo.imgFileFormat);
    fr=find(sceneInfo.frameNums==imfr);
%     im = imread(sprintf('d:/acvt/projects/tracker-mot/data/tmp/afl-acf-cs-dco/final/frame_%04d.jpg',fr));
    if frame == 1,  %first frame, create GUI
        figure('Number','off', 'Name',['Tracker - ' video_path])
        im_handle = imshow(im, 'Border','tight', 'InitialMag',200);
        rect_handle = rectangle('Position',rect_position, 'EdgeColor','g');
%         rect_handle2 = rectangle('Position',rect_position2, 'EdgeColor','b','linestyle',':');
    else
        try  %subsequent frames, update GUI
            set(im_handle, 'CData', im)
            set(rect_handle, 'Position', rect_position)
%             set(rect_handle2, 'Position', rect_position2)
        catch  %#ok, user has closed the window
            return
        end
    end
%     pause
    % check overlaps
    ious=zeros(1,N);
    for id=1:N
%         id
        if id==cid, continue; end
%         stInfo.W(fr,id)
%         pause
        if ~stInfo.W(fr,id), continue; end
        
        x1a=rect_position(1); y1a=rect_position(2);
        w1=rect_position(3); h1=rect_position(4);
        x2a=x1a+w1; y2a=y1a+h1;
        
        w2=stInfo.W(fr,id); h2=stInfo.H(fr,id);
        
        x1b=stInfo.Xi(fr,id)-w2/2;
        y1b=stInfo.Yi(fr,id)-h2;
        x2b=stInfo.Xi(fr,id)+w2/2;
        y2b=stInfo.Yi(fr,id);
        
%         if x1a>x2b || x2a<x1b, continue; end
%         if y1a>y2b || y2a<y1b, continue; end
        
        %         w1=x2a-x1a; h1=y2a-y1a;
%                 [x1a y1a w1 h1]
%                 [x1b y1b w2 h2]
        ious(id)=boxiou(x1a,y1a,w1,h1,x1b,y1b,w2,h2);
%         ious(id)
%                 pause
    end
%     ious
%     pause
    [maxiou, tarid]=max(ious);
    starting=ls(tarid,1)==fr;
    ending=ls(tarid,2)==fr;
    termpt= (starting || ending);
%     maxiou
%     tarid
    if maxiou>.5 && termpt
        fprintf('tracker %d encountered id %d at frame %d\n',cid,tarid,fr);
        mid=tarid;
        mt=fr;
        bb=bb(1:frame,:);
        pause(.1);
        break;
    end
    
    if frame==numel(img_files)
        fprintf('tracker %d terminated at final frame %d\n',cid,fr);
        mid=0;
        mt=fr;
        bb=bb(1:frame,:);
        pause(.1);
        break;
    end
    
    bm=5;
    if frame>1 && (x1a<bm || y1a<bm || x1a+w1>sceneInfo.imgWidth-bm || y1a+h1>sceneInfo.imgHeight-bm)
        fprintf('tracker %d terminated at image border in frame %d\n',cid,fr);
        mid=0;
        mt=fr;
        bb=bb(1:frame,:);
        pause(.1);
        break;
    end
    
    %     ious
    %     pause
    
    
    drawnow
    
    % 	pause(0.05)  %uncomment to run slower
    
    
end

close
if resize_image, bb = bb * 2; end
bb(:,5)=.75;
% dlmwrite('output/cs.txt',bb);


if resize_image, positions = positions * 2; end

disp(['Frames-per-second: ' num2str(numel(img_files) / time)])

%show the precisions plot
% show_precision(positions, ground_truth, video_path)

