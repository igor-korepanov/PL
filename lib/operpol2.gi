
################################################################################
## ОПИСАНИЕ
## Программа вычисляет индексы внутренних клеток и индексы граничных клеток. 
## ЗАМЕЧАНИЕ:
## входные данные: pol - политоп
## выходные данные:
# зависимости:
#
# InstallGlobalFunction(VnutVnesh, function(pol)
#     local dim,l,i,j,s,ind,vnut,k,gr,border;
#
#dim:=Length(pol.faces);
#
## определяем индексы внешних (dim-1)-клеток (при необходимости можно 
#l:=Length(pol.faces[dim-1]);
#border:=[]; # список индексов внешних 2-клеток
#for i in [1..l] do
#   s:=0;
#   for j in pol.faces[dim] do
#      if i in j then s:=s+1; fi;
#   od;
#   if s=1 then Add(border,i); fi;
#od;
#
## указываем на какие симплексы натянуты (dim-1)-клетки на границе
#ind:=List(border, x -> PolBnd(pol,[dim-1,x]));
#
#vnut:=rec();
#for k in [0,1 .. dim-2] do
#
#   gr:=[];
#   for i in ind do
#      Add(gr, i[k+1]);
#   od;
#   gr:=Concatenation(gr); # нашли индексы k-клеток лежащих на грнице
#
#   # вычисляем индексы внутренних k-клеток
#   if k>0 then
#      vnut.(k):=Difference([1..Length(pol.faces[k])],gr);
#   else 
#      vnut.(k):=Difference([1..Length(pol.vertices)],gr);
#   fi;
#
#od;
#vnut.(dim-1):=Difference([1..l],border);
#
#
#return rec(border:=border,vnut:=vnut);
#end);


###############################################################################


# ОПИСАНИЕ
# Стягивание k-клетки которая состоит из двух вершин, дву 1-клеток, двух
# 2-клеток и т.д., до (k-1)-клеток (назовем такие клетки минимальными). k-клетка стягивается на одну из своих (k-1)-клеток
# ЗАМЕЧАНИЕ: Клетка стягивается на одну из ее (k-1)-клеток. Проверку того, что
# стягивание возможно оставляем за пользователем.
# входные данные: pol1 - политоп
#                 adr=[размерность, индекс] - адрес минимальной клетки
# выходные данные: политоп
# зависимости:

 InstallGlobalFunction(ContractMiniFace, function(pol1,adr)
     local pol,ind,s,i;


pol:=StructuralCopy(pol1);
pol:=DelFace(pol,adr);
ind:=pol1.faces[adr[1]][adr[2]]; # узнаем (k-1)-клетки которые нужно склеить
ind:=Set(ind); # вообще это множество должно уже быть сортированным

# Во все клетки размерности adr[1] добавляем клетку ind[2].
s:=1;
for i in pol.faces[adr[1]] do
   if ind[2] in i then 
      Add(i,ind[1]);
      pol.faces[adr[1]][s]:=Set(i);
   fi; 
   s:=s+1;
od;

pol:=DelFace(pol,[adr[1]-1, ind[2]]); # удаление лишней клетки ind[2]


return pol;
end);

# ПОЯСНЕНИЕ:
#

###############################################################################



# ОПИСАНИЕ
# Дробим выбранную k-клетку (k-1)-клеткой. 
# ЗАМЕЧАНИЕ: Проверку того, что данную клетку можно подразбить выбранным образом оставляем пользователю.
# входные данные: pol - политоп
#                 adr - адрес k-клетки которую будем дробить
#                 nabor - индексы (k-2)-клеток на которые будет натянута дробящая (k-1)-клетка
#                         если дробится 1-клетка, то объект nabor это имя новой вершины
# выходные данные: политоп
# зависимости:

 InstallGlobalFunction(DivideFace, function(pol1,adr,nabor)
     local interes,pos,ind,l,s,i,pol, v;



pol:=StructuralCopy(pol1);



if adr[1]>1 then 
#-------------------------------------------------------------------------

	# 1) выбираем все (k-1)-клетки разбиваемой
	interes:=pol.faces[adr[1]][adr[2]];
	# 2) смотрим из каких (k-2)-клеток они состоят
	interes:=pol.faces[adr[1]-1]{interes};
	# 3) из этих наборов выкидываем (k-2)-клетки на которые будут натянута новая (k-1)-клетка
	interes:=List(interes, i->Difference(i, nabor));
	# 4) разделяем полученный список множеств на два списка связных наборов
	pos:=ConnectedSubset(interes);
	ind:=StructuralCopy(pol.faces[adr[1]][adr[2]]);
	pos:=ind{pos}; # выделели (k-1)-клетки которые будут образовывать одну k-клетку
	# 5) добавляем дробящую (k-1)-клетку
	Add(pol.faces[adr[1]-1],Set(nabor));
	l:=Length(pol.faces[adr[1]-1]); # количество (k-1)-клеток
	# 6) заменяем раздрабливаемую клетку на половинку
	Add(pos, l); 
	pol.faces[adr[1]][adr[2]]:=pos;
	# 7) создаем вторую часть дробленной клетки
	ind:=Difference(ind,pos);
	Add(ind, l);
	# 8) добавляем вторую полвинку дробленной клетки
	Add(pol.faces[adr[1]], ind);
	# 9) учтем в (k+1)-клетках что мы подразбили клетку
	l:=Length(pol.faces[adr[1]]);
	if adr[1]<Length(pol.faces) then
	   s:=1;
	   for i in pol.faces[adr[1]+1] do
	      if adr[2] in i then
	         Add(pol.faces[adr[1]+1][s],l);
	      fi;
	      s:=s+1;
	   od;
	fi;

else
#-----------------------------------------------------------------------------------
#                         если дробится ребро

   v:=StructuralCopy(pol.faces[1][adr[2]][2]);
   l:=Length(pol.vertices);
   Add(pol.vertices,nabor); # добавили имя новой вершины
   l:=l+1;
   # дробим ребро
   pol.faces[1][adr[2]][2]:=StructuralCopy(l);
   Add(pol.faces[1],[v,l]);
   # отражаем дробление ребра на 2-клетках
   l:=Length(pol.faces[1]);
   s:=1;
   for i in pol.faces[2] do
      if adr[2] in i then
         Add(pol.faces[2][s], l);
      fi;
      s:=s+1;
   od;
fi;

return pol;
end);


###############################################################################

# ОПИСАНИЕ
#  Программа сортирует политоп так, что бы первыми в списках .faces[k] шли
#  клетки которые лежат на границе.
# ЗАМЕЧАНИЕ: Если \alpha это i-ая k-клетка на гарнице, то эта клетка cтавится на место i, а та клетка которая имела индекс i занимает освободившееся место.
# входные данные: pol1 - политоп
# выходные данные:
# зависимости:

 InstallGlobalFunction(FirstBoundary, function(pol1)
      local pol,n,bord,sostB,sost,i,j,ver,s,k;


pol:=StructuralCopy(pol1);
n:=Length(pol.faces);

bord:=PolBoundary(pol);
sostB:=List(bord, i-> PolBnd(pol, [n-1, i]));

sost:=[];
for i in [1 .. n-1] do
   sost[i]:=[];
   for j in sostB do
      Append(sost[i], j[i]);
   od;
   sost[i]:=Set(sost[i]);
od; # вычислили все клетки на границе

ver:=Remove(sost, 1); # в одельный список выделили набор вершин лежащих на границе
s:=1;
for i in ver do
   if s = i then ;
   else
      pol:=PermFaces(pol,(s,i),0);
   fi;
   s:=s+1;
od; # теперь в списке pol.vertices сперва идут вершины которые лежат на границе

Add(sost, bord);

for k in [1 .. n-1] do
   s:=1;
   for i in sost[k] do
      if s = i then ;
      else
         pol:=PermFaces(pol,(s,i),k);
      fi;
      s:=s+1;
   od;
od;


return pol;
end);


###############################################################################

# ОПИСАНИЕ
#	Производим объединение двух политопов.
# ЗАМЕЧАНИЕ:
# входные данные:	pol1
#			pol2
# выходные данные:
#			объект типа политоп
# зависимости:

 InstallGlobalFunction(FreeUnionPol, function(pol1,pol2)
		local	pol,pol2ver,lp,dim2,i;


#Создаем новые вершины
pol:=StructuralCopy(pol1);
pol.vertices:=List(pol.vertices,x->[1,x]);
pol2ver:=List(pol2.vertices, x->[2,x]);
Append(pol.vertices,pol2ver);

lp:=Length(pol1.vertices); # length previously
dim2:=Length(pol2.faces);

for i in [1 .. dim2] do
	Append(pol.faces[i], pol2.faces[i]+lp);
	lp:=Length(pol1.faces[i]);
od;

return pol;
end);


###############################################################################

# ОПИСАНИЕ
#  Проверка является ли объект политопом
# ЗАМЕЧАНИЕ: Полная проверка на то, что все клетки являются дисками пока не
# представляется возможной. Тем не менее для размерностей от 1 до 3(4?) можно
# утверждать, что проверка является точной.
# входные данные: pol - политоп
# выходные данные: true\false
# зависимости:

#		  И Д Е Я
# 1) В записи обязательно должны присутствовать поля "vertices" и "faces".
# 2) Все клетки должны быть натянуты(ссылаться) на клетки которы были описаны ранее (кроме вершин).
# 3) Все клетки должны быть шарами\дисками. Вкачестве проверки этого факта взята характеристика Эйлера.
# 4) Не должно существовать клеток размерности меньшей dim, которые не входят ни в какие клетки максимальной размерности.


 InstallGlobalFunction(IsPolytope, function(pol)
     local	name_space,verify,kolichestvo,dim,n,ostov,
     		odnorodnost,invEuler,sostav,length,i;



# 1)---------------------------------------------------------------------------
# произовдится проверка наличия соответствующих обязательных полей

verify:=IsRecord(pol);
if verify then
	name_space:=RecNames(pol);
	verify:=("vertices" in name_space and "faces" in name_space);
else
	Print("Record havn't fild .vertices or .faces\n");
fi;

# 2)---------------------------------------------------------------------------

if verify then
	kolichestvo:=Length(pol.vertices);
	dim:=Length(pol.faces);
	n:=1;
	repeat
		ostov:=Set(Concatenation(pol.faces[n]));
		verify:=(Length(ostov) = kolichestvo);
		kolichestvo:=Length(pol.faces[n]);
		n:=n+1;
	until n>dim or (verify=false);
fi;
if verify then
else
	Print("В политопе имеются битые ссылки\n");
fi;

# 3)---------------------------------------------------------------------------

if verify then
#	odnorodnost:=List([1..dim], i->[]); # цепляем данные для 4-го шага
#
#	n:=1;
#	repeat
#		sostav:=FaceComp(pol,[dim,n]);
#		invEuler:=List([0..dim-1], i-> (-1)^i * Length(sostav.(i)));
#		verify:= (Sum(invEuler)=2);
#		odnorodnost:=List([1..dim]-1, i->Union(sostav.(i),odnorodnost[i+1]));
#		n:=n+1;
#	until n>kolichestvo or (verify=false);

	n:=1;
	repeat
		length:=Length(pol.faces[n]);
		
		i:=1;
		repeat
			sostav:=FaceComp(pol,[n,i]);
			invEuler:=List([0 .. n-1], x->(-1)^x *Length(sostav.(x)));
			invEuler:=Sum(invEuler);
			verify:=(invEuler = 1 - (-1)^n);
			i:=i+1;
		until 
			(i>length) or (verify=false);

		n:=n+1;
	until
		(n>dim) or (verify=false);

	# в будущем этот участок надо будет заменить на участок с EulerNumber
	# n:=1;
	# while verify and (n<dim) do
	# 	list:=[1..Length(pol.faces[n])];
	# 	while verify and not IsEmpty(list) do
	# 		i:=Remove(list);
	# 		sost:=FaceComp(pol,[n,i]);
	# 		en:=EulerNumber(sost);
	# 		if en = 1 then
	# 		else
	# 			verify:=false;
	# 			Print("The cell ", [n,i], "isn't a ball.\n");
	#		fi;
	#	od;
	#	n:=n+1;
	# od;
fi;

# 4)---------------------------------------------------------------------------
# Этот пункт лишний

##  if verify then
##  #	odnorodnost:=List(odnorodnost, i -> Length(i));
##  	odnorodnost:=List([1 .. dim], x->Set(Concatenation(pol.faces[x])));
##  	odnorodnost:=List(odnorodnost, x->Length(x));
##  	verify:=(odnorodnost[1] = Length(pol.vertices));
##  
##  	n:=2;
##  	repeat
##  		verify:=(odnorodnost[n] = Length(pol.faces[n-1]));
##  		n:=n+1;
##  	until
##  		(n>dim) or verify=false;
##  fi;



return verify;
end);

# ПРОВЕРКА:
# Проводилась на политопе S3cubic и на производных объекта полученных
# добавлением\удалением некоторых клеток. Так же попробовали провести проверку
# для Trefoil

###############################################################################

# ОПИСАНИЕ
#  Осуществляем заданную перестановку k-клеток политопа
# ЗАМЕЧАНИЕ: 
# входные данные: pol - политоп
#                 perm - перестановка 
#                 k - размерность клеток, которые перестанавливаем
# выходные данные:
# зависимости:

 InstallGlobalFunction(PermFaces, function(pol1, perm, k)
     local pol,lf,ind,lp,i;


pol:=StructuralCopy(pol1);

if k>0 then 
   pol.faces[k]:=Permuted(pol.faces[k], perm);
   lf:=Length(pol.faces[k]);
else
   pol.vertices:=Permuted(pol.vertices, perm);
   lf:=Length(pol.vertices);
fi;

if k<Length(pol.faces) then 
   # в списке ind на месте i  стоит индекс который получит i-ая клетка после перестановки
   ind:=ListPerm(perm);
   lp:=Length(ind);
   lf:=lf-lp;
   Append(ind,lp+[1 .. lf]);

   pol.faces[k+1]:=List(pol.faces[k+1], i->Set(ind{i}));
fi;


return pol;
end);


###############################################################################

# ОПИСАНИЕ:
# Упрощенный алгоритм поиска граничных (n-1)-клеток.
# ЗАМЕЧАНИЕ:
# входные данные:pol
# выходные данные:
# зависимости: НЕТ

 InstallGlobalFunction(PolBoundary, function(pol)
     local n,l,s,i,j,bondary,t;

n:=Length(pol.faces);
l:=Length(pol.faces[n-1]);
s:=[1..l]*0;

for i in pol.faces[n] do
   for j in i do
      s[j]:=s[j]+1;
   od;
od;

bondary:=[];
t:=1;
for i in s do
   if i=1 then 
      Add(bondary, t);
   fi;
   t:=t+1;
od;

return bondary;
end);


###############################################################################

# ОПИСАНИЕ:
# Пусть для некоторого симплекса \delta политопа pol имеется такая окрестность,
# что если удалить сам рассматриваемый симплекс из нее вместе с его гарницей, то
# мы получим несколько не пересекающихся дисков. То в таком случае данный
# симплекс \delta можно вырезать из политопа, более экономичнм способом.

# ЗАМЕЧАНИЕ: Проверку того, что такая окрестность для данного симплекса
# существует, оставляем за пользователем.
# входные данные: pol - политоп
#                 adr - адрес клетки которую удаляем
# выходные данные: политоп
#
# зависимости:
#

 InstallGlobalFunction(PolMinusFaceDoublingMethod, function(pol1,adr)
         local pol,n,clas,dim,pos,lc,star,clasters,ldim,ind,i,name;



pol:=StructuralCopy(pol1);
n:=Length(pol.faces); # размерность политопа

dim:=adr[1];
pos:=adr[2];

if dim = n then 
	Remove(pol.faces[n],pos);
else

	# (dim+1)-клетки звезды объединяем в кластеры по n-клеткам звезды
	star:=StarFace(pol,adr);
	clasters:=List(star.(n), i -> FaceComp(pol,[n,i]).(dim+1));
	clasters:=List(clasters, i -> Intersection(i,star.(dim+1)));

	# список clasters должен распасться на не пересекающиеся списки, что и
	# соответствует распаду окрестности симплекса
	lc:=Length(clasters);
	clas:=ConnectedSubset(clasters); 	# нашли первый класс, в котором в
										# качестве дубликата будет сама клетка
	ind:=Difference([1..lc],clas);
	clasters:=clasters{ind}; 		# что осталось в кластерах

	lc:=Length(clasters);
	if dim=0 then 
		ldim:=Length(pol.vertices);
	else
		ldim:=Length(pol.faces[dim]);
	fi;
	while lc > 0 do
		ldim:=ldim+1;
		clas:=ConnectedSubset(clasters);
		ind:=Difference([1..lc],clas);
		clas:=Set(Concatenation(clasters{clas})); 
		for i in clas do	# замена исходного симплекса на дубликат
			pol.faces[dim+1][i]:=Difference(pol.faces[dim+1][i],[pos]);
			Add(pol.faces[dim+1][i],ldim);
		od;
		if dim=0 then	# нужно добавить новую вершину
			name:=StructuralCopy(ldim)-1;
			repeat
				name:=name+1;
			until 
				(name in pol.vertices)=false;

			Add(pol.vertices, name);
		else
			Add(pol.faces[dim],pol.faces[dim][pos]);
		fi;
		clasters:=clasters{ind};
		lc:=Length(ind);
	od;

fi;


return pol;
end);

# ПРОВЕРКА:
# на кластере из двух тетраэдров трехмерного движения Пахрена. Было произведено разделение кластера на два не пересекающихся тетраэдра.

###############################################################################

# ОПИСАНИЕ
# ЗАМЕЧАНИЕ:
# входные данные:	pol - политоп
#			setoffaces - набор индексов клеток для которых хотим найти гарницу
# 			dim -  размерность этих клеток
# выходные данные:	список индексов (dim-1)-клеток лежащих на гарнице исследуемых клеток
# зависимости:

 InstallGlobalFunction(SetOfFacesBoundary, function(pol,setoffaces,dim)
		local	nabor,setnabor,ind,t,i,s,j;


nabor:=pol.faces[dim]{setoffaces};
setnabor:=Set(Concatenation(nabor));
ind:=[];
t:=1;
for i in setnabor do
	s:=0;
	for j in nabor do
		if i in j then
			s:=s+1;
		fi;
	od;
	if s=1 then
		Add(ind,t);
	fi;
	t:=t+1;
od;


return setnabor{ind};
end);

# ПРОВЕРКА:
# проводилась с помощью программы ZeifertSurface, т.е. проверялось, что границей поверхности Зеферта действительно является заданный узел.

###############################################################################

# ОПИСАНИЕ
#  Находим все клети которые содержатся в рассматриваемой клетке adr.
# ЗАМЕЧАНИЕ: Саму клетку также включаем в свой состав
# входные данные:	pol - политоп
# 			adr - адрес клетки
# выходные данные: запись списков индексов входящих в состав клеток по размерностям
# зависимости: НЕТ

 InstallGlobalFunction(FaceComp, function(pol,adr)
	local	dim,pos,sostav,i;



dim:=adr[1];
pos:=adr[2];

sostav:=rec();
sostav.(dim):=[pos];

for i in [dim-1, dim-2 .. 0] do
	sostav.(i):=pol.faces[i+1]{sostav.(i+1)};
	sostav.(i):=Set(Concatenation(sostav.(i)));
od;

return sostav;
end);


###############################################################################

# ОПИСАНИЕ
# Функция создания триангулированной n-сферы и -шара (n-симплекса)
# ЗАМЕЧАНИЕ: 
# входные данные: n - размерность
# выходные данные: p - политоп
# зависимости: нет

# триангулированная n-сфера
 InstallGlobalFunction(sphereTriangul, function(n)
      local p,k,i,j,vertgr,ind ;


p:=rec(vertices:=[],faces:=[]);
p.vertices:=[1..n+2];
p.faces[1]:=Combinations(p.vertices,2);
vertgr:=[];
vertgr[1]:=p.faces[1];
for k in [2..n] do
   vertgr[k]:=Combinations(p.vertices,k+1);
   p.faces[k]:=[];
   for i in vertgr[k] do
      ind:=[];
      for j in Combinations(i,k) do
         Add(ind,Position(vertgr[k-1],j));
      od;
      Add(p.faces[k],ind);
   od;   
od;

return p; 
end);

# n-симплекс (триангулированный n-диск)
 InstallGlobalFunction(ballTriangul, function(n)
      local p;

if n=1 then
   p:=rec(vertices:=[1,2],faces:=[[[1,2]]]);
else
   p:=sphereTriangul(n-1);
   p.faces[n]:=[[1..n+1]];
fi;

return p;
end);

###############################################################################

# ОПИСАНИЕ:
# функция которая вычисляет звезду грани adr в политопе pol
# В качестве определения звезды берем следующее:
#	ЗВЕЗДОЙ для данной клетки назовем набор клеток большей размерности в которых содержится иследуемая нами.
# По таком определению сама клетка НЕ ВХОДИТ в свою звезду
# входные данные:	pol - политоп
#			adr - адрес грани, для которой строится звезда ( adr=[размерность,индекс])
# выходные данные: запись (record)  по размерностям клеток
# зависимости:

 InstallGlobalFunction(StarFace, function(pol,adr)
	local	dim,pos,star,n,s,ind,i,j;



dim:=adr[1];
pos:=adr[2];
star:=rec();
n:=Length(pol.faces); # размерность политопа

s:=1;
ind:=[];
for i in pol.faces[dim+1] do
	if pos in i then
		Add(ind,s);
	fi;
	s:=s+1;
od;
star.(dim+1):=StructuralCopy(ind);

for j in [dim+2 .. n] do
	s:=1;
	ind:=[];
	for i in pol.faces[j] do
		if IsEmpty(Intersection(i,star.(j-1))) then ;
		else
			Add(ind,s);
		fi;
		s:=s+1;
	od;
	star.(j):=StructuralCopy(ind);
od;


return star;
end);

# ПРОВЕРКА:
# на кластерах тетраэдров образующих трехмерные движения Пахнера.

###############################################################################

# ОПИСАНИЕ
#  Выделяем подполитоп из данного политопа.
# ЗАМЕЧАНИЕ:
# входные данные: pol - политоп
#                 ind - индексы клеток высших размерностей из которых состоит подполитоп (высших размерностей подполитопа)
#                 dim - размерность подполитопа
# выходные данные:
# зависимости:

 InstallGlobalFunction(SubPolytope, function(pol1, ind, dim)
     local Isost,pol,sost,k,i,ver,s,l;


# Основная идея заклучается в следующем: 
# Все клетки принадлежашиее клеткам ind перегоняем в начало списков. В таком случае первые (для каждой размерности разное количество) клетки в данной размерности будут образовывать интересующий нас подполитоп и нам не нужно будет возиться с определением того, какой индекс будет иметь та или иная клетка в новом политопе.

pol:=StructuralCopy(pol1);

# выделяем состав каждой отдельной клетки
Isost:=List(ind, i -> PolBnd(pol, [dim , i]));

# создаем общий список клеток размерности k лежащий на выделяемом подполитопе
sost:=[];
for k in [1 .. dim] do
   sost[k] := [];
   for i in Isost do
      Append(sost[k], i[k]);
   od;
   sost[k]:=Set(sost[k]);
od;

# список вершин выделим отдельно
ver:=Remove(sost,1);
# добавляем индексы самих клеток
Add(sost,Set(ind));

s:=1;
for i in ver do
	if i<>s then
		pol:=PermFaces(pol,(s,i),0);
	fi;
	s:=s+1;
od;

l:=Length(ver);
pol.vertices:=pol.vertices{[1 .. l]};

for k in [1 .. dim] do
	s:=1;
	for i in sost[k] do
		if i<>s then
			pol:=PermFaces(pol, (s,i),k);
		fi;
		s:=s+1;
	od;
	l:=Length(sost[k]);
	pol.faces[k]:=pol.faces[k]{[1 .. l]};
od;

pol.faces:=pol.faces{[1 .. dim]};


return pol;
end);


###############################################################################

# ОПИСАНИЕ
#	Операция триангулирующая заданную клетку в политопе. Граница клетки
#	должна быть уже триангулированна.
# ЗАМЕЧАНИЕ: Граница клетки должна быть уже триагулированна.
# входные данные:	pol - политоп
#			adr - адрек триангулируемой клетки
# выходные данные:	политоп
# зависимости:

# InstallGlobalFunction(TriangulateFace, function(pol,adr)
#		local	l2_before,l2,kolco,porydok,rebro,koren,vetki,drobim_tyt,vetka,new_ind,newver;
#
#
## 1)---------------------------------------------------------------------------
#
#if adr[1] = 2 then
#	l2_before:=Length(pol.faces[2]);
#	l2:=StructuralCopy(l2_before);
#	if Length(pol.faces[2][adr[2]]) = 3 then ;
#	elif Length(pol.faces[2][adr[2]])=2 then
#		rebro:=pol.faces[1][pol.faces[2][adr[2]][1]];
#		pol:=DivideFace(pol,adr,rebro);
#		newver:=Length(pol.vertices);
#		repeat newver:=newver+1;
#		until (newver in pol.vertices) = false;
#		pol:=DivideFace(pol,[1,Length(pol.faces[1])], newver);
#	else
#		kolco:=pol.faces[1]{pol.faces[2][adr[2]]};
#		kolco:=SortCircle(kolco);
#		drobim_tyt:=StructuralCopy(adr[2]);
#		while Length(kolco)>3 do
#			vetki:=Difference(Union(kolco{[1,2]}),Intersection(kolco{[1,2]}));
#			pol:=DivideFace(pol,[2,drobim_tyt],vetki);
#			l2:=l2+1;
#			Add(kolco, StructuralCopy(vetki));
#			Remove(kolco,1);
#			Remove(kolco,1);
#			if Length(pol.faces[2][drobim_tyt])=3 then
#				drobim_tyt:=StructuralCopy(l2);
#			fi;
#		od;
#
#	fi;
#
## 2)---------------------------------------------------------------------------
#
#else 
#	Print("\n Sorry. This part of a program TriangulateFace didn't write. You can write it. \n\n");
#fi;
#
## 3)---------------------------------------------------------------------------
#
#
#return pol;
#end);
#

###############################################################################

# ОПИСАНИЕ
# Вычисляем данные о движении Пахнера. Это задание симплекса до и после
# движения, представление этих данных в виде политопов, вычисление индексов в
# матрице fk которые соответствуют внутренним граням.
# ЗАМЕЧАНИЕ:
# входные данные: n - размерность пространства над которым вычисляется движение
#                 k - движение пахнера из k -> n+2-k (k симплексов --- левая часть, n+2-k --- правая) k=1,...,n+1
# выходные данные: информация о соответствующем движении Пахнера
#              .l - данные для левой части движения
#              .r - данные для правой части движения
#                 .pol - политоп
#                 .sim - симплекс
#                 .vnut - индексы внутренних граней
# зависимости: SimPol, 
#

 InstallGlobalFunction(dataPachner, function(n,k)
     local comb,date,e,pol,s,vnut,i,t,j,x, l,real,future,new_pos,old_pos;


# 1) создаем левый и правый симплексы движения пахнера k -> n+2-k
comb:=Combinations([1..n+2], n+1);
#sim:=rec(1:=comb{[1..k]}, 2:=comb{[k+1..n+2]}); # левый и правый симплексы

# подготовка данных
date:=rec(1:=rec(sim:=comb{[1..k]}),2:=rec(sim:=comb{[k+1..n+2]})); # создали левый и правый симплексы

# 2) Вычисляем внутренние грани (номера по которым идет интегрирование)
for e in [1,2] do
   # if e=1, then we calcul for l.h.s.
   # if e=2, then we calcul for r.h.s.
   pol:=FromSimplexToPolytope(date.(e).sim); # переводим данные из формата "симплекс" в формат "политоп"

   # 3) Вычисляем внутренние симплексы.
   s:=1;
   vnut:=[];
   for i in pol.faces[n-1] do
      t:=0;
      for j in pol.faces[n] do
         if s in j then t:=t+1; fi;
      od;
      if t=2 then Add(vnut,s); fi;
      s:=s+1;
   od; # вычислили индексы внутренних (n-1)-клеток в политопе pol
   # теперь эти индексы нужно перевести в индексы которым они соответсвуют столбцам в матрице (саму матрицу можно создать программой MatrixFkTriangulPol).

# Будет удобно если внутренние (n-1)-грани будут стоять на последних местах, а для одинаковых внешних (n-1)-граней слева и справа натянутых на одни и теже вершины индексы совпадали. Граням как внутренним так и внешним присваивается естественный порядок по упорядоваченному множеству вершин на которые грань натянута.
l:=Length(pol.faces[n-1]);
real:=List([1..l],x->PolBnd(pol,[n-1,x])[1]);
future:=Difference([1..l],vnut);
future:=StructuralCopy(real{future});
future:=Set(future);
Append(future,StructuralCopy(Set(real{vnut}))); # теперь список future содержит желаемый порядок

new_pos:=List(future,x->Position(real,x)); # старые индексы (n-1)-граней на новых местах
old_pos:=List(real,x->Position(future,x)); # новые индексы (n-1)-граней
pol.faces[n-1]:=pol.faces[n-1]{new_pos}; # пересортировали грани
pol.faces[n]:=List(pol.faces[n],x->Set(old_pos{x})); # преобразовываем индексы n-граней
vnut:=old_pos{vnut};

   # формируем выходные данные
   date.(e).pol:=StructuralCopy(pol);
   date.(e).vnut:=StructuralCopy(vnut);

od;

#redate:=rec(l:=date.1, r:=date.2);

return rec(l:=date.1, r:=date.2);
end);


###############################################################################

# ОПИСАНИЕ
# программа переводящая симплекс в политоп 
# ЗАМЕЧАНИЕ: Реализованный алгоритм возможно будет слишком затратным для больших триангуляций.
# входные данные: simp - симплекс
# выходные данные: p - политоп
# зависимости:

 InstallGlobalFunction(FromSimplexToPolytope, function(simp)
     local n,p,cs,vr,lv,s,j,i,x,tek;


# 1) подготовка данных
n:=Length(simp[1])-1; # размерность
p:=rec(vertices:=[], faces:=[]);
cs:=StructuralCopy(simp);

# 2) запуск основного цикла
while n>1 do
   p.faces[n]:=[];
    vr:=[]; lv:=0;
    s:=1;
   for j in cs do
      tek:=Combinations(j,n); # тут все комбинации будут упорядоченными
      p.faces[n][s]:=[];
      for i in tek do
         if i in vr then Add(p.faces[n][s],Position(vr,i)); # s:=s.stop;
         else Add(vr,i); lv:=lv+1; Add(p.faces[n][s],lv);
         fi;
      od;
      p.faces[n][s]:=Set(p.faces[n][s]);
      s:=s+1;
   od;
   cs:=vr;
   n:=n-1;
od;
p.vertices:=Union(simp);
# именами вершин могут не оказаться цифры, по этому нужно сделать подсчет индексов
p.faces[1]:=[];
for i in cs do
   tek:=List(i, x->Position(p.vertices,x));
   tek:=Set(tek);
   Add(p.faces[1],tek);
od;

return p;
end);

