---
editor_options: 
  markdown: 
    wrap: sentence
---

# FIBOS R (BETA)

The Occluded Surface (OS) algorithm is a widely used approach for analyzing atomic packing in biomolecules. 
Here, we introduce **FIBOS**, an R and Python package that extends the OS methodology with enhancements. 
It integrates efficient Fortran code from the original OS implementation and introduces an innovation: 
the use of Fibonacci spirals for surface point distribution. This modification reduces anisotropy and 
ensures a more uniform and even distribution of surface dots, improving the accuracy
of the algorithm.

Python fibos version: https://github.com/insilico-unifei/fibos-py.git.

## Operating Systems

FIBOS was designed to be multiplatform and run on Linux, Windows and Mac.\
Tested on:

- **Linux**: Ubuntu ($\geq$ 20.04)
- **Windows**: Windows 11
- **Mac**: MacOS 15.0.1

## Compilers

- gfortran
- gcc

## R versions

Tested on: 4.4.1

## Instalations

### Preliminary

Some preliminary actions according to OS:

#### Linux (Ubuntu)
Install gfortran:
```bash
$ sudo apt install gfortran
```

#### Windows

Install RTools from:
```
https://cran.r-project.org/bin/windows/Rtools
```

Install gfortran from (version $\geq$ 13.2):
```
http://www.equation.com/servlet/equation.cmd?fa=fortran
```

Set the PATH to the R bin folder as an administrator:

```bash
$ setx PATH "%PATH%;C:\Program Files\R\R-x.x.x\bin"

```
where x.x.x is the actual version number of your R installation.

#### MacOS

Install Homebrew:
```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/
HEAD/install.sh)”
```

In your shell, set the PATH to include the Homebrew bin folder by adding it into 
the .zshrc file

```
export PATH= "/path/to/homebrew/bin:$PATH"

```
where "/path/to/homebrew/bin" is the actual homebrew path in your system. So, reload it:

```bash
$ source ~/.zshrc

```

Some Mac versions (with Apple Silicon) may require Rosetta:
```bash
$ softwareupdate --install-rosetta --agree-to-license
```

Install xcode and gfortran from:
```bash
https://cran.r-project.org/bin/macosx/tools/
```

### Install fibos:

```R
install.packages("devtools")
library("devtools")
install_github("https://github.com/insilico-unifei/fibos-R.git") 
```

## Main functions:

1.  **`occluded_surface(pdb, method = "FIBOS")`**: Implements the Occluded Surface 
algorithm, generating points, areas, and normals for each atom. As parameters it 
accepts a PDB id (or the path to a local PDB file) and a method selection — either 
the classic 'OS' or the default 'FIBOS'. The function returns the results as a table 
and creates a file named `prot_PDBid.srf` in the `fibos_file` directory.

2.  **`osp(file)`**: Implements the Occluded Surface Packing (OSP) metric for 
each residue. Accepts a path to an .srf file generated by `occluded_surface` as a 
parameter and returns the results as a table summarized by residue.

### Quickstart:

```R
library(fibos)

# Calculate FIBOS per atom and create .srf files in fibos_files folder
pdb_fibos <- occluded_surface("1fib", method = "FIBOS")

# Show first 3 rows of pdb_fibos table
pdb_fibos |> utils::head(3) |> print()

# A tibble: 3 × 6
#   ATOM                       NUMBER_POINTS  AREA RAYLENGTH DISTANCE
#   <chr>                              <int> <dbl>     <dbl>    <dbl>
# 1 GLN    1@N___>HIS   3@NE2_             6  1.29     0.791     5.49
# 2 GLN    1@N___>HIS   3@CE1_             1  0.2      0.894     6.06
# 3 GLN    1@N___>HIS   3@CG__             1  0.16     0.991     6.27

# Calculate OSP metric per residue from .srf file in fibos_files folder
pdb_osp <- osp(fs::path("fibos_files","prot_1fib.srf"))

# Show first 3 rows of pdb_osp table
pdb_osp |> utils::head(3) |> print()

# A tibble: 3 × 5
#   Resnum Resname    OS `os*[1-raylen]`   OSP
#    <dbl> <chr>   <dbl>           <dbl> <dbl>
# 1      1 GLN      36.8            22.0 0.157
# 2      2 ILE      49.4            36.2 0.317
# 3      3 HIS      64.2            43.2 0.335
``` 

### A more complex example:

```R     
library(fibos)
library(furrr)

# source of PDB files
pdb_folder <- "PDB"

# fibos folder output
fibos_folder <- "fibos_files"

# Create PDB folder if it does not exist
if (!fs::dir_exists(pdb_folder)) fs::dir_create(pdb_folder)

# PDB ids list
pdb_ids = c("8RXN","1ROP") |> tolower()

# Get PDB files from RCSB and put them into the PDB folder 
pdb_paths <- pdb_ids |> bio3d::get.pdb(path = pdb_folder)
pdb_paths |> print()

# Save default environment variable "mc.cores" to recover later
default_cores <- getOption("mc.cores")

# Detect number of physical cores and update "mc.cores" according to pdb_ids size
ideal_cores <- min(parallel::detectCores(), length(pdb_ids))
if (ideal_cores > 0) options(mc.cores = ideal_cores)

# Calculate in parallel FIBOS per PDBid 
# Create .srf files in fibos_files folder
# Return FIBOS tables in pdb_fibos list
if (ideal_cores > 1) future::plan(multisession, workers = ideal_cores)
pdb_fibos <- pdb_paths |> furrr::future_map(\(x) occluded_surface(x, method = "FIBOS"), 
                                            .options = furrr_options(seed = 123))
# Recover default "mc.cores"
if (ideal_cores > 0) options(mc.cores = default_cores)

# Show first 3 rows of first pdb_fibos table
pdb_fibos[[1]] |> utils::head(3) |> print()

# Prepare paths for the generated .srf files in folder fibos_files
srf_paths <- pdb_ids |> purrr::map(\(x) fs::path(fibos_folder, paste0("prot_",x), ext = "srf")) |> 
             unlist()
srf_paths |> print()

# Calculate OSP metric by residue
# Return OSP tables in pdb_osp list
pdb_osp <- srf_paths |> purrr::map(\(x) osp(x))

# Show first 3 rows of the first pdb_osp table
pdb_osp[[1]] |> utils::head(3) |> print()
```

### Case study:
[Here](https://github.com/insilico-unifei/fibos-R-case-study-supp.git) we show a 
case study  (currently only in R), aiming to compare the packing density between experimentally 
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


