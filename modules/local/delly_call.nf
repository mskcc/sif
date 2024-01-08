process DELLY_CALL {


    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/delly:1.2.6':
        'docker.io/mskcc/delly:1.2.6' }"

    input:
    tuple val(meta),    path(normal), path(normal_index)
    tuple val(meta2),   path(tumor),  path(tumor_index)
    tuple val(meta3),   path(fasta)
    tuple val(meta4),   path(fai)
    tuple val(meta4),   path(exclude)
    val(delly_type)

    output:
    tuple val(meta), path("*.bcf"), path("*.bcf.csi")     , emit: sv_output
    path "versions.yml"                                   , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /opt/delly/bin/delly \\
        call \\
        ${args} \\
        --genome ${fasta} \\
        --exclude ${exclude} \\
        --outfile ${prefix}.${delly_type}.bcf \\
        ${tumor} \\
        ${normal}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        delly: 1.2.6
        htslib: 1.15.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.${delly_type}.bcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        delly: 1.2.6
        htslib: 1.15.1
    END_VERSIONS
    """

}
