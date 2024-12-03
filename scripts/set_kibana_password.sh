#!/bin/bash

# 설정
ELASTICSEARCH_URL="https://elasticsearch.www.projectkkk.com:9200"

# 서비스 계정 토큰 생성
response=$(curl -X POST "${ELASTICSEARCH_URL}/_security/service/kibana/credential/token/create" \
  -H "Content-Type: application/json" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert /usr/share/kibana/config/kibana.pem \
  --silent)

# 응답에서 토큰 추출
token=$(echo $response | jq -r '.token.value')

if [ ! -z "$token" ]; then
  # 환경 변수로 토큰 설정
  export ELASTICSEARCH_SERVICE_TOKEN=$token
  echo "Service token이 성공적으로 생성되었습니다."

  # kibana.yml 설정에도 반영
  sed -i "s/elasticsearch.username:.*$/elasticsearch.serviceaccounttoken: $token/" /usr/share/kibana/config/kibana.yml
  exit 0
else
  echo "Service token 생성 실패"
  exit 1
fi