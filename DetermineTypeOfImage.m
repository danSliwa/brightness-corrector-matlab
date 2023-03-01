function imgType = DetermineTypeOfImage(inputImg)
% Deciding if the image is dark or light:
inputImg = real(inputImg);
hist = histcounts(inputImg, 256); % histogram
sumDark = sum(hist(1:56));
sumLight = sum(hist(200:256));

if sumLight > sumDark
    imgType = 'light';
else
    imgType = 'dark';
end
end