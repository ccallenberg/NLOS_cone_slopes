function plot_result(gt, hiddenvolume, plotkind)
    

wallsize = size(gt, 2);

switch plotkind
    case 1
        
        figure;
        isosurface(gt);
        xlim([0,wallsize])
        ylim([0,wallsize])
        zlim([0,wallsize])
        xlabel('x');
        ylabel('y');
        zlabel('z');
        title('ground truth');
        
        figure;
        isosurface(hiddenvolume);
        xlim([0,wallsize])
        ylim([0,wallsize])
        zlim([0,wallsize])
        xlabel('x');
        ylabel('y');
        zlabel('z');
        title('reconstruction');
        
    case 2
        fig = figure('Position', [300 300 1800 700]);
        scaling = permute(repmat([1:size(gt, 3)], [size(gt, 1), 1, size(gt, 2)]), [1, 3, 2]);
        gt_depth = squeeze(squeeze(sum(gt.*scaling, 3))./sum(gt,3));
        subplot(1, 3, 1); 
        imagesc(gt_depth);
        title('Ground Truth');
        cLimits = get(gca,'CLim');
        axis square
        colorbar
        
        scalinghv = permute(repmat([1:size(hiddenvolume, 3)], [size(hiddenvolume, 1), 1, size(hiddenvolume, 2)]), [1, 3, 2]);
        hv_depth = sum(hiddenvolume.*scalinghv, 3)./sum(hiddenvolume,3);
        subplot(1, 3, 2);
        mask = sum(hiddenvolume,3);
        thresh = prctile(mask(mask~=0), 0); % percentile of nonzero entries
        mask(mask < thresh) = 0;
        mask(mask >= thresh) = 1;
        imagesc(hv_depth .* mask, cLimits);
        title('Reconstruction');
        axis square
        colorbar
        
        subplot(1, 3, 3);
        mask = sum(hiddenvolume,3);
        thresh = prctile(mask(mask~=0), 80); % percentile of nonzero entries
        mask(mask < thresh) = 0;
        mask(mask >= thresh) = 1;
        imagesc(hv_depth .* mask, cLimits);
        title('Reconstruction, 20% brightest');
        axis square
        colorbar

end
    
end