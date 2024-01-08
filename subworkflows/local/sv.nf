include { DELLY } from '../../subworkflows/local/delly'
include { BCFTOOLS_CONCAT as concat_sv; BCFTOOLS_CONCAT as concat_filtered_sv} from '../../modules/local/bcftools_concat'
include { VCF2MAF } from '../../modules/local/vcf2maf'
include { FORMAT_MAF } from '../../modules/local/format_maf'


workflow SV {
    take:
    ch_normal           // normal bam
    ch_tumor            // tumor bam
    ch_fasta_ref        // fasta path
    ch_fasta_fai_ref    // fasta_fai path
    delly_exclude       // delly exclude file
    delly_type          // delly type list

    main:

    DELLY (
        ch_normal,
        ch_tumor,
        ch_fasta_ref,
        ch_fasta_fai_ref,
        delly_exclude,
        delly_type
    )

    concat_sv (
        DELLY.out.sv
    )

    concat_filtered_sv (
        DELLY.out.sv_filtered
    )

    VCF2MAF (
        concat_filtered_sv.out.vcf
    )

    FORMAT_MAF (
        VCF2MAF.out.maf
    )

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(DELLY.out.versions)
    ch_versions = ch_versions.mix(concat_sv.out.versions)
    ch_versions = ch_versions.mix(concat_filtered_sv.out.versions)
    ch_versions = ch_versions.mix(VCF2MAF.out.versions)
    ch_versions = ch_versions.mix(FORMAT_MAF.out.versions)

    emit:
    sv = concat_sv.out.vcf
    sv_filtered = concat_filtered_sv.out.vcf
    maf_file = VCF2MAF.out.maf
    portal = FORMAT_MAF.out.portal
    versions = ch_versions
}
