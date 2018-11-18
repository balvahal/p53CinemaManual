function [] = plotLinearRegression(x,y,xnew,color)
    mdlr = fitlm(x,y,'RobustOpts','on');
    [yhat1,ci1] = predict(mdlr,xnew','Alpha',0.1,'Simultaneous',true);
    plot(xnew, yhat1, 'Color', color);
    hold all;
    plot(xnew, ci1, 'Color', color, 'LineStyle', '--');
end