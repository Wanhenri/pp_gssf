#!/bin/ksh
#
#set -x

# get operatinal GFS forecast and analysis data 
#
# in /stornext/online19/mcga_fisica/w.santos/GFS/

dates=${1:-2016122500}                   ;#forecast cycle ; colocar data inicial dependendo de qntos dias de prev quero
datee=${2:-2017013112}

#dir=/stornext/online7/pnt/oper/tempo/externos/Download/FORECAST/GFS_025gr     # /201602/2912

dir=/stornext/online19/mcga_fisica/w.santos/GFS/GFS_05
comout=${WORK_HOME}/gfs

if [ ! -s $comout ]; then mkdir -p $comout ;fi
cd $comout  ||exit 8

while [ $dates -le $datee ] ; do

date24h=`~/bin/advance_cymdh $dates +24`
date36h=`~/bin/advance_cymdh $dates +36`
date48h=`~/bin/advance_cymdh $dates +48`
date60h=`~/bin/advance_cymdh $dates +60`
date72h=`~/bin/advance_cymdh $dates +72`
date84h=`~/bin/advance_cymdh $dates +84`
date96h=`~/bin/advance_cymdh $dates +96`
date108h=`~/bin/advance_cymdh $dates +108`
date120h=`~/bin/advance_cymdh $dates +120`
date132h=`~/bin/advance_cymdh $dates +132`
date144h=`~/bin/advance_cymdh $dates +144`
date156h=`~/bin/advance_cymdh $dates +156`
date168h=`~/bin/advance_cymdh $dates +168`

cdate=$dates

IDAY=`echo $cdate |cut -c 1-8`
yyyy=`echo $cdate |cut -c 1-4 `
mm=`echo $cdate |cut -c 5-6 `
dd=`echo $cdate |cut -c 7-8 `
fcyc=`echo $cdate |cut -c 9-10 `

errexp=0
ffcst=00

vlength=${3:-156}    #anterior=3:-156             
#ultimo periodo de analise pra 00z;  ;#verification end hour of forecast ;ultimo periodo de análise
if [ ${fcyc} -eq 12 ]; then vlength=168 ; fi    
#ultimo periodo de analise de 12z

fhout=${4:-3}                            ;#output frequency

while [ $ffcst -le $vlength ] ; do
  fdate=`~/bin/advance_cymdh $cdate +$ffcst `

  filein=$dir/$yyyy$mm/$dd$fcyc/gfs.t${fcyc}z.pgrb2f${ffcst}.${cdate}.grib2
  fileout=tmp.grib2
  if [ -e ${fileout} -a $ffcst -eq 00 ]; then rm $fileout ; fi
  if [ -s $filein ]; then
    ~/bin/wgrib2 $filein -append -match "(:TMP:2 m above ground:)" -grib	$fileout #(:TMP:2 m above ground:)
  fi
  if [ ! -s $fileout ]; then errexp=1 ; fi
  ffcst=$((ffcst+fhout))
  if [ $ffcst -lt 10 ]; then ffcst=0$ffcst ; fi
done

  fileout=rain.gfs.${IDAY}${fcyc}
  fileout1=GFS_merge_${cdate}.nc
#  ~/bin/wgrib2 tmp.grib2 -ncep_norm ${fileout}     ;# corrige os acumulados 
  ~/bin/wgrib2 tmp.grib2 -netcdf ${fileout1}      ;# converte em netcdf

    if [ ${cdate:8:2} == "12" ]; then
     echo "12 cycle"
#     cdo timselsum,8,0 ${fileout1} forecast_${cdate}.nc ;# acumula cada 24h
#     cdo splitsel,1 forecast_${cdate}.nc fcst           ;# separa em 24, 48, 72 h 
     mv fcst000000.nc fcst.$date24h.24.nc
     mv fcst000001.nc fcst.$date48h.48.nc
     mv fcst000002.nc fcst.$date72h.72.nc
     mv fcst000003.nc fcst.$date96h.96.nc
     mv fcst000004.nc fcst.$date120h.120.nc
     mv fcst000005.nc fcst.$date144h.144.nc
     mv fcst000006.nc fcst.$date168h.168.nc
    else
     echo "00 cycle"
#     cdo timselsum,8,4 ${fileout1} forecast_${cdate}.nc ;# acumula cada 24, apos as primeiras 12h
#     cdo splitsel,1 forecast_${cdate}.nc fcst           ;# separa em previsoes 36, 60, 84h 
     mv fcst000000.nc fcst.$date36h.36.nc
     mv fcst000001.nc fcst.$date60h.60.nc
     mv fcst000002.nc fcst.$date84h.84.nc
     mv fcst000003.nc fcst.$date108h.108.nc
     mv fcst000004.nc fcst.$date132h.132.nc
     mv fcst000005.nc fcst.$date156h.156.nc
    fi

  rm -f tmp.grib2 ${fileout1} forecast_${cdate}.nc

dates=`~/bin/advance_cymdh $dates +12`

done

exit 0 

# exemplo para jan 2015 para ciclo 12Z
#
# concatena as previsoes num arquivo se quiser só as 12 ; se quiser os dados de 00 substituir 12 por 00

cdo cat fcst.201501??12.24.nc prev.2015.jan.24h.nc
cdo cat fcst.201501??12.48.nc prev.2015.jan.48h.nc
cdo cat fcst.201501??12.72.nc prev.2015.jan.72h.nc

rm -f fcst.2015*.nc

exit 0
