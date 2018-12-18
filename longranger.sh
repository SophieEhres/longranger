#!/bin/bash/

###########################
# This is a pipeline for longranger wgs with hg19 reference genome on Graham CC server
# Needs to be started from a directory containing fastqs demultiplexed with bcl2fastq
###########################


names=$( ls *.fastq.gz | grep -e "F0" | cut -d'_' -f1 | uniq)

mkdir fastq

for i in $names; do
        mkdir fastq/$i;
        echo "name is ${i}";
        files=$( ls *.fastq.gz | grep -e "$i");

        for j in $files; do
                echo "file is ${j}";
                mv $j fastq/$i;
                echo "moving ${j} to ${i}";

        done

done


mkdir bash_files

directories=$(ls fastq_files)
home=$(pwd)
genome=${MUGQIC_INSTALL_HOME}/genomes/species/Homo_sapiens.hg19/genome/10xGenomics/refdata-hg19-2.1.0/
bash=bash_files
fastq=${home}/fastq_files

for i in $directories; do
        echo $i;
        echo "#!/bin/bash
        cd $home
        echo 'start date'
        date
        module load mugqic/longranger
        longranger wgs --id $i --fastqs ${fastq}/${i} --vcmode freebayes --reference $genome --localcores 12 --localmem 80">${bash}/${i}_longranger.sh;

        sbatch -A $RAP_ID --mail-type=END,FAIL --mail-user=$JOB_MAIL -J ${i}_longranger --time=24:00:0 --mem=80G -N 1 -n 12 ${bash}/${i}_longranger.sh;

        sleep 1;
done


