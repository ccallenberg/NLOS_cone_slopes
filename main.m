%% Reconstructing hidden NLOS geometry from light cone slopes
% author: Clara Callenberg (callenbe@cs.uni-bonn.de)

%% set up

% general parameters:
wallsize = 256; % number of pixels in x, y and z used for ground truth hidden volume 
confocal = true; % measurement is confocal or not
displayMeasurement = false; % display the NLOS measurement as a 'video'
save_recodata = false; % save parameters during reconstruction for later analysis (use analyze_recodata(recodata) for plots)

scene = 4; % choose Ground Truth scene 
% 1: one square in the center
% 2: two smaller squares
% 3: 4 small squares in different depths
% 4: one tilted square in the center
% 5: a Stanford bunny

% reconstruction parameters:
gauss_sigma = 2; % sigma of Gauss filter used in calculation of structure tensor
brightness_threshold_prctile = 0; % percentile of brightness below which datapoints are omitted (0..100)
gradient_threshold_prctile = 90;   % percentile of gradient below which datapoints are omitted (0..100)
coherence_threshold = 0.7;        % threshold of coherence below which datapoints are omitted (0..1)


%% create ground truth and measurement

[gt, grid] = create_ground_truth(wallsize, confocal, scene); 

%% display measurement

if displayMeasurement
    a = prctile(grid(:), 20);
    b = prctile(grid(:), 100);
    figure;
    for i = 1:size(grid, 1)
        imagesc(squeeze(grid(i,:,:)), [a, b]);
        title(i);
        drawnow;
        pause(0.001)
    end
end

%% calculate gradients, reconstruct and plot result

[phis, coherences, derivatives, grad3d, grad3d2] = calculate_gradients(grid, gauss_sigma);

[hiddenvolume, recodata] = reconstruct_hiddenvolume(grid, derivatives, coherences, grad3d2, confocal, brightness_threshold_prctile, gradient_threshold_prctile, coherence_threshold, save_recodata);
    
plot_result(gt, hiddenvolume, 2);    
