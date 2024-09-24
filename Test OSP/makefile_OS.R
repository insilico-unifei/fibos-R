#library(os)
library(FIBOS)
library(readr)
library(dplyr)
library(tidyr)
if(1){
  file = readLines("table_4.dat")
  means_file = "all_means.dat"
#  con_means = file(means_file,"w")
  results_tibble <- tibble(
    file_name = character(),
    mean_value = numeric()
  )
  tempo = system.time({
  for(item in file){
    item_aux = paste(item,".pdb",sep = "")
    FIBOS::occluded_surface(item_aux,"OS")
    osp_file = paste("fibos_files/prot_",item,sep = "")
    osp_file = paste(osp_file,".srf",sep = "")
    osp = FIBOS::osp(osp_file)
    osp = osp$OSP
    mean_item = mean(osp)
    results_tibble <- add_row(results_tibble, file_name = item, mean_value = mean_item)
#    name_file = paste(item,"_pak_R.dat",sep = "")
#    line_means = paste(item,mean_item)
#    writeLines(line_means,con_means)
#    con = file(name_file,"w")
#    writeLines(as.character(osp),con)
#    close(con)
  }
#  close(con_means)
  if(file.exists("prot.pak")){
    file.remove("prot.pak")
  }
  if(file.exists("prot.srf")){
    file.remove("prot.srf")
  }
  if(file.exists("temp.pdb")){
    file.remove("temp.pdb")
  }})
  print(tempo)
}
