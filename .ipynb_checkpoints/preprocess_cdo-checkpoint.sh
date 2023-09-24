#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --ntasks=3
#SBATCH --mail-type=ALL

#==============================================================================
# Preprocessing climate data with cdo

# This is a bash script to preprocess some netcdf files using cdo. 

# The first line in the script (#!/bin/bash) is called a "shebang" and is importnat.
# It tells the computer that this is a bash script. 

# The next lines (#SBATCH...) are for the supercomputer job submission. 
# They tell it how much time we are requesting for the job (here 1 hour), 
# how many cores we want to run on, and whether we want to receive emails when the 
# job starts, ends, fails etc. 
# See more options here: https://hpc.vub.be/docs/job-submission/slurm/

# Created: September 2023
# By: rosa.pietroiusti@vub.be
#==============================================================================

# tic
START=$(date +%s.%N)

# load modules
module purge && module load CDO/2.0.6-gompi-2022a


#==============================================================================
# settings
#==============================================================================

# set input directories and start and end year of simulations
inDIR=./sample-data/
echo **inDIR is $inDIR 

# set output directory
outDIR=./sample-output
echo **outDIR is $outDIR

# set start and end year to save your final file
startYEAR=2020
endYEAR=2022

# ==============================================================================
# processing : option 1 - crop all files, merge all timesteps, then delete intermediate files
# ==============================================================================

# loop through files to crop files (x1,x2,y1,y2)
echo **cropping files
for FILE in $inDIR/*.nc; do
	FILENAME=$(basename -s .nc ${FILE})
	cdo -O sellonlatbox,-9,0,36,45 $FILE $outDIR/${FILENAME}_cropped.nc
done



# merge files
echo **merging files
cdo -O mergetime $outDIR/*_cropped.nc $outDIR/fwi_merged_cropped_${startYEAR}_${endYEAR}.nc 

# then you can go in the folder and delete all the files that end in "*_cropped.nc" since you
# dont need them anymore.

# ==============================================================================
# processing : option 2 - pipe the commands so you dont make any intermediate files
# ==============================================================================


echo **cropping and merging at the same time
cdo -O -L -sellonlatbox,-9,0,36,45 -mergetime $inDIR/*.nc $outDIR/fwi_merged_cropped_piped_${startYEAR}_${endYEAR}.nc 

# ==============================================================================
# note. when you "glob" with the asterisk *.nc it will merge all the files in the directory
# if you have lots of files and you only want to select some of them according to a range between start and end year you can specify a range with brace expansion like *{2021..2022}.nc
# this will select only the files that end in 2021.nc or 2022.nc: 
# ==============================================================================

echo *merging files 
cdo -O mergetime $inDIR/*{2020..2022}.nc $outDIR/fwi_merged_2020_2022.nc 

#==============================================================================
# end
#==============================================================================

# toc
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo; echo "Elapsed time is" $DIFF "seconds."; echo
