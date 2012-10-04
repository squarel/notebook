#!/bin/bash
# PDP homework Notebook Taker
# just for fun
# enjoy!

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

format="%-8s%-4s%-8s%-8s%-16s%-12s%-30s"
format_comment="%"
if ! [ -f "notebook.txt" ]; then
    echo "notebook.txt not exists, auto create one" &&
        touch notebook.txt && echo "notebook.txt created!" || 
        echo "notebook.txt created fail"
    printf "$format" Date Who Start Stop Interruptions TimeOnTask Comments >> notebook.txt &&
        echo "header inserted!" ||
        echo "header inserted fail!"
fi

while [ -z $name ]
do
    echo "your name: "
    read -r name
done

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

function record_new()
{
    intr=0
    start_date="$(date +%m/%d)" 
    start_time="$(date +%H:%M)"
    task_time=0
    echo "new record begins at: $start_date $start_time"
    while true
    do
        echo "enter for pause, 1 for done with this record and leave comment:"
        read -r rec_opt
        if [ "$rec_opt" = "1" ];then
            end_time="$(date +%H:%M)"
            diff_time="$(calculate_diff $start_time $end_time)"
            task_time=$(($diff_time-$intr))
            echo "comment:"
            read -r comment
            printf "\n$format" $start_date $name $start_time $end_time $intr $task_time $comment | tee -a notebook.txt
            echo "record inserted!"
            break
        elif [ -z $rec_opt ];then
            pause_start_stamp=$(date +%s)
            echo "pause at: $(date +%H:%M)"
            while true
            do
                echo "enter for resume:"
                read -r key
                if [ -z $key ];then
                    pause_end_stamp=$(date +%s)
                    pause_time=$(($pause_end_stamp-$pause_start_stamp))
                    pause_minute=$(($pause_time/60))
                    if [ $(($pause_time%60)) != 0 ];then
                        pause_minute=$(($pause_minute+1))
                    fi
                    echo "paused for $pause_minute minute(s)"
                    intr=$(($intr+$pause_minute))
                    break
                fi
            done
        fi
    done
}

function calculate()
{


}

while true
do
    echo "what's next(1: add record; 2: calculate total time; 3: commit and quit; 4: quit;): "
    read -r opt
    case $opt in
        "1")
            record_new
            ;;
        "2")
            calculate
            ;;
        "3")
            echo "================committing to svn: $(date "+%m/%d %H:%M") ===================" >> notebook.txt
            svn commit
            ;;
        "4")
            break
            ;;
        *)
            echo "input 1-4"
            ;;
    esac
done



