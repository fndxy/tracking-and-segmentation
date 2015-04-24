function do_form_codebook(config_file)
  
%% Created: Jin Wang  06/09/2012

  
%% Evaluate global configuration file
try
    eval(config_file);
catch
    disp('config file failed!')
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% If no VQ structure specifying codebook
%% give some defaults

if ~exist('VQ')
  %% 1000 words is standard setting
  VQ.Codebook_Size = 1000;
  %% Max number of k-means iterations
  VQ.Max_Iterations = 10;
  %% Verbsoity of Mark's code
  VQ.Verbosity = 0;
end

%% load the feature_data
load([FEATURE_DIR,'data_tran.mat']);% use the standarlized features

%% descriptors for the k-means, only use several sequence for each class
% generate random index
temp_index = randperm(size(data_tran{1},2));

all_descriptors = [];
for i = 1:size(data_tran,2)
    for j = 1:size(temp_index,2)/20 % only use a subset (1/20 here) of training data to construct the codebook
        all_descriptors = [all_descriptors,data_tran{i}{temp_index(j)}];
    end
end
clear data_tran; % save memory


%% codebook size
codebook_size = VQ.Codebook_Size;

%% form options structure for clustering
cluster_options.maxiters = VQ.Max_Iterations;
cluster_options.verbose  = VQ.Verbosity;

%% OK, now call kmeans clustering
[centers,sse] = vgg_kmeans(double(all_descriptors), codebook_size, cluster_options);

%% form name to save codebook
du_mkdir(CODEBOOK_DIR);
fname = [CODEBOOK_DIR , 'kmean','_', num2str(codebook_size) , '.mat']; 

%% save centers to file...
save(fname,'centers');
