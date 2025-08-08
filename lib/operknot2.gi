###############################################################################
# ОПИСАНИЕ
#  Создаем диаграму узла, удобную для построение паралели на дополнении узла,
#  имеющей нулевой коэффициент зацепления с данным узлом.
# ЗАМЕЧАНИЕ:
# входные данные: knot1 - диаграмма узла
# выходные данные:
# зависимости:

 InstallGlobalFunction( ZeroLinkFromKnot, function(knot1)
     local knot,newname,link,abs,sign,l,s,i,a,b,c,name;

knot:=StructuralCopy(knot1);

# Блок закомментированный ниже блок кода это функция которая убирает из
# диаграммы узла свободные петли. Этот блок предлагается вынести в отдельную
# функцию.
#
## удаляем свободные петли если есть 
#newname:=List(knot.kod, i->i[1]);
#name:=List(knot.orient, i->[1]);
#l:=Length(knot.kod);
#ind:=[];
#for i in [1 .. l-1] do
#   if newname[i]=newname[i+1] then
#      Add(ind, i);
#      Add(ind, i+1); # мы нашли петлю
#      s:=Position(name, newname[i]);
#      Remove(knot.orient,s); # удаляем информацию о петле
#      Remove(name,s);
#   fi;
#od;
#Sort(ind, function(u,w) return u>w; end);
#for i in ind do # удаляем сами петли
#   Remove(knot.kod, i);
#od;

# считаем линк зацепления по узлу
link:=Sum(List(knot.orient, i->i[2]));
abs:=AbsInt(link);
sign:=SignInt(link);
l:=Length(name)+1;
s:=Length(knot.kod);

for i in [1 .. abs] do
   # нужно создать имена новых вершин
   newname:=[];
   for i in [1 .. 3] do
      while l in name do
         l:=l+1;
      od;
      Add(newname, l);
      l:=l+1;
   od;
   
   a:=newname[1];
   b:=newname[2];
   c:=newname[3];
   
   # добавляем "зацепленную" петлю
   Add(knot.kod, [ StructuralCopy(c), -1],s);
   Add(knot.kod, [ StructuralCopy(b), -1],s);
   Add(knot.kod, [ StructuralCopy(a), -1],s);
   
   Add(knot.kod, [ StructuralCopy(c), 1],s);
   Add(knot.kod, [ StructuralCopy(b), 1],s);
   Add(knot.kod, [ StructuralCopy(a), 1],s);
   
   Add(knot.orient, [ StructuralCopy(a), -sign]);
   Add(knot.orient, [ StructuralCopy(b),  sign]);
   Add(knot.orient, [ StructuralCopy(c), -sign]);
   
   s:=s-1; # Данный счетчик корректен так, как количество ребер в два раза превышает количество двойных точек, а коэффициент зацепления не может быть больше чем их количество (имеется в виду количество двойных точек).
od;


return knot;
end );

###############################################################################

# ОПИСАНИЕ
# Возможно улучшение результата --- можно переписать указание поверхности
# Зейферта на тех 2-клетках которые уже есть, без добавления новой нижней.
# Может быть вообще получится упростить данный участок кода.

# Создаем поверхность Зейферта с заданной границей в виде узла K

# ЗАМЕЧАНИЕ:
# входные данные: K - диаграмма узла
# выходные данные: pol. - политоп
#                   .vertices
#                   .faces
#                   .knot - индексы 1-клеток по которым проходит узел
#                   .zeifert - индексы 2-клеток на которые натянута поверхность Зейферта
# зависимости:

 InstallGlobalFunction( ZeifertSurface, function(K)
     local d2,n,i,
           int,out,s,t,j, rebra,zcircles,okr,na4alo,konec,vot,l,
	   under,l2,ostov,pol,l3, underZ,tyt,ind,
	   grd2,lu2, underD,ost,gran,diski,nad,
	   1kl,surface,max,glubina,uzlovie,k, del, vertikal,
	   v,before,l0,vn,uzl,newname,name,ver;


# 1) построение граффа диаграммы

d2:=rec(vertices:=[], faces:=[[]]);
d2.vertices:=List(K.orient, i->i[1]);
n:=Length(K.kod); # это количество 1-клеток граффа
d2.faces[1]:=List([1..n-1], i->[K.kod[i][1], K.kod[i+1][1]]);
Add(d2.faces[1],[K.kod[n][1],K.kod[1][1]]); 
d2.faces[1]:=List(d2.faces[1],i->[Position(d2.vertices,i[1]), Position(d2.vertices, i[2])]);

# 2) определяем окружности Зейферта

#  а) для каждой точки определяем входящие и исходящие ребра
int:=[];
out:=[];
s:=1;
for i in [1 .. n/2] do
   int[s]:=[];
   out[s]:=[];
   t:=1;
   for j in d2.faces[1] do
      if i = j[1] then # то это исходящее ребро
         Add(out[s],t);
      elif i = j[2] then # то это входящее ребро
         Add(int[s],t);
      fi;
      t:=t+1;
   od;
   s:=s+1;
od;

# б) непосредственное выделение окружностей Зейферта
rebra:=[1 .. n]; # индексы всех ребер
zcircles:=[]; # окружности Зейферта
l:=StructuralCopy(n);
while l>0 do
   okr:=[rebra[1]];
   Remove(rebra,1);
   l:=l-1;
   s:=1;
   na4alo:=d2.faces[1][okr[1]][1];
   konec:=d2.faces[1][okr[s]][2];
   while na4alo <> konec do
      # ищем ребра исходящие из вершины konec, среди них выбираем то ребро чей индекс не равен okr[s]+1
      if okr[s] = n then # учитываем цикличность
         vot:=Difference(out[konec],[1])[1];
      else
         vot:=Difference(out[konec],[okr[s]+1])[1];
      fi;
      Add(okr, vot);
      s:=s+1;
      l:=l-1;
      konec:=d2.faces[1][okr[s]][2];
      rebra:=Difference(rebra,[vot]);
   od;
   # нашли замкнутую ориентируему окружность которая по построению является окружностью Зейферта
   Add(zcircles, StructuralCopy(okr));
od; #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 3) вкладываем заданный узел в S^3
pol:=KnotInS3(K);
#    удаляем "заглушку" (3-диск который приклеивался, что бы создать полноценное S^3)
l3:=Length(pol.faces[3]);
Remove(pol.faces[3],l3);

# 4) Выделяем нижнее основание вложенного узла (under)

under:=[]; # список 2-клеток лежащих на нижнем основании (основании уровня "0")
l2:=Length(pol.faces[2]);
# узнаем на какие врешины натянута каждая 2-клетка
ostov:=List([1..l2], i->PolBnd(pol,[2,i])[1]);
# переводим индекс каждой вершины в информацию о том на каком основании она находится
ostov:=List(ostov, i->Set(pol.vertices{i}[2]));

s:=1;
for i in ostov do
   if i=["0"] then # все вершины этой клетки лежат на нижнем основании
      Add(under,s);
   fi;
   s:=s+1;
od;
# При таком выделении 2-клеток в списке under могут оказаться вертикальные 2-клетки, состоящие всего из двух вершин.
# Лишние 2-клетки из списка under можно удалить проверив лежат ли на ней ребра из узла
s:=1;
ind:=[];
for i in under do
   tyt:=Intersection(pol.faces[2][i], pol.knot);
   if IsEmpty(tyt) then
      Add(ind,s);
   fi;
   s:=s+1;
od;
under:=under{ind}; # выбрали клетки которые действительно лежат на нижнем основании

# 5) теперь нужно спроектировать окружности Зейферта на выделенное основание
# 1-клетки на основаниях имеют порядковую нумерацию соответствующую порядковой нумерации в списке pol.knot

ostov:=List(under,i->StructuralCopy(pol.faces[2][i]));
underZ:=Set(Concatenation(ostov));
# проекции окружностей Зейферта на нижнее основание
underZ:=List(zcircles, i->underZ{i});

# 6) выделяем диски которые ограничивают окружностями Зейферта

#  а) выделяем границу диска основания
grd2:=List(under, i->StructuralCopy(pol.faces[2][i])); 
lu2:=Length(under); # количество 2-клеток на нижнем основании
for i in [2 .. lu2] do
   tyt:=Difference(grd2[i],grd2[1]);
   grd2[1]:=Difference(grd2[1],grd2[i]);
   Append(grd2[1],tyt);
od;
grd2:=grd2[1]; # Список 1-клеток на границе диска основания
#ostov:=List(under,i->StructuralCopy(pol.faces[2][i]));

# б) для каждой проекции окружности Зейферта находим диски, которые они ограничиывают
#    Идея заключается в следующем: последовательно выкидываем 2-клетки примыкающие к краю, пока не оголим границу исследуемой окружности, все что останется и будет нужным списком дисков.
underD:=[];
for okr in underZ do
   diski:=StructuralCopy(under); # текущий список 2-клеток основания 
   gran:=StructuralCopy(grd2); # текущий список 1-клеток на границе основания
   ost:=StructuralCopy(ostov); # текущие 1-клетки основания

   while (Set(okr)=Set(gran)) = false do
      s:=0;
      repeat  
         s:=s+1;
	 # смотрим исть ли у данной клетки ребро на крае диска
	 t:=Intersection(ost[s], gran);
	 # смотрим лежит ли это ребро на окружности (их может быть несколько)
         tyt:=Intersection(t,okr); #s:=s.top;
	 if IsEmpty(t) then
            tyt:=[0]; # учитываем, что эта 2-клетка внутренняя
	 fi; 
      until
         IsEmpty(tyt);

      tyt:=Remove(ost,s);
      Remove(diski,s);
      Append(gran,tyt);
      gran:=Difference(gran,t);
   od;

   Add(underD, StructuralCopy(diski));
od;
#-----------------------------------------------------------------------------------

# выделяем поверхность Зейферта

# выдлеяем вешины поверхности Зейферта над узлом
vertikal:=[];
surface:=[]; # список 2-клеток принадлежащих поверхности Зейферта
ind:=[];
1kl:=Set(Concatenation(underZ)); # набор 1-клеток на нижнем основании
s:=1;
for i in pol.faces[2] do
   v:=Intersection(i,pol.knot);
   if IsEmpty(v) then ;
   else
      if IsEmpty(Intersection(i,1kl)) then ;
      else
         Add(vertikal,s);
	 Add(ind,v[1]);
      fi;
   fi;
   s:=s+1;
od;
SortParallel(ind, vertikal);

# Сперва работаем с дисками которые лежат "выше" всех
s:=1;
ind:=[];
for tyt in underD do
   if Length(tyt)=1 then
      Append(surface, vertikal{zcircles[s]});
      Add(surface,tyt[1]); # список tyt это одноэлементный список
   else
      Add(ind,s);
   fi;
   s:=s+1;
od;

# работаем с оставшимися дисками
underD:=underD{ind};
underZ:=underZ{ind};
zcircles:=zcircles{ind};
# считаем уровни для оставшися дисков
nad:=[];
for i in underD do
   ind:=[];
   s:=1;
   for j in underD do
      if Intersection(i,j)=Set(i) then
         Add(ind,s);
      fi;
      s:=s+1;
   od;
   Add(nad,StructuralCopy(ind));
od;

glubina:=List(nad, i->Length(i));
max:=Maximum(glubina); # считам максимальную глубину вхождения дисков
# в списке ind[i] содержатся позиции дисков в которых содежится i-ый диск, имеются в виду позиции которые они имеют в списке underD
l2:=Length(pol.faces[2]);
l3:=Length(pol.faces[3]);
while max>0 do
   s:=1;
   for i in glubina do
      if i=max then
         l2:=l2+1;
	 Append(surface, vertikal{zcircles[s]});
	 Add(surface, StructuralCopy(l2));
	 # создаем "днище" которое приклеиваем к рассматриваемому диску (указания на диск которые сейчас создадим мы уже внесли в список surface)
         Add(pol.faces[2], StructuralCopy(underZ[s])); # добавили клетку по границе диска
	 Add(pol.faces[3], StructuralCopy(underD[s])); # создали новую 3-клетку
	 l3:=l3+1;
	 Add(pol.faces[3][l3], StructuralCopy(l2)); # указали 2-клетку закрывающую созданную 3-клетку

	 # теперь подкорректируем списки underD, укажем что некоторые клетки мы заменили новой
	 for j in nad[s] do
            underD[j]:=Difference(underD[j], underD[s]);
	    Add(underD[j],l2);
	 od;
      else 
         Add(ind,s);
      fi;
      s:=s+1;
   od;
   glubina:=glubina{ind};
   underD:=underD{ind};
   underZ:=underZ{ind};
   zcircles:=zcircles{ind};
   nad:=nad{ind};
   max:=max-1;
od;

# Заклеиваем заглушку
Add(pol.faces[3],PolBoundary(pol));




pol.zeifert:=surface;
return pol;
end );

###############################################################################

# ОПИСАНИЕ
# Построение простой границы многообразия Зейферта, которая состоит из двух отрезков (1-симплексов) 
# ЗАМЕЧАНИЕ:
# входные данные: knot - узел для которого стоим поверхность Зейферта
# выходные данные: pol - политом с указанной поверхностью Зейферта
# зависимости:

# ИДЕЯ: 
# 1) Выделяем порядок вершин и порядок ребер узла. 
# 2) Каждое очередное новое ребро подразбиваем, кадую очередную новую 2-клетку так же.
# 3) Делаем разрез по новым клеткам. Вклеиваем 3-диск с необходимым нам подразбиением.
# 4) Добавлем новую клетку к поверхности.



 InstallGlobalFunction( ZeifertSurfaceWithSimplyBoundary, function(knot)
     local 	pol,ver,i,vnut_1kl_zeif,kolvo_ver,previous_ver,l1,l2,new_ver,
     		star_z,order,pos,s,order_1kl,order_2kl,j,
		isol_ver,subpol,kolco,new_3kl,l3;



pol:=ZeifertSurface(knot);

# 1)---------------------------------------------------------------------------

ver:=[]; # порядок обхода вершин, соответствующий порядку обхода узла
for i in knot.kod do
	if i[2]=1 then
		s:=[i[1],"1"];
		Add(ver,Position(pol.vertices,s));
	else
		s:=[i[1],"0"];
		Add(ver,Position(pol.vertices,s));				# ++
	fi;
od;

vnut_1kl_zeif:=pol.faces[2]{pol.zeifert};
vnut_1kl_zeif:=Set(Concatenation(vnut_1kl_zeif));
vnut_1kl_zeif:=Difference(vnut_1kl_zeif,pol.knot);

# 2)---------------------------------------------------------------------------

kolvo_ver:=Length(ver);
previous_ver:=StructuralCopy(ver[1]);
l1:=Length(pol.faces[1]);
l2:=Length(pol.faces[2]);
new_ver:=StructuralCopy(kolvo_ver);

       #                                 # for checking
					#if IsPolytope(pol) then ;
					#else
						#Print("\n\n Oops! Line: 68. \n\n");
						#s:=s.stop;
					#fi;

for i in [2 .. kolvo_ver-1] do

		star_z:=StarFace(pol,[0,ver[i]]); # звезда вершины на поверхности Зейферта
		star_z.1:=Intersection(vnut_1kl_zeif,star_z.1);
		star_z.2:=Intersection(pol.zeifert,star_z.2);

	# Порядок встречи 1- и 2-клеток если идти рядом с границей поверхности.
	order:=StructuralCopy(pol.faces[2]{star_z.2});
	order:=List(order, x->Intersection(x, star_z.1));
	pos:=0;
	repeat pos:=pos+1; until pol.knot[i-1] in pol.faces[2][star_z.2[pos]];
	s:=Remove(star_z.2, pos);	# параллельное изменение списков pol.zeifert и order
	Add(star_z.2,s,1);
	s:=Remove(order,pos);
	Add(order,s,1);								# ++

	s:=ConnectedSubset(order);
	order:=order{s};
	order_1kl:=[order[1][1]];
	order_2kl:=star_z.2{s};
	for j in order do
		s:=Difference(j,order_1kl);
		Append(order_1kl,s);
	od;
	
	s:=1;
	for j in order_1kl do

			new_ver:=new_ver+1;
			pol:=DivideFace(pol,[1,j],new_ver);
			l1:=l1+1;
			Add(vnut_1kl_zeif,l1);

		pol:=DivideFace(pol,[2,order_2kl[s]],[previous_ver,new_ver]);
		previous_ver:=StructuralCopy(new_ver);
		s:=s+1;
		l2:=l2+1;
		l1:=l1+1;
		Add(pol.zeifert,l2);
		Add(vnut_1kl_zeif,l1);
	od;
	
					# for checking
       #                                 if IsPolytope(pol) then ;
					#else
						#Print("\n\n Oops! Line: 117. \n\n");
						#s:=s.stop;
					#fi;
od;

pos:=0;
repeat pos:=pos+1; until pol.knot[kolvo_ver-1] in pol.faces[2][pol.zeifert[pos]];
pol:=DivideFace(pol,[2,pol.zeifert[pos]],[ver[kolvo_ver],previous_ver]);
l2:=l2+1;
l1:=l1+1;
Add(pol.zeifert,l2);
Add(vnut_1kl_zeif,l1);

					# for checking
					#if IsPolytope(pol) then ;
					#else
						#Print("\n\n Oops! Line: 133. \n\n");
						#s:=s.stop;
					#fi;
# 3)---------------------------------------------------------------------------

# Сперва нужно разобраться какие 2-клетки добавились при обходе по краю. 
isol_ver:=ver{[2 .. kolvo_ver-1]};
subpol:=rec(vertices:=[], faces:=[]);
subpol.faces[2]:=[];
for i in pol.zeifert do
	s:=FaceComp(pol,[2,i]).0;
	s:=Intersection(s,isol_ver);
	if IsEmpty(s) then ;
	else
		Add(subpol.faces[2],i);
	fi;
od;
subpol.faces[1]:=Set(Concatenation(pol.faces[2]{subpol.faces[2]}));

kolco:=SetOfFacesBoundary(pol,subpol.faces[2],2);

new_3kl:=StructuralCopy(subpol.faces[2]);
for i in subpol.faces[2] do
	pol:=PolMinusFaceDoublingMethod(pol,[2,i]);
	l2:=l2+1;
	Add(new_3kl, l2);
od;

for i in Difference(subpol.faces[1],kolco) do
	pol:=PolMinusFaceDoublingMethod(pol,[1,i]);
od;

					# for checking
					#if IsPolytope(pol) then ;
					#else
						#Print("\n\n Oops! Line: 168. \n\n");
						#s:=s.stop;
					#fi;
# 4)---------------------------------------------------------------------------

Add(pol.faces[3],new_3kl);
l3:=Length(pol.faces[3]);

pol:=DivideFace(pol,[3,l3],kolco);
l2:=l2+1;

pol:=DivideFace(pol,[2,l2],pol.faces[1][pol.knot[kolvo_ver]]);
	
					# for checking
					#if IsPolytope(pol) then ;
					#else
						#Print("\n\n Oops! Line: 184. \n\n");
						#s:=s.stop;
					#fi;
#-------------------------------------------------(формирование выходных данных)

pol.knot:=[pol.knot[kolvo_ver], Length(pol.faces[1])];
pol.zeifert:=Difference(pol.zeifert,subpol.faces[2]);

	j:=pol.faces[2][l2];
#	second:=pol.faces[2][l2+1];
	s:=pol.faces[2]{pol.zeifert};
	if IsEmpty(Intersection(j,s)) then
		Add(pol.zeifert,l2+1);
	else
		Add(pol.zeifert,l2);
	fi;



for i in [1,2,3] do
	s:=1;
	for j in pol.faces[i] do
		pol.faces[i][s]:=Set(pol.faces[i][s]);
		s:=s+1;
	od;
od;

return pol;
end );

# ПРОВЕРКА:
# Проверка проводилась на узлах: трилистнике, восьмерке, неузле и узле 7_7. 
# В качестве проверочного фактора были взяты:
#	1) полученная запись должна быть политопом;
#	2) количество 2-клеток поверхности Зейферта до и после упрощения границы должно остаться неизменным;
#	3) граница поверхности Зейферта должна состоять из двух отрезков.

###############################################################################



# ОПИСАНИЕ
# Строим дополение узла в сфере S^3. Дополнительно указываем два метридиана, две
# параллели и коэффициент зацепления параллей (обе параллели будут иметь один и
# тот же коэффициент зацепления). Сводим границу полученного многообразия к
# четырем прямоугольникам (граница is тор).

#-------------------------------------------------------------------------------------------------#
#                        нарисуй рисунки к пояснениям алгоритма                                   #
#-------------------------------------------------------------------------------------------------#

# ЗАМЕЧАНИЕ: 
# входные данные: knot - диаграмма узла
#
# выходные данные:
#
# зависимости:
#

#


 InstallGlobalFunction( ComplementOfKnot, function(knot1)
     local knot, petly,link,sign,a,l,vn,newname,kosan,b,c,
           disk, ostov,s,vertical,i,pod,nad,pol,l3,l2,kriska,t,ind,j,sost,
           kasanie,l0,sost_nad,sost_pod,v,
           namek,drob,name,l1, antiv,eta,
           meridian,lp,ku4a,parallel, para,
           ver,bord,levo,prav;




knot:=StructuralCopy(knot1);

## 0) Создаение нужной диаграммы по которой выбранные параллели будут иметь нулевой коэффициент зацепления.
##  a) Напоминание: в программе погружения узла в 3-диск требовалось, что бы на диаграмме не было свободных петель, т.е. участков кода вида ...[a, "1"],[a,"0"]... или ...[a,"0"],[a,"1"]... . Избавимся от таких петель если они есть.
#name:=List(knot.kod, i-> i[1]);
#l1:=Length(name);
#petly:=[];
#s:=[];
#for i in [1 ..l1-1] do
#   if name[i]=name[i+1] then
#      Add(petly, i);   # запоминаем позиции двойной точки образующей петлю
#      Add(petly, i+1); # (потом мы будем их удалять из списка knot.kod)
#      Add(s,name[i]); # запоминаем имя вершины на которой образована петля
#   fi;
#od;
#
#if name[1]=name[l1] then
#   Add(petly,1);
#   Add(petly,l1);
#   Add(s,name[1]);
#fi;
# Sort(petly,function(u,w) return u>w ; end); # сортируем полученные индексы по убыванию
#for i in petly do # удаление из списка knot.kod
#   Remove(knot.kod, i);
#od;
#for i in s do    # удаление соответсвующей информации из списка knot.orient
#   t:=0;
#   j:=1;
#   while t<1 do
#      if i in knot.orient[j] then
#         Remove(knot.orient, j);
#         t:=t+1;
#      fi;
#      j:=j+1;
#   od;
#od; 
#
##  б) вычисляем какое зацепление будут иметь параллели если будут иметь выделенные нами линии на трубчатой окрестности узла, если будем вырезать по этой диаграмме.
#link:=List(knot.orient, i->i[2]);
#link:=Sum(link);
#sign:=1; if link<0 then sign:=-1; fi; # дополнительно определили знак
#
##  в) создаем |link| вершин с ориентациями -sign
#name:=List(knot.orient, i->i[1]);
#v:=Length(name);
#l:=sign*link;
#newname:=[];
#for i in [1..l+2] do
#   repeat v:=v+1;
#   until (v in name)=false;
#   Add(newname, StructuralCopy(v));
#od;
#
##  г) создаем "косичку" из созданных нами вершин.
#vn:=[]; # создание списка отметок прохождения сверху или снизу
#for i in [1 .. l-1] do
#   Add(vn, 1);
#   Add(vn, -1);
#od;
#
#a:=StructuralCopy(newname[l]);
#b:=StructuralCopy(newname[l+1]);
#c:=StructuralCopy(newname[l+2]);
#
#newname:=newname{[1 .. l-1]};
#kosan:=[];
#for i in [1 ..l-1] do # создание спиcка последовательности имен вершин "косички"
#   kosan[i]:=StructuralCopy(newname[i]);
#   kosan[2*l-1-i]:=StructuralCopy(newname[i]);
#od;
#s:=1; #s:=s.stop;
#for i in kosan do # создание участка кода "косички"
#   kosan[s]:=[i, vn[s]];
#   s:=s+1; 
#od;
#for i in newname do
#   Add(knot.orient, [i, -sign]); # задали ориентации в новых точках
#od;
#
#
## д) Т.к. нам нельзя создавать свободной петли, то нужно последнюю свободну петлю провести над каким либо ребром узла. Что и делается на этом шаге:
#if l>0 then
#   Add(kosan, [a, -1], l);
#   Add(kosan, [c, -1], l);
#   Add(kosan, [b, -1], l);
#   Add(kosan, [a,  1], l);
#   Add(kosan, [c,  1], l);
#   Add(kosan, [b,  1], l);
#
#   Add(knot.orient, [a, -sign]);
#   Add(knot.orient, [b, -sign]);
#   Add(knot.orient, [c,  sign]);
#
#fi; 
#
## е) такую "косичку" мы можем вставить на любом участке кода. Добавим ее в конец списка knot.kod
#Append(knot.kod, kosan); 
#++++++++++++++++++++++(проверенно вручную)++++++++++++++++++++++++++++++++

# 1) погружаем узел в диск
disk:=KnotInS3(knot); # построили погружение узла в сферу S^3

# 2) Находим вертикальные 2-клетки над узлом и под узлом.
#  а) Для этого мы используем следующую идею: Так как все ребра узла проходят по вертикальным 2-клеткам, и под каждой 1-клеткой на основании находится ровно одно ребро, то каждая вертикальная 2-клетка лежит либо над либо под ребром узла. Выделить вертикальные 2-клетки мы сможем по этому принцыпу (наличия в ее составе ребра узла).
s:=1;
l2:=Length(disk.faces[2]);
ind:=[1..l2];
vertical:=[];
for i in disk.knot do
   t:=0;
   j:=1;
   vertical[s]:=[];
   while t<2 do
      if i in disk.faces[2][ind[j]] then
         Add(vertical[s], ind[j]);
         t:=t+1;
      fi;
      j:=j+1;
   od;
   s:=s+1;
od;

#  б) Все вертикальные 2-клетки могут быть либо треугольными, либо двуугольными и четрырехугольными. Если посмотреть на вершины на которые натянуты 2-клетки будет видно, что если клетка состоит из трех ветршин и она "под", то она будет иметь две вершины отмеченные "0"  и одну вершину отмеченну "1" (и наоборот). Если же клетка 4-угольная, то противоположная ей 2-клетка, содержащая это же ребро узла будет двуугольником. 
nad:=[];
pod:=[];
for i in vertical do
   sost:=List(i, x -> PolBnd(disk, [2,x])[1]);
   sost:=List(sost, x -> disk.vertices{x}[2]); # смотрим какими индексами помечены вершины (верхн,низ)
   s:=Length(sost[1]);
   if s=2 then
      if "0" in sost[1] then 
         Add(pod, i[1]);
         Add(nad, i[2]);
      else
         Add(nad, i[1]);
         Add(pod, i[2]);
      fi;
   elif s=3 then 
      Sort(sost[1]);
      if sost[1] = ["0", "0", "1"] then
         Add(pod, i[1]);
         Add(nad, i[2]);
      else 
         Add(nad, i[1]);
         Add(pod, i[2]);
      fi;
   elif s=4 then
      if "0" in sost[2] then 
         Add(pod, i[2]);
         Add(nad, i[1]);
      else
         Add(nad, i[2]);
         Add(pod, i[1]);
      fi;
   fi;
od;

# 3) Для дальнейших пострений мы предполагаем, что каждое ребро узла входит только в две 2-клетки и соответсвенно две 3-клетки. Что обеспечивается за счет способа построение погружения узла.

# Сейчас, будем вырезать все 1-клетки по которым проходит узел. Функция вырезания PolMinusFace устроена так, что при вырезании клетки (елси ее размерность не равна размерности многообарзия) она НЕ повреждает индексы остальных клеток которые существовали до вырезания, а новые клетки образованные при этой процедуре она добавляет в конец списков (замечание: для того, что бы осуществить сохранение индексов, одна из новых клеток вставляется на место вырезаемой). 
# Параллельно, можно проверять сколько добавилось новых 2-клеток. По построению количество новых 2-клеток при каждом вырезании должно быть равно двум.
for i in disk.knot do
	pol:=PolMinusFace(disk, [1,i]);
od;

# 4) Для каждой вершины выделим 2-клетки которые ее касаются, если вершина принадлежит верхнему основанию, то 2-клетки будем выделять из списка вертикальних "под", и наоборот, если вершина принадлежит нижнему основанию, то 2-клетки будем выделять из списка вертикальных "над".
kasanie:=[];
l0:=Length(disk.vertices);
sost_nad:=List(nad, i -> PolBnd(pol,[2,i])[1]); # вершины на которые натянуты эти клетки
sost_pod:=List(pod, i -> PolBnd(pol,[2,i])[1]); # вершины на которые натянуты эти клетки
for v in [1..l0] do
   kasanie[v]:=[];
   if pol.vertices[v][2] = "1" then # индекс "1" означает верх, верхнее основание
      s:=0;
      t:=1;
      while s<2 do
         if v in sost_pod[t] then
            Add(kasanie[v],t);
            s:=s+1; # мы нашли одну 2-клетку которая касается данной вершины (всего их 2 по построению)
         fi;
         t:=t+1;
      od;
      # Сейчас индексы с списках kasanie это позиции в списках sost_pod. Нам нужны идексы 2-клеток
      kasanie[v]:=StructuralCopy(pod{kasanie[v]});
   else # в данном случае вершина принадлежит нижнему основанию
      s:=0;
      t:=1;
      while s<2 do
         if v in sost_nad[t] then
            Add(kasanie[v],t);
            s:=s+1;
         fi;
         t:=t+1;
      od;
      # Сейчас индексы с списках kasanie[v] это позиции в списках sost_nad. Нам нужны идексы 2-клеток 
      kasanie[v]:=StructuralCopy(nad{kasanie[v]});
   fi;
od; 



# 4) Теперь вырезаем вершины, но особым образом. (Лучше всего идея показана на рисунках). Идея заключается в том, что используется на алгоритм вырезания PolMinusFace, а для того что бы вырезать окрестность точки, сама эта тока дублируется, и некоторые ребра в качестве своей точки будут иметь дублированную. Так же добавляется еще пара ребер, которые будут принадлежать некоторым 2-клеткам, вместо вырезаемой точки. При таком вырезании список 3-клеток не затрагивается
for v in [1..l0] do

   # a) выделим ребра которые имеют в себе исследуемую вершину
   s:=1;
   namek:=[];
   for i in pol.faces[1] do
      if v in i then
         Add(namek,s);
      fi;
      s:=s+1;
   od;
   
   # б.) Находим индексы 1-клеток которые будут иметь дубликат данной вершины. Все такие 1-клетки находятся на 2-клетках которые мы назвали касательными к данной вершине
   drob:=List(kasanie[v], i-> StructuralCopy(pol.faces[2][i])); # 
   drob:=List(drob, i-> Intersection(i, namek));
   drob:=Concatenation(drob);
   drob:=Set(drob); # в этом списке будут содержаться повторяющиеся индексы
   
   # г) придумываем имя новой вершине.
   l0:=Length(pol.vertices); 
   name:=l0+1; # по построению такого имени вершины еще не было
   
   # д) замещение вершины на дубликат
   Add(pol.vertices,name);
   for i in drob do # по построению список drob должен быть длины 3, ЕСЛИ НУЖНО можно включить проверку этого условия
      pol.faces[1][i] := Difference(pol.faces[1][i],[v]);
      Add(pol.faces[1][i], name); # name больше всех остальных индексов
   od;
   
   # e) создаем две 1-клетки натянутые на исследуемую вершину и ее дубль
   l1:=Length(pol.faces[1]);
   Append(pol.faces[1], [ [v,name],[v,name] ]);
   
   # ё) Нам нужно узнать какие 2-клетки теперь будут иметь в себе новые созданные нами 1-клетки
   # Можно представить, что два ребра узла проходящие через вершину которую мы пытаемся удалить (пусть и несколько хитрым способом) лежат на некоторой вертикальной плоскости. Тогда все 2-клетки лежащие с одной стороны от этой плоскости будут содеражать одно и тоже добавленное ребро (1-клетку), 2-клетки с другой строны от этой плоскости будут содерать вторую копию от этого ребра.
   antiv:=[disk.vertices[v][1]]; # находим противопложную вершину для данной
   if disk.vertices[v][2]="1" then
      Add(antiv,"0");
   else
      Add(antiv,"1");
   fi; # сейчас мы только нашли ее имя
   antiv:= Position(disk.vertices, antiv); # нашли индекс противопложной вершины
   
   # находим 2-клетки с той и этой строны в которых надо добавить ребра
   l1:=l1+1; # теперь это индекс первого добавленного ребра
   for i in kasanie[antiv] do # 3-клетки с одной сторны должны содержать одну(какую-то) клетку которая указана в списке kasinie для этой вершины
      
      # Т.о. мы разделили клетки с "той" и "этой" строны. Теперь нужно найти 2-клетки с соответсвующей стороны в которые нужно добавить это 1-клетку. Одну такую 2-клетку мы уже знаем это клетка с индексом i, но мы не будем делать этого сразу, а осуществим это в цикле, позже.
      # непосредственно находим 3-клетки с "этой" стороны
      eta:=[];
      s:=0;
      t:=1;
      while s<2 do
         if i in pol.faces[3][t] then
            Add(eta,t);
            s:=s+1;
         fi;
         t:=t+1;
      od;
      
      # одно и тоже ребро должно быть добавленно к тем 2-клеткам с "этой" строны которые имеют и вершину v и вершину name.
      eta:=List(eta, i -> pol.faces[3][i]);
      eta:=Set(Concatenation(eta)); # список индексов 2-клеток с "этой" стороны
      s:=0;
      t:=1;
      while s<3 do # такое условие выбрано по тому, что 2-клеток в которые добавится новое ребро с "этой" стороны будет всего 3
         ostov:=PolBnd(pol,[2,eta[t]])[1]; # указали вершины на которые натянута данная 2-клетка
         if (v in ostov) and (name in ostov) then
            Add(pol.faces[2][eta[t]], l1);
            s:=s+1;
         fi;
         t:=t+1;
      od;
      
      l1:=l1+1; # 
   od;

od; #++++++++++++++++++++++++++++++ (были проверены: 1-остов и граница, вручную) +++++++++++++++++++++++++++++++++++++++++
#s:=s.stop;

# 4) Упрощение PL-разбиения
# Заметим, что если стянуть все вертикальные 2-клетки которые состоят только из двух ребер на одно из них, то ребро узла (или уже ребро параллели) просто окажется на основании диска. Такое стягивание не повредит политоп (т.е. после осущетсвления этой операции, все клетки остануться шарами и само многообразие не изменится). Так же можно стянуть все минимальные 2-клетки (состоящии только из двух ребер) на одно из из собственных ребер. 

l2:=Length(pol.faces[2]);
s:=1;
while s<l2+1 do
   if Length(pol.faces[2][s])=2 then
      pol:=ContractMiniFace(pol, [2,s]);
      l2:=l2-1; # если клетка минимальна, то мы ее удалили из списка 2-клеток (соответсвенно, список уменьшился, s менять не нужно)
   else
      s:=s+1; # если клетка не минимальная то переходим к следующему индексу
   fi;
od;

# 5) Выделение параллелей и меридианов.
# Все 1-клетки лежащие на меридианах находятся в конце списка (их количество равно количеству вершин)
l0:=Length(pol.vertices);
meridian:=[];
l1:=Length(pol.faces[1]);
meridian:=l1 +1 -[1 ..  l0]; # выбрали последние l0 индексов из всех индексов 1-клеток (пока еще этот список мы не разделяли)
ku4a:=PolBoundary(pol);
ku4a:=List(ku4a, i-> StructuralCopy(pol.faces[2][i]));
ku4a:=Set(Concatenation(ku4a));
ku4a:=Difference(ku4a, meridian); # список 1-клеток которые будут образовывать параллели

# Теперь мы можем указать две паралели. 
ostov:=List(ku4a, i-> pol.faces[1][i]);
parallel:=[];
parallel[1]:=ConnectedSubset(ostov);
parallel[1]:=ku4a{parallel[1]};
parallel[2]:=Difference(ku4a, parallel[1]);

## Мы можем выделить два меридиана: в списке meridian они группируются по два (по построению). 
#meridian[1]:=StructuralCopy([meridian[1], meridian[2]]);
#meridian[2]:=StructuralCopy([meridian[3], meridian[4]]);
#meridian:=meridian{[1,2]};

# Выбирем меридиан удобным для нас способом. Выбираем меридиан на вершинах узла между которыми расположено только одно ребро выбранное для параллели.
v:=disk.faces[1][disk.knot[1]];
# меридианы будем брать на этих вершинах
sost:=List(meridian, i->pol.faces[1][i]);
a:=[]; b:=[];
s:=0; t:=1;
while s<4 do
   if v[1] in sost[t] then
      Add(a,meridian[t]);
      s:=s+1;
   elif v[2] in sost[t] then
      Add(b, meridian[t]);
      s:=s+1;
   fi;
   t:=t+1;
od;
meridian:=StructuralCopy([a,b]);
#++++++++++++++++++++++++(ручная проверка параллелей и меридиан)++++++++++++++++++++++++++++++++

pol:=rec(vertices:=pol.vertices, faces:=pol.faces, parallel:=parallel, meridian:=meridian);


#-----------------------------------------------------------------------------------------------#
#------------------- Упрощаем границу до четырех прямоугольников -------------------------------#

# А) Подготовка к вклеиванию нового участка трубки для тора.

# Определяем верхние и нижние вершины меридианов.
ver:=List(pol.meridian{[1,2]}[1], i->pol.faces[1][i]); # из каждого меридиана взяли по одному ребру и выяснили на какие вершины он натянут
# так как все списки pol.faces[1][i] отсортированны по возрастанию, то по построению первым в этом списке будет идти индекс вершины построенной при погружении узла в 3-сферу, второй индекс это индекс дубликата этой вершины.
for i in [1,2] do
   if pol.vertices[ver[i][1]][2]="0" then # нулем были помечены вершины на нижнем основании
      ver[i]:=ver[i]{[2,1]}; 
   fi;
od; # сделали так, чтоб в списках ver первыми шли индексы вершин сверху

# Когда мы указывали меридианы, мы сделали так, что этими меридианами ребра образующие параллели сверху\снизу разбились на два участка. Один из этих участков содержит только одно ребро, второй все остальные ребра. Обозначим отдельными символами индексы ребер лежащих на первых участках.
s:=Position(pol.faces[1], Set(ver{[1,2]}[1])); # нашли индекс ребра натянутого на верхние вершины меридианов (по построению он единственный)
t:=Position(pol.faces[1], Set(ver{[1,2]}[2])); # нашли индекс ребра натянутого на нижние вершины меридианов
if s in pol.parallel[1] then
   parallel:=pol.parallel;
else
   parallel:=pol.parallel{[2,1]};
fi; # первым в списке parallel будут идти индексы ребер верхней параллели

# выделяем списки индексов на втором участке
parallel[1]:=Difference(parallel[1],[s]);
parallel[2]:=Difference(parallel[2],[t]);

bord:=PolBoundary(pol);
sost:=List(bord, i -> pol.faces[2][i]{[3,4]}); # выбрали только те ребра которые лежат на меридианах (по построению они последние в списках)
ind:=ConnectedSubset(sost);
levo:=bord{ind};             # индексы 2-клеток границы слева от узла
prav:=Difference(bord, levo);# индексы 2-клеток границы справа от узла
# лево и право выбраны условно

# определим "левое" и "правое" ребро выделенного меридиана
sost:=sost{ind}; # список sost состоит только из индексов ребер по которым проходят меридианы (не обязательно выделенные нами)
sost:=(Concatenation(sost));
for i in [1,2] do
   if pol.meridian[i][1] in sost then
   else
      pol.meridian[i]:=pol.meridian[i]{[2,1]};
   fi;
od; # сделали так, что бы первыми в списках меридианов шли индексы ребер слева

# из списка levo выкидываем индекс 2-клетки которые лежат на первом участке
sost:=List(levo, i->pol.faces[2][i]);
i:=0; j:=1;
while i<1 do
   if s in sost[j] then
      Remove(levo, j);
      i:=1;
   fi;
   j:=j+1;
od;
# из списка prav выкидываем индекс 2-клетки которые лежат на первом участке
sost:=List(prav, i->pol.faces[2][i]);
i:=0; j:=1;
while i<1 do
   if s in sost[j] then
      Remove(prav, j);
      i:=1;
   fi;
   j:=j+1;
od;
# теперь списки levo и pravo списки 2-клеток на оставшемся участке тора

# Б) Вклеиваине нового участка трубки тора

# Добавляем новое ребро между верхними\нижними вершинами меридианов
l1:=Length(pol.faces[1]);
Add(pol.faces[1], Set(ver{[1,2]}[1])); # верхнее ребро, его индекс l1+1
Add(pol.faces[1], Set(ver{[1,2]}[2])); # ниждее ребро, его индекс l1+2

# Создаем 2-клетки заменяющие 2-клетки слева и справа
l2:=Length(pol.faces[2]);
for i in [1,2] do
   j:=pol.meridian{[1,2]}[i]; # 1-клетки меридиана слева\справа
   Append(j, l1+[1,2]); # добавляем к ним связующие 1-клетки для меридианов (которые мы добавили)
   Add(pol.faces[2], StructuralCopy(j));
od; # заменяющая левая 2-клетка будет иметь индекс l2+1, правая --- l2+2

# Создаем 2-клетки сверху и снизу, на добавленных 1-клетках
Add(parallel[1], l1+1); # сверху
Add(parallel[2], l1+2); # снизу

Add(pol.faces[2], parallel[1]); # ее индекс l2+3
Add(pol.faces[2], parallel[2]); # ее индекс l2+4

# Создаем 3-клетки
# левую:
   Append(levo, [l2+1, l2+3, l2+4]);
   Add(pol.faces[3], levo);
# правую:
   Append(prav, [l2+2, l2+3, l2+4]);
   Add(pol.faces[3], prav);
   
# В) указываем новые параллели
pol.parallel:=[ [s, l1+1], # верхняя параллель
                [t, l1+2] ]; # нижняя параллель



for i in [1..3] do
   pol.faces[i]:=List(pol.faces[i], x->Set(x));
od;














# a:=a.stop;
return pol;
end );

# ПОЯСНЕНИЕ:
#


###############################################################################



# ОПИСАНИЕ
#  Построение триангуляции многообразия полученного при вырезании трубчатой
#  окрестности узла. В качестве дополнительной информации указываются две
#  параллели и два меридиана.

# ЗАМЕЧАНИЕ: В качестве параллели выделена линия на трубчатой окрестности узла,
# имеющая нулевой коэффициент зацепления с этим узлом.
# входные данные: knot - узел
# 
# выходные данные:
#
# зависимости:
#



 
 InstallGlobalFunction( TriangulateComplementOfKnot, function(knot,orient)
     local pol,bord,a,b,s,i,sost,ver,j,perm,newpor,verxparal,vermerid;




# Вырезание погружение узла из S^3.
pol:=ComplementOfKnot(knot); 

# вычисляем границу
bord:=PolBoundary(pol); 



#         схема разбиения границы на данный момент 
#  +---------------------------+---------------------------+
# 1|                          3|                          1|
#  |                           |                           |
#  |            c              |             d             |      vnes
#  |                           |                           |
#  |                           |                           |
#  |                           |                           |
#  |---------------------------+---------------------------| <-- верхняя параллель (условно)
# 2|                          4|                          2|
#  |                           |                           |
#  |            a              |             b             |      vnut
#  |                           |                           | 
#  |                           |                           |
#  |                           |                           |
#  +---------------------------+---------------------------+
# 1                           3                           1     1,2,3,4 --- vertetices name


# Наша задача сейчас триангулизировать гарницу многообразия. Ее PL-разбиение (разбиение границы) представлено на схеме выше. Для нас нужна триангуляция тора двумя не пресекающимимся друг с другом группами линий, которые на данной схеме образуют диагонали прямоугольников. Если на прямоугольнике а задать диагональ (14), то такая же диагональ будет на прямоугольнике d, на прямоугольниках c и b будет диагональ (23). Но на прямоугольнике a можно выбрать другую диагональ и уже на остальных прямоугольниках диагонали будут выбраны в соответсвии с нашим выбором. 

# Не произвольно на диаграмме (в нашем способе задания) определено некоторое напраление по узлу. В соответсвии с этим можно было сказать какая клетка лежит слева от узла (по направлению) какая справа, чем мы и пользовались при построении погружения и вырезания узла. В программе CopmlementOfKnot в списках meridian[i] первыми шли индексы 1-клеток которые лежат слева от узла по направлению обхода. Первая же параллель в списке parallel это параллель над узлом (вторая соответсвенно под узлом).


#-----------------------------------------------------------------------------------------------------------------#
# К чему бы можно было привязать выбор набора диагоналей на клетках? Пока ответ на этот вопрос не ясен. Поэтому здесь по алгоритму выбирается произвольная клетка на которой добавляесят диагональ (14) (если orient = +1) или диагональ (23) (если orient = -1)
#-----------------------------------------------------------------------------------------------------------------#

# Сперва переместим границу в начало списков pol.faces и находим образы меридианов и параллелей в новой индексации.
# Новый индекс у граничного ребра i, будет его порядковый номер среди граничных ребер.
bord:=PolBoundary(pol);
sost:=List(bord, i->pol.faces[2][i]);
sost:=Set(Concatenation(sost));

pol:=FirstBoundary(pol);

for i in [1,2] do
   for j in [1,2] do
      pol.meridian[i][j]:=Position(sost, pol.meridian[i][j]);
      pol.parallel[i][j]:=Position(sost, pol.parallel[i][j]);
   od;
od;
# в списке bord тоже изменились индексы 2-клеток на границе, т.к. у нас заведомо всего четыре прямоугольника, то
bord:=[1..4];

# Условно, вершинам на одно из параллелей (пусть для определенности это будет нижняя параллель) присвоим имена 1 и 3 (произвольно) и на другой параллели вершинам присвоим именя 2 и 4.
verxparal:=pol.faces[1][pol.parallel[1][1]]; # смотрим на какие вершины натянута верхняя параллель
vermerid:=List(pol.meridian, i-> pol.faces[1][i[1]]); # смотрим на какие вершины натянуты меридианы

newpor:=[];
newpor[2]:=verxparal[1];
newpor[4]:=verxparal[2];

   if newpor[2] in vermerid[1] then 
      newpor[1]:=Difference(vermerid[1], newpor)[1];
      newpor[3]:=Difference(vermerid[2], newpor)[1];
   else
      newpor[3]:=Difference(vermerid[1], newpor)[1];
      newpor[1]:=Difference(vermerid[2], newpor)[1];
   fi;
# newpor это порядок вершин который нам нужно задать.
# Переставим вершины.
perm:=PermListList(newpor,[1 .. 4]);
pol:=PermFaces(pol,perm,0);
# для удобства обращения переименуем первые 4 вершины их порядковыми номерами
for i in [1 .. 4] do
   pol.vertices[i]:=i;
od;

# выбираем первую же попавшуюся 2-клетку и добавляем на ней диагональ, в пару к ищем еще одну 2-клетку которая не имеет общих ребер с первой клеткой
a:=[bord[1]]; # первая группа прямоугольников на которых добавляется диагональ на одинаковые вершины
b:=[];        # вторая группа прямоугольников на которых добавляется диагональ на одинаковые вершины
for i in bord{[2..4]} do
   if IsEmpty(Intersection(pol.faces[2][a[1]], pol.faces[2][i])) then
      Add(a,i);
   else
      Add(b,i);
   fi;
od; 

# непосредтсвенное добавление диагоналей
if orient = +1 then
   pol:=Diagonal2(pol,a[1],[1,4]);
   pol:=Diagonal2(pol,a[2],[1,4]);
   pol:=Diagonal2(pol,b[1],[2,3]);
   pol:=Diagonal2(pol,b[2],[2,3]);
elif orient = -1 then
   pol:=Diagonal2(pol,b[1],[1,4]);
   pol:=Diagonal2(pol,b[2],[1,4]);
   pol:=Diagonal2(pol,a[1],[2,3]);
   pol:=Diagonal2(pol,a[2],[2,3]);
else
   Print(" Function input mast be (knot, +-1). Please, chek youre the input. \n");
   break;
fi; # триангулизовали границу
 
# триангуляция остального политопа
pol:=PolTriangulate(pol);



return pol;
end );

# ПОЯСНЕНИЕ:
#
