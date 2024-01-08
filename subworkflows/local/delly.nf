include { DELLY_CALL } from '../../modules/local/delly_call'
include { DELLY_FILTER } from '../../modules/local/delly_filter'

workflow DELLY {
    take:
    ch_normal           // normal bam
    ch_tumor            // tumor bam
    ch_fasta_ref        // fasta path
    ch_fasta_fai_ref    // fasta_fai path
    delly_exclude       // delly exclude file
    each delly_type     // delly type list

    main:

    DELLY_CALL (
        ch_normal,
        ch_tumor,
        ch_fasta_ref,
        ch_fasta_fai_ref,
        delly_exclude,
        delly_type
    )

    DELLY_FILTER (
        DELLY_CALL.out.sv_output,
        delly_type
    )

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(DELLY_CALL.out.versions)
    ch_versions = ch_versions.mix(DELLY_FILTER.out.versions)


    emit:
    sv          = DELLY_FILTER.out.sv_output
    sv_filtered = DELLY_FILTER.out.sv_pass_output
    versions    = ch_versions
}
