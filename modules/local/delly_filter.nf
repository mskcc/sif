process DELLY_FILTER {


    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/delly:1.2.6':
        'docker.io/mskcc/delly:1.2.6' }"

    input:
    tuple val(meta), path(sv_output), path(sv_index)
    val(delly_type)

    output:
    tuple val(meta), path("*.bcf"), path("*.bcf.csi")     , emit: sv_pass_output
    path "versions.yml"                                   , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def pair_file_contents = "${meta.tumorSampleName}\ttumor\n${meta.normalSampleName}\tcontrol"
    def pair_file_name = "tn_pair.txt"

    """
    echo "${pair_file_contents}" > "${pair_file_name}"
    /opt/delly/bin/delly \\
        filter \\
        ${args} \\
        --svtype ${type} \\
        --outfile ${prefix}.pass.bcf \\
        ${sv_output}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        delly: 1.2.6
        htslib: 1.15.1
    END_VERSIONS
    """

}
