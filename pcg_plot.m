function pcg_plot(signal,Fs)
    %PCG_PLOT Helper function for plotting
    %   Example usage: plot signal, mark heartsounds with stars, mark
    %   segments as a line above the signal
    %   You can also mark each segment by plotting the signal with
    %   different colors
    t = linspace(0, length(signal)/Fs, length(signal));
    [S_loc,ib_seg,~,pks,~,normed_sig] = processing(signal,Fs);
    plot(t, normed_sig, S_loc, pks, '*'); hold on; plot(t, ib_seg, 'black', 'LineWidth', 1);
    hold off; axis tight; grid on; 
    xlabel("Time(sec)");  ylabel("Amplitude");
    legend("Normalized Audio Signal", "Peaks", "S1-S2 vs Systole-Diastole");
    title("Peaks with S1,S2 and Systole,Diastole differentiated");
end