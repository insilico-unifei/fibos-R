#!/bin/csh -f
#Script to remove alternate conformations and hydrogens from PDB file

#Get all ATOM records and remove acetylated N-terminus
grep ^ATOM temp1.pdb | grep -v "ACE" > tmp0

#Remove hydrogens
#May want to comment this out
awk '((substr($0,14,1))!="H")&&((substr($0,13,1))!="H")' tmp0 > tmp1

#Remove alternate conformations (some have U and L for un-liganded and liganded,
#  we will take the unliganded form here)
#Some put it in column 27 and start with "A" for the first alternate
awk '((substr($0,17,1))!="B")&&((substr($0,17,1))!="2")&&((substr($0,17,1))!="L")&& \
      ((substr($0,27,1))!="A")&&((substr($0,27,1))!="B")&&((substr($0,27,1))!="C")&& \
       ((substr($0,27,1))!="D")&&((substr($0,27,1))!="E")&&((substr($0,27,1))!="F")&& \
      ((substr($0,27,1))!="G")&&((substr($0,27,1))!="H")&&((substr($0,27,1))!="I")' tmp1 > tmp2

#Print records from first alternate or all records if no alternates
awk '\
  ((substr($0,17,1))=="A")||((substr($0,17,1))=="1")||((substr($0,17,1))=="U") {print substr($0,1,16),substr($0,18,63)} \
  ((substr($0,17,1))!="A")&&((substr($0,17,1))!="1")&&((substr($0,17,1))!="U") {print} \
' tmp2 > tmp3

#In case the following were in ATOM records rather than HETATM records
grep -v HOH tmp3 | grep -v PMS | grep -v FOR | grep -v ALK | grep -v ANI > tmp4

#Add END to the end of the PDB file
echo END >> tmp4

#Call the file input_argument.cln
mv tmp4 temp1.cln 

#Clean up
rm tmp*
