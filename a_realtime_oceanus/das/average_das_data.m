% loads in processed and combined das data to make 5 minute
% averages and save in .mat file with all 

bb = load([localdir 'mfiles' filesep 'deglitch_matrix.mat']);
dparam = fields(bb);
cc = load([localdir 'mfiles' filesep 'empty_avg_das.mat']);
avg1 = fields(cc);
dd1 = dir([localdir 'processed' filesep '*eq14.mat']);

first_mat = load([localdir 'processed' filesep ...
                    'fluorometer_flowthrough_eq14.mat']);
time = first_mat.fluorometer.time;
max_time = max(time);
min_time = min(time);
day_min = 1/24/60;                    
bin_vec = [min_time:5*day_min:max_time];

dt = mean(diff(bin_vec));
time = bin_vec(1:end-1)+dt/2;
cc.time = time;

num_it = 1;
for ii = 1:length(dd1)
    disp(dd1(ii).name)
    ff = load([localdir 'processed' filesep dd1(ii).name]);
    var1 = fields(ff);
    var2 = fields(ff.(char(var1)));

    dparam2.fl = fields(bb.(char(dparam(ii))));
    
    for kk = 3:length(var2)

        num_it = num_it+1;
        time = ff.(char(var1)).(char(var2(2)));    
        data_ts = ff.(char(var1)).(char(var2(kk)));
        
        if length(data_ts) == length(time)
            deglitch_params = bb.(char(dparam(ii))).(char(dparam2.fl(kk-2)));
        elseif length(data_ts) ~= length(time)
            
            if kk == length(var2)
               kk = kk;
               num_it = num_it-1;
            elseif kk == length(var2)-1
                kk = kk+1;
            end
            time = ff.(char(var1)).(char(var2(kk-1)));
            data_ts = ff.(char(var1)).(char(var2(kk)));
            deglitch_params = ...
                bb.(char(dparam(ii))).(char(dparam2.fl(kk-3)));
        end
        len = deglitch_params(1);
        num_std = deglitch_params(2);
            if len == 0;
               len = length(data_ts);
            end
        deglitched_ts = deglitch(data_ts,len,num_std);
        [avg_vec,variance,len_bin]  = bindata1d(bin_vec,time, ...
                                                deglitched_ts); ...
        cc.(char(avg1(num_it))) = avg_vec;
          
          das = cc;
    end

end

       save([localdir filesep 'processed' filesep 'avg_das.mat'],'das') 
       %       save([wdmycloud 'processed/avg_das.mat'],'das')

