#!/bin/bash

# 인자 확인
if [ $# -eq 0 ]; then
    echo "Usage: $0 <tag_name>/<project_name>"
    echo "Example: $0 RealVul_Dataset/jasper"
    echo "Note: Available tag names are listed at https://github.com/seokjeon/VP-Bench/tags"
    exit 1
fi

ARGUMENT=$1
DS_NAME=$(dirname "$ARGUMENT")
PROJECT_NAME=$(basename "$ARGUMENT")
INPUT_DIR="input/${DS_NAME}/${PROJECT_NAME}"
OUTPUT_DIR="output/${DS_NAME}/${PROJECT_NAME}"
mkdir -p "${INPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Step 1-2: 다운로드 및 압축 해제는 prepare.sh에서 수행되며,
# docker-compose.yml에서 볼륨 마운트로 연결됨

# Step 3. Extract vulnerable functions
if [ ! -d "${OUTPUT_DIR}/vulnerable_source_code" ]; then
    # 출력 디렉토리 생성
    mkdir -p "${OUTPUT_DIR}/vulnerable_source_code"
    tail -n +2 "${INPUT_DIR}/${PROJECT_NAME}_dataset.csv" | while IFS=',' read -r file_name vulnerable_lines rest; do
        # vulnerable_line_numbers가 비어있지 않으면
        if [ -n "$vulnerable_lines" ]; then
            source_file="${INPUT_DIR}/source_code/$file_name"
            file_name="$file_name.c"
            # file_name 추출 및 파일 복사
            if [ -f "$source_file" ]; then
                cp "$source_file" "${OUTPUT_DIR}/vulnerable_source_code/$file_name"
                echo "Copied: $file_name"
            else
                echo "Not found: $file_name"
            fi
        fi
    done
else
    echo "${OUTPUT_DIR}/vulnerable_source_code directory already exists, skipping extraction."
fi

# Step 4. Generate signature database
SignatureDB="${OUTPUT_DIR}/hidx/hashmark_4_${PROJECT_NAME}.hidx"
if [ ! -f "$SignatureDB" ]; then
    mkdir -p "${OUTPUT_DIR}/hidx"
    echo "Generating ${PROJECT_NAME} signatureDB..."
    cd hmark \
    && python3 ./hmark.py -c ../${OUTPUT_DIR}/vulnerable_source_code/ on -n \
    && cd - \
    && cp ./hmark/hidx/hashmark_4_vulnerable_source_code.hidx "${SignatureDB}" \
    && echo "Signature database generated in '${SignatureDB}' directory."
else
    echo "Signature database already exists, skipping generation."
fi