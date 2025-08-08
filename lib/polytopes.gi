Print("We gonna eat your brain\n");

# Define polytopes somehow

InstallValue(
s1, rec(
  vertices := List(["A", "B"]),
  faces := List([
    # 1-faces
    List([Set([1,2])])
  ])  
));

InstallValue(
s2, rec( 
  vertices := List(["A", "B", "C"]),
  faces := List([
    # 1-faces
    List([Set([1,2]), Set([2,3]), Set([3,1])]),
    # 2-faces
    List([Set([1,2,3])])
  ])
));

InstallValue(
s3, rec( 
  vertices := List(["A", "B", "C","D"]),
  faces := List([
    # 1-faces
    List([Set([1,2]), Set([2,3]), Set([3,1]), 
          Set([4,1]), Set([4,2]), Set([4,3])]),
    # 2-faces
    List([Set([1,2,3]), Set([1,5,4]), Set([3,4,6]), Set([2,5,6])]),
    # 3-faces
    List([[1,2,3,4]])
  ])
));

InstallValue(
3sq, rec(
  vertices := List(["A", "B", "C", "D"]),
  faces := List([
    # 1-faces
    List([Set([1,2]), Set([2,3]), Set([3,4]), Set([4,1])]),
    # 2-faces
    List([[1,2,3,4],[1,2,3,4],[1,2,3,4]])
  ])
));

InstallValue(
T2, rec(
  vertices := List(["A", "B", "C", "D"]),
  faces := List([
    # 1-faces
    List([Set([1,2]), Set([2,3]), Set([3,4]), Set([4,1]),
          Set([1,2]), Set([2,3]), Set([3,4]), Set([4,1])]),
    # 2-faces
    List([Set([1,2,3,4]),Set([5,6,7,8]),Set([2,5,4,7]),Set([3,6,1,8])])
  ]),
  syms := [ [(1,2)(3,4), (1,5)(2,4)(3,7)(6,8), (1,3)(2,4)], # translation
            [(1,4)(2,3), (1,3)(2,6)(4,8)(5,7), (1,4)(2,3)], # another translation
            [(), (1,5)(2,6)(3,7)(4,8), (1,2)(3,4)], #  x -> -x (both coordinates;
                                                    # at the moment, no need to do it for each separately) 
            [(2,4), (1,4,5,8)(2,7,6,3), (1,3,2,4)] # rotation
          ]
));

InstallValue(
cube, rec(
  vertices := List(["A", "B", "C", "D", "A'", "B'", "C'", "D'"]),
  faces := List([
    # 1-faces
    List([Set([1,2]), Set([2,3]), Set([3,4]), Set([4,1]),
          Set([1,5]), Set([2,6]), Set([3,7]), Set([4,8]),
          Set([5,6]), Set([6,7]), Set([7,8]), Set([8,5])]),
    # 2-faces
    List([Set([1,6,9,5]),Set([6,2,7,10]),Set([7,11,8,3]),Set([8,12,5,4]),
          Set([1,2,3,4]),Set([9,10,11,12])]),
    # 3-faces
    List([Set([1,2,3,4,5,6])])
  ])
));


InstallValue(
S3cubic, rec(
  vertices := List(["A", "B", "C", "D", "A'", "B'", "C'", "D'"]),
  faces := List([
    # 1-faces
    List([Set([1,2]), Set([2,3]), Set([3,4]), Set([4,1]),
          Set([1,5]), Set([2,6]), Set([3,7]), Set([4,8]),
          Set([5,6]), Set([6,7]), Set([7,8]), Set([8,5])]),
    # 2-faces
    List([Set([1,6,9,5]),Set([6,2,7,10]),Set([7,11,8,3]),Set([8,12,5,4]),
          Set([1,2,3,4]),Set([9,10,11,12])]),
    # 3-faces
    List([Set([1,2,3,4,5,6]),Set([1,2,3,4,5,6])])
  ])
));

InstallValue(
S1, rec(
  vertices := ["A","B"],
  faces := [
    # 1-faces
    [[1,2], [1,2]]
  ],
  syms := [ [(1,2),(1,2)], [(),(1,2)] ]
));

InstallValue(
S2, rec(
  vertices := ["A", "B", "C"],
  faces := [
    # 1-faces
    [ [1,2], [1,3], [2,3] ],
    # 2-faces
    [ [1,2,3], [1,2,3] ],
  ],
  syms := [ [(1,2,3),(1,3,2),()], [(),(),(1,2)], [(2,3),(1,2),()] ]
));
    

InstallValue(
S4, rec(
  vertices := ["A","B","C","D","E"],
  faces := [
    # 1-faces
    [ [1,2], [1,3], [1,4], [1,5], [2,3], [2,4], [2,5], [3,4], [3,5], [4,5] ],
    # 2-faces
    [ [1,2,5], [1,3,6], [1,4,7], [2,3,8], [2,4,9], [3,4,10], [5,6,8], [5,7,9], [6,7,10], [8,9,10] ],
    # their vertices:
    #  1,2,3    1,2,4    1,2,5    1,3,4    1,3,5    1,4,5     2,3,4    2,3,5    2,4,5     3,4,5
    # 3-faces
    [ [1,2,4,7], [1,3,5,8], [2,3,6,9], [4,5,6,10], [7,8,9,10] ],
    # their vertices:
    #  1,2,3,4    1,2,3,5    1,2,4,5    1,3,4,5     2,3,4,5
    # 4-faces
    [ [1,2,3,4,5], [1,2,3,4,5] ]
  ]
));

InstallValue(
D3, rec(
  vertices := List(["A","B","C","D"]),
  faces := List([
    # 1-faces
    [ [1,2], [1,3], [1,4], [2,3], [3,4], [2,4] ],
    # 2-faces
    [ [1,2,4], [1,3,6], [2,3,5], [4,5,6], [4,5,6] ],
    # 3-faces
    [ [1,2,3,4], [1,2,3,5] ]
  ])
));

InstallValue(
3cubes, rec(
  vertices := List(["A", "B", "C", "D", "A'", "B'", "C'", "D'"]),
  faces := [
    # 1-faces
    [Set([1,2]), Set([2,3]), Set([3,4]), Set([4,1]),
          Set([1,5]), Set([2,6]), Set([3,7]), Set([4,8]),
          Set([5,6]), Set([6,7]), Set([7,8]), Set([8,5])],
    # 2-faces
    [Set([1,6,9,5]),Set([6,2,7,10]),Set([7,11,8,3]),Set([8,12,5,4]),
          Set([1,2,3,4]),Set([9,10,11,12])],
    # 3-faces
    [[1,2,3,4,5,6],[1,2,3,4,5,6],[1,2,3,4,5,6]]
    ]
));

InstallValue(
bigon, rec(
  vertices := ["A","B"],
  faces := [
    # 1-faces
    [ [1,2], [1,2] ],
    # 2-faces
    [ [1,2] ]
  ]
));

InstallValue(
3pillow, rec(
  vertices := ["A", "B", "C", "D"],
  faces := [
    # 1-faces
    [ [1,2], [2,4], [1,3], [3,4], [1,4], [1,4] ],
    # 2-faces
    [ [3,4,5], [3,4,6], [1,2,5], [1,2,6] ],
    # 3-faces
    [ [1,2,3,4] ]
  ]
));

InstallValue(
3pillow1, rec(
  vertices := ["A", "B", "C", "D"],
  faces := [
    # 1-faces
    [ [1,2], [1,3], [2,3], [2,3], [2,4], [3,4] ],
    # 2-faces
    [ [1,2,3], [1,2,4], [3,5,6], [4,5,6] ],
    # 3-faces
    [ [1,2,3,4] ]
  ]
));

InstallValue(
lantern, rec(
  vertices := ["A", "B"],
  faces := [
    # 1-faces
    [ [1,2], [1,2], [1,2] ],
    # 2-faces
    [ [1,2], [2,3], [1,3] ],
    # 3-faces
    [ [1,2,3] ]
  ]
));

InstallValue(
DoubleLantern, rec(
  vertices := ["A", "B"],
  faces := [ 
    # 1-faces
    [ [1,2], [1,2], [1,2], [1,2] ],
    # 2-faces
    [ [1,2], [2,3], [3,4], [1,4] ],
    # 3-faces
    [ [1,2,3,4], [1,2,3,4] ]
  ]
));

InstallValue(
MobiusBand, rec(
  vertices := ["A", "B", "C", "D"],
  faces := [
    # 1-faces
    [ [1,2], [3,4], [2,3], [2,4], [1,4], [1,3] ],
    # 2-faces
    [ [1,2,3,5], [1,2,4,6] ]
  ]
));

################################################################################### now functions
###################################################################################

InstallGlobalFunction( Lens,
function (p,q)

local i,
  lens_vertices, 
  edges_AC, edges_BC, edges_AD, edges_BD, edges_AB, edges_CD,
  faces_ACD_upper, faces_ACD_lower, faces_BCD_upper, faces_BCD_lower, 
    faces_ABC_left, faces_ABC_right, faces_ABD_left, faces_ABD_right,
  tetra_upper_left, tetra_upper_right, tetra_lower_left, tetra_lower_right,
  all_faces
;

lens_vertices := ["A", "B", "C", "D"];

edges_AC := List( [1..p], i -> [1,3] );
edges_BC := List( [1..p], i -> [2,3] );
edges_AD := List( [1..p], i -> [1,4] );
edges_BD := List( [1..p], i -> [2,4] );
edges_AB := [[1,2], [1,2]]; # first upper, then lower
edges_CD := [[3,4], [3,4]]; # first upper, then lower
# and then all edges will be assembled in a single list in this very order

faces_ACD_upper := List( [1..p], i -> [i, 2*p+i, 4*p+3] );
faces_ACD_lower := List( [1..p], i -> [1+(q+i-1) mod p, 2*p+i, 4*p+4] );
faces_BCD_upper := List( [1..p], i -> [p+i, 3*p+i, 4*p+3] );
faces_BCD_lower := List( [1..p], i -> [p+ 1+(q+i-1) mod p, 3*p+i, 4*p+4] );
faces_ABC_left := List( [1..p], i -> [i, p+i, 4*p+1] );
faces_ABC_right := List( [1..p], i -> [1+i mod p, p+i, 4*p+2] );
faces_ABD_left := List( [1..p], i -> [2*p+i, 3*p+i, 4*p+1] );
faces_ABD_right := List( [1..p], i -> [2*p +1+i mod p, 3*p+i, 4*p+2] );
# and then all 2-faces will be assembled in a single list in this very order

tetra_upper_left := List( [1..p], i -> [i, 2*p+i, 4*p+i, 6*p+i] );
tetra_upper_right := List( [1..p], i -> [1+i mod p, 2*p+i, 5*p+i, 7*p+i] );
tetra_lower_left := List( [1..p], i -> [p+i, 3*p+i, 4*p+ 1+(q+i-1) mod p, 6*p+i] );
tetra_lower_right := List( [1..p], i -> [p+ 1+i mod p, 3*p+i, 5*p+ 1+(q+i-1) mod p, 7*p+i] );

all_faces := [ 
  Concatenation( edges_AC, edges_BC, edges_AD, edges_BD, edges_AB, edges_CD ),
  Concatenation( faces_ACD_upper, faces_ACD_lower, faces_BCD_upper, faces_BCD_lower, 
    faces_ABC_left, faces_ABC_right, faces_ABD_left, faces_ABD_right ),
  Concatenation( tetra_upper_left, tetra_upper_right, tetra_lower_left, tetra_lower_right ) 
];

return
  rec ( vertices := lens_vertices, faces := all_faces );

end );



#########################

InstallGlobalFunction( PolPrint,
# print all the faces of simplitial complex in terms of names of vertices
# (in a bit awkward fashion, but who cares)
function (s) 
  local d,d1,f,f1,f2,i,j,k,fs;

  Print("Vertices: ", s.vertices, "\n");
  
  # loop over dimension of faces (actual dimensions are d-1)
  for d in [1..Length(s.faces)] do
    # loop over faces of given dimension
    for k in [1..Length(s.faces[d])] do
      f := s.faces[d][k];
      f1 := f;
      # recursively substitute faces
      for d1 in [d-1,d-2..1] do
        f2 := [];
	for i in [1..Length(f1)] do
	  UniteSet(f2, s.faces[d1][f1[i]]); 
	od;
	f1 := f2;
      od;
      # finally, substitute faces names
      fs := [];
      for i in [1..Length(f1)] do
        UniteSet(fs, [s.vertices[f1[i]]]);
      od;
      Print("Face ", d, " #", k, " (", f, ") is ", fs, "\n");
    od;
  od;
end );


##################################

InstallGlobalFunction( ballAB,
# a ball of dimension n and just two vertices A and B
function(n)
  local l, m;
    l := List( [1..n-1], x -> [ [1,2], [1,2] ] );
    m := Concatenation( l, [[[1,2]]] );

  return rec(
    vertices := ["A", "B"],
    faces := m
  );
end );

#######################################

InstallGlobalFunction( sphereAB,
# a sphere of dimension n and just two vertices A and B
function(n)
  local l;
    l := List( [1..n], x -> [ [1,2], [1,2] ] );

  return rec(
    vertices := ["A", "B"],
    faces := l
  );
end );

###########################################




