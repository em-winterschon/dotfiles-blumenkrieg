#!/bin/bash
set -x
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
	    echo -n "$1 " 
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
	_nVariance $*
	_nMean $*
	_nRange $*
