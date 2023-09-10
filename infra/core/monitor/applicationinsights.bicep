@minLength(10)
@maxLength(260)
param name string
param dashboardName string
param location string = resourceGroup().location
param tags object
param logAnalyticsWorkspaceId string
param includeDashboard bool = true

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' =  {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    Flow_Type: 'Bluefield'
    IngestionMode: 'LogAnalytics'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

module applicationInsightsDashboard 'applicationinsights-dashboard.bicep' =  if (includeDashboard) {
  name: 'application-insights-dashboard'
  params: {
    name: dashboardName
    location: location
    applicationInsightsName: applicationInsights.name
  }
}

output id string =  applicationInsights.id 
output name string =   applicationInsights.name  
output connectionString string =   applicationInsights.properties.ConnectionString 
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
