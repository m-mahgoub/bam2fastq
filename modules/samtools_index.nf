process SAMTOOLS_INDEX {
    tag "${meta.id}"
    conda "bioconda::samtools=1.16.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.16.1--h6899075_1' :
        'quay.io/biocontainers/samtools:1.16.1--h6899075_1' }"
    
    cpus 8
    memory '64 GB'
    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*ai") , optional:true, emit: index


    script:
    """
    samtools \\
        index \\
        -@ ${task.cpus-1} \\
        $input

    """
}