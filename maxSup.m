function mat = maxSup(matrix)
    %disp('input size: '); disp(size(matrix));
    [r, c] = find(matrix == max(matrix));
    maxPerCol = zeros(size(matrix, 1), size(matrix, 2));
    for i = 1:size(matrix, 2)
        maxPerCol(:, i) = matrix(r(i), c(i));
    end
    mat = matrix .* (matrix == maxPerCol);
end