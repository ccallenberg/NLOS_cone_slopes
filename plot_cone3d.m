function cone = plot_cone3d(confocal, wallsize, Px, Py, Pz, drawplot)

% confocal: true or false
% wallsize: extent of wall in x and y directions (cm)
% P: coordinates of point in hidden volume
% drawplot: true or false (opens figure and plots if true)

c = 299792458 * 100; % speed of light in cm / s

% laser in (0,0,0)
cone = zeros(wallsize, wallsize);
for x = 1:wallsize
    for y = 1:wallsize
        d_PW = sqrt((x-Px)^2 + (y-Py)^2 + Pz^2);
        if ~confocal
            d_LP = sqrt(Px^2 + Py^2 + Pz^2);
            cone(x, y) = d_LP + d_PW;
        else
            cone(x, y) = 2* d_PW;
        end
    end
end

if drawplot
    %t = cone ./ c;
    figure;
%     plot([1:samples], t*10^9)
    z = [1:wallsize];
    mesh(cone);
    xlabel('x_1 / cm') 
    %     ylabel('t / ns')
    ylabel('x_2 / cm') 
    zlabel('c \tau / cm')
    ylim([0 inf])
end

end