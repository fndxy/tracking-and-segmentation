function do_representation(config_file)
  
%% Top-level function that calls code to compute respresentaion

%% Created: Jin Wang 06/09/2012.

%% Evaluate global configuration file
try
    eval(config_file);
catch
    disp('config file failed');
end

load([DATA_DIR,'data_all.mat']);

for i = 1:size(data_all,2)
    for j = 1:size(data_all{i},2)
        %% sliding a subwindows along a time series and extract a feature
        %% vector for each sub sequences by transformation (e.g., 'wavelet')
         disp('class  instance');
         disp([i,j]);
        data_tran{i}{j} = series_transform(data_all{i}{j}',sub_length,inter_point);
    end
end
    
du_mkdir(FEATURE_DIR);
save([FEATURE_DIR,'data_tran.mat'],'data_tran');
