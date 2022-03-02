#!/bin/bash
rsync -avzP ~/GitHub/WBI_forecasts/outputs/AB*.tar.gz pseudotsuga.for-cast.ca:~/GitHub/WBI_forecasts/outputs/
rsync -avzP ~/GitHub/WBI_forecasts/outputs/BC*.tar.gz pseudotsuga.for-cast.ca:~/GitHub/WBI_forecasts/outputs/
rsync -avzP ~/GitHub/WBI_forecasts/outputs/MB*.tar.gz pseudotsuga.for-cast.ca:~/GitHub/WBI_forecasts/outputs/
rsync -avzP ~/GitHub/WBI_forecasts/outputs/SK*.tar.gz pseudotsuga.for-cast.ca:~/GitHub/WBI_forecasts/outputs/
