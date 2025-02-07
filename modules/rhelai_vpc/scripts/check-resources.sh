eval "$(jq -r '@sh "RG_NAME=\(.rg_name) COS_NAME=\(.cos_name)"')"

#echo "rg = ${RG_NAME}"
#echo "cos = ${COS_NAME}"

OUTPUT=$(ibmcloud resource group $RG_NAME -q)
rg_status=$?

if [[ $rg_status == 0 ]]; then
  create_rg="false"
else
  create_rg="true"
fi


jq -n --arg create_rg "$create_rg" '{"create_rg":$create_rg}'