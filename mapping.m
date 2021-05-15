function new_x=mapping(x,new_rrh,rrh)
new_x=zeros(size(x,1),rrh);
for i=1:size(new_rrh,2)
    new_x(:,new_rrh(1,i))=x(:,i);
end
end