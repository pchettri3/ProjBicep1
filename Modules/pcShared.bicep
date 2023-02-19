//param pcnamingConvention string
param location string
param environment string
param tags object
param restrictedNamingPlaceHolder string
// param resourceNamingPlacHolder string
var enableSS = environment == 'prod'
param aaDate string = utcNow('mm-dd-yy')
var sharedNamePrefixes = loadJsonContent('./Parameters/AzPrefixes.json')
@allowed([
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAssesment'
  'Updates'
  'VMInsights'
])
@description('Solutions would be added to the log analytics workspace. - DEFA?ULT VALUE  AgentHealthAssistant,AntiMalware,AzureActivity,ChangeTracking,Security, SecurityInsights,ServiceMap,SQLAssesment,Updates,VMInsights')
param parPcLawSolutions array = [   
'AzureActivity'
'ChangeTracking'
'Security'
'SecurityInsights'
//'ServiceMap'
//'SQLAssesment'
//'Updates'
//'VMInsights'
]
// param parPcLawSolutions array TEMP{test}

// 'AgentHealthAssistant'
// 'AntiMalware'
module pcAutomation 'shared/pcAutomation.bicep' =  if (enableSS) {
  name: 'deployauto${aaDate}'
  params: {
    namingConvention: replace(restrictedNamingPlaceHolder, '[PC]',sharedNamePrefixes.parameters.automationAccountPrefix)
    location: location
    tags: tags
  }
}

module pcLaw 'Shared/pcLaw.bicep'= if (enableSS) {
  name: 'deploy-law-${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.logAnalyticsWorkspacePrefix}'
  params: {
    namingConvention: '${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.logAnalyticsWorkspacePrefix}'
   parPcLawSolutions: parPcLawSolutions
    pcAutoId: pcAutomation.outputs.pcAutomationAccountId
    tag: tags
    location:location
   }
  }

module keyVault 'Shared/pcKeyVault.bicep' = if (enableSS) {
  name: 'deploy-kv${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.KeyVault}'
  params: {
    location: location
    namingConvention: replace(restrictedNamingPlaceHolder, '[PC]',sharedNamePrefixes.parameters.KeyVault) 
    tags: tags
    
    }
  }
module recovery 'Shared/pcRecoveryVault.bicep' = {
  name: 'deploy-rsv${aaDate}'
     params: {
    location: location
    tags: tags
    namingConvention: '${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.RecoveryServicesvault}'
    
  }
}

