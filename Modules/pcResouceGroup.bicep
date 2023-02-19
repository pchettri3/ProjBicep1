targetScope = 'subscription'
param tags object
param addressPrefixes array
param subnets array
// param environment string
param dnsServers array 
// param snetlength int
// param index int
param resourceNamingPlacHolder string
//param locationlist string
// param index int
param snetNamePrefix string
param location string
param demoRgName string
// param coreRgName string = ''
// param coreVnetname string = ''
param saNamingPrefix string
// param vnetNamingPrefix string
// param sharedNamePrefixes string
param saAccountCounts int
// var deployResource = environment !='core'
var resourceNamePrefix = loadJsonContent('./Parameters/AzPrefixes.json')
// var core = contains(namingConvention, 'core')? true : false


var vnetName = replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.virtualnetworkPrefix)
var nsgNamingPlaceHolder = replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.NetworSecurityGroup)
// var snetNamingPlaceholder = replace(resourceNamingPlacHolder, '[PC]',resourceNamePrefix.parameters.subNetPrefix)

resource pcResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'Deploy-${demoRgName}'
  location: location
  tags:tags
}
@description('Creates number of storage account specified during deployment')
module StorageAccount './pcStorageAccount.bicep' = [ for i in range(0, saAccountCounts): { //if(deployResource) {
 scope: pcResourceGroup
name: 'depoy-${saNamingPrefix}sa0${i}'


params:{
  location: location
  saAccountName: '${saNamingPrefix}sa0${i}'
  tags: tags
}
}]


module pcVirtualNetwork './pcVirtualNetwork.bicep' = {
  scope: pcResourceGroup
  name: vnetName
  
params: {
  // coreVirtualNetworkname: vnetNamingPrefix
  addressPrefixes: addressPrefixes
  location: location
  tags: tags
  subnets: subnets
  dnsServers: dnsServers
  //snetlength: snetlength
  //index : index
  vnetName: vnetName
  //subNetName: snetNamingPlaceholder
  nsgNamePrefix: nsgNamingPlaceHolder
  snetNamePrefix: snetNamePrefix
  // environment: environment
  // coreRgName: coreRgName **** keeping in remaked until desing change **************
 
}
}
/*
module coreTools 'pcShared.bicep' = if (core == true) {
  scope: pcResourceGroup
  name: 'Deploy-${pcResourceGroup.name}-mgmtyools'
  params: {
    location: location
     pcnamingConvention: resourceNameRG
    tags: tags
  }
}

output coreVnetName string = pcv.outputs.vnetName
output coreRgname string = pcResourceGroup.name
output coreSubnetid string = virtualNetwork.outputs.vnetID
*/
output snetarray array = subnets
// output ResourceGroupID string = pcResourceGroup.id
output coreVnetname string = pcVirtualNetwork.outputs.virtualNetworkName
output coreVnetid string = pcVirtualNetwork.outputs.virtualNetworkId
