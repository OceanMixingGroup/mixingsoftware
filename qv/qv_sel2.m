function active=qv_sel2(handles)
for i=1:length(handles)
  temp(i)=get(handles(i),'value');
end
active=find(temp);
