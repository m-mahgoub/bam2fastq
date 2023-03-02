process SAMTOFASTQ {
    conda "bioconda::gatk4=4.3.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gatk4:4.3.0.0--py36hdfd78af_0':
        'quay.io/biocontainers/gatk4:4.3.0.0--py36hdfd78af_0' }"
    
    publishDir "$params.outdir/fastq", mode:'copy', pattern: '*.fastq.gz'
    cpus 8
    memory '64 GB'

    input:
    tuple val(meta), path(bam), path(bam_index)
    path (fasta)

    output:
    tuple val(meta), path('*.fastq.gz'), emit: fastq

    script:
    def output = params.single_end ? "--FASTQ ${meta.id}.fastq.gz" : "--FASTQ ${meta.id}_1.fastq.gz --SECOND_END_FASTQ ${meta.id}_2.fastq.gz"
    def avail_mem = 3
    if (!task.memory) {
        log.info '[GATK SamToFastq] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    if( !params.is_cram )
        """
        gatk --java-options "-Xmx${avail_mem}g" SamToFastq \\
            --INPUT $bam \\
            $output \\
            --TMP_DIR . \\
            --INCLUDE_NON_PF_READS  \\
            --VALIDATION_STRINGENCY SILENT
        """
    else
        """
        gatk --java-options "-Xmx${avail_mem}g" SamToFastq \\
            --INPUT $bam \\
            $output \\
            --TMP_DIR . \\
            --INCLUDE_NON_PF_READS \\
            --VALIDATION_STRINGENCY SILENT \\
            --REFERENCE_SEQUENCE $fasta
        """
}