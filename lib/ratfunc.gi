################################################################################

#			<ManSection><Func Name="DivideRationalFunction" Arg="f,g" />
#				<Description>
#					Осуществляется деление двух рациональных функций заданных в
#					формате неприводимых множителей.
#					<Example>
#					</Example>
#				</Description>
#			</ManSection>

InstallGlobalFunction( DivideRationalFunction,
function(f1,g1)
	local	f, g, h;

	f:=SimplifyRationalFunction(f1);
	g:=SimplifyRationalFunction(g1);

	f.numerator:=Append(f.numerator, g.denominator);
	f.denominator:=Append(f.denominator, g.numerator);

	h:=rec(	coef:=f.coef/g.coef, 
	 		numerator:=f.numerator,
	 		denominator:=f.denominator);

return SimplifyRationalFunction(h);
end);
################################################################################

#			<ManSection><Func Name="GcdPolynomial" Arg="f,g" />
#				<Description>
#					Находится наибольший общий делитель для двух полиномов.
#					Результат выдается в виде списка неприводимых многочленов.
#					<Example>
#gap> a:=x^5+y^5;;
#gap> b:=(x^7+y^7)*(x+y)^2;;
#gap> GcdPolynomial(a,b);
#[ x_1+x_2 ]
#					</Example>
#				</Description>
#			</ManSection>

InstallGlobalFunction(GcdPolynomial,
function(f,g)
	local	coef_f, coef_g, list_f, list_g, i, p, pos, gcd, ind;

	if IsPolynomial(f) then
		coef_f:=LeadingCoefficient(f);
		list_f:=Factors(f/coef_f);
	elif IsRecord(f) then
		list_f:=StructuralCopy(f.numerator);
	fi;
	if IsPolynomial(g) then
		coef_g:=LeadingCoefficient(g);
		list_g:=Factors(g/coef_g);
	elif IsRecord(g) then
		list_g:=StructuralCopy(g.numerator);
	fi;

	i:=1;
	ind:=[];
	for p in list_f do
		pos:=Position(list_g, p);
		if pos=fail then
		else
			Remove(list_g,pos);
			Add(ind,i);
		fi;
		i:=i+1;
	od;
	gcd:=[];
	while not IsEmpty(ind) do
		Add(gcd,Remove(list_f, Remove(ind)));
	od;

return gcd;
end);
################################################################################

#			<ManSection><Func Name="LcmPolynomial" Arg="f,g" />
#				<Description>
#					Находится наименьшее общее кратное для двух полиномов.
#					Результат выдается в виде списка неприводимых многочленов.
#					<Example>
#gap> a:=x^5+y^5;;
#gap> b:=(x^7+y^7)*(x+y)^2;;
#gap> LcmPolynomial(a,b);
#[ x_1+x_2, x_1+x_2, x_1+x_2, x_1^4-x_1^3*x_2+x_1^2*x_2^2-x_1*x_2^3+x_2^4,
#  x_1^6-x_1^5*x_2+x_1^4*x_2^2-x_1^3*x_2^3+x_1^2*x_2^4-x_1*x_2^5+x_2^6 ]
#					</Example>
#				</Description>
#			</ManSection>

InstallGlobalFunction(LcmPolynomial,
function(f,g)
	local	coef_f, coef_g, list_f, list_g, i, ind, lcm, common, chastots;

	if IsPolynomial(f) then
		coef_f:=LeadingCoefficient(f);
		list_f:=Factors(f/coef_f);
	elif IsRecord(f) then
		list_f:=StructuralCopy(f.numerator);
	fi;
	if IsPolynomial(g) then
		coef_g:=LeadingCoefficient(g);
		list_g:=Factors(g/coef_g);
	elif IsRecord(g) then
		list_g:=StructuralCopy(g.numerator);
	fi;

	common:=Union(list_f,list_g);
	chastots:=List(common, 
		x -> Maximum(Length(Positions(list_f,x)),Length(Positions(list_g,x))));
	ind:=[1 .. Length(common)];
	lcm:=List(ind, i -> List([1..chastots[i]], x -> common[i]));
	lcm:=Concatenation(lcm);

return lcm;
end);
################################################################################

#			<ManSection><Func Name="ProductRationalFunctions" Arg="f,g" />
#				<Description>
#					Функция проводит умножение двух рациональных функций
#					заданных в формате неприводимых многочленов.
#					<Example>
#					</Example>
#				</Description>
#			</ManSection>

InstallGlobalFunction(ProductRationalFunctions,
function(f1,g1)
	local	h, f, g;

	f:=SimplifyRationalFunction(f1);
	g:=SimplifyRationalFunction(g1);
	h:=f;
	Append(h.numerator, g.numerator);
	Append(h.denominator, g.denominator);
	h.coef:=h.coef * g.coef;
	h:=SimplifyRationalFunction(h);

return h;
end);

################################################################################
#	Упрощение рациональной функции. В GAP рациональные функции либо не
#	сокращаются (имеется в виду сокращение общих множителей), либо
#	сокращаются не полностью. Так же могут не сокращаться числовые
#	коэффициенты. Данная программа обходит это неудобство. (На сколько
#	позволяет функционал GAP).

InstallGlobalFunction(SimplifyRationalFunction,
function(ratf)
	local	numerator, denominator, lcn, lcd, factorN, factorD,
	commonfactors, element, pos, coef, quastion_record, quastion_rational,
	s, edinica, ind, i;


	quastion_record:=IsRecord(ratf);
	quastion_rational:=IsRationalFunction(ratf);
	
	if quastion_record then 
		factorN:=StructuralCopy(ratf.numerator);
		factorD:=StructuralCopy(ratf.denominator);
		coef:=ratf.coefficient;
	elif quastion_rational then
#	 1)-----------------------------------------------------------------------
		numerator:=NumeratorOfRationalFunction(ratf);
		denominator:=DenominatorOfRationalFunction(ratf);
		lcn:=LeadingCoefficient(numerator);	# тип данных - число
		lcd:=LeadingCoefficient(denominator);	# тип данных - число
		coef:=lcn/lcd;
		numerator:=numerator/lcn;
		denominator:=denominator/lcd;
		factorN:=Factors(numerator); #Print(" + \n");
		factorD:=Factors(denominator); #Print(" + \n");
	else
		Print("Sory, function  \n", ratf, "\n isn't rational function.\n");
	fi;

#	 2)-----------------------------------------------------------------------
	i:=1;
	ind:=[];
	for element in factorD do
		pos:=Position(factorN, element);
		if pos = fail then
		else
			Remove(factorN,pos);
			Add(ind,i);
		fi;
		i:=i+1;
	od;
	while not IsEmpty(ind) do
		Remove(factorD, Remove(ind));
	od;
#	 3)-----------------------------------------------------------------------
#	Удаление единиц из списков numerator, denominator.
	if IsEmpty(factorN) then ;
		if not IsEmpty(factorD) then
			edinica:=One(factorD[1]);
		fi;
	else
		edinica:=One(factorN[1]);
	fi;

	s:=1;
	pos:=[];
	for element in factorN do
		if not element = edinica then
			Add(pos, s);
		fi;
		s:=s+1;
	od;
	factorN:=factorN{pos};

	s:=1;
	pos:=[];
	for element in factorD do
		if not element = edinica then
			Add(pos, s);
		fi;
		s:=s+1;
	od;
	factorD:=factorD{pos};

return rec(coef:=coef, numerator:=factorN, denominator:=factorD);
end);
