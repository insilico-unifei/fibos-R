#' @title Prot Reading
#' @name read_prot
#'
#' @description It is crucial to read and manipulate the data of the occluded
#'              surfaces that were calculated. Through the results, it is
#'              possible to draw important conclusions and perform studies on
#'              specific proteins and their behavior at the atomic level.
#'
#' @param file Path or name of prot file.
#'
#' @details The function allows reading a prot file, which contains data
#'          calculated using the OS or FIBOS methodology. The input parameter
#'          is the name of the file "prot.srf" or the directory path where it is
#'          located."
#'
#' @seealso [occluded_surface()]
#' @seealso [osp()]
#' @seealso [read_osp()]
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)
#'
#'
#' @importFrom readr read_fwf
#' @importFrom dplyr filter
#' @importFrom dplyr rename
#' @importFrom stringr str_count
#' @importFrom tidyr separate
#'

read_prot = function(file){
  dado = read_fwf(file,show_col_types = FALSE)
  dado = filter(dado, X1 == "INF")
  dado$X7 = NULL
  dado = rename(dado, INF = X1, ATOM = X2, NUMBER_POINTS = X3, AREA = X4, RAYLENGTH = X5, DISTANCE = X6)
  dado$NUMBER_POINTS = gsub("\\s\\pts","", dado$NUMBER_POINTS)
  dado$AREA = gsub("\\s\\A2","", dado$AREA)
  dado$RAYLENGTH = gsub("\\s\\Rlen","", dado$RAYLENGTH)
  dado$NUMBER_POINTS = as.integer(dado$NUMBER_POINTS)
  dado$AREA = as.double(dado$AREA)
  dado$RAYLENGTH = as.double(dado$RAYLENGTH)
  dado$DISTANCE = as.double(dado$DISTANCE)
  dado$INF = NULL
  return(dado)
}
