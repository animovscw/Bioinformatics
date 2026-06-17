# ДЗ 3 — Пайплайн получения генетических вариантов

---

## Данные

| Тип | Аккессия | Платформа |
|-----|----------|-----------|
| Риды | [ERR3279523](https://www.ncbi.nlm.nih.gov/sra/ERR3279523) | Oxford Nanopore MinION R9.4 |
| Референс | [GCF_000005845.2](https://www.ncbi.nlm.nih.gov/assembly/GCF_000005845.2/) | *E. coli* K-12 MG1655 |

Скачать риды:
```bash
wget "https://ftp.sra.ebi.ac.uk/vol1/fastq/ERR327/003/ERR3279523/ERR3279523.fastq.gz" \
  -O data/ERR3279523.fastq.gz
```

Скачать референс:
```bash
wget -P ref/ https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip ref/GCF_000005845.2_ASM584v2_genomic.fna.gz && mv ref/*.fna ref/ecoli.fa
```

---

## Инструменты

| Инструмент | Версия | Назначение |
|------------|--------|------------|
| FastQC | 0.12.1 | Контроль качества ридов |
| minimap2 | 2.28 | Картирование ONT-ридов на референс |
| samtools | 1.13 | SAM/BAM конвертация, сортировка, статистика |
| freebayes | — | Коллинг вариантов |
| Reflow | — | Фреймворк пайплайнов (cloud-native) |

---

## Структура репозитория

```
├── data/               # FASTQ, SAM, BAM, VCF (не в git)
├── ref/                # Референсный геном и индексы (не в git)
├── qc/                 # Отчёты FastQC
├── logs/               # Логи всех шагов
├── scripts/
│   └── parse_flagstat.sh   # Разбор samtools flagstat + OK/not OK
└── reflow/
    ├── hello.rf            # Hello World пайплайн
    ├── qc_pipeline.rf      # Основной пайплайн
    └── INSTALL.md          # Установка Reflow
```

---

## Воспроизведение

```bash
# 1. Индексирование референса
minimap2 -d ref/ecoli.mmi ref/ecoli.fa

# 2. FastQC
fastqc data/ERR3279523.fastq.gz -o qc/ --threads 4

# 3. Картирование
minimap2 -ax map-ont -t 4 ref/ecoli.mmi data/ERR3279523.fastq.gz \
  > data/sample.sam 2> logs/minimap2.log

# 4. SAM -> sorted BAM
samtools view -bS data/sample.sam | samtools sort -o data/sample.sorted.bam
samtools index data/sample.sorted.bam

# 5. Статистика
samtools flagstat data/sample.sorted.bam > data/flagstat.txt

# 6. Оценка качества
bash scripts/parse_flagstat.sh data/flagstat.txt

# 7. Пайплайн на Reflow
reflow run -local reflow/qc_pipeline.rf
```

---

## Алгоритм оценки качества картирования

```
FastQC → minimap2 → samtools view → samtools flagstat
  → parse %mapped → [%mapped > 90%?]
      ├── Да → samtools sort → freebayes → VCF → "Finished"
      └── Нет → "not OK" + сохранить QC-отчёт
```