#!/usr/bin/env cwl-runner
# Generated from: ./plink --allow-extra-chr --recode vcf-iid --bfile GRCh37vcf2bplink --out GRCh37brestore --biallelic-only strict --keep-allele-order
class: CommandLineTool
cwlVersion: v1.0
baseCommand: plink
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/plink:1.90b6.21--h516909a_0
arguments:
  - --allow-extra-chr
  - --recode
  - --bfile
  - $(inputs.in_bed.dirname)/$(inputs.in_bed.nameroot)
  - --out
  - $(inputs.out_name)
  - --biallelic-only
  - --keep-allele-order
inputs:
  # - id: bfile
  #   type: string
  - id: in_bed
    type: File
    secondaryFiles:
      - ^.bim
      - ^.fam
  # - id: in_bim
  #   type: File
  # - id: in_fam
  #   type: File
  # - id: in_log
  #   type: File
  # - id: in_nosex
  #   type: File
  - id: out_name
    type: string
outputs:
  - id: all-for-debugging
    type:
      type: array
      items: [File, Directory]
    outputBinding:
      glob: "*"
#  - id: out
#    type: Any
#    outputBinding:
#      glob: "$(inputs.out_name)"
