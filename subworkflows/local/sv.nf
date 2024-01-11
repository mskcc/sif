include { DELLY_CALL } from '../../modules/local/delly_call'
include { DELLY_FILTER } from '../../modules/local/delly_filter'
include { BCFTOOLS_CONCAT as concat_sv; BCFTOOLS_CONCAT as concat_filtered_sv} from '../../modules/local/bcftools_concat'
include { VCF2MAF } from '../../modules/local/vcf2maf'
include { FORMAT_MAF } from '../../modules/local/format_maf'
include { GET_TOOL_VERSION } from '../../modules/local/get_tool_version'
include { ADD_MAF_COMMENT } from '../../modules/local/add_maf_comment'


workflow SV {
    take:
    ch_normal              // normal bam
    ch_tumor               // tumor bam
    ch_fasta_ref           // fasta path
    ch_fasta_fai_ref       // fasta_fai path
    ch_delly_exclude       // delly exclude file
    delly_type             // delly type list
    ch_exac_filter         // Exac filter vcf
    ch_exac_filter_index   // Exac filter index

    main:

    DELLY_CALL (
        ch_normal,
        ch_tumor,
        ch_fasta_ref,
        ch_fasta_fai_ref,
        ch_delly_exclude,
        delly_type
    )

    delly_call_output = DELLY_CALL.out.sv_output.transpose()

    DELLY_FILTER (
        delly_call_output
    )

    combined_sv = delly_call_output
        .map{
            new Tuple(it[0].id,it[0],it[2],it[3])
        }
        .groupTuple()
        .map{
            new Tuple(it[1][0],it[2], it[3])
    }

    combined_filtered_sv = DELLY_FILTER.out.sv_pass_output
        .map{
            new Tuple(it[0].id,it[0],it[1], it[2])
        }
        .groupTuple()
        .map{
            new Tuple(it[1][0],it[2], it[3])
    }

    concat_sv (
        combined_sv
    )

    concat_filtered_sv (
        combined_filtered_sv
    )

    VCF2MAF (
        concat_filtered_sv.out.vcf,
        ch_fasta_ref,
        ch_fasta_fai_ref,
        ch_exac_filter,
        ch_exac_filter_index
    )

    delly_tool = Channel.value("delly")

    GET_TOOL_VERSION (
        delly_tool,
        DELLY_CALL.out.versions
    )

    ADD_MAF_COMMENT (
        VCF2MAF.out.maf,
        delly_tool,
        GET_TOOL_VERSION.out.tool_version
    )

    FORMAT_MAF (
        VCF2MAF.out.maf
    )

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(DELLY_CALL.out.versions)
    ch_versions = ch_versions.mix(DELLY_FILTER.out.versions)
    ch_versions = ch_versions.mix(concat_sv.out.versions)
    ch_versions = ch_versions.mix(concat_filtered_sv.out.versions)
    ch_versions = ch_versions.mix(VCF2MAF.out.versions)
    ch_versions = ch_versions.mix(GET_TOOL_VERSION.out.versions)
    ch_versions = ch_versions.mix(ADD_MAF_COMMENT.out.versions)
    ch_versions = ch_versions.mix(FORMAT_MAF.out.versions)

    emit:
    sv = concat_sv.out.vcf
    sv_filtered = concat_filtered_sv.out.vcf
    maf_file = ADD_MAF_COMMENT.out.maf
    portal = FORMAT_MAF.out.portal
    versions = ch_versions
}
