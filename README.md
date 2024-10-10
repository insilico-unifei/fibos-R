---
editor_options: 
  markdown: 
    wrap: sentence
---

# FIBOS-R (BETA)

The Occluded Surface (OS) algorithm is a widely used approach for analyzing atomic packing in biomolecules. 
Here, we introduce FIBOS, an R and Python package that extends the OS methodology with enhancements. 
FIBOS integrates efficient Fortran code from the original OS implementation and introduces an innovation: 
the use of Fibonacci spirals for surface point distribution. This modification reduces anisotropy and 
ensures a more uniform and even distribution of surface dots, improving the accuracy
of the algorithm.

Python version here: [FIBOS-PY (BETA)](https://github.com/insilico-unifei/FIBOS-PY.git).

## Operating Systems

FIBOS was designed to be multiplatform and run on Linux, Windows and Mac.
However, it has been tested on the following versions:

- **Linux**: Ubuntu 20.04
- **Windows**: 
- **Mac**: 


## Instalation

```         
install.packages("devtools"")
install_github("https://github.com/insilico-unifei/FIBOS-R.git") 
```

These additional packages may be required:

```         
install.packages("tidyverse", "bio3d", "fs", "furrr")
```

## Main functions:

1.  **`occluded_surface(pdb, method = "FIBOS")`**: The function accepts parameters for the path to a PDB file and 
a method selection, either "OS" or "FIBOS" (default). It calculates points, areas, and normals 
for each atom, returning the results as a table (tibble) and generating a file named `prot_PDBid.srf` 
in the `fibos_file` directory.

1.  **`osp(file)`**: The function accepts parameter for the path to a SRF file and return a 
table (tibble) consolidated by residue.

### Example:

```         
  folder <- "PDB" 
  if (!dir.exists(folder)) fs::dir_create(folder)
  pdb.ids = c("8RXN","1ROP") 
  pdb.path <- pdb.ids |> bio3d::get.pdb(path = folder) 
  
  pdb.fibos <- pdb.path |> map(\(x) occluded_surface(x, method = "FIBOS"))
  
  pdb.fibos[[1]] |> head(3)
  
  # A tibble: 3 × 6
    INF   ATOM                       NUMBER_POINTS  AREA RAYLENGTH DISTANCE
    <chr> <chr>                              <int> <dbl>     <dbl>    <dbl>
  1 INF   MET    1@N___>SER  29@CB__             2  0.4      0.927     6.16
  2 INF   MET    1@N___>SER  29@CA__             1  0.2      0.958     6.35
  3 INF   MET    1@CA__>PRO  15@CB__             9  1.86     0.246     4.09
  
  srf.path <- pdb.path |> map(\(x) gsub("/", "/prot_", x)) |> 
                          map(\(x) gsub("\\.pdb",".srf", x)) |> 
                          map(\(x) gsub(folder, "fibos_files", x)) 
  
  pdb.osp <- srf.path |> map(\(x) osp(x))
  
  pdb.osp[[1]] |> head(3)
  
  # A tibble: 3 × 5
    Resnum Resname    OS `os*[1-raylen]`   OSP
     <dbl> <chr>   <dbl>           <dbl> <dbl>
  1      1 MET      40.2            29.0 0.207
  2      2 LYS      43.4            29.2 0.22 
  3      3 LYS      68.1            46.6 0.356
    
  file.rename("fibos_files","fibos_files_test")
```

### More complete application example:
[Here](https://github.com/insilico-unifei/FIBOS-R-case-study-supp.git) we show a case study, aiming 
to compare the packing density between experimentally determined 
structures and the same structures predicted by AlphaFold (AF).

## Authors

-   Carlos Silveira ([carlos.silveira\@unifei.edu.br](mailto:carlos.silveira@unifei.edu.br))\
    Herson Soares ([d2020102075\@unifei.edu.br](mailto:d2020102075@unifei.edu.br))\
    Institute of Technological Sciences,\
    Federal University of Itajubá,\
    Campus Itabira, Brazil.

-   João Romanelli ([joaoromanelli\@unifei.edu.br](mailto:joaoromanelli@unifei.edu.br)) \
    Institute of Applied and Pure Sciences, \
    Federal University of Itajubá, \
    Campus Itabira, Brazil.

-   Patrick Fleming ([Pat.Fleming\@jhu.edu](mailto:Pat.Fleming@jhu.edu)) \
    Thomas C. Jenkins Department of Biophysics, \
    Johns Hopkins University, \
    Baltimore, MD, USA

## References

Fleming PJ, Richards FM. Protein packing: Dependence on protein size, secondary structure and amino acid composition. J Mol Biol 2000;299:487–98.

Pattabiraman N, Ward KB, Fleming PJ. Occluded molecular surface: Analysis of protein packing. J Mol Recognit 1995;8:334–44.

## Status

In Progress.


