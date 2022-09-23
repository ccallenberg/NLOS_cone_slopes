function [phis, coherences, derivatives, grad3d, grad3d2] = calculate_gradients(grid, gausssigma)

%% all gradient images (slicing x and y)

fprintf('Calculating gradient images... 00%%\n');
m = size(grid, 1);
datasize = size(grid, 2);

gradients_xslices = zeros(2, m, datasize, datasize);
gradients_yslices = zeros(2, m, datasize, datasize);

for i = 1:datasize
    if mod(i, 10) == 0 || i == datasize
        fprintf('\b\b\b\b%02d%%\n', uint8(i/datasize*100));
    end

    [Shx,Svx] = imgradientxy(squeeze(grid(:,i,:)));
    gradients_xslices(1, :, :, i) = Shx;
    gradients_xslices(2, :, :, i) = Svx;
    
    [Shy,Svy] = imgradientxy(squeeze(grid(:,:,i)));

    gradients_yslices(1, :, :, i) = Shy;
    gradients_yslices(2, :, :, i) = Svy;
end

%% calculate 3D gradients in every point (can be used for filtering)

lap = zeros(3, 3, 3);
lap(2,2,2) = 6;
lap(2,2,1) = -1;
lap(2,3,2) = -1;
lap(3,2,2) = -1;
lap(2,2,3) = -1;
lap(2,1,2) = -1;
lap(1,2,2) = -1;
grad3d = convn(grid, lap, 'same');

gl = fspecial3('gaussian', 5, 1);
gl(4,4,4) = 0;
gl = gl./max(gl(:));
gl(4,4,4) = -sum(gl(:));

grad3d2 = convn(grid, gl, 'same');

%%
kernel = fspecial('gaussian', ceil(3*gausssigma), gausssigma);    

%            z      y/x     N        x or y slice
Jhhs = zeros(m, datasize, datasize, 2);
Jhvs = zeros(m, datasize, datasize, 2);
Jvvs = zeros(m, datasize, datasize, 2);

fprintf('Convolving... 00%%\n')

for i = 1:datasize
    if mod(i, 10) == 0 || i == datasize
        fprintf('\b\b\b\b%02d%%\n', uint8(i/datasize*100));
    end
    Jhhs(:,:,i,1) = conv2(squeeze(gradients_xslices(1,:,:,i)) .* squeeze(gradients_xslices(1,:,:,i)), kernel, 'same');
    Jhvs(:,:,i,1) = conv2(squeeze(gradients_xslices(1,:,:,i)) .* squeeze(gradients_xslices(2,:,:,i)), kernel, 'same');
    Jvvs(:,:,i,1) = conv2(squeeze(gradients_xslices(2,:,:,i)) .* squeeze(gradients_xslices(2,:,:,i)), kernel, 'same');
    
    Jhhs(:,:,i,2) = conv2(squeeze(gradients_yslices(1,:,:,i)) .* squeeze(gradients_yslices(1,:,:,i)), kernel, 'same');
    Jhvs(:,:,i,2) = conv2(squeeze(gradients_yslices(1,:,:,i)) .* squeeze(gradients_yslices(2,:,:,i)), kernel, 'same');
    Jvvs(:,:,i,2) = conv2(squeeze(gradients_yslices(2,:,:,i)) .* squeeze(gradients_yslices(2,:,:,i)), kernel, 'same');
end

clear gradients_xslices
clear gradients_yslices



fprintf('Calculating angles... 00%%\n');
%                   z  y/x       x/y       x or y slice
phis        = zeros(m, datasize, datasize, 2);
coherences  = zeros(m, datasize, datasize, 2);
derivatives = zeros(m, datasize, datasize, 2);


for i = 1:datasize % go through all slices
    if mod(i, 10) == 0 || i == datasize
        fprintf('\b\b\b\b%02d%%\n', uint8(i/datasize*100));
    end
    for xory = 1:2  % first x slices, then y slices

        Jhh = Jhhs(:,:,i,xory);
        Jhv = Jhvs(:,:,i,xory);
        Jvv = Jvvs(:,:,i,xory);
        
        phi = 1/2 * atan2(Jvv-Jhh,2*Jhv);
        coherence = ((Jvv-Jhh).^2+4*Jhv.^2) ./ (Jhh+Jvv).^2;
        derivative = tan(phi-pi/4);
        derivative(isnan(coherence)) = 1000;
        
        phis(:,:,i,xory) = phi;
        coherences(:,:,i,xory) = coherence;
        derivatives(:,:,i,xory) = derivative;

    end
end
clear Jxx
clear Jxy
clear Jyy

end
