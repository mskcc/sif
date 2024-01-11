process DELLY_FILTER {


    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/delly:1.2.6':
        'docker.io/mskcc/delly:1.2.6' }"

    input:
    tuple val(meta), val(delly_type), path(sv_output), path(sv_index)

    output:
    tuple val(meta), path("*.bcf"), path("*.bcf.csi")     , emit: sv_pass_output
    path "versions.yml"                                   , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def pair_file_name = "tn_pair.txt"

    """
    cat <<-END_PAIR > ${pair_file_name}
    ${meta.tumorSampleName} tumor
    ${meta.normalSampleName}    control
    END_PAIR

    /opt/delly/bin/delly \\
        filter \\
        ${args} \\
        --samples ${pair_file_name} \\
        --outfile ${prefix}.${delly_type}.pass.bcf \\
        ${sv_output}

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
    touch ${prefix}.${delly_type}.pass.bcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        delly: 1.2.6
        htslib: 1.15.1
    END_VERSIONS
    """

}
