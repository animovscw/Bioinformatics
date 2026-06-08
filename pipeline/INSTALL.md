# Установка фреймворка Snakemake

## Требования
- Python 3.8+
- pip
- graphviz (для визуализации DAG)

## Установка
```bash
pip install "snakemake==7.32.4" "pulp==2.7.0"
sudo apt install graphviz
```

## Проверка
```bash
snakemake --version
# 7.32.4
```

## Запуск Hello World
```bash
snakemake -s pipeline/hello.smk --cores 1
```

## Запуск основного пайплайна
```bash
snakemake -s pipeline/qc_pipeline.smk --cores 4
```

## Визуализация DAG
```bash
snakemake -s pipeline/qc_pipeline.smk --dag --forceall | dot -Tpng > pipeline_dag.png
```
