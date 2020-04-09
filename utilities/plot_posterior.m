function fig = plot_posterior(fmu, fs2, x, y, xs, v, i)
    fig = figure('visible', 'off');
    % fig = figure(i);
    f = [fmu+2*sqrt(fs2); flip(fmu-2*sqrt(fs2),1)];
    fill([xs; flip(xs,1)], f, [166, 206, 227] / 255, ...
     'facealpha', 0.7, ...
     'edgecolor', 'none');
    hold on; plot(xs, fmu, "color", [31, 120, 180] / 255); plot(x, y, 'k.'); plot(0,v,'b*');
    legend('95% CI','mean p*','data','actual vote')
    xlabel("days before voting"); ylabel("polling proportions");
end