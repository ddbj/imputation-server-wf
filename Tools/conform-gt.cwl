#!/usr/bin/env cwl-runner

class: CommandLineTool
id: conform-gt
label: conform-gt
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/beagle-5.2:1.1.0
    
baseCommand: [ java ]

inputs:

  ref:
    type: File
    doc: Reference VCF file
    inputBinding:
      prefix: ref=
      separate: false
      position: 3

  gt:
    type: File
    doc: Target VCF file
    inputBinding:
      prefix: gt=
      separate: false
      position: 4

  region:
    type: string
    inputBinding:
      prefix: chrom=
      separate: false
      position: 6

  outprefix:
    type: string
    inputBinding:
      prefix: out=
      separate: false
      position: 7

outputs:
  - id: vcf
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).vcf.gz
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.outprefix).log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /tools/conform-gt.24May16.cee.jar
  - position: 5
    prefix: match=
    separate: false
    valueFrom: POS
