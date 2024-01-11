#!/usr/bin/env bash

#USAGE: format_maf.sh [prefix] [input_maf]

## Remove comments

grep \
    '^[^#;]' \
    $2 \
    > \
    $1.grepped.txt

## Extract columns

awk \
    -F "\t" \
    'NR==1 { for(i=1;i<=NF;i++) \
        { \
            f[$i]=i \
        } \
        print "Hugo_Symbol\tEntrez_Gene_Id\tCenter\tTumor_Sample_Barcode\tFusion\tMethod\tFrame" \
    } \
    NR>1 \
    { \
        print $(f["Hugo_Symbol"])"\t"$(f["Entrez_Gene_Id"])"\t"$(f["Center"])"\t"$(f["Tumor_Sample_Barcode"])"\t"$(f["Fusion"])"\t"$(f["Method"])"\t"$(f["Frame"]) \
    }' \
    $1.grepped.txt \
    > \
    $1.extracted.txt

## Add two columns - RNA_support and no, DNA_support and yes

sed \
    '1s/$/\tDNA_support\tRNA_support/;2,$s/$/\tyes\tno/' \
    $1.extracted.txt \
    > \
    $1.columns_added.txt

## Portal format output
awk \
    -F "\t" \
    'NR==1  \
    { \
        for(i=1;i<=NF;i++) \
        { \
            f[$i]=i \
        } \
    } \
    { \
        print $(f["Hugo_Symbol"])"\t"$(f["Entrez_Gene_Id"])"\t"$(f["Center"])"\t"$(f["Tumor_Sample_Barcode"])"\t"$(f["Fusion"])"\t"$(f["DNA_support"])"\t"$(f["RNA_support"])"\t"$(f["Method"])"\t"$(f["Frame"]) \
    }' \
    $1.columns_added.txt \
    > \
    $1.portal.txt
