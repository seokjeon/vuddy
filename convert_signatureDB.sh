#!/bin/bash

# 인자 확인
if [ $# -eq 0 ]; then
    echo "Usage: $0 <dataset_name>"
    echo "Example: $0 VP-Bench_Train_Dataset"
    exit 1
fi

if [ $2=="off" ]; then
    ABS_LEVEL="0"
else # abs is on
    ABS_LEVEL="4"
fi

ARGUMENT=$1
export INPUT_DIR="input/$ARGUMENT"
export OUTPUT_DIR="output/$ARGUMENT"
mkdir -p "${INPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}/vulnerable_source_code/"

# Step 1-2: 다운로드 및 압축 해제는 prepare.sh에서 수행되며,
# docker-compose.yml에서 볼륨 마운트로 연결됨

# Step 3. Extract vulnerable functions
if [ "$ARGUMENT" == "VP-Bench_Train_Dataset" ]; then
    # 출력 디렉토리 생성
    mkdir -p "${OUTPUT_DIR}/vulnerable_source_code"
    mlr --csv filter '$vulnerable_line_numbers != ""' then cut -f unique_id "${INPUT_DIR}/Real_Vul_data.csv" \
    | tail -n +2 \
    | while IFS= read -r unique_id; do
    src="${INPUT_DIR}/all_source_code/${unique_id}.c"
    dst="${OUTPUT_DIR}/vulnerable_source_code/${unique_id}.c"
    if [ -f "$src" ]; then cp "$src" "$dst"; else echo "Not found: $unique_id"; fi
    done
fi
if [ "$ARGUMENT" == "VP-Bench_Test_Dataset" ]; then
    cp -r "${INPUT_DIR}/all_source_code" "${OUTPUT_DIR}/vulnerable_source_code"
fi

# Step 4. Generate signature database
SignatureDB="${OUTPUT_DIR}/hidx/hashmark_${ABS_LEVEL}_${ARGUMENT}.hidx"
if [ ! -f "$SignatureDB" ]; then
    mkdir -p "${OUTPUT_DIR}/hidx"
    echo "Generating ${ARGUMENT} signatureDB..."
    cd hmark \
    && python3 ./hmark.py -c ../${OUTPUT_DIR}/vulnerable_source_code/ $2 -n \
    && cd - \
    && cp ./hmark/hidx/hashmark_${ABS_LEVEL}_vulnerable_source_code.hidx "${SignatureDB}" \
    && echo "Signature database generated in '${SignatureDB}' directory."
else
    echo "Signature database already exists, skipping generation."
fi