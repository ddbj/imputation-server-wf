#!/usr/bin/env cwl-runner

class: CommandLineTool
id: beagle-imputation
label: beagle-imputation
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/beagle-5.2:1.1.0
    
baseCommand: [ java ]

inputs:

  java_options:
    type: string?
    default: -Xmx64g
    inputBinding:
      position: 1
      shellQuote: false

  ref:
    type: File
    doc: Reference file
    inputBinding:
      prefix: ref=
      separate: false
      position: 4

  gt:
    type: File
    doc: Target VCF file
    inputBinding:
      prefix: gt=
      separate: false
      position: 5

  map:
    type: File
    doc: Genetic map file
    inputBinding:
      prefix: map=
      separate: false
      position: 6

  region:
    type: string
    inputBinding:
      prefix: chrom=
      separate: false
      position: 7

  gp:
    type: string
    default: true
    inputBinding:
      prefix: gp=
      separate: false
      position: 9

  nthreads:
    type: int
    default: 16
    inputBinding:
      prefix: nthreads=
      separate: false
      position: 10

  outprefix:
    type: string
    inputBinding:
      prefix: out=
      separate: false
      position: 11

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
    valueFrom: /usr/local/share/beagle-5.2_21Apr21.304-0/beagle.jar
  - position: 8
    prefix: impute=
    separate: false
    valueFrom: "true"
