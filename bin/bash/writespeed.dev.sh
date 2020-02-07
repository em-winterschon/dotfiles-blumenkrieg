#!/bin/bash

#-- Block: monitor.writespeed()
#-- Purpose: show write speed for file or directory

## Testable with the following command to generate consistent writes
## > dd if=/dev/zero of=/tmp/zero bs=1 count=50000000 &
## > monitor.writespeed /tmp/zero

#------------------------------------------------------------------------------#
#function monitor.writespeed () {

    ## Prints errors
    function _self.error() {
	echo $1;
	return $2;
    }
    
    ## Prints our help file
    function _self.help() {
	cat<<EOF
> monitor.writespeed [realtime stats for file|dir]
Author  : Madeline Everett
Repo    : $SUPERBASH_REPO_URL
Version : $VERSION
Date    : $DATE

Usage: monitor.writespeed [options]

 -t, --target     file or directory to monitor [default: none]
 -h, --help       print the help text [default: none]
 -e, --exitzero   exit if target speed = 0 [yes/no][default: no]
 -i, --interval   polling time in seconds [default: 2]
 -u, --unit       units of measure [k=Kbyte, m=Mbyte] [default: k]
 -s, --sequence   write output sequentially to new line [yes/no] [default: yes]

--------------------------------------------------------------------------------

EOF
	return 1;
    }

    ## Start::Data Analysis Functions
    function _self.calc() {

	function _mean() {
	    len=$#
	    echo  $* | tr " " "\n" | sort -n | head -n $(((len+1)/2)) | tail -n 1
	}
	
	function _nMean() {
	    echo -n "$1 " 
	    shift 
	    _mean $* 
	}
	
	function _variance() {
	    count=$1
	    avg=$2
	    shift
	    shift
	    sum=0
	    for n in $* 
	    do 
		diff="($avg-$n)"
		quad="($diff*$diff)"
		sum="($sum+$quad)"
	    done 
	    echo "scale=2;$sum/$count" | bc 
	}
	
	function _sum() {
	    form="$(echo $*)"
	    formula=${form// /+}
	    echo $((formula))
	}
	
	function _nVariance() {
	    #echo -n "$1 " 
	    shift 
	    count=$#
	    s=$(_sum $*) 
	    avg=$(echo "scale=2;$s/$count" | bc)
	    var=$(_variance $count $avg $*)
	    echo $var
	}

	function _range() { 
	    min=$1
	    max=$1
	    for p in $* ; do 
		(( $p < $min )) && min=$p
		(( $p > $max )) && max=$p
	    done 
	    echo $min ":" $max 
	}
	
	function _nRange() {
	    echo -n "$1 " 
	    shift 
	    _range $* 
	}
	
	## Stats processing intiator
	if [ $# -eq 0 ] || [ $# -eq 1 ]; then
	    return
	else 	    
	    echo -n "line: "; echo $*;
	    echo -n "Variance: "; _nVariance $*;
	    echo -n "Mean: "; _nMean $*;
	    echo -n "Range: "; _nRange $*;
	    echo ''
	fi
    }
    
    ## Set defaults for GetOps
    help="no"
    target="null"
    sequence="yes"
    unit="k"
    interval="2"
    skip="no"
    exitzero="no"

    ## Temp files
    _log_min=`mktemp -t _writespeed.log_min.XXXXXXXX`
    _log_hour=`mktemp -t _writespeed.log_hour.XXXXXXXX`
    
    ## Check ARGV array
    ##  - If only one argv and is not for help, perhaps we're skipping options
    ##  - If skipping options we can bypass the other arg checks and execut
    clear 
    if [ $# -eq 0 ]; then
	_self.help;
	skip=null;
    else
	if [ $# -eq 1 ]; then
	    if [ $1 = "-h" ]; then _self.help; return; 
	    elif [ $1 = "--help" ]; then _self.help; return;
	    else
		_self.help;
		target=$1;
		skip="yes";
	    fi
	fi
    fi
    
    ## Check GetOps flags
    if [ $skip = "no" ]; then
	_self.help;
	while [ $# -gt 0 ]; do
	    case $1 in
		-h|--help) help="yes" ;;
		## long opts need additional shift
		-t|--target) target="$2" ; shift;;
		-i|--interval) interval="$2" ; shift;;
		-u|--unit) unit="$2" ; shift;;
		-s|--sequence) sequence="$2" ; shift;;
		-e|--exitzero) exitzero="$2" ; shift;;
		(--) shift; break;;
		(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
		(*) break;;
	    esac
	    shift
	done
    fi  

    if [ $skip != "null" ]; then
    ## Check help
	echo "Selected Settings\n"
	helpval=$(echo $help | awk '{print tolower($0)}')
	if [ "$helpval" = "yes" ]; then _self.help; return; fi
	
    ## Check interval is an integer
	echo -n " --interval: "
	if [ "$interval" -eq "$interval" ] 2>/dev/null; then echo $interval;
	else _self.error "Error: interval specified is not an integer." 3; fi
	
    ## Check unit
	echo -n " --unit: "
	unitval=$(echo $unit | awk '{print tolower($0)}')
	echo $unitval
	if [ "$unitval" = "k" ]; then unit="-k" && desc="KB";
	elif [ "$unitval" = "g" ]; then unit="-g" && desc="GB";
	elif [ "$unitval" = "m" ]; then unit="-m" && desc="MB";
	else unit="-k" && desc="KB"; fi
	
    ## Check sequence
	echo -n " --sequence: "
	seqval=$(echo $sequence | awk '{print tolower($0)}')
	echo $seqval
	if [ "$seqval" = "yes" ]; then inplace=0; else inplace=1; fi

    ## Check exitzero
	echo -n " --exitzero: "
	exitval=$(echo $exitzero | awk '{print tolower($0)}')
	echo $exitval
	if [ "$exitval" = "yes" ]; then xval=1; else xval=0; fi
	
    ## Check target
	echo -n " --target: "
	echo $target
	if [ "$target" = "null" ]; then _self.error "\nError: Target is missing or null."; fi

    ## Check tmp files
	echo "_log_min: $_log_min"
	echo "_log_hour: $_log_hour"
	
    ## Execute...
	echo "----------------------------------------------------------------"
	du -ks "$target" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    echo ""    
	    size=$(du -ks "$target" | awk '{print $1}')
	    runseq=1	
	    while [ 1 ]; do
		prevsize=$size
		size=$(du $unit -s "$target" | awk '{print $1}')
		csize=$((${size} - ${prevsize}))
		cmin=$((${csize}* (60/${interval}) ))
		chour=$((${cmin}* 60))
		msg="$target, net+/-: ${csize}$desc, ${cmin}$desc/min, ${chour}$desc/hr, now: ${size}$desc"

		## write cmin and chour values to tmpfile as long as they're positive values.
		if [[ $cmin =~ ^[0-9]+$ ]]; then printf "%s" "${cmin} " >> $_log_min; fi
		if [[ $chour =~ ^[0-9]+$ ]]; then printf "%s" "${chour} " >> $_log_hour; fi
		    
		## only display data if we're on the non-first loop.
		if [ $runseq -ne 1 ]; then
		    if [ $inplace -eq 1 ]; then echo -e "\e[1A $msg"; 
		    else
			#echo $msg;

			## process tmp file for stat calulations
			cp $_log_min $_log_min.br
			echo '' >> $_log_min.br
			cat $_log_min.br | while read line; do 
			    _self.calc $line
			done
		    fi
		    
		## if existvalue is set then exit if growth hits zero and this is not our first loop
		    if [ $xval -eq 1 ] && [ $runseq -ne 1 ] && [ $csize -eq 0 ]; then break; fi
		fi
		runseq=0
		sleep $interval
	    done
	fi
    fi
#}

