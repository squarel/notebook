start=$(awk -F ' ' '$7 ~ /Q1/{ print NR }' notebook.txt)
end=$(awk -F ' ' '$7 ~ /Q2/{ print NR }' notebook.txt)
awk -F ' ' -v start=$start -v end=$end 'NR>=$start&&NR<=$end{sum += $6} END {print sum}' notebook.txt

