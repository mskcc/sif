process FORMAT_MAF {


    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/alpine:3.19-with-bash':
        'docker.io/mskcc/alpine:3.19-with-bash' }"

    input:
    tuple val(meta),  path(inputMaf)

    output:
    tuple val(meta), path("*.portal.txt")     , emit: portal
    path "versions.yml"                       , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    export SINGULARITY_BIND="$projectDir"
    ./$projectDir/bin/format_maf.sh \\
        ${prefix} \\
        ${inputMaf}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: BusyBox v1.36.1
        awk: BusyBox v1.36.1
        sed: BusyBox v1.36.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.portal.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: BusyBox v1.36.1
        awk: BusyBox v1.36.1
        sed: BusyBox v1.36.1
    END_VERSIONS
    """

}
