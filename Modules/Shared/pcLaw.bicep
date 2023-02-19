param namingConvention string
param location string = resourceGroup().location
param tag object
param parPcLawSolutions array
param pcAutoId string
 
@description('created after import')
resource pclaw 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  properties: {
 //   source: 'Azure'
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1.0')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  name: 'laW${namingConvention}'
  location: location
  tags: tag
}
@batchSize(1)
@description('la')
resource resPcLawSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [ for solution in parPcLawSolutions: if (!empty(parPcLawSolutions)){ 
  name: '${solution}(${pclaw.name})'
  location: location
  properties: {
    workspaceResourceId: pclaw.id
  }
  plan:{
    name:'${solution}(${pclaw.name})'
    product:'OMSGallery/${solution}'
    publisher:'Microsoft'
    promotionCode:' '
  }
}]

resource resLawLinkedServiceForAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: '${pclaw.name}/Automation'
  properties: {
    resourceId:pcAutoId
  }
}
output pclawid string = pclaw.id
output pclawname string = pclaw.name
