function grid = load_data(file, scaleToCm)

path = 'C:\Users\callenberg\Downloads\';

data = h5read([path file], '/data');
deltaT = h5read([path file], '/deltaT');
cameraGridSize = h5read([path file], '/cameraGridSize');

sprintf('wall size = %f', cameraGridSize(1))
sprintf('bin_resolution = %e', cameraGridSize(1)/size(data,1)/3e8)

%%

if startsWith(file, 'chinese_dragon')
    data = squeeze(data);
    data = permute(data, [3, 4, 2, 1]);
end

if ndims(data) == 4
    grid = squeeze(data(:,:,2,:));
    grid = permute(grid, [3, 1, 2]);
else
    disp('this is probably not confocal data');
end


%%
fieldsize = cameraGridSize(1)*100;
origSize = size(grid,2);

T = size(grid, 1)*deltaT;
Nnew = round(T*100);

deltaX = cameraGridSize(1)/size(grid, 2);

if scaleToCm
    
    gridres = zeros(size(grid, 1), fieldsize, fieldsize);
    
    for z = 1:size(grid, 1)
        img = squeeze(grid(z, :, :));
        img = imresize(img, [fieldsize, fieldsize], 'nearest');
        gridres(z, :,:) = img;
    end
    
    
    grid_final = zeros(Nnew, fieldsize, fieldsize);
    
    for x = 1:fieldsize
        img = squeeze(gridres(:,x,:));
        img = imresize(img, [Nnew, fieldsize], 'nearest');
        grid_final(:,x,:) = img;
    end

else
    
    newZsize = round(size(grid, 1)*deltaT*100);
%     newZsize = round(size(grid, 1) * deltaT/deltaX);
    
    grid_final = zeros(newZsize, origSize, origSize);
    
    for x = 1:origSize
        img = squeeze(grid(:,x,:));
        img = imresize(img, [newZsize, origSize]);
        grid_final(:,x,:) = img;
    end
    
end

%%
grid = grid_final;

end