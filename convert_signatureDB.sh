#!/bin/bash

# Step 1. Download RealVul Dataset files
if [ ! -f "jasper_dataset.csv" ]; then
    echo "Downloading jasper_dataset.csv..."
    wget https://github.com/seokjeon/VP-Bench/releases/download/RealVul_Dataset/jasper_dataset.csv
else
    echo "jasper_dataset.csv already exists, skipping download."
fi

if [ ! -f "jasper_source_code.tar.gz" ]; then
    echo "Downloading jasper_source_code.tar.gz..."
    wget https://github.com/seokjeon/VP-Bench/releases/download/RealVul_Dataset/jasper_source_code.tar.gz
else
    echo "jasper_source_code.tar.gz already exists, skipping download."
fi

# Step 2. Extract the source code files
if [ ! -d "source_code" ]; then
    echo "Extracting jasper_source_code.tar.gz..."
    tar -xvf jasper_source_code.tar.gz
else
    echo "source_code directory already exists, skipping extraction."
fi

# Step 3. Extract vulnerable functions
OUTPUT_DIR="vulnerable_source_code"
if [ ! -d "$OUTPUT_DIR" ]; then
    # 출력 디렉토리 생성
    mkdir -p "$OUTPUT_DIR"
    tail -n +2 jasper_dataset.csv | while IFS=',' read -r file_name vulnerable_lines rest; do
        # vulnerable_line_numbers가 비어있지 않으면
        if [ -n "$vulnerable_lines" ]; then
            source_file="source_code/$file_name"
            file_name="$file_name.c"
            # file_name 추출 및 파일 복사
            if [ -f "$source_file" ]; then
                cp "$source_file" "$OUTPUT_DIR/$file_name"
                echo "Copied: $file_name"
            else
                echo "Not found: $file_name"
            fi
        fi
    done
else
    echo "$OUTPUT_DIR directory already exists, skipping extraction."
fi

# Step 4. Generate signature database
SignatureDB="./hmark/hidx/hashmark_4_vulnerable_source_code.hidx"
if [ ! -d "$SignatureDB" ]; then
    echo "Generating jasper signatureDB..."
    cd hmark \
    && python ./hmark.py -c ../vulnerable_source_code/ on -n \
    && cd - \
    && echo "Signature database generated in './hmark/hidx/hashmark_4_vulnerable_source_code.hidx' directory."
else
    echo "Signature database already exists, skipping generation."
fi
