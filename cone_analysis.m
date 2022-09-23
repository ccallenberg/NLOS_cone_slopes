leg = {};

figure;
for i = 100
    plot_cone(500, 250, i, true);
    hold on
    leg{end+1} = sprintf('x = 250cm, z = %scm', int2str(uint16(i)));
end
legend(leg, 'Location', 'southeast');


%%

cones = zeros(6,500);
figure;
leg = {};
count = 1;
for j = 100:150:400
    for i = 100:100:200
        cones(count, :) = plot_cone(500, j, i, true);
        count = count + 1;
        hold on
        leg{end+1} = sprintf('x = %scm, z = %scm', int2str(uint16(j)), int2str(uint16(i)));
        count, j, i
    end
end
legend(leg, 'Location', 'southeast');


%% geometry
cones = zeros(100, 500);

for x = 200:299
    y = 300+0.01*(x-250)^2;
    cones(x-199, :) = plot_cone(500, x, y, false);
end

%% 
cones = zeros(100, 500);



%%
m = ceil(max(cones(:)));
grid = zeros(m, 500);

for i = 1:500
    for j = 1:100
        v = cones(j, i);
        grid(floor(v), i) = grid(floor(v), i) + 1;
    end
end

figure; imagesc(grid);

%% matlab hough transform
[H, theta, rho] = hough(grid);
figure; imagesc(H);

%%
maxd = round(sqrt(sum(size(grid).^2)));
mind = -maxd;
houghspace = zeros(1000,2*maxd+1);
for i = 1:size(grid, 1)
    for j = 1:size(grid, 2)
        v = grid(i, j);
        if v ~= 0
            for a = 1:1000
                alpha = pi/1000*a;
                d = i * cos(alpha) + j * sin(alpha);
                houghspace(a, ceil(d)+maxd) = houghspace(a, ceil(d)+maxd) + 1;
            end
        end
    end
end
%houghspace = imrot(houghspace, 90);
figure; imagesc(houghspace);
            


%%
maxd = round(sqrt(sum(size(grid).^2)));
mind = -maxd;
houghspace = zeros(500,2*maxd+1);
zs = zeros(1, numel(grid)*500);
zcount = 0;
for i = 1:size(grid, 1)
    for j = 1:size(grid, 2)
        v = grid(i, j);
        if v ~= 0
            for x = 1:500
                zcount = zcount + 1;
                %alpha = pi/1000*a;
                %d = i * cos(alpha) + j * sin(alpha);
                r = 4*x^2-4*x*i+i^2-j^2;
                p = i^2-j^2;
                if r > 0 && p > 0
                    z = round((sqrt(p)*sqrt(r))/(2*j));
                    houghspace(x, z+1) = houghspace(x, z+1) + 1;
                    zs(zcount) = z;
                end
            end
        end
    end
end

%%
maxd = round(sqrt(sum(size(grid).^2)));
mind = -maxd;
houghspace = zeros(500,2*maxd+1);
xs = zeros(1, numel(grid)*500);
xcount = 0;
for i = 1:size(grid, 1)
    for j = 1:size(grid, 2)
        v = grid(i, j);
        if v ~= 0
            for z = 1:500
                xcount = xcount + 1;
                %alpha = pi/1000*a;
                %d = i * cos(alpha) + j * sin(alpha);
                %z = round((sqrt(i^2-j^2)*sqrt(4*x^2-4*x*i+i^2-j^2)))/(2*j));
                r = 4 * z^2 *i^2 *j^2 - 4 *z^2 *j^4 + i^4 *j^2 - 2*i^2 *j^4 + j^6;
                p = sqrt(r) + i^3 - i*j^2;
                if p > 0
                    x = round(p/(2* (i^2 - j^2)));
                    houghspace(x, z+1) = houghspace(x, z+1) + 1;
                    xs(xcount) = x;
                end
            end
        end
    end
end
%houghspace = imrot(houghspace, 90);
% figure; imagesc(houghspace);


%%


