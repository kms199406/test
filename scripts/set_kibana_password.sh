#!/bin/bash

# Elasticsearch 내부 도커 네트워크 주소 사용
ELASTICSEARCH_URL="https://elasticsearch:9200"

# 서비스 계정 생성 및 토큰 발급
curl -X POST "${ELASTICSEARCH_URL}/_security/service/elastic/kibana/credential/token/create" \
  -H "Content-Type: application/json" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert /usr/share/kibana/config/kibana.pem

# 또는 kibana_system 사용자 비밀번호 설정
curl -X POST "${ELASTICSEARCH_URL}/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  -d "{\"password\":\"${KIBANA_PASSWORD}\"}" \
  --cacert /usr/share/kibana/config/kibana.pem