# whole genome HG0217 shuffled order 

export REF=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

MAXMEM=16g
SAMPLE=HG02107
BAMFILE=HG02107.shuf
THREADS=16

FASTQ=`ls *_1.filt.fastq.gz | sed s/_1.filt.fastq.gz//`

for i in `echo $FASTQ`;
do
       echo shuffle-fastq $i\_1.filt.fastq.gz $i\_2.filt.fastq.gz $i-
done | parallel -j 8

FASTQ=`ls *_1.fq.gz | sed s/_1.fq.gz//`

for i in `echo $FASTQ`;
do
        bwa mem -M -t $THREADS $REF $i\_1.fq.gz $i\_2.fq.gz  | samtools view -@ $THREADS -S -b -u - | samtools sort -@ $THREADS -m $MAXMEM -  tmp.$BAMFILE.$i;
done

samtools merge $BAMFILE.bam tmp.$BAMFILE.*.bam 

picard-tools AddOrReplaceReadGroups I= $BAMFILE.bam O= $BAMFILE.rg.bam RGPU= tata RGID= $SAMPLE RGLB= $SAMPLE RGPL= illumina RGSM= $SAMPLE;

picard-tools MarkDuplicates I= $BAMFILE.rg.bam O= $BAMFILE.rmdup.bam M= $BAMFILE.txt;

samtools index $BAMFILE.rmdup.bam