% Scale-space Blob Detection
% CSE573 Homework 2
% Written by: James J. Huang
% Date: 10-05-2017

function blobDetection(imPath, k, n, sigma_init, threshold)
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Arguments:
    %            imPath      - Path of image to be processed
    %            k           - Scale factor for sigma
    %            n           - Number of scales used
    %            sigma_init  - Initial sigma value
    %            threshold   - Threshold for which maxima must satisfy
    % Return:
    %            blob_image  - Image passed in with blobs on top
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    
    %% Loading and preprocessing
    % Load image
    im = imread(imPath);

    % Convert image to grayscale and double
    imG = rgb2gray(im);
    imG = im2double(imG);

    % Image dimensions
    w = size(imG, 2);
    h = size(imG, 1);
    
    %% Building a Laplacian scale space
    close all;
    
    % Assigning initial sigma and size of filter;
    sigma = zeros(n, 1);
    sigma(1) = sigma_init;
    sizeLOG = zeros(n ,1);
    sizeLOG(1) = 2*ceil(3*sigma(1)) + 1;
    
    % Populaing sigma and size matrix
    for i = 2:n
        sigma(i) = k * sigma(i-1);
        sizeLOG(i) = 2*ceil(2.5*sigma(i)) + 1;
    end
    
    % Radius of circle
    radius = sqrt(2) * sigma;

    % Initialize cell to store LoG filters
    filterLOG = cell(n ,1);

    % Initialize scale space matrix and localMax matrix
    % localMax keeps the local layer maxima values after applying
    % either ordfilt2 or colfilt
    scale_space = zeros(h, w, n);
    localMax = zeros(h, w, n);

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %~~~~~~~~~~~~~~~~ LoG filter and local maxima search ~~~ ~~~~~~~~~~~%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    for i = 1:n
        scale = scale_space(:, :, i);
        % Generating normalized LoG filter of size sizeLOG and sigma
        filterLOG{i} = sigma(i)^2 * fspecial('log', sizeLOG(i), sigma(i));
        % Applying LoG filter on smoothed image
        scale =  (imfilter(imG, filterLOG{i}, 'replicate')).^2;
        scale_space(:, :, i) = scale;
        % Using ordfilt2 or colfilt to find local maximum of 3x3 matrices 
        % over the image and replacing other 8 elements with local max
        %scale = colfilt(scale, [3 3], 'sliding', @max);
        scale = ordfilt2(scale, 9, ones(3));
        % Saving local scale max 
        localMax(:, :, i) = scale;
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %~~~~~~~~~ Scale space suppression per pixel in all scales ~~~~~~~~~%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Initialize 3D matrix to store max pixel values of all scales
    scaleMax = zeros(h, w, n);
    
    for i = 1:numel(scale_space(:,:,1))
        % Converting form index to subscripts helps avoid nested for-loops
        [y, x] = ind2sub([h w], i);
        % Looking for max value of pixel in 3rd dimension
        maxPixel = max(localMax(y, x, :));
        % Assigning the max value found to all pixels with same subscript 
        % in all scales
        scaleMax(y, x, :) = maxPixel;
    end     
    
    % First logical finds the scale where max value appears, second 
    % logical eliminates any max value lower than threshold
    scale_space = (scale_space == scaleMax) .* (scale_space > threshold)...
                  .* scale_space;
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Finding x, and y coordinates of surviving maxima along with the
    % scale at which it is located, and converting that to radius 
    [y, x, z] = ind2sub(size(scale_space), find(scale_space > 0));
    circY = y;
    circX = x;
    circR = radius(z);

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Plotting detected blobs on image
    show_all_circles(imG, circX, circY, circR);
    title({'Increasing filter size method', strcat(num2str(numel(circR)), ' circles')}...
        , 'FontSize', 24); 
    xlabel(strcat('threshold = ', num2str(threshold)), 'FontSize', 24);   
end


