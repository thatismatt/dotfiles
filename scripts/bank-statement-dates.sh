#!/bin/bash

cd ~/personal/bank-statements/

for f in $(find . -name "Statement*") ; do
    old_date=$(sed "s/.*Statement_\(.*\).pdf/\1/" <<< $f)
    new_date=$(date -d $old_date +%F)
    echo $f statement-$new_date.pdf
    mv $f statement-$new_date.pdf
done
