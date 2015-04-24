function do_vq(config_file)

%% Function vector-quantizes the features using the codebook
%% A histogram over codebook entries is also computed and stored.            
  
%% Created: Jin Wang 06/09/2011
   
  
        
%% Evaluate global configuration file
try
    eval(config_file);
catch
    disp('config file failed!')
end

%% load the string data
load([FEATURE_DIR,'data_tran.mat']);
load([CODEBOOK_DIR,'kmean','_', num2str(VQ.Codebook_Size), '.mat']);

%% loop over all features
for i=1:size(data_tran,2)
    disp(i);
    for j = 1:size(data_tran{i},2)
         
        %% Find number of points per time series
        nPoints = size(data_tran{i}{j},2);
    
        %% Set distance matrix to all be large values
        distance = Inf * ones(nPoints,VQ.Codebook_Size);
    
        %% Loop over all centers and all points and get L2 norm btw. the two.
%         for p = 1:nPoints
%             for c = 1:VQ.Codebook_Size
%                 distance(p,c) = norm(centers(:,c) - double(data_tran{i}{j}(:,p)));
%             end
%         end
        

        % much faster than the above loop method
        [row,col]=size(data_tran{i}{j});
        centers = reshape(centers,[row,1,VQ.Codebook_Size]);
        centersMat = repmat(centers,[1,col,1]);
        dataMat = repmat(data_tran{i}{j},[1,1,VQ.Codebook_Size]);
        dataMat = (dataMat - centersMat).^2;
        dataSum = sum(dataMat,1);
        distance = reshape(dataSum,[],size(dataSum,3));% we donot need to .^0.5
        
%         dataSum = reshape(dataSum,[],size(dataSum,3));
%         distance = dataSum.^0.5;
        
        
        %% Now find the closest center for each point
        [tmp,descriptor_vq] = min(distance,[],2);

        %% Now compute histogram over codebook entries for song
        histogram = zeros(1,VQ.Codebook_Size);
        for p = 1:nPoints
            histogram(descriptor_vq(p)) = histogram(descriptor_vq(p)) + 1;
            
        end
        feature_hist{i}(:,j)=histogram';
        
    end
end
    
% save bag-of-words representation
savepath = [FEATURE_DIR,'FeatureHist','_',num2str(sub_length),'_',num2str(VQ.Codebook_Size),'.mat'];
save(savepath,'feature_hist');
