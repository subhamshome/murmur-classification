function [hit_percent,miss_percent,multihit_percent,hrdiff_percent,ibsegdiff_percent,Se,Sp] = calc_score(props_predict,props_true,labels)
%CALC_SCORE Evaluate your submission
%   Input:
%       props_predict   - predicted properties (struct)
%       props_true      - ground truth properties (struct)
%       labels          - heart cycle labels (cell)
%
%   Output:
%       hit/miss/multihit_percent      - found/missed/multi-detection heartsound (percent)
%       hrdiff_percent                 - heartrate error (percent)
%       ibsegdiff_percent              - inbetween segment overlap error (percent)
%       Se/Sp                          - sensitivity/specificity

conf = [0,0;
        0,0];
for k=1:length(labels)
    ids = cell2mat(labels{k}(:,3));
    starts = cell2mat(labels{k}(:,1));
    stops = cell2mat(labels{k}(:,2));
    
    % S_loc test
    % hit/miss/multihit
    s1s = starts(ids==1 | ids==3)*4000;
    s1e = stops(ids==1 | ids==3)*4000;
    hit=0; miss=0; multi=0;
    for kk=1:length(s1s) % fix hit/miss calculation by Levente Maucha
        after_start = (s1s(kk)<=props_predict(k).S_loc);
        before_end = (s1e(kk)>=props_predict(k).S_loc);
        num = sum(after_start==before_end);
        if num>0
            hit=hit+1;
            if num>1
                multi=multi+1;
            end
        else
            miss=miss+1;
        end
    end

    hit_percent(k) = hit/length(s1s) *100;
    miss_percent(k) = miss/length(s1s) *100;
    if hit ~= 0
        multihit_percent(k) = multi/hit *100;
    else
        multihit_percent(k) = 0;
    end

    % HR test
    hrdiff = abs(props_predict(k).HR - props_true(k).HR);
    hrdiff_percent(k) = hrdiff/props_true(k).HR *100;

    % ib_seg test
    ib_starts = starts(ids==2 | ids==4)*4000;
    ib_stops = stops(ids==2 | ids==4)*4000;
    ib_seg = zeros(props_predict(k).len,1);
    
    % fix start indexing by Márton Szabó
    if ib_starts(1) == 0
        ib_starts(1) = 1;
    end

    for kk = 1:length(ib_starts)
        ib_seg(ib_starts(kk):ib_stops(kk))=1;
    end
    compare = props_predict(k).ib_seg;
    compare(1:ib_starts(1)) = 0;
    compare(ib_stops(end):end) = 0;
    ibsegdiff = sum(abs(compare - ib_seg));
    ibsegdiff_percent(k) = ibsegdiff/numel(ib_seg) *100; % fix accuracy calculation by Beatrix Stier

    % pathology test
    x = abs(props_predict(k).pathology-1)+1;
    y = abs(props_true(k).pathology-1)+1;
    conf(x,y) = conf(x,y)+1;
end
Se = conf(1,1)/(conf(1,1)+conf(2,1));
Sp = conf(2,2)/(conf(1,2)+conf(2,2));
% assignin("base", "conf_mat", conf);
disp(conf);
end