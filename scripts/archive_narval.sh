#!/bin/bash

#------------------------------------------------------------------------------#
# NWT
#------------------------------------------------------------------------------#

cd /mnt/wbi_data/borealBirdsAndForestry
tar -vc --use-compress-program="pigz -p 16" -f - inputs | split -b 10G - inputs.tar.gz.
tar -vc --use-compress-program="pigz -p 16" -f - outputs | split -b 10G - outputs.tar.gz.

rsync -avP /mnt/wbi_data_orig/borealBirdsAndForestry/*.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/nwt_data/borealBirdsAndForestry/

cd /mnt/wbi_data/caribouRSF

tar -vc --use-compress-program="pigz -p 4" -f inputs.tar.gz inputs
tar -vc --use-compress-program="pigz -p 4" -f outputs.tar.gz outputs

rsync -avP /mnt/wbi_data_orig/caribouRSF/*.tar.gz narval:/home/achubaty/projects/rrg-stevec/achubaty/nwt_data/caribouRSF/

cd /mnt/wbi_data/NWT
tar -vc --use-compress-program="pigz -p 16" -f - inputs | split -b 10G - inputs.tar.gz.

rsync -avP /mnt/wbi_data_orig/NWT/*.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/nwt_data/NWT/

cd /mnt/wbi_data/NWT/outputs
tar -vc --use-compress-program="pigz -p 4" -f caribou.tar.gz caribou
tar -vc --use-compress-program="pigz -p 4" -f factorialExperiment.tar.gz factorialExperiment
tar -vc --use-compress-program="pigz -p 16" -f - landscapeRuns | split -b 10G - landscapeRuns.tar.gz.
tar -vc --use-compress-program="pigz -p 16" -f - PAPER_EffectsOfClimateChange | split -b 10G - PAPER_EffectsOfClimateChange.tar.gz.

rsync -avP /mnt/wbi_data_orig/NWT/outputs/*.tar.gz narval:/home/achubaty/projects/rrg-stevec/achubaty/nwt_data/NWT/outputs/
rsync -avP /mnt/wbi_data_orig/NWT/outputs/*.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/nwt_data/NWT/outputs/

#------------------------------------------------------------------------------#
# WBI
#------------------------------------------------------------------------------#

## BAM
cd /mnt/wbi_data/BAM
tar -vc --use-compress-program="pigz -p 16" -f stacks2001.tar.gz stacks2001
tar -vc --use-compress-program="pigz -p 16" -f stacks2011.tar.gz stacks2011

rsync -avP /mnt/wbi_data/BAM/*.tar.gz narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/BAM/

cd /mnt/wbi_data/BAM/bootstrap_rasters
tar -vc --use-compress-program="pigz -p 16" -f mean.tar.gz mean
tar -vc --use-compress-program="pigz -p 16" -f var.tar.gz var

rsync -avP /mnt/wbi_data/BAM/bootstrap_rasters/*.tar.gz narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/BAM/bootstrap_rasters/

## Harvesting [completed]
cd /mnt/wbi_data/
tar -vc --use-compress-program="pigz -p 4" -f Harvesting.tar.gz Harvesting

rsync -avP /mnt/wbi_data/Harvesting.tar.gz narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/

## posthocBirds
cd /mnt/wbi_data/posthocBirds
tar -vc --use-compress-program="pigz -p 4" -f - inputs | split -b 10G - inputs.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - outputs | split -b 10G - outputs.tar.gz.

rsync -avP /mnt/wbi_data/posthocBirds/outputs.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/posthocBirds/ ## TODO

## WBI_forecasts
cd /mnt/wbi_data_orig/WBI_forecasts
tar -vc --use-compress-program="pigz -p 16" -f - inputs | split -b 10G - inputs.tar.gz.

rsync -avP /mnt/wbi_data_orig/WBI_forecasts/inputs.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/

cd /mnt/wbi_data_orig/WBI_forecasts/outputs
tar -vc --use-compress-program="pigz -p 4" -f - AB | split -b 10G - AB.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - BC | split -b 10G - BC.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - MB | split -b 10G - MB.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - NT | split -b 10G - NT.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - SK | split -b 10G - SK.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - YT | split -b 10G - YT.tar.gz.
tar -vc --use-compress-program="pigz -p 4" -f - summary | split -b 10G - summary.tar.gz.

rsync -avP /mnt/wbi_data_orig/WBI_forecasts/outputs/*.tar.gz narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/

rsync -avP /mnt/wbi_data_orig/WBI_forecasts/outputs/*.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/

## WBI_MPB
cd /mnt/wbi_data/WBI_MPB
tar -vc --use-compress-program="pigz -p 4" -f - inputs | split -b 10G - inputs.tar.gz.

rsync -avP /mnt/wbi_data/WBI_MPB/inputs.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_MPB/

cd /mnt/wbi_data/WBI_MPB/outputs
tar -vc --use-compress-program="pigz -p 4" -f - MPB | split -b 10G - MPB.tar.gz.

rsync -avP /mnt/wbi_data/WBI_MPB/outputs/MPB.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_MPB/outputs/

## WBI_SBW
cd /mnt/wbi_data/WBI_SBW
tar -vc --use-compress-program="pigz -p 4" -f - inputs | split -b 10G - inputs.tar.gz.

rsync -avP /mnt/wbi_data/WBI_SBW/inputs.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_SBW/

cd /mnt/wbi_data/WBI_SBW/outputs
tar -vc --use-compress-program="pigz -p 4" -f - SBW | split -b 10G - SBW.tar.gz.

rsync -avP /mnt/wbi_data/WBI_SBW/outputs/SBW.tar.gz.* narval:/home/achubaty/projects/rrg-stevec/achubaty/wbi_data/WBI_SBW/outputs/

