#' @title Files Manipulating.
#' @name create_folder
#'
#' @description Function for creating folders and manipulating files in the FIBOS system.
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)
#'
change_files = function(pdb_name){
  if(fs::path_ext(pdb_name) == "pdb"){
    pdb_name = fs::path_file(pdb_name)
    pdb_name = fs::path_ext_remove(pdb_name)
  }
  name_pdb = pdb_name
  name_raydist = pdb_name
  if(fs::file_exists("prot.srf") == TRUE){
    name_string = paste("prot_",pdb_name,sep = "")
    name_pdb = fs::path_ext_set(name_string,".srf")
    fs::file_move("prot.srf", name_pdb)
  }
  if(fs::file_exists("raydist.lst") == TRUE){
    name_raydist = paste("raydist_",pdb_name,sep ="")
    name_raydist = fs::path_ext_set(name_raydist,"lst")
    fs::file_move("raydist.lst", name_raydist)
  }
  return(name_pdb)
}
