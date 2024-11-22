#' @title Occluded Surface (OS)
#' @name occluded_surface
#'
#' @description The Occluded Surface (OS) algorithm is a widely used approach for analyzing atomic packing in biomolecules. Here, we introduce FIBOS, an R and Python package that extends the OS methodology with enhancements. The homonymous function occluded_surface calculates OS per atom.
#'
#' @param pdb 4-digit PDB id (will fetch it from the RCSB repository) or the path to a PDB local file.
#' @param method Method to be used: OS (classic) or FIBOS (default).The classic OS covers the surface radially with one of the axes as a reference when allocating the dots. In FIBOS, Fibonacci spirals were used to allocate the dots, which is known to produce lower axial anisotropy as well as more evenly spaced points on a sphere.
#' @param verbose only for debugging.
#'
#' @details
#' Occluded Surface (OS) (Pattabiraman et al. 1995) method distributes dots (representing patches of area) across the atom surfaces. Each dot has a normal that extends until it reaches either a van der Waals surface of a neighboring atom (the dot is considered occluded) or covers a distance greater than the diameter of a water molecule (the dot is considered non-occluded and disregarded). Thus, with the summed areas of dots and the lengths of normals, it is possible to compose robust metrics capable of inferring the average packing density of atoms, residues, proteins, as well as any other group of biomolecules.
#'
#' For more details, see (Fleming et al, 2000) and (Soares, et al, 2024)
#'
#' @return A table containing:
#' 	\item{\code{ATOM}}{the atomic contacts for each atom.}
#' 	\item{\code{NUMBER OF POINTS}}{the number of dots (patches of area) on atomic surface.}
#' 	\item{\code{AREA}}{the summed areas of dots.}
#'  \item{\code{RAYLENGTH}}{the average lengths of normals normalized by 2.8 Å (water diameter). So, raylen is a value between 0 and 1. A raylen close to 1 indicates worse packaging.}
#'  \item{\code{DISTANCE}}{the average distances of contacts in (Å).}
#'
#' @seealso [osp]
#'
#' @author Herson Soares, João Romanelli, Patrick Fleming, Carlos Silveira.
#'
#' @references
#' Fleming PJ, Richards FM. Protein packing: Dependence on protein size, secondary structure and amino acid composition. J Mol Biol 2000;299:487–98.(\url{https://doi.org/10.1006/jmbi.2000.3750})
#'
#' Pattabiraman N, Ward KB, Fleming PJ. Occluded molecular surface: Analysis of protein packing. J Mol Recognit 1995;8:334–44. (\url{https://doi.org/10.1002/jmr.300080603})
#'
#' Herson H. M. Soares, João P. R. Romanelli, Patrick J. Fleming, Carlos H. da Silveira. bioRxiv, 2024.11.01.621530. (\url{https://doi.org/10.1101/2024.11.01.621530})
#'
#' @examples
#' library(fibos)
#'
#' # Calculate FIBOS per atom and create .srf files in fibos_files folder
#' pdb_fibos <- occluded_surface("1fib", method = "FIBOS")
#'
#' # Calculate OSP metric per residue from .srf file in fibos_files folder
#' pdb_osp <- osp(fs::path("fibos_files","prot_1fib.srf"))
#'
#' @export
occluded_surface = function(pdb, method = "FIBOS", verbose = FALSE){
  if(verbose == TRUE){
    print("Relizando limpeza de arquivos.")
  }
  remove_files()
  system_arch_1 = Sys.info()
  if(verbose == TRUE){
    print("Carregando pacotes fortran...")
  }
  if(system_arch_1["sysname"] == "Linux"||system_arch_1["sysname"] == "Darwin"){
    dyn.load(fs::path_package("fibos","libs","fibos.so"))
    if(verbose == TRUE){
      print("fibos.so carregado.")
    }
  } else{
    path_lib = fs::path("libs",.Platform$r_arch)
    dyn.load(fs::path_package("fibos",path_lib,"fibos.dll"))
    if(verbose == TRUE){
      print("fibos.dll carregado.")
    }
  }
  source_path = fs::path_real(".")
  change = FALSE
  if(fs::path_ext(pdb) ==  ""){
    arq_aux = fs::path_ext_set(pdb,"pdb")
    if(fs::file_exists(arq_aux)){
      fs::file_delete(arq_aux)
    }
    name_pdb = fs::path_ext_set(pdb,"pdb")
  }else{
    name_pdb = fs::path_file(pdb)
    if(fs::file_exists(pdb) == FALSE){
      stop("File not Found: ", name_pdb)
    }
    pdb = fs::path_abs(pdb)
    change = TRUE
  }
  if(!fs::dir_exists("fibos_files")){
    fs::dir_create("fibos_files")
  }
  withr::with_tempdir({
    if(verbose == TRUE){
      print("Inicio do WD temporario...")
    }
    dest_temp = fs::path_real(".")
    if(change == TRUE){
      if(!fs::file_exists(pdb)){
        fs::file_copy(pdb,dest_temp)
      }
      if(verbose == TRUE){
        print("PDB copiado...")
      }
    }
    meth = 0
    path = fs::path_package("fibos","extdata","radii")
    fs::file_copy(path, dest_temp)
    if(verbose == TRUE){
      print("radii copiado")
    }
    interval = clean_pdb(pdb)
    if(verbose == TRUE){
      print("Reestruturação do PDB")
    }
    iresf = interval[1]
    iresl = interval[2]
    if(toupper(method) == "OS"){
      meth = 1
    }
    if(toupper(method) == "FIBOS"){
      meth = 2
    }
    if(!(toupper(method) == "OS")&!(toupper(method) == "FIBOS")){
      stop("Wrong Method")
    }
    if(verbose == TRUE){
      print("Inicio da série de cálculos.")
    }
    execute(1, iresl, meth, verbose)
    if(verbose == TRUE){
      print("Descarregando Fortran.")
    }
    if(system_arch_1["sysname"] == "Linux"||system_arch_1["sysname"] == "Darwin"){
      dyn.unload(fs::path_package("fibos","libs","fibos.so"))
      if(verbose == TRUE){
        print("Descarregando fibos.so.")
      }
    } else{
      path_lib = fs::path("libs",.Platform$r_arch)
      dyn.unload(fs::path_package("fibos",path_lib,"fibos.dll"))
      if(verbose == TRUE){
        print("Descarregando fibos.dll.")
      }
    }
    if(verbose == TRUE){
      print("Removendo arquivos.")
    }
    remove_files()
    if(verbose == TRUE){
      print("Renomeando arquivos.")
    }
    name_prot = change_files(name_pdb)
    delete_pdb = fs::dir_ls(dest_temp,glob = "*.pdb")
    fs::file_delete(delete_pdb)
    if(verbose == TRUE){
      print("PDB deletado.")
    }
    final_dest = fs::path(source_path,"fibos_files")
    if(verbose == TRUE){
      print("Copiando .srf")
    }
    copy_files = fs::dir_ls(dest_temp,glob = "*.srf")
    if(verbose == TRUE){
      print("SRF copiado")
    }
    fs::file_copy(copy_files,final_dest, overwrite = TRUE)
    if(verbose == TRUE){
      print("Copiando .lst")
    }
    copy_files = fs::dir_ls(dest_temp,glob = "*.lst")
    fs::file_copy(copy_files,final_dest, overwrite = TRUE)
    if(verbose == TRUE){
      print("Definindo name_prot")
    }
    name_prot = fs::path(final_dest,name_prot)
    if(verbose == TRUE){
      print("Retornando tabela")
    }
    return(read_prot(name_prot))
  })
}

remove_files = function(){
  files_list = fs::dir_ls(glob = "*.ms")
  if(length(files_list)>0){
    fs::file_delete(files_list)
    files_list = NULL
  }
  files_list = fs::dir_ls(glob = "*.inp")
  if(length(files_list)>0){
    fs::file_delete(files_list)
    files_list = NULL
  }
  files_list = fs::dir_ls(glob = "*.txt")
  if(length(files_list)>0){
    fs::file_delete(files_list)
    files_list = NULL
  }
  if(fs::file_exists("file.srf")){
    fs::file_delete("file.srf")
  }
  if(fs::file_exists("fort.6")){
    fs::file_delete("fort.6")
  }
  if(fs::file_exists("part_i.pdb")){
    fs::file_delete("part_i.pdb")
  }
  if(fs::file_exists("part_v.pdb")){
    fs::file_delete("part_v.pdb")
  }
  if(fs::file_exists("temp.pdb")){
    fs::file_delete("temp.pdb")
  }
  if(fs::file_exists("radii")){
    fs::file_delete("radii")
  }
}
