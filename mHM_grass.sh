#!/bin/bash
#GRASS 7 PREPROCESSOR - start from grass command line
#(cc) jackisch@kit.edu

echo "Please enter PROJECT name (to retrieve the internal files later): "
read PRO
outDIR=./$PRO
echo "Please enter DEM name: "
read DEM

g.region rast=$DEM
g.region -l

echo "Please specify the region extend according to the desired resolution: "
echo "(You need to round the corners appropriately) "
echo "Resolution for processing: "
read reso
echo "Northern Edge"
read north
echo "Southern Edge"
read south
echo "Western Edge"
read west
echo "Eastern Edge"
read east

g.region n=$north s=$south w=$west e=$east res=$reso

r.fill.dir input=$DEM output=$PRO.fill outdir=$PRO.dir areas=$PRO.problem --overwrite
r.surf.idw input=$PRO.fill npoints=5 output=$PRO.resamp --overwrite
r.fill.dir input=$PRO.resamp output=$PRO.refill outdir=$PRO.redir areas=$PRO.reproblem --overwrite
r.surf.idw input=$PRO.refill npoints=3 output=$PRO.raw.resamp --overwrite

r.watershed -s elev=$PRO.raw.resamp drain=$PRO.fdir basin=$PRO.bas stream=$PRO.str thresh=50000 --overwrite

#identify basin 4373327.77	5449863.67
echo "Specifiy Basin Outlet: "
echo "Easting"
read outE
echo "Northing"
read outN
echo "Gauge ID"
read gID

r.water.outlet input=$PRO.fdir output=$PRO coordinates=$outE,$outN --overwrite 

#set gauge
echo $outE,$outN,gID > gauge_pos_sim.txt
r.in.xyz input=gauge_pos_sim.txt output=$PRO.gauge separator=',' --overwrite

#update basin
r.mapcalc 'dummyr = if($PRO.fdir>0,1,$PRO.gauge/$gID)' --overwrite

g.region rast=dummyr
g.region n=$north s=$south w=$west e=$east res=$reso

#re-run analysis
#run terraflow / r.watershed 
r.mapcalc "$PRO.shrunken = $PRO.raw.resamp * dummyr" --overwrite
r.watershed -a -b elev=$PRO.shrunken accumulation=$PRO.faccum tci=$PRO.tci drainage=$PRO.fdir stream=$PRO.str threshold=5000 memory=1000 --overwrite
r.terraflow elevation=$PRO.shrunken filled=$PRO.tf_fill direction=$PRO.tf_fdir swatershed=$PRO.sinkwater accumulation=$PRO.tf_faccum tci=$PRO.tf_tci memory=1000 --overwrite
r.slope.aspect elevation=$PRO.shrunken slope=$PRO.slope aspect=$PRO.aspect --overwrite

r.out.arc input=$PRO.shrunken output=$outDIR/dem.asc dp=0 --overwrite
r.out.arc input=$PRO.aspect output=$outDIR/aspect.asc dp=0 --overwrite
r.out.arc input=$PRO.slope output=$outDIR/slope.asc dp=0 --overwrite
r.out.arc input=$PRO.faccum output=$outDIR/facc.asc dp=0 --overwrite

#update fdir
echo "1 -1 = 128
2 -2 = 64
3 -3 = 32
4 -4 = 16
5 -5 = 8
6 -6 = 4
7 -7 = 2
8 -8 = 1
0 = 255" > f_dir_reclass

r.reclass input=$PRO.fdir output=$PRO.fdir_arc rules=f_dir_reclass
r.out.arc input=$PRO.fdir_arc output=$outDIR/fdir.asc dp=0 --overwrite
r.out.arc input=$PRO.gauge output=$outDIR/gauge.asc dp=0 --overwrite

#Landuse
#$PRO_corine25 > manual reclass
#Soil
#single soil
r.out.arc input=$PRO_corine25_new output=$outDIR/LUclass.asc dp=0 --overwrite
r.out.arc input=dummyr output=$outDIR/soil.asc dp=0 --overwrite
