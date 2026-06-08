# Pipeline: E.coli ONT quality assessment
# Data: SRR7517493, minimap2 map-ont

SAMPLE   = "SRR7517493"
FASTQ    = f"data/{SAMPLE}.fastq.gz"
REF      = "ref/ecoli.fa"
REF_MMI  = "ref/ecoli.mmi"
THRESHOLD = 90

rule all:
    input:
        "data/flagstat.txt",
        "logs/qc_result.txt"

rule fastqc:
    input:
        FASTQ
    output:
        html = "qc/{SAMPLE}_fastqc.html".replace("{SAMPLE}", SAMPLE),
        zip  = "qc/{SAMPLE}_fastqc.zip".replace("{SAMPLE}", SAMPLE)
    threads: 4
    shell:
        "fastqc {input} -o qc/ --threads {threads}"

rule minimap2_index:
    input:
        REF
    output:
        REF_MMI
    shell:
        "minimap2 -d {output} {input}"

rule minimap2_map:
    input:
        ref = REF_MMI,
        reads = FASTQ
    output:
        sam = "data/sample.sam"
    threads: 4
    log:
        "logs/minimap2.log"
    shell:
        "minimap2 -ax map-ont -t {threads} {input.ref} {input.reads} "
        "> {output.sam} 2> {log}"

rule samtools_sort:
    input:
        "data/sample.sam"
    output:
        bam = "data/sample.sorted.bam",
        bai = "data/sample.sorted.bam.bai"
    threads: 4
    shell:
        "samtools view -bS {input} | samtools sort -o {output.bam} -@ {threads} && "
        "samtools index {output.bam}"

rule flagstat:
    input:
        "data/sample.sorted.bam"
    output:
        "data/flagstat.txt"
    shell:
        "samtools flagstat {input} > {output}"

rule check_mapping_quality:
    input:
        flagstat = "data/flagstat.txt",
        script   = "scripts/parse_flagstat.sh"
    output:
        "logs/qc_result.txt"
    shell:
        "bash {input.script} {input.flagstat} qc/ > {output} 2>&1 || true"
