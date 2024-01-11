process GET_TOOL_VERSION {


    tag "get_version_$tool"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/alpine:3.19-with-bash':
        'docker.io/mskcc/alpine:3.19-with-bash' }"

    input:
    val(tool)
    path(version_yaml), stageAs: "tool_version.yml"

    output:
    stdout emit: tool_version
    path "versions.yml"   , emit: versions

    script:
    task.ext.when == null || task.ext.when
    def prefix = task.ext.prefix

    """
    grep '${tool}:' tool_version.yml | tail -n1 | awk '{ print \$2}'


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: BusyBox v1.36.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix
    """
    echo "1.0"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: BusyBox v1.36.1
    END_VERSIONS
    """
}
