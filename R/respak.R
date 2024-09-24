#' @title Respak Calcule
#' @name osp
#'
#' @description The OSP value is important for verifying the quality of the values
#'              calculated by the developed package for calculating the contact
#'                areas between the molecules of the analyzed protein.
#'
#' @param file Prot File (.srf).
#'
#' @seealso [read_prot()]
#' @seealso [occluded_surface()]
#' @seealso [read_osp()]
#'
#' @importFrom readr read_table
#'
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)
#'
#' @export
osp = function(file){
  if(endsWith(file,".srf")==FALSE){
    file = paste(file,".srf",sep = "")
  }
  if(file.exists(file) == FALSE){
    stop("File not Found: ",file)
  }
  name = file
  if(file.exists(file)){
    if(file!="prot.srf"){
      file.rename(file,"prot.srf")
      file = "prot.srf"
    }
    system_arch_1 = Sys.info()
    if(system_arch_1["sysname"] == "Linux"||system_arch_1["sysname"] == "Darwin"){
      dyn.load(system.file("libs", "FIBOS.so", package = "FIBOS"))
    } else if(system_arch_1["sysname"] == "Windows"){
      if(system_arch_1["machine"] == "x86-64"){
        dyn.load(system.file("libs/x64", "FIBOS.dll", package = "FIBOS"))
      } else{
        dyn.load(system.file("libs/x86", "FIBOS.dll", package = "FIBOS"))
      }
    }
    .Fortran("respak", PACKAGE = "FIBOS")
    if(system_arch_1["sysname"] == "Linux"||system_arch_1["sysname"] == "Darwin"){
      dyn.unload(system.file("libs", "FIBOS.so", package = "FIBOS"))
    } else if(system_arch_1["sysname"] == "Windows"){
      if(system_arch_1["machine"] == "x86-64"){
        dyn.unload(system.file("libs/x64", "FIBOS.dll", package = "FIBOS"))
      } else{
        dyn.unload(system.file("libs/x86", "FIBOS.dll", package = "FIBOS"))
      }
    }
    osp_data = readr::read_table("prot.pak")
    file = gsub(".srf","",name)
    file = paste(file,".pak",sep = "")
    file.rename("prot.srf",name)
    file.rename("prot.pak",file)
    return(osp_data)
  }
  else{
    return(NULL)
  }
}

#' @title Read OSP Value
#' @name osp
#'
#' @description The OSP value is important for verifying the quality of the values
#'              calculated by the developed package for calculating the contact
#'                areas between the molecules of the analyzed protein.
#'
#' @param prot_file OSP File (.pak).
#'
#' @importFrom readr read_table
#'
#'
#' @export
read_osp = function(prot_file){
  if (endsWith(prot_file, ".pak") == FALSE){
    prot_file = paste(prot_file,".pak",sep = "")
  }
  if(file.exists(prot_file) ==  FALSE){
    stop("File not Found: ", prot_file)
  }
  osp_data = readr::read_table(file)
  return(osp_data)
}
