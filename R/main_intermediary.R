#' @title Surface Calc
#' @name execute
#'
#' @description The implemented function executes the implemented methods.
#'              Using this function, it is possible to calculate occluded areas
#'              through the traditional methodology, Occluded Surface, or by
#'              applying the Fibonacci OS methodology. At the end of the method
#'              execution, the "prot.srf" file is generated, and returned for
#'              the function. The data in this file refers to all contacts
#'              between atoms of molecules present in a protein's PDB.
#'
#' @param iresf The number of the first element in the PDB
#' @param iresl The number of the first element in the PDB
#' @param maxres Maximum number of residues.
#' @param maxat Maximum number of atoms.
#'
#' @seealso [read_prot()]
#' @seealso [read_osp()]
#' @seealso [occluded_surface()]
#'
#' @importFrom stats rnorm
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)

#'
call_main = function(iresf, iresl, maxres, maxat){
  resnum = integer(maxres)
  x = double(maxat)
  y = double(maxat)
  z = double(maxat)
  main_75 = .Fortran("main", resnum = as.integer(resnum), natm = as.integer(0),
                     x=as.double(rnorm(maxat)) ,y = as.double(rnorm(maxat)),
                     z = as.double(rnorm(maxat)), iresf, iresl, PACKAGE = "fibos")
  return(main_75)
}

execute = function(iresf, iresl, method){
  maxres = 10000
  maxat = 50000
  system_arch = Sys.info()
  if(system_arch["sysname"] == "Linux" || system_arch["sysname"] == "Darwin"){
    dyn.load(system.file("libs", "fibos.so", package = "fibos"))
  } else if(system_arch["sysname"] == "Windows"){
    if(system_arch["machine"] == "x86-64"){
      dyn.load(system.file("libs/x64", "fibos.dll", package = "fibos"))
    } else{
      dyn.load(system.file("libs/x86", "fibos.dll", package = "fibos"))
    }
  }
  main_75 = call_main(iresf, iresl, maxres, maxat)
  for(ires in 1:(iresl)){
    intermediate = .Fortran("main_intermediate", main_75$x, main_75$y,
                            main_75$z, as.integer(ires), main_75$resnum,
                            main_75$natm, PACKAGE = "fibos")
    .Fortran("main_intermediate01",x=as.double(rnorm(maxat)),
             y = as.double(rnorm(maxat)),
             z = as.double(rnorm(maxat)), as.integer(ires), main_75$resnum,
             main_75$natm, PACKAGE = "fibos")
    .Fortran("runSIMS", PACKAGE = "fibos", as.integer(method))
    .Fortran("surfcal", PACKAGE = "fibos")
  }
  .Fortran("main_intermediate02", as.integer(method),PACKAGE = "fibos")
  if(system_arch["sysname"] == "Linux" || system_arch["sysname"] == "Darwin"){
    dyn.unload(system.file("libs", "fibos.so", package = "fibos"))
  } else if(system_arch["sysname"] == "Windows"){
    if(system_arch["machine"] == "x86-64"){
      dyn.unload(system.file("libs/x64", "fibos.dll", package = "fibos"))
    } else{
      dyn.unload(system.file("libs/x86", "FIBOS.dll", package = "fibos"))
    }
  }
}
