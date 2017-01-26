function [] = quiverc(ax,x,y,u,v,cmap,clim,crefx,crefy,crefz,lw,sw)
% [] = quiverc(ax,x,y,u,v,cmap,clim,crefx,crefy,crefz,lw,sw)
% if sw=1 black and wight arrows
%function to color quiver refering some backgroundfield

cvec=clim(1):(clim(2)-clim(1))/63:clim(2);


for k=1:length(x)

   cx=find(crefx==x(k));
   cy=find(crefy==y(k));
   
   %determin the color
   if(crefz(cy,cx)>clim(1) && crefz(cy,cx)<clim(2))
       [trash ci]=min(abs(cvec-crefz(cy,cx))); 
       cc(k,:)=cmap(ci,:);
   elseif(crefz(cy,cx)<=clim(1))
        cc(k,:)=cmap(1,:);
   else
        cc(k,:)=cmap(64,:);
   end
   if(sw)
       if(sum(cc(k,:))>1.5)
           cc(k,:)=[0 0 0];
       else
           cc(k,:)=[1 1 1];
       end
   end
   if(isnan(crefz(cy,cx)))
       cc(k,:)=[0 0 0];
   end

end 

index=1:length(cc(:,1));
 while(length(index)>0) 
     m=1;
     n=1;
     clear cindex;
     cctemp=nan;
     indextemp=[];
   for k=1:length(index)
       
      if((cc(k,:)==cc(1,:))) 
         cindex(m)=index(k);
         m=m+1;
      else
          if(n==1)
              clear cctemp;
          end
         indextemp(n)=index(k);
         cctemp(n,:)=cc(k,:);
          n=n+1;
      end
   end  
   hold on;
   quiver(ax,x(cindex),y(cindex),u(cindex),v(cindex),0,'Color',cc(1,:),'Linewidth',lw);
   
   cc=cctemp;
   index=indextemp;
 end   
 
 
end