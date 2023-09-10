
#!/bin/sh

echo ""
echo "Loading allowed origins to function app"
echo ""

echo "$AZURE_RESOURCE_GROUP"
echo "$AZURE_FUNCTION_APP"
echo "$FRONTEND_URI"

az functionapp cors add -g "$AZURE_RESOURCE_GROUP" -n "$AZURE_FUNCTION_APP" --allowed-origins "$FRONTEND_URI"