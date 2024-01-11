process ADD_MAF_COMMENT {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/alpine:3.19-with-bash':
        'docker.io/mskcc/alpine:3.19-with-bash' }"

    publishDir "${params.outdir}/${meta.id}/", pattern: "${meta.id}.*", mode: params.publish_dir_mode

    containerOptions "--bind $projectDir"

    input:
    tuple val(meta), path(input_maf)
    val(tool_name)
    val(tool_version)

    output:
    tuple val(meta), path("*.svs.maf")         , emit: maf
    path "versions.yml"                         , emit: versions

    script:
    task.ext.when == null || task.ext.when
    def prefix = task.ext.prefix ?: "${meta.id}"
    def tool_name_trim = "${tool_name}".trim()
    def tool_version_trim = "${tool_version}".trim()

    """
    $projectDir/bin/concat_with_comments.sh \\
        ${tool_name_trim} \\
        ${tool_version_trim} \\
        ${prefix}.svs.maf \\
        ${input_maf}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: BusyBox v1.36.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    touch ${prefix}.svs.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: BusyBox v1.36.1
    END_VERSIONS
    """
}
