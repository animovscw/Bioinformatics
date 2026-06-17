#!/usr/bin/env bash
set -euo pipefail

FLAGSTAT_FILE="${1:-data/flagstat.txt}"
QC_DIR="${2:-qc}"
THRESHOLD=90
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Извлечь % из строки вида: "246029 + 0 mapped (77.80% : N/A)"
# grep -v primary — исключить строку "primary mapped"
MAPPED_PCT=$(grep " mapped (" "$FLAGSTAT_FILE" \
  | grep -v "primary" \
  | grep -oP '\d+\.\d+(?=%)' \
  | head -1)

echo "----------------------------------------"
echo "Flagstat file : $FLAGSTAT_FILE"
echo "Mapped reads  : ${MAPPED_PCT}%"
echo "Threshold     : ${THRESHOLD}%"
echo "----------------------------------------"

# Сравнение через awk (поддерживает float)
RESULT=$(awk -v pct="$MAPPED_PCT" -v thr="$THRESHOLD" \
  'BEGIN { print (pct+0 >= thr+0) ? "OK" : "not OK" }')

echo "Quality check : $RESULT"
echo "----------------------------------------"

if [ "$RESULT" = "OK" ]; then
  cp "$QC_DIR"/*.html \
     "$QC_DIR/QC_report_OK_${TIMESTAMP}.html" 2>/dev/null || true
  echo "QC report saved: QC_report_OK_${TIMESTAMP}.html"
  exit 0
else
  cp "$QC_DIR"/*.html \
     "$QC_DIR/QC_report_NOT_OK_${TIMESTAMP}.html" 2>/dev/null || true
  echo "QC report saved: QC_report_NOT_OK_${TIMESTAMP}.html"
  exit 1
fi
