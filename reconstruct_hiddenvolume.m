function [hiddenvolume, recodata] = reconstruct_hiddenvolume(grid, derivatives, coherences, grad3d, confocal, thresh_prctile, gradthresh_prctile, coherencethresh, check)



datasize = size(grid, 2);
m = size(grid, 1);
hiddenvolume = zeros(datasize, datasize, 2*size(grid, 1));

thresh = prctile(grid(:), thresh_prctile);
slope = zeros(1, 2);


% threshold for slope
if confocal
    slopethresh = 0.7;
else
    slopethresh = 0.35;
end

gradthresh = prctile(abs(grad3d(:)), gradthresh_prctile);

if ~check
    recodata = 0;
end

datacount = 0;

% loop over every voxel in the measurement
for x = 1:size(grid, 2)
    for y = 1:size(grid, 3)
        for z = 1:size(grid, 1)
            
            slope(1) = derivatives(z,y,x,1);
            slope(2) = derivatives(z,x,y,2);
            h = slope(1);
            g = slope(2);  % value of derivative in x and y direction
            
            % filter data by brightness, gradient, slope, coherence
            if grid(z, x, y) > thresh && grad3d(z, x, y) >= gradthresh  && (abs(h) > 0.001 && abs(h) < slopethresh) && (abs(g) > 0.001 && abs(g) < slopethresh) && coherences(z,y,x,1) > coherencethresh && coherences(z,x,y,2) > coherencethresh
                solveAnalytically = true;
                if ~solveAnalytically
                    syms x_P y_P z_P
                    if confocal
                        eq1 = 2*sqrt((x - x_P)^2 + (y - y_P)^2 + z_P^2) - z;
                        eq2 = 2*(x - x_P) / sqrt((x - x_P)^2 + (y - y_P)^2 + z_P^2) - g;
                        eq3 = 2*(y - y_P) / sqrt((x - x_P)^2 + (y - y_P)^2 + z_P^2) - h;
                    else
                        eq1 = sqrt(x_P^2 + y_P^2 + z_P^2) + sqrt((x - x_P)^2 + (y - y_P)^2 + z_P^2) - z;
                        eq2 = (x - x_P) / sqrt((x - x_P)^2 + (y - y_P)^2 + z_P^2) - g;
                        eq3 = (y - y_P) / sqrt((x - x_P)^2 + (y - y_P)^2 + z_P^2) - h;
                    end
                    eqns = [eq1, eq2, eq3];                   
                    [sol_xP, sol_yP, sol_zP] = vpasolve(eqns, [x_P, y_P, z_P], [datasize/2, datasize/2, datasize/2]);
                else
                    if confocal
                        sol_xP = -z*g/4 + x;
                        sol_yP = -z*h/4 + y;
                        sol_zP = abs(sqrt(-g^2 - h^2 + 4)*z/4);
                    else
                        sol_xP = -(z^2*g + g*x^2 - g*y^2 + 2*h*x*y - 2*z*x)/(2*(-g*x - h*y + z));
                        sol_yP = -(z^2*h + 2*g*x*y - h*x^2 + h*y^2 - 2*z*y)/(2*(-g*x - h*y + z));
                        sol_zP = abs(sqrt(-g^2 - h^2 + 1)*(z^2 - x^2 - y^2)/(2*(-g*x - h*y + z)));
                    end
                end
                if ~isempty(sol_xP) && ~isempty(sol_yP) && ~isempty(sol_zP)
                    if sol_xP > 0 && sol_yP > 0 && sol_zP > 0 && sol_xP < size(hiddenvolume, 1) && sol_yP < size(hiddenvolume, 2) && sol_zP < size(hiddenvolume, 3)
                        hiddenvolume(ceil(sol_xP), ceil(sol_yP), ceil(sol_zP)) = hiddenvolume(ceil(sol_xP), ceil(sol_yP), ceil(sol_zP)) + grid(z,x,y);
                        if check
                            datacount = datacount + 1;
                            recodata(datacount, :) = [sol_xP, sol_yP, sol_zP, grid(z,x,y), coherences(z,y,x,1), coherences(z,x,y,2), slope(1), slope(2), grad3d(z, x,y)];
                        end
                    end
                end
            end
        end
    end
end

fprintf('\n');
end