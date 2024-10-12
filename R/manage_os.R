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
occluded_surface = function(pdb, method = "FIBOS"){
  remove_files()
  source_path = getwd()
  change = FALSE
  if(grepl(".pdb", pdb) ==  FALSE){
    arq_aux = paste(pdb,".pdb", sep = "")
    if(file.exists(arq_aux)){
      file.remove(arq_aux)
    }
  }else{
    name_pdb = pdb
    name_pdb = substr(name_pdb, nchar(name_pdb)-7, nchar(name_pdb))
    if(file.exists(pdb) == FALSE){
      stop("File not Found: ", name_pdb)
    }
    pdb_aux = read.pdb(pdb)
    pdb = name_pdb
    change = TRUE
  }
  if(!dir.exists("fibos_files")){
    dir.create("fibos_files")
  }
  withr::with_tempdir({
  pdbname = getwd()
#  pdbname = tempdir()
# setwd(pdbname)
  if(change == TRUE){
    write.pdb(pdb_aux,pdb)
  }
  meth = 0
  path = system.file("extdata", "radii", package = "fibos")
  file.copy(from = path, to = getwd())
  interval = clean_pdb(pdb)
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
  suppressMessages({
  execute(1, iresl, meth)
  })
  remove_files()
  pdb_name = change_files(pdb)
  arquivos = list.files(pdbname, full.names = TRUE)
  arquivos <- grep("\\.pdb$", arquivos, invert = TRUE, value = TRUE)
  source_path = paste0(source_path,"/fibos_files","")
  file.copy(arquivos,source_path,overwrite = TRUE)
  return(read_prot(pdb_name))
  })
}

remove_files = function(){
  files_list = dir(pattern = "\\.ms")
  if(length(files_list)>0){
    file.remove(files_list)
    files_list = NULL
  }
  files_list = dir(pattern = "\\.inp")
  if(length(files_list)>0){
    file.remove(files_list)
    files_list = NULL
  }
  files_list = dir(pattern = "\\.txt")
  if(length(files_list)>0){
    file.remove(files_list)
    files_list = NULL
  }
  if(file.exists("file.srf")){
    file.remove("file.srf")
  }
  if(file.exists("fort.6")){
    file.remove("fort.6")
  }
  if(file.exists("part_i.pdb")){
    file.remove("part_i.pdb")
  }
  if(file.exists("part_v.pdb")){
    file.remove("part_v.pdb")
  }
  if(file.exists("temp.pdb")){
    file.remove("temp.pdb")
  }
  if(file.exists("radii")){
    file.remove("radii")
  }
}
