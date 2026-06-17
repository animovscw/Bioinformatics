rule hello_world:
    output:
        "logs/hello_snakemake.txt"
    shell:
        "echo 'Hello from Snakemake!' > {output}"
