 #!/bin/sh

echo ""
echo "Loading azd .env file from current environment"
echo ""

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values)
EOF

if [ -z "$AZD_PREPDOCS_RAN" ] || [ "$AZD_PREPDOCS_RAN" = "false" ]; then
    # echo 'Creating python virtual environment "scripts/.venv"'
    python3 -m venv ./scripts/.venv

    source ./scripts/.venv/bin/activate

    # echo 'Installing dependencies from "requirements.txt" into virtual environment'
    ./scripts/.venv/bin/python3 -m pip install -r ./scripts/requirements.txt

    echo 'Running "prepdocs.py"'
    # ./scripts/.venv/bin/python3 ./scripts/prepdocs.py './data/*.pdf' --storageaccount "cmhgenaipoceus2sto" --storagekey "F0sTvvk1okRHyYb4qH6VZCOTViDyoMr3itZ6roSt78fUEv+2n+ajk+HGO0UsybHT5meqOYATD18o+AStLllg3g=="  --container "content" --searchservice "cmh-genai-poc-eus2-srch" --searchkey 1osRaQHQ1qyYZZduiG8thc2JSdNCWwSOnvCGA3QcL0AzSeAvXqTH --index "gptkbindex" --formrecognizerservice "cmh-genai-poc-eus2-cog-fr" --formrecognizerkey aea89e70f3e84ea8bd9054732eb75aac  --tenantid "9ca75128-a244-4596-877b-f24828e476e2" -v
    ./scripts/.venv/bin/python3 ./scripts/prepdocs.py './data/*.pdf' --storageaccount "$AZURE_STORAGE_ACCOUNT" --container "$AZURE_STORAGE_CONTAINER" --searchservice "$AZURE_SEARCH_SERVICE" --index "$AZURE_SEARCH_INDEX" --formrecognizerservice "$AZURE_FORM_RECOGNIZER_SERVICE" --tenantid "$AZURE_TENANT_ID" -v

    azd env set AZD_PREPDOCS_RAN "true"
else
    echo "AZD_PREPDOCS_RAN is set to true. Skipping the run."
fi





