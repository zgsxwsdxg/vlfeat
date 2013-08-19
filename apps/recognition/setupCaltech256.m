function imdb = setupCaltech256(datasetDir, varargin)
% SETUPCALTECH256    Setup Caltech 256 and 101 datasets
%    This is similar to SETUPGENERIC(), with modifications to setup
%    Caltech-101 and Caltech-256 according to the standard
%    evaluation protocols. Specific options include:
%
%    Variant:: 'caltech256'
%      Either 'caltech101' or 'caltech256'.
%
%    AutoDownload:: true
%      Automatically download the data from the Internet if not
%      found at DATASETDIR.
%
%    See:: SETUPGENERIC().

opts.lite = false ;
opts.numTrain = 30 ;
opts.numTest = 25 ;
opts.seed = 1 ;
opts.variant = 'caltech256' ;
opts.autoDownload = true ;
opts = vl_argparse(opts, varargin) ;

% Download and unpack
vl_xmkdir(datasetDir) ;
switch opts.variant
  case 'caltech101'
    name = '101_ObjectCategories' ;
    checkClassName = 'airplanes' ;
    url = 'http://www.vision.caltech.edu/Image_Datasets/Caltech101/101_ObjectCategories.tar.gz' ;
    numClasses = 102 ;
  case 'caltech256'
    name = '256_ObjectCategories' ;
    checkClassName = '001.ak47' ;
    url = 'http://www.vision.caltech.edu/Image_Datasets/Caltech256/256_ObjectCategories.tar' ;
    numClasses = 257 ;
  otherwise
    error('Uknown dataset variant ''%s''.', opts.variant) ;
end

if exist(fullfile(datasetDir, checkClassName), 'file')
  % ok
elseif exist(fullfile(datasetDir, name, checkClassName), 'file')
  datasetDir = fullfile(datasetDir, name) ;
elseif opts.autoDownload
  fprintf('Downloading %s data to ''%s''. This will take a while.', opts.variant, datasetDir) ;
  untar(url, datasetDir) ;
  datasetDir = fullfile(datasetDir, name) ;
else
  error('Could not find %s dataset in ''%s''', opts.variant, datasetDir) ;
end

% Read classes
imdb = setupGeneric(datasetDir, ...
  'numTrain', opts.numTrain, 'numVal', 0, 'numTest', opts.numTest,  ...
  'expectedNumClasses', numClasses, ...
  'seed', opts.seed, 'lite', opts.lite) ;

% In Caltech 256 background is not evaluated
switch opts.variant
  case 'caltech101'
  case 'caltech256'
    imdb.images.sets(classes == 257) = 0 ;
    ok = find(imdb.images.sets ~= 0) ;
    imdb.images.id = ids(ok) ;
    imdb.images.name = names(ok) ;
    imdb.images.set = sets(ok) ;
    imdb.images.class = classes(ok) ;
end

