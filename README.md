---
editor_options: 
  markdown: 
    wrap: sentence
---

# R fibos (BETA)

The Occluded Surface (OS) algorithm is a widely used approach for analyzing atomic packing in biomolecules. 
Here, we introduce **fibos**, an R and Python package that extends the OS methodology with enhancements. 
It integrates efficient Fortran code from the original OS implementation and introduces an innovation: 
the use of Fibonacci spirals for surface point distribution. This modification reduces anisotropy and 
ensures a more uniform and even distribution of surface dots, improving the accuracy
of the algorithm.

Python fibos version: https://github.com/insilico-unifei/fibos-py.git.

## Operating Systems

fibos was designed to be multiplatform and run on Linux, Windows and Mac.
However, it has been tested on the following versions:

- **Linux**: Ubuntu ($\geq$ 20.04)
- **Windows**: Windows 11
- **Mac**: MacOS 15.0.1


## Instalation

These additional packages may be required:

```         
install.packages("tidyverse", "bio3d", "fs", "furrr")
```

Install fibos:

```         
install.packages("devtools"")
library("devtools")
install_github("https://github.com/insilico-unifei/fibos-R.git") 
```

## Main functions:

1.  **`occluded_surface(pdb, method = "FIBOS")`**: Implements the Occluded Surface 
algorithm, generating points, areas, and normals for each atom. It accepts the path 
to a PDB file and a method selection—either the classic 'OS' or the default 'FIBOS'. 
The function returns the results as a table (tibble) and creates a file named 
prot_PDBid.srf in the fibos_file directory.

1.  **`osp(file)`**: Implements the Occluded Surface Packing (OSP) metric for 
each residue. Accepts a path to an SRF file generated by occluded_surface as a 
parameter and returns the results as a table (tibble) summarized by residue. 

### A simple example:

```         
  library(tidyverse)
  library(bio3d)
  library(fs)
  library(furrr)
  library(fibos)
  
  # source of PDB files
  folder <- "PDB"
  
  # Create folder if it does not exists
  if (!dir.exists(folder)) fs::dir_create(folder)
  
  # PDB ids
  pdb_ids = c("8RXN","1ROP") 
  
  # Get PDB from RCSB, put it in folder and return path to it
  pdb_path <- pdb_ids |> bio3d::get.pdb(path = folder) 
  
  # Calculate FIBOS per atom per PDBid, create SRF files in fibos_files folder and 
  # return FIBOS in a list of tables in pdb_fibos
  plan(multisession, workers = 2) # comment this to serial
  pdb_fibos <- pdb_path |> furrr::future_map(\(x) occluded_surface(x, method = "FIBOS"), 
                                            .options = furrr_options(seed = 123))
  
  # Show first 3 rows of first table in pdb_fibos list
  pdb_fibos[[1]] |> utils::head(3)
  
  # A tibble: 3 × 6
    INF   ATOM                       NUMBER_POINTS  AREA RAYLENGTH DISTANCE
    <chr> <chr>                              <int> <dbl>     <dbl>    <dbl>
  1 INF   MET    1@N___>SER  29@CB__             2  0.4      0.927     6.16
  2 INF   MET    1@N___>SER  29@CA__             1  0.2      0.958     6.35
  3 INF   MET    1@CA__>PRO  15@CB__             9  1.86     0.246     4.09
  
  # Mounts srf paths
  srf_path <- pdb_ids |> map(\(x) fs::path("fibos_files", paste0("prot_",x), 
                                           ext = "srf")) |> unlist()
  
  # Consolidate FIBOS by residue in a list of tables in pdb.osp
  pdb_osp <- srf_path |> purrr::map(\(x) osp(x))
  
  # Show first 3 rows of first table in pdb.osp list
  pdb_osp[[1]] |> utils::head(3)
  
  # A tibble: 3 × 5
    Resnum Resname    OS `os*[1-raylen]`   OSP
     <dbl> <chr>   <dbl>           <dbl> <dbl>
  1      1 MET      40.2            29.0 0.207
  2      2 LYS      43.4            29.2 0.22 
  3      3 LYS      68.1            46.6 0.356
  
  # Rename the fibos_files folder to preserve it
  file.rename("fibos_files","fibos_files_test")
```

### More complex example:
[Here](https://github.com/insilico-unifei/fibos-R-case-study-supp.git) we show a 
case study  (in R only), aiming to compare the packing density between experimentally 
determined structures and the same structures predicted by AlphaFold (AF).

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


