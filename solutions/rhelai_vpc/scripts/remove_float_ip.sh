#!/bin/bash

set -e

FLOAT_ID="$1"
REGION="$2"

# === Step 1: Get IAM access token ===
echo "Getting IAM access token..."
IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$IBMCLOUD_API_KEY" | jq -r .access_token)

if [ -z "$IAM_TOKEN" ] || [ "$IAM_TOKEN" == 'null' ]; then
    echo "Failed to get access token."
    exit 1
fi

echo "Access token retrieved."

# === Step 2: Detach the floating IP ===
echo "Detaching floating IP from VSI..."

DETACH_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -X PATCH \
    "https://$REGION.iaas.cloud.ibm.com/v1/floating_ips/$FLOAT_ID?version=2022-03-01&generation=2" \
    -H "Authorization: Bearer $IAM_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"target": null}')

if [ "$DETACH_RESPONSE" == "200" ]; then
    echo "Floating IP successfully detached."
else
    echo "Failed to detach floating IP. HTTP status: $DETACH_RESPONSE"
    exit 2
fi

echo "Deleting floating IP..."
DELETE_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -X DELETE "https://$REGION.iaas.cloud.ibm.com/v1/floating_ips/$FLOAT_ID?version=2022-03-01&generation=2" \
    -H "Authorization: Bearer $IAM_TOKEN")

if [ "$DELETE_RESPONSE" == "204" ]; then
    echo "Floating IP deleted."
else
    echo "Failed to delete floating IP. HTTP status: $DELETE_RESPONSE"
    exit 3
fi
