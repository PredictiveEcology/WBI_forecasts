#!/bin/bash

DATA_PATH=/mnt/data/climate/ClimateNA_data

cd ${DATA_PATH}

## TODO: doesn't work with provs that have spaces (BC & NT-NU)
PROV=Ontario

## mv files
#mv ${PROV}/CanESM5_ssp245_* ${DATA_PATH}/future_2011-2100/CanESM5_ssp245/yearly/${PROV}/
#mv ${PROV}/CNRM-ESM2-1_ssp245_* ${DATA_PATH}/future_2011-2100/CNRM-ESM2-1_ssp245/yearly/${PROV}/
#mv ${PROV}/CanESM5_ssp370_* ${DATA_PATH}/future_2011-2100/CanESM5_ssp370/yearly/${PROV}/
#mv ${PROV}/CNRM-ESM2-1_ssp370_* ${DATA_PATH}/future_2011-2100/CNRM-ESM2-1_ssp370/yearly/${PROV}/
#mv ${PROV}/CanESM5_ssp585_* ${DATA_PATH}/future_2011-2100/CanESM5_ssp585/yearly/${PROV}
#mv ${PROV}/CNRM-ESM2-1_ssp585_* ${DATA_PATH}/future_2011-2100/CNRM-ESM2-1_ssp585/yearly/${PROV}/

## zip files
pushd ${DATA_PATH}/future_2011-2100/CanESM5_ssp245/yearly/
zip -r CanESM5_ssp245_${PROV}_annual.zip ${PROV}
popd

pushd ${DATA_PATH}/future_2011-2100/CNRM-ESM2-1_ssp245/yearly
zip -r CNRM-ESM2-1_ssp245_${PROV}_annual.zip ${PROV}
popd

pushd ${DATA_PATH}/future_2011-2100/CanESM5_ssp370/yearly
zip -r CanESM5_ssp370_${PROV}_annual.zip ${PROV}
popd

pushd ${DATA_PATH}/future_2011-2100/CNRM-ESM2-1_ssp370/yearly
zip -r CNRM-ESM2-1_ssp370_${PROV}_annual.zip ${PROV}
popd

pushd ${DATA_PATH}/future_2011-2100/CanESM5_ssp585/yearly/
zip -r CanESM5_ssp585_${PROV}_annual.zip ${PROV}
popd

pushd ${DATA_PATH}/future_2011-2100/CNRM-ESM2-1_ssp585/yearly
zip -r CNRM-ESM2-1_ssp585_${PROV}_annual.zip ${PROV}
popd

