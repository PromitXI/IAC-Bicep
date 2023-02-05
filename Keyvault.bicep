@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'QA'
  'Prod'
])
param envoirnment string

@description('The Location of The Resource Group and All Other Resources')
param location string




param name string =take('PWB-${envoirnment}-KeyVlt-${uniqueString(resourceGroup().id)}-get',20)



resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    softDeleteRetentionInDays:30
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: 'd80c687c-8974-4c5f-8265-75f0ed2213d2'
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'

          ]
          secrets: [
            'list'
            'get'
            'set'

            
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  dependsOn:[
    keyVault
  ]
  name: 'keyVaultName/${name}'
  properties: {
    value: 'value'
    
  }
}

