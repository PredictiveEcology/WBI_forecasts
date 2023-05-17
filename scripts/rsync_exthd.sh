#!/bin/bash

EXTHDD_PATH=/media/achubaty/10TBdog

mkdir -p ${EXTHDD_PATH}/WBI/inputs/climate
rsync -avzP inputs/climate/future ${EXTHDD_PATH}/WBI/inputs/climate/
rsync -avzP inputs/climate/historic ${EXTHDD_PATH}/WBI/inputs/climate/

mkdir -p ${EXTHDD_PATH}/WBI/outputs
rsync -avzP outputs/*_run* ${EXTHDD_PATH}/WBI/outputs/

mkdir -p ${EXTHDD_PATH}/WBI/outputs/{AB,BC,MB,NT,SK,NT}/postprocess
rsync -avzP outputs/AB/postprocess ${EXTHDD_PATH}/WBI/outputs/AB/
rsync -avzP outputs/BC/postprocess ${EXTHDD_PATH}/WBI/outputs/BC/
rsync -avzP outputs/MB/postprocess ${EXTHDD_PATH}/WBI/outputs/MB/
rsync -avzP outputs/NT/postprocess ${EXTHDD_PATH}/WBI/outputs/NT/
rsync -avzP outputs/SK/postprocess ${EXTHDD_PATH}/WBI/outputs/SK/
rsync -avzP outputs/YT/postprocess ${EXTHDD_PATH}/WBI/outputs/YT/

