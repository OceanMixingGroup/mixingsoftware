function adcp=subtractbt(adcp);

adcp.u=adcp.u-ones(size(adcp.depth,1),1)*adcp.ubt;
adcp.v=adcp.v-ones(size(adcp.depth,1),1)*adcp.vbt;
adcp.w=adcp.w-ones(size(adcp.depth,1),1)*adcp.wbt;
