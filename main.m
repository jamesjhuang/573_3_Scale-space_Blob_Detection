% Main
% CSE573_HW2
% Written by: James J. Huang

imPath = '../data/poolball.jpeg';
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~ Blob detection with increasing filter size ~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
k = sqrt(2);
n = 10;
sigma_init = sqrt(2);
threshold = 0.045;
figure;
tic
blobDetection(imPath, k, n, sigma_init, threshold);
t_M1 = toc;
clearvars -except t_M1 k n sigma_init threshold imPath

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~ Blob detection with 1 filter and downsampled image ~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
sigma_down = sigma_init;
k_down = k;
threshold_down = threshold;
n_down = n;
figure;
tic
blobDownsample(imPath, k_down, n_down, sigma_down, threshold_down);
t_M2 = toc;

if t_M2 > t_M1
    fprintf('Downsample is slower by %.3d seconds\n', t_M2 - t_M1);
else
    fprintf('Downsample is faster by %.3d seconds\n', t_M1 - t_M2);
end
