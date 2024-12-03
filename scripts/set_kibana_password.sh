#!/bin/bash

# 설정할 비밀번호
NEW_PASSWORD="elastic"

# Elasticsearch URL
ELASTICSEARCH_URL="https://elasticsearch.www.projectkkk.com:9200"

# Elasticsearch 관리자 계정
ELASTIC_USERNAME="elastic"

# Elasticsearch 관리자 비밀번호
ELASTIC_PASSWORD="elastic"

# Kibana 시스템 계정 비밀번호 설정 요청
curl -X POST "${ELASTICSEARCH_URL}/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -u "${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}" \
  -d "{\"password\": \"${NEW_PASSWORD}\"}"

# 실행 결과 확인
if [ $? -eq 0 ]; then
  echo "Kibana 시스템 계정 비밀번호가 성공적으로 설정되었습니다."
else
  echo "Kibana 시스템 계정 비밀번호 설정에 실패했습니다."
fi
