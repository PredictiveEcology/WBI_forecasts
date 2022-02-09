#!/bin/bash
rsync -avzP ~/GitHub/WBI_forecasts/outputs/NT* picea.for-cast.ca:/mnt/wbi_data/WBI_forecasts/outputs/
rsync -avzP ~/GitHub/WBI_forecasts/outputs/YT* picea.for-cast.ca:/mnt/wbi_data/WBI_forecasts/outputs/
