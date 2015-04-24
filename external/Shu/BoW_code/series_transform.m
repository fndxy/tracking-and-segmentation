function tran = series_transform(data,sub_length,inter_point)
%% sliding a subwindows along a time series and extract a feature
%% vector for each sub sequences by transformation (e.g.,'wavelet')
%% Created by Jin Wang    06/09/2011

% data    1*D matrix    D is the length of time series
% sub_length   the length of the subwindow

tran=[];
for i = 1:inter_point:length(data)-sub_length
    sub_sequence = data(i:i+sub_length-1);
    
    sub_sequence = (sub_sequence-mean(sub_sequence))/std(sub_sequence);
    
%     [sub_tran aa] = dwt(sub_sequence,'db1');
    [sub_tran aa] = dwt(sub_sequence,'db3');
    bb=norm(sub_tran);
    sub_tran = sub_tran/bb;
    tran=[tran,sub_tran'];
end