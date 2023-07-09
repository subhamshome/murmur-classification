%% Folder
clc; clear;

folder = 'data/normal/';
[props_n,labels_n] = run_for_folder(folder);

folder = 'data/murmur/';
[props_m,labels_m] = run_for_folder(folder);

props = [props_n,props_m];
labels = [labels_n;labels_m];

%reading in ground truth HR-s (temp variable used to filter for these files)
hr_normal = readtable("data/HR_normal.csv");
hr_murmur = readtable("data/HR_murmur.csv");

hr_n = table2array(hr_normal(:,2));
hr_m = table2array(hr_murmur(:,2));
hrs = [hr_n;hr_m];

%setting ground truth array
zero = zeros(50,1);
one = ones(50,1);
pathology = [zero; one];

%clearing variables
clear temp
clear props_true

%setting up the ground truth struct array
for k=1:length(hrs)
    temp.HR = hrs(k);
    temp.pathology = pathology(k);
    props_true(k) = temp;
end
%% Calculation
[hit_percent,miss_percent,multihit_percent,hrdiff_percent,ibsegdiff_percent,Se,Sp] = ...
    calc_score(props,props_true,labels);

avg_percent = mean([hit_percent;miss_percent;multihit_percent;hrdiff_percent;ibsegdiff_percent],2);
avg_hit_percent = avg_percent(1);
avg_miss_percent = avg_percent(2);
avg_multihit_percent = avg_percent(3);
avg_hrdiff_percent = avg_percent(4);
avg_ibsegdiff_percent = avg_percent(5);