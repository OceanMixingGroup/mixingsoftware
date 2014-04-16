% run_home_shear.m
% path(path,'c:\work\home\marlin\proc\');
clear all
path_raw = '\\Balt\rdata\Home\Marlin\Marlin\';
path_save= '\\Balt\rdata\work\home\marlin\eps_mat\';
load c:\sasha\work\velocity_eq
load c:\sasha\work\sum_tcp

DIR = dir(path_raw);
a={DIR.name};
I = strmatch('hm00',a);
a = a(I);
a=sort(a);
q.script.pathname =  path_raw;
q.script.prefix = 'hm00';
for cast1=194:4613% 1:4613
    if cast1~=[1:193,408:416,593:604,666,856:872,943,977:983,1881,1882,1914:1924,1995,2255,...
                2610,2614,2633,2807,2821,2865,3394:3395,4285,4287,4295:4296]
      file=sprintf('hm00%4.3f',cast1/1000);
      if exist([path_raw file],'file')
%       disp(cast1)
      q.script.num=cast1;
      clear global head data cal cast
      global data cal head cast
      [data,head] = raw_load(q);
      cast=cast1;
      cali_hm00_shear;
      nfft=256;
      q.series={'ptime','ctime','stime','t','c','s','p','fallspd','epsilon1','epsilon2','epsilon3'};
      warning off
      binsize=2;%sec
      avg=average_data_gen(q.series,'binsize',binsize,'nfft',nfft,'depth_or_time','time');
      if 194<=cast&cast<=407; tow=1; end
      if 417<=cast&cast<=592; tow=2; end
      if 605<=cast&cast<=855; tow=3; end
      if 873<=cast&cast<=942; tow=4; end
      if 984<=cast&cast<=1358; tow=5; end
      if 1359<=cast&cast<=1727; tow=6; end
      if 1728<=cast&cast<=1913; tow=7; end
      if 1925<=cast&cast<=2345; tow=8; end
      if 2346<=cast&cast<=2650; tow=9; end
      if 2651<=cast&cast<=2692; tow=10; end
      if 2693<=cast&cast<=2740; tow=11; end
      if 2741<=cast&cast<=2781; tow=12; end
      if 2781<=cast&cast<=2820; tow=13; end
      if 2822<=cast&cast<=2864; tow=14; end
      if 2866<=cast&cast<=2906; tow=15; end
      if 2907<=cast&cast<=2949; tow=16; end
      if 2950<=cast&cast<=2990; tow=17; end
      if 2990<=cast&cast<=3045; tow=18; end
      if 3045<=cast&cast<=3089; tow=19; end
      if 3088<=cast&cast<=3132; tow=20; end
      if 3131<=cast&cast<=3176; tow=21; end
      if 3175<=cast&cast<=3221; tow=22; end
      if 3220<=cast&cast<=3266; tow=23; end
      if 3264<=cast&cast<=3310; tow=24; end
      if 3310<=cast&cast<=3347; tow=25; end
      if 3347<=cast&cast<=3393; tow=26; end
      if 3396<=cast&cast<=3490; tow=27; end
      if 3490<=cast&cast<=3558; tow=28; end
      if 3558<=cast&cast<=3622; tow=29; end
      if 3622<=cast&cast<=3688; tow=30; end
      if 3688<=cast&cast<=3754; tow=31; end
      if 3754<=cast&cast<=3826; tow=32; end
      if 3826<=cast&cast<=3892; tow=33; end
      if 3892<=cast&cast<=3965; tow=34; end
      if 3965<=cast&cast<=4027; tow=35; end
      if 4027<=cast&cast<=4292; tow=36; end
      if 4297<=cast&cast<=4614; tow=37; end
      
      it=tow;
      set_tag_pts_hm00;
      [lxs lys]=size(tag_pts.all);
      for i=1:lxs
          id=find(avg.PTIME>=tag_pts.all(i,1)-0.003125 & avg.PTIME<tag_pts.all(i,2)+0.003125);
          avg.FALLSPD(id)=NaN;
          avg.EPSILON1(id)=NaN;
          avg.EPSILON2(id)=NaN;
          avg.EPSILON3(id)=NaN;
          avg.C(id)=NaN;
          avg.T(id)=NaN;
          avg.S(id)=NaN;
      end
      [lxs lys]=size(tag_pts.eps);
      for i=1:lxs
          id=find(avg.PTIME>=tag_pts.eps(i,1)-0.003125 & avg.PTIME<tag_pts.eps(i,2)+0.003125);
          avg.EPSILON1(id)=NaN;
          avg.EPSILON2(id)=NaN;
          avg.EPSILON3(id)=NaN;
      end
      [lxs lys]=size(tag_pts.eps1);
      for i=1:lxs
          id=find(avg.PTIME>=tag_pts.eps1(i,1)-0.003125 & avg.PTIME<tag_pts.eps1(i,2)+0.003125);
          avg.EPSILON1(id)=NaN;
      end
      [lxs lys]=size(tag_pts.eps2);
      for i=1:lxs
          id=find(avg.PTIME>=tag_pts.eps2(i,1)-0.003125 & avg.PTIME<tag_pts.eps2(i,2)+0.003125);
          avg.EPSILON2(id)=NaN;
      end
      [lxs lys]=size(tag_pts.eps3);
      for i=1:lxs
          id=find(avg.PTIME>=tag_pts.eps3(i,1)-0.003125 & avg.PTIME<tag_pts.eps3(i,2)+0.003125);
          avg.EPSILON3(id)=NaN;
      end
      fs=sprintf('hm00%04d',cast);
      disp(fs)
      eval(['save ' path_save fs ' avg head']);
      end % if exist([path_raw file],'file')
  end % if cast~=[1:193,408:416,593:604,
end % for cast=