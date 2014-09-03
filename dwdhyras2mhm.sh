#!/bin/bash

# Alle Operationen von DWD- -> mHM-NetCDF
# wichtig, wenn leere Zeilen Fehler hervorrufen: dos2unix -n ifile_dos.sh ofile_unix.sh

# Gebiet ausschneiden + missing_Value + valid range setzen wegen -999 NoData:
for ((year=1976;year<=2006;year++)); do echo "processing $year"; cdo sellonlatbox,9.0,14.0,46.0,49.0 -setmissval,-999 -setvrange,0,10000 pr_hyras_1_${year}_v2.0.nc pr_inn_${year}.nc; done

# Simon (Ruhr):
# for ((year=1990;year<=2006;year++)); do echo "processing $year"; cdo sellonlatbox,6.0,9.0,50.0,52.0 -setmissval,-999 -setvrange,0,10000 pr_hyras_1_${year}_v2.0.nc pr_ruhr_${year}.nc; done

# Zeit korrigieren:
# for ((year=1976;year<=2006;year++)); do echo "processing $year"; ncatted -a units,time,o,c,"days since ${year}-01-01 00:00:00" pre_inn_${year}.nc pre_inn_${year}.nc; done

# "falsches" _fillvalue löschen, [overwrite!]
# for ((year=1990;year<=2006;year++)); do echo "processing $year"; ncatted -O -a _fillvalue,pr,d,, pr_ruhr_${year}.nc; done

# Variable (pr -> pre) umbenennen:
# for ((year=1976;year<=2006;year++)); do echo "processing $year"; cdo chname,pr,pre pr_inn_${year}.nc pre_inn_${year}.nc; done

# Zusammenfügen (eventuell sind mehrere Teilschritte nötig wenn Ausgabedatei zu groß bzw Zwischenschritte, RAM und so):
# for ((year=1976;year<=1980;year++)); do echo "processing $year"; cdo mergetime pre_inn_\*.nc pr_hyras_1_${year}_v2.0.nc pr_inn_${year}.nc; done
# cdo mergetime pre_inn_\*.nc pre_inn_1976_2006.nc

# Jahresniederschlag
# for ((year=1976;year<=2006;year++)); do echo "processing $year"; cdo yearsum pre_inn_${year}.nc pre_inn_yearsum_${year}; done
# oder:
# cdo yearsum pre_inn_1976-2006.nc pre_inn_yearsum_1976_2006.nc

# Langjähriges Mittel der Jahresniederschläge:
# cdo timavg pre_inn_yearsum_1976-2006.nc pre_inn_avg_1976-2006.nc 

################################################################################
# "Arbeitsbereich":
################################################################################

# for ((year=1976;year<=2006;year++)); do echo "processing $year"; cdo yearsum pre_inn_${year}.nc pre_inn_yearsum_${year}.nc; done
# cdo mergetime /pre_inn2/pre_inn_yearsum_*.nc pre_inn_yearsum_1976_2006.nc
# cdo timavg pre_inn_yearsum_1976_2006.nc pre_inn_avg_1976-2006.nc 


#for ((year=1976;year<=2006;year++)); do echo "processing $year"; cdo setmissval,-999 pre_inn_${year}.nc pre_inn2_${year}.nc; done
