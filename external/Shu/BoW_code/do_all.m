% extract local segments
do_representation('config_file_128_1000');

% construct codebook
do_form_codebook('config_file_128_1000');

% codewords assignment
do_vq('config_file_128_1000');