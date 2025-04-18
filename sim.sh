#!/bin/bash

DB_NAME="abc"
TABLE_NAME="simcard"

generate_serial() {
    prefix=("0815" "0816" "0858")
    p=${prefix[$RANDOM % ${#prefix[@]}]}
    n1=$(shuf -i 100-999 -n 1)
    n2=$(shuf -i 100-999 -n 1)
    echo "$p $n1 $n2"
}

generate_price() {
    prices=(1650000 2200000 3300000 5000000 5500000)
    echo "${prices[$RANDOM % ${#prices[@]}]}"
}

while true; do
    query="INSERT INTO $TABLE_NAME (id_operator, id_category, serial, price, publish) VALUES"
    for i in {1..1000}; do
        serial=$(generate_serial)
        price=$(generate_price)
        query+="(2, 33, '$serial', $price, 'Yes'),"
    done
    query="${query%,};"  # hapus koma terakhir

    # Jalankan query tanpa -u dan -p karena pakai .my.cnf
    mysql "$DB_NAME" -e "$query"

    echo "1000 rows inserted at $(date)"
    sleep 1
done
