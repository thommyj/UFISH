#!/bin/bash

EXPECTED_ARGS=4
BSIZE=1024
EXPSCRIPT="expect -d `pwd`/readblock.exp"

if [ $# -ne $EXPECTED_ARGS ]
then
	echo "usage: `basename $0` file tty address size"
	exit 0
fi

if [ -f $1 ]
then
	echo "$1 already exists, exiting"
	exit 0
fi

if [ ! -c $2 ]
then
	echo "couldn't find device $2"
	exit 0
fi

#TODO check ADDR and size
TMPDIR=`mktemp -d`
OUTFILE="`pwd`/$1"
TTY=$2
#address and size are probably hex
STARTADDR=`echo $(($3))`
SIZE=`echo $(($4))`
ENDADDR=`expr $STARTADDR + $SIZE`
TMPFILE="$TMPDIR/tmp_$BSIZE"

echo "using $TMPDIR"
pushd $TMPDIR

for (( ADDR=$STARTADDR; ADDR<=$ENDADDR; ADDR=$ADDR+$BSIZE ))
do
	echo "Processing address `printf "0x%08X" $ADDR` "
	##todo check if less than BSIZE left
	##todo while not ok
	  $EXPSCRIPT $2 $TMPFILE `printf "0x%08X" $ADDR` $BSIZE 
	  if [ $? -gt 0 ]
	  then
            echo "error when sending file"
	    exit 1
	  fi
	##todo convert tmpfile and add to outfile
	cat $TMPFILE >> $OUTFILE
done 

popd
rm -rf $TMPDIR


