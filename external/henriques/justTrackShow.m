function bb=justTrackShow(sceneInfo,initBox,prevModel,allim)
show_output=true;
% show_output=false;
mid=[]; mt=[];
global jtcnt;

%  Exploiting the Circulant Structure of Tracking-by-detection with Kernels
%
%  Main script for tracking, with a gaussian kernel.
%
%  Jo�o F. Henriques, 2012
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


% [F,N]=size(stInfo.W);


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
% resize_image=false;

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

backwards=initBox(5)>initBox(6);
frames=initBox(5):initBox(6);
if backwards
    frames=fliplr(initBox(6):initBox(5));
end

% frames=initBox(5):F;
% if backwards
%     %     img_files=img_files(end:-1:1);
%     frames=initBox(5):-1:1;
% end

img_files=img_files(frames);
if ~isempty(allim)
    allim=allim(frames);
end
% img_files

time = 0;  %to calculate FPS
bb=zeros(numel(img_files),4);
positions = zeros(numel(img_files), 2);  %to calculate precision

for frame = 1:numel(img_files),
    %     frame
    %     img_files{frame}
    %load image
    
    if ~isempty(allim)
        im=allim{frame}.im;
    else
        im = imread([video_path img_files{frame}]);
        imrgb = imread([video_path img_files{frame}]);
        if size(im,3) > 1,
            im = rgb2gray(im);
        end
    end
    
    if resize_image,
        if ~isempty(allim)
            im=allim{frame}.imhalf;
        else
            im = imresize(im, 0.5);
        end
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
%         size(alphaf)
%         size(z)
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
        if show_output
%             figure('Number','off', 'Name',['Tracker - ' video_path])
            clf;
            im_handle = imshow(imrgb, 'Border','tight', 'InitialMag',200);
            rect_handle = rectangle('Position',rect_position, 'EdgeColor','g','linewidth',3);
        end
        %         rect_handle2 = rectangle('Position',rect_position2, 'EdgeColor','b','linestyle',':');
    else
        try  %subsequent frames, update GUI
            if show_output
                set(im_handle, 'CData', imrgb);
                set(rect_handle, 'Position', rect_position)
            end
            %             set(rect_handle2, 'Position', rect_position2)
        catch  %#ok, user has closed the window
            return
        end
    end
    if show_output,    
        
        drawnow; 
        pause(.01);
%         im2save=getframe(gcf);
%         im2save=im2save.cdata;
%         jtcnt=jtcnt+1;
%         imwrite(im2save,sprintf('tmp/sm/initsol/nbhood/justtrack_%04d.png',jtcnt));
    end
    
%     	pause(0.5)  %uncomment to run slower
    
    
end

% if show_output,close; end
if resize_image, bb = bb * 2; end
bb(:,5)=.75;
% dlmwrite('output/cs.txt',bb);


if resize_image, positions = positions * 2; end

% disp(['Frames-per-second: ' num2str(numel(img_files) / time)])

%show the precisions plot
% show_precision(positions, ground_truth, video_path)

