#Arguments (see below for the detailed descriptions): BAMDIR(required) OUTDIR(required) NUMOFTHREADS(required) QUALTHRESHOLD(optional)

BAMDIR=$1 #path to the directory where bam files exist. This caller will process all the bam files in this directory. Your bam files should end with ".bam" extension.
OUTDIR=$2 #created VCFs will be created in this directory
NUMOFTHREADS=$3 #number of threads allowed for this run
QUALTHRESHOLD=$4 #quality threshold
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

freebayesWithThreshold () {
	local i=$1
	fname=`basename $i`
	freebayes -b $BAMDIR/$fname -f $REFFILE | awk -F'\t' '{if($6 >= qual || substr($1,1,1) == "#") print $0;}' qual="$QUALTHRESHOLD" > $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
}

freebayesWoThreshold () {
	local i=$1
	fname=`basename $i`
	freebayes -b $BAMDIR/$fname -f $REFFILE > $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
}

countThreads=0
#qual filter
if [ "$#" -gt 3 ]; then
	for i in `ls $BAMDIR/*.bam`; do freebayesWithThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;
else
	for i in `ls $BAMDIR/*.bam`; do freebayesWoThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;
fi
wait