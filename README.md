# Домашнее задание 4 — клиническая аннотация вариантов (student_22, GRCh38)

## Файлы
- `student_22.vcf` — исходный VCF
- `results/annotated_variants.tsv` — итоговая таблица, 50 строк.
- `results/vep_output.json` — экспорт Ensembl VEP
- `results/clinvar_output.json` — ClinVar
- `results/gnomad_output.json` — gnomAD v4
- `report.md` — отчет и заключение

## Статистика VCF
Записей: 50; chr21: 10; chr22: 40; транзиций: 41; трансверсий: 9.

## Настройки аннотации
- **VEP**: Ensembl REST `POST /vep/human/region`, GRCh38, параметры `canonical=1 mane=1 hgvs=1 numbers=1 protein=1 symbol=1 af=1 af_gnomadg=1 variant_class=1 appris=1 tsl=1 SIFT=b PolyPhen=b check_existing=1 clinvar=1`. Возвращаются все транскрипты.
- **Выбор транскрипта**: protein-coding транскрипты → MANE Select; если нет — Ensembl canonical; если нет — самый тяжелый protein-coding. Для всех 50 вариантов сработало правило MANE Select. Столбец `vep_most_severe_any_transcript` — самое тяжелое последствие среди всех транскриптов (может отличаться от MANE).
- **ClinVar**: `esearch` по rsID, затем `esummary`; каждая запись проверена по `canonical_spdi` на совпадение позиции и ALT. Поле — germline classification.
- **gnomAD**: dataset `gnomad_r4`, запрос по `chrom-pos-ref-alt`; `combined_af` = (AC экзомов + AC геномов) / (AN экзомов + AN геномов).
