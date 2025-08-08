##  For the LoadPackage mechanism in GAP >= 4.4 only the entries
##  .PackageName, .Version, .PackageDoc, .Dependencies, .AvailabilityTest
##  .Autoload   are needed.

SetPackageInfo( rec(

PackageName := "PL",

Subtitle := "Piecewise-Linear Topology and Mathematical Physics",


Version := "0.1.1",

PackageDoc := rec(
  BookName  := "PL",
  Archive := [],
  ArchiveURLSubset := [],
  HTMLStart := [],
  PDFFile   := "doc/manual.pdf",
  SixFile   := [],
  LongTitle := [],
  Autoload  := false
),


Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := []                      
),

AvailabilityTest := ReturnTrue,

Autoload := false,

));


