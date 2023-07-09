function properties = project_run(signal)
    %PROJECT_RUN This should be the main function of your project.
    %   Input: PCG signal (fs: 4000 Hz)
    %   Output: properties struct
    %           S_loc:      heartsound locations (samples)
    %           HR:         heartrate (bpm)
    %           ib_seg:     systole/diastole regions (binary mask, 1-s at given samples)
    %           pathology:  normal/murmur (0-normal, 1-murmur)

    load linearSVM_16feat.mat;

    properties.S_loc = [];
    properties.HR = 0;
    properties.ib_seg = ones(size(signal));
    properties.pathology = 0;
    properties.len = length(signal);

    Fs = 4000;
    [S_loc,ib_seg,HeartRate,~,table,~] = processing(signal,Fs);

%     figure;
%     pcg_plot(signal,Fs);

    S_loc = S_loc * Fs;
    properties.S_loc = S_loc;
    properties.HR = HeartRate;
    properties.ib_seg = ib_seg;

%     Prediction using our classifier
    yfit = linearSVM_16feat.predictFcn(table);
    
    if yfit=="normal"
        properties.pathology = 0;
    elseif yfit == "murmur"
        properties.pathology = 1;
    end
end