#!/bin/bash

EXPECTED_ARGS=3
BSIZE=1024
CMDFILE="cmdfile"
PREFIX="part_"
EXPSCRIPT="expect -d `pwd`/sendblock.exp"

if [ $# -ne $EXPECTED_ARGS ]
then
	echo "usage: `basename $0` file tty address"
	exit 0
fi

if [ ! -f $1 ]
then
	echo "couldn't find file $1"
	exit 0
fi

if [ ! -c $2 ]
then
	echo "couldn't find device $2"
	exit 0
fi


TMPDIR=`mktemp -d`
CMDFILE="$TMPDIR/cmdfile"
INFILE=$1
ADDR=$3


echo "using $TMPDIR"
cp $INFILE $TMPDIR
pushd $TMPDIR
split -b $BSIZE $INFILE $PREFIX

SPLITFILES=`find . -type f -name "$PREFIX*" | sort`

for f in $SPLITFILES
do
	echo "Processing $f"
	##todo: only send non 0xFF
	hexdump -v -e '/4 "0x%_ax  "' -e '/4 "0x%08X" "\n"' binary | sed -e 's/^/mw.l /g' > $CMDFILE
	##todo calculate crc32
	##todo while not ok
	  $EXPSCRIPT $2 $CMDFILE $ADDR
	  if [ $? -gt 0 ]
	  then
            echo "error when sending file"
	    exit 1
	  fi


	#convert to decimal and increase by BSIZE
	ADDR=`expr $(($ADDR)) + $BSIZE`
	ADDR=`printf "0x%08X" $ADDR`
done 

popd
rm -rf $TMPDIR


