%% compile mex files

srcFiles={'maskCost','unariesOF','unariesCol','insideAny','labelcount','xdotyMex'};
srcExt='c';
srcdir=fullfile(pwd,'mex','src');
outdir=fullfile(pwd,'mex','bin');

if ~exist(outdir,'dir'), mkdir(outdir); end

opts='-silent -O CFLAGS="\$CFLAGS -std=c99"'; 
% if ispc, opts=''; end

for k=1:length(srcFiles)
    eval(sprintf('mex %s -outdir %s %s.%s',opts,outdir,fullfile(srcdir,char(srcFiles(k))),srcExt));
end

fprintf('Mex compiled successfully!\n');