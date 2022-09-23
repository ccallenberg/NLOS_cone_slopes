function analyze_recodata(recodata, gt)
%%
% recodata: sol_xP, sol_yP, sol_zP, grid(z,x,y), coherences(z,y,x,1), coherences(z,x,y,2), slope(1), slope(2), grad3d(z, x,y)
wallsize = size(gt, 2);

recodata = double(recodata);

gooddata = zeros(size(recodata));
baddata = zeros(size(recodata));

gcount = 0;
bcount = 0;

for i = 1:size(recodata, 1)
    pos = round(recodata(i, 1:3));
    intensity = recodata(i, 4);
    coh = recodata(i, 5:6);
    slopes = recodata(i, 7:8);
    grad = recodata(i, 9);
    
    boxsize = 5;
    boxx1 = max(1, pos(1)-boxsize);
    boxx2 = min(wallsize, pos(1)+boxsize);
    boxy1 = max(1, pos(2)-boxsize);
    boxy2 = min(wallsize, pos(2)+boxsize);
    boxz1 = max(1, pos(3)-boxsize);
    boxz2 = min(wallsize, pos(3)+boxsize);
    
    
    testbox = gt(boxx1:boxx2, boxy1:boxy2, boxz1:boxz2);
    if sum(testbox(:)) > 0
        gcount = gcount + 1;
        gooddata(gcount, :) = recodata(i, :);
    else
        bcount = bcount + 1;
        baddata(bcount, :) = recodata(i, :);
    end
end
gooddata(gcount+1:end,:) = [];
baddata(bcount+1:end,:) = [];

%%
titles = ["X", "Y", "Z", "pixel brightness", "coherences(z,y,x,1)", "coherences(z,x,y,2)", "slope(1)", "slope(2)", "3D gradient"];

figure; 
for i = 1:10
    subplot(3,4,i);
    if i < 10
        h1 = histogram(squeeze(gooddata(:,i)), 100, 'Normalization', 'probability');
        hold on
        h2 = histogram(squeeze(baddata(:,i)), 100, 'Normalization', 'probability');
        hold off

        title(titles(i));
        legend('good data', 'bad data');
    else
        histogram(squeeze(gooddata(:,4)).*squeeze(gooddata(:,9)), 100, 'Normalization', 'probability');
        hold on
        histogram(squeeze(baddata(:,4)).*squeeze(baddata(:,9)), 100, 'Normalization', 'probability');
        hold off
        title("brightness * gradient");
        legend('good data', 'bad data');
    end
end
