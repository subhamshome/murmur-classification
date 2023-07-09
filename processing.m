% This is our main processing file. This file processes the input signal,
% finds the peaks, calculates heart rate, separates S1-S2 from
% systole-diastole regions and gets the signal ready for classification by
% creating the dataset for the signal by extracting features

function [S_loc,ib_seg,HeartRate,pks_normed,data,normed_sig] = processing(signal,Fs)

    audiofile = signal';
    t = linspace(0, length(audiofile)/Fs, length(audiofile));
    
    % Bandpass Filtering
    filtered_sig = bandpass(audiofile,[20 400],Fs);
    
    % Calculating the mean entropy as a feature, before using Shannon
    entropy = mean(wentropy(filtered_sig,'log energy')); % feature
    
    % Shannon Entropy
    ShannonEnergy = @(x) x.^2 .* log(x.^2);
    SEdata = ShannonEnergy(filtered_sig - mean(filtered_sig));
    SEenv = envelope(-SEdata, 100, 'peak');
    SEenv2 = abs(SEenv);
    
    % Normalization
    normed_sig = normalize(SEenv2); % final time domain signal

    % Frequency Domain Features

    % FFT
    L = size(normed_sig,2);
    Fn = Fs/2;
    FT_af = fft(SEenv2)/L;
    Fv = linspace(0, 1, fix(L/2)+1)*Fn;
    Iv = 1:numel(Fv);

    % Max Frequency Peaks
    [PksL,~] = findpeaks(abs(FT_af(Iv))*2);
    max_peak_f = max(PksL); % feature
    
    % Power Spectral Density
    [pxx,~] = pwelch(normed_sig,'power');
    dB = pow2db(pxx);
    high_pwelch = max(dB); % feature
    
    % Short-time Fourier Transform
    a = stft(normed_sig,Fs,'frequencyrange', 'onesided', 'Window',kaiser(256,5),'OverlapLength', 220);
    [rows, cols] = size(a);
    val = 0;
    for i=1:rows
      for j=1:cols
        val = val+abs(a(i,j));
      end
    end
    full_stft_sum = fix(val); % feature
    
    % Wavelet Decomposition
    [c,l] = wavedec(audiofile, 6, 'db2');
    [~,~,~,~,cd5,cd6] = detcoef(c,l,[1 2 3 4 5 6]);
    sum_cd5 = sum(abs(cd5));
    sum_cd6 = sum(abs(cd6));
    
    % Mel-Frequency Cepstral Coefficients (MFCC)
    win = hamming(1024,"periodic");
    S = stft(normed_sig,"Window",win);
    coeffs = mfcc(S,Fs,"LogEnergy","Ignore");
    coeffs(:,1) = [];
    added_mfcc_coeffs = sum(coeffs,1);
    mfcc_1 = added_mfcc_coeffs(1); % feature
    mfcc_2 = added_mfcc_coeffs(2); % feature

    % Empirical Mode Decomposition
    [imf, ~, ~] = emd(audiofile,'Interpolation','pchip');
    mad_imf6 = mad(imf(:,6));

    %% Heart Sound Locations, Heart Rate and region division

    % Heart Sound Locations
    [pks,locs] = findpeaks(normed_sig, "MinPeakHeight", 0.005, "MinPeakDistance", Fs*0.2);
    S_loc = t(locs);
    pks_normed = normed_sig(locs);

    % Heart Rate
    HeartRate = ((numel(pks)/2)*60)/(t(1,end)-t(1,1));
    
    % Separating S1-S2 and Sysole-Diastole regions
    s12 = (0.12*Fs)/2;
    length_audio = size(audiofile,2);
    ib_seg = ones(size(audiofile));
    for i=1:size(locs,2)
        lower_end = max(1, locs(i)-s12);
        upper_end = min(locs(i)+s12, length_audio);
        ib_seg(1,lower_end:upper_end) = 0;
        sum_hs = sum(audiofile(lower_end:upper_end),"all");
    end
    ib_seg = ib_seg'; % this is the final binary mask

    %% Features Collection and Dataset Creation

    % features_table as a 1xn table for one signal
    data = table();

    % Statisctial Features
    data.mean = mean(normed_sig);
    data.median = median(normed_sig);
    data.mean_abs_dev = mad(normed_sig);
    data.skewness = skewness(normed_sig);
    data.kurtosis = kurtosis(normed_sig);
    data.iqr = iqr(normed_sig);

    % Time Domain Features
    data.entropy = entropy;
    data.sum_hs = sum_hs;
    data.mad_imf6 = mad_imf6;

    % Frequency Domain Features
    data.max_freq_peak = max_peak_f;
    data.high_pwelch = high_pwelch;

    % Time-Frequency Domain Features
    data.stft_sum = full_stft_sum;
    data.sum_cd5 = sum_cd5;
    data.sum_cd6 = sum_cd6;
    data.mfcc_1 = mfcc_1;
    data.mfcc_2 = mfcc_2;

end

