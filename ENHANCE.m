function out = ENHANCE(in, cameraModel, ratioMax)
if ~exist('cameraModel', 'var')
    cameraModel = CameraModels.Sigmoid();
end
if ~isfloat(in), in = im2double(in); end
estimater = @(t)limeEstimate(t, 0.15, 2);

imgType = DetermineTypeOfImage(in);
%%
T = max(in, [], 3);
T = imresize( estimater( imresize( T, 0.5 ) ), size(T) );
K = repmat(min(1./T,ratioMax),[1,1,size(in,3)]); % white-ish mask
if strcmp(imgType, 'light')
    K = -K; % if the image has too much light, flip the mask to black-ish
end
out = cameraModel.btf(in, K);
end