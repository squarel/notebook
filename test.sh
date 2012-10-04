
function calculate_diff()
{
    start=$1
    end=$2
    h1=$(echo $start | cut -f 1 -d ':')
    h2=$(echo $end | cut -f 1 -d ':')
    m1=$(echo $start | cut -f 2 -d ':')
    m2=$(echo $end | cut -f 2 -d ':')
    if [ $h1 -le $h2 ];then
        diff=$((($h2*60+$m2)-($h1*60+$m1)))
    else
        diff=$((24*60-($h1*60+$m1)+($h2*60+$m2)))
    fi
    echo $diff
}

calculate_diff 21:02 00:15
