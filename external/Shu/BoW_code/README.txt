This code is used to demonstrate the bag-of-words representation for biomedical time series. To show the demostration, execute "mex vgg_kmiter.cxx" to compile the c library and run the file "do_all.m". The original time seires locates in ./data/original_data/ and the bag-of-words representation will be ./data/feature/FeatureHist_128_1000.mat

Note that it has been tested under 64-bit Linux environment using MATLAB 7.11.0. You have to compile the file "vgg_kmiter.cxx" by "mex vgg_kmiter.cxx" in MATLAB

For more details, please refer our paper "J.Wang et al. Bag-of-words representation for biomedical time series classification". For any questions, please contact Jin Wang <jay.wangjin@gmail.com>.

