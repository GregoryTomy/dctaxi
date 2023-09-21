#!/bin/bash

# install gdown if not already installed
pip install gdown


FILE_IDS=(
  '1yF2hYrVjAZ3VPFo1dDkN80wUV2eEq65O'
  '1Z7ZVi79wKEbnc0FH3o0XKHGUS8MQOU6R'
  '1I_uraLKNbGPe3IeE7FUa9gPfwBHjthu4'
  '1MoY3THytktrxam6_hFSC8kW1DeHZ8_g1'
  '1balxhT6Qh_WDp4wq4OsG40iwqFa86QgW'
)

for ID in "${FILE_IDS[@]}"
do
  gdown --id "$ID"
done

mkdir -p data_dctaxi

YEARS=(
  '2015'
  '2016'
  '2017'
  '2018'
  '2019'
)

for YEAR in "${YEARS[@]}"
do
  unzip -o "taxi_$YEAR.zip" -d data_dctaxi
done
