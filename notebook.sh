#!/bin/bash
# PDP homework Notebook Taker
# just for fun
# enjoy!
##########################################
# USAGE:
# "svn propedit svn:ignore ."
# add notebook.sh
# save and quit
# copy or soft link notebook.sh

# TODO same field can show space not 0 or duplicate 
# TODO replace total time ,not inserted
# TODO insert new record before total time

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

format="%-8s%-4s%-8s%-8s%-16s%-12s%-30s"
filename=notebook.txt
comment="nothing"

if ! [ -f "$filename" ]; then
    echo "$filename not exists, auto create one" &&
        touch $filename && echo "$filename created!" || 
        echo "$filename created fail"
    printf "$format\n" Date Who Start Stop Interruptions TimeOnTask Comments >> $filename &&
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
        diff=$((($h2*60+10#$m2)-($h1*60+10#$m1)))
    else
        diff=$((24*60-($h1*60+10#$m1)+($h2*60+10#$m2)))
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
            printf "$format\n" $start_date $name $start_time $end_time $intr $task_time "$comment" | tee -a $filename
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
    start_pattern="Q$1.*analysis"
    end_pattern="Q$1.*finish"
    start_row=$(awk -F ' ' -v s_pattern=$start_pattern '$0 ~ s_pattern{ print NR }' $filename)
    end_row=$(awk -F ' ' -v e_pattern=$end_pattern '$0 ~ e_pattern { print NR }' $filename)
    total_time=$(awk -F ' ' -v s=$start_row -v e=$end_row 'NR>=s && NR<=e{sum += $6} END {print sum}' $filename)
    echo $total_time
}

while true
do
    echo "what's next(1: add record 2: calculate total time 3: commit and quit 4: print 5: quit): "
    read -r opt
    case $opt in
        "1")
            record_new
            echo "================committing to svn: $(date "+%m/%d %H:%M") ===================" >> $filename
            svn commit -m "$comment" 
            ;;
        "2")
            have_total_time=$(sed -n '/Total Time/p' $filename)
            if [ -z "$have_total_time" ];then
                echo "\n\n\n\n\n" >> $filename
            else
                sed '/Total Time/d' $filename > 1.txt
                cat 1.txt > $filename
                rm -f 1.txt
            fi
            i=0
            while true
            do
                i=$(($i+1))
                total_time=$(calculate $i)
                if ! [ -z $total_time ];then
                    echo "Total Time On Task Q$i (miniutes)            $total_time" >> $filename
                    echo "Total Time On Task Q$i (hours)               $(($total_time/60))" >> $filename
                else
                    break
                fi
            done
            ;;
        "3")
            echo "================committing to svn: $(date "+%m/%d %H:%M") ===================" >> $filename
            svn commit
            ;;
        "4")
            cat notebook.txt
            ;;
        "5")
            break
            ;;
        *)
            echo "input 1-4"
            ;;
    esac
done



