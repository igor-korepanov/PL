
###############################################################################

# ОПИСАНИЕ
# "Выделение связной компоненты" если множество пересекается хотя бы с одни
# множеством из компоненты, то оно тоже принадлежит компоненте. Выводится первая
# же попавшаяся компонента.
# ЗАМЕЧАНИЕ:
# входные данные: list1 - список списков (подразумевается, что его элементами являются списки)
# 
# выходные данные: выводятся индексы элементов из списка list1.
#
# зависимости:
#



 InstallGlobalFunction( ConnectedSubset, function(list1)
     local ver, s,ind,del,i,list;


list:=StructuralCopy(list1);
ver:=list[1];
s:=1;
ind:=[1];
del:=[2,3..Length(list)];
while s<Length(ver)+1 do
   for i in del do
      if ver[s] in list[i] then
         Append(ver, list[i]);
         Add(ind,i);
      fi; 
   od;
   del:=Difference(del,ind);
   s:=s+1;
od;


return ind;
end );

# ПОЯСНЕНИЕ:
#

###############################################################################


# ОПИСАНИЕ
#	Строим упорядочение списка глубины 2, считая что данный список можно
#	описать как цикл.

# ЗАМЕЧАНИЕ:
# входные данные:	list
#			
# 			
# выходные данные:
#
#


 InstallGlobalFunction( SortCircle, function(list)
		local	n,sort,s,t;



n:=Length(list);
sort:=[Remove(list,1)];
s:=1;
while s<n do
	t:=0;
	repeat t:=t+1;
	until IsEmpty(Intersection(sort[s],list[t]))=false;

	Add(sort,Remove(list,t));
	s:=s+1;
od;



return sort;
end );

# ПРОВЕРКА:
#
#
