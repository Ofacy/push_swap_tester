#!/bin/sh

RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m' # No Color
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

NUMBERS=${1}
ITERATIONS=${2}
GOAL=${3}
THREADS=${4}
ITERATIONS_PER_THREAD=$((ITERATIONS/THREADS))
I=0


while [ $I -lt $THREADS ]
do
	./complexity $NUMBERS $ITERATIONS_PER_THREAD $GOAL >> thread$I &
	I=$((I+1))
done
wait
PIRE=0
MEILLEUR=999999999999
MOYENNE=0
OBJECTIF=0
I=0
while [ $I -lt $THREADS ]
do
	cat thread$I | sed -e 's/\x1b\[[0-9;]*m//g' > thread$I.txt
	CURRENTAVERAGE=$(cat thread$I.txt | grep "Moyenne" | awk '{print $3}' | tail -1)
	eval MOYENNE=$(($MOYENNE+$CURRENTAVERAGE))
	CURRENTWORST=$(cat thread$I.txt | grep "Pire" | awk '{print $3}' | tail -1)
	CURRENTBEST=$(cat thread$I.txt | grep "Meilleur" | awk '{print $3}' | tail -1)
	CURRENTOBJECTIF=$(cat thread$I.txt | grep "Objectif" | awk '{print $7}' | tail -1 | cut -c2-)
	eval OBJECTIF=$(($OBJECTIF+$CURRENTOBJECTIF))
	if [ $CURRENTWORST -gt $PIRE ]
	then
		PIRE=$CURRENTWORST
	fi
	if [ $CURRENTBEST -lt $MEILLEUR ]
	then
		MEILLEUR=$CURRENTBEST
	fi
	rm thread$I.txt
	rm thread$I
	I=$((I+1))
done
echo "Pire = $RED$PIRE$RESET instructions"
echo "Moyenne = $YELLOW$(echo "$MOYENNE / $THREADS" | bc)$RESET instructions"
echo "Meilleur = $GREEN$MEILLEUR$RESET instructions"
echo "Objectif = $RED$(echo "$OBJECTIF / $THREADS" | bc)$RESET au dessus de $BLUE$GOAL$RESET"
