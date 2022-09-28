#!/usr/bin/env cwl-runner
# Generated from: ./plink --allow-extra-chr --recode vcf-iid --file GRCh37vcf2plink --out GRCh37restore --biallelic-only strict --keep-allele-order
class: CommandLineTool
cwlVersion: v1.0
baseCommand: plink
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/plink:1.90b6.21--h516909a_0
arguments:
  - --allow-extra-chr
  - --recode
  - --file
  - $(inputs.in_bed.dirname)/$(inputs.in_bed.nameroot)
  - --out
  - $(inputs.out_name)
  - --biallelic-only
  - --keep-allele-order
inputs:
  - id: in_bed
    type: File
    secondaryFiles:
      - ^.ped
      - ^.map
  - id: out_name
    type: string
outputs:
  - id: out_vcf
    type: File
    outputBinding:
      glob: "$(inputs.out_name).vcf"
