function [gt, grid] = create_ground_truth(wallsize, confocal, geometrytype)
% creates a ground truth 3D scene and a corresponding NLOS "measurement"

gt = zeros(wallsize,wallsize,wallsize);

disp('Creating geometry and calculating cones...');


switch geometrytype
    
    case 1  % one large square
        
        sqsize = floor(0.4*wallsize);
        cones = zeros(sqsize*sqsize, wallsize, wallsize);
        conecount = 1;
        for x = (floor(0.5*wallsize)-floor(0.5*sqsize)):(floor(0.5*wallsize)-floor(0.5*sqsize)+sqsize)-1
            for y = (floor(0.5*wallsize)-floor(0.5*sqsize)):(floor(0.5*wallsize)-floor(0.5*sqsize)+sqsize)-1
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, floor(0.5*wallsize), false);
                gt(x, y, floor(0.5*wallsize)) = 1;
                conecount = conecount + 1;
            end
        end
        
    case 2 % two smaller squares
        
        cones = zeros(2*round(0.02*wallsize)^2, wallsize, wallsize);
        conecount = 1;
        for x = round(0.2*wallsize):round(0.2*wallsize)+round(0.02*wallsize)
            for y = round(0.2*wallsize):round(0.2*wallsize)+round(0.02*wallsize)
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, round(0.5*wallsize), false);
                gt(x, y, round(0.5*wallsize)) = 1;
                conecount = conecount + 1;
            end
        end
        for x = round(0.7*wallsize):round(0.7*wallsize)+round(0.02*wallsize)
            for y = round(0.7*wallsize):round(0.7*wallsize)+round(0.02*wallsize)
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, round(0.5*wallsize), false);
                gt(x, y, round(0.5*wallsize)) = 1;
                conecount = conecount + 1;
            end
        end
        
    case 3 % four small squares in different depths
        
        sqsize = floor(0.04 * wallsize);
        cones = zeros(4*sqsize^2, wallsize, wallsize);
        conecount = 1;
        pos = floor(0.2*wallsize);
        for x = pos:pos+sqsize
            for y = pos:pos+sqsize
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, floor(0.2*wallsize), false);
                gt(x, y, pos) = 1;
                conecount = conecount + 1;
            end
        end
        for x = 3*pos:3*pos+sqsize
            for y = 3*pos:3*pos+sqsize
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, floor(0.4*wallsize), false);
                gt(x, y, 2*pos) = 1;
                conecount = conecount + 1;
            end
        end
        for x = pos:pos+sqsize
            for y = 3*pos:3*pos+sqsize
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, floor(0.6*wallsize), false);
                gt(x, y, 3*pos) = 1;
                conecount = conecount + 1;
            end
        end
        for x = 3*pos:3*pos+sqsize
            for y = pos:pos+sqsize
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, floor(0.8*wallsize), false);
                gt(x, y, 4*pos) = 1;
                conecount = conecount + 1;
            end
        end
        
    case 4  % one large tilted square
        sqsize = (floor(0.4*wallsize)+1);
        cones = zeros(sqsize^2, wallsize, wallsize);
        conecount = 1;
        for x = floor(wallsize/2)-floor(sqsize/2):floor(wallsize/2)+ceil(sqsize/2)
            for y = floor(wallsize/2)-floor(sqsize/2):floor(wallsize/2)+ceil(sqsize/2)
                depth = round(wallsize/2+x/5);
                cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, depth, false);
                gt(x, y, depth) = 1;
                conecount = conecount + 1;
            end
        end
        
    case 5 % bunny
        
        file = "bunny_depthmap.txt";
        
        f = fopen(file,'r');
        formatSpec = '%f';
        sizeBunny = [64 64];
        
        bunny = imrotate(fscanf(f,formatSpec,sizeBunny), -90).*20 + 32;
        bunny = padarray(bunny, [(wallsize-64)/2 (wallsize-64)/2]);
        
        
        gt = zeros(wallsize,wallsize,200);
        cones = zeros(64*64, wallsize, wallsize);
        conecount = 1;
        for x = 1:wallsize
            for y = 1:wallsize
                if bunny(x,y) > 0 && bunny(x,y) ~= 20+32
                    gt(x,y,round(bunny(x,y))) = 1;
                    cones(conecount, :, :) = plot_cone3d(confocal, wallsize, x, y, round(bunny(x,y)), false);
                    conecount = conecount + 1;
                end
            end
        end
        cones(conecount+1:end, :, :) = [];
end

disp('done');


% function plot to 3d measurement:
disp('Creating measurement...');

m = ceil(max(cones(:)));
grid = zeros(m, wallsize, wallsize);

for i = 1:wallsize
    for k = 1:wallsize
        for j = 1:size(cones, 1)
            v = cones(j, k, i);
            ls = v-floor(v);
            if round(v) > 0
                grid(floor(v), k, i) = grid(floor(v), k, i) + 1 - ls;
                grid(floor(v)+1, k, i) = grid(floor(v)+1, k, i) + ls;
            end
        end
    end
end

disp('done');

end