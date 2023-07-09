function [props,labels] = run_for_folder(folder)
%RUN_FOR_FOLDER Runs your project_run function for all files in a folder
%   Requires that the wav and tsv files have the same name

    files = dir([folder '*.wav']);
    files = struct2table(files);

    for k=1:length(files.name)
        fname = files.name(k);
        fname = fname{:};
        sig = audioread([folder fname]);
        lab = readtable([folder fname(1:end-4) '.tsv'],"FileType","delimitedtext","Delimiter","tab");
        lab = table2cell(lab);
        labels{k,:} = lab;
        props(k) = project_run(sig);
%         fprintf('%s\n',fname);
    end

end