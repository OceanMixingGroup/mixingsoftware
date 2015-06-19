function fix_fig2()
set(gca,'linewidth',1,'xticklabel','','fontsize',14,'box','on','layer','top')
resize_gca([0 -.02 -.03 .03])
hh=get(gca,'children'),set(hh,'linewidth',1)