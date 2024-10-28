#' @title Calcule the Surface
#' @name occluded_surface
#'
#' @description The calculation of occluded surface areas is essential for
#'              understanding the possibility of an enzyme passing between atoms
#'              of a protein. To perform the calculation, it is considered that
#'              a surface is occluded based on tests with a probe, which is
#'              typically the water molecule.
#'
#' @param pdb Input containing only the name of the 4-digit PDB file, the file will be obtained online. If there is an extension ".pdb" or full path, the file will be obtained locally.
#' @param method Method to be used: OS or FIBOS
#'
#' @seealso [read_prot()]
#' @seealso [read_osp()]
#' @seealso [osp()]
#'
#' @importFrom stringr str_sub
#' @importFrom withr with_tempdir
#' @importFrom bio3d read.pdb
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)
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
