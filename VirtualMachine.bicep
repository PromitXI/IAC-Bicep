@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'QA'
  'Prod'
])
param envoirnment string

@description('The Location of The Resource Group and All Other Resources')
param location string

@description('The ID for the Network Subnet')
param subnetid string

@description('The ID for the Virtual Network')
param Vnetid string

@description('The name of Computer Deployed by VM')
param computername string

@description('Username of the VM')
@secure()
param VMAdminUserName string

@description('The Admin Password of VM')
@secure()
param VMAdminPassword string

@description('The size of the VM')
@allowed([
  'Standard_D2_v3'
  'Standard_B1s'
  'Standard_DS1_v2'
  'Standard_DS2'
  'Standard_DS4_v2'
])
param VmSize string 

var VirtualMachineName='PWB-EDM-${envoirnment}-${location}001'
var nicName='PWB-NIC-${envoirnment}'
var OSDisk='${VirtualMachineName}-OSDisk'


resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'VM-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetid
          }
        }
      }
    ]
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: VirtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: VmSize
    }
    osProfile: {
      computerName: computername
      adminUsername: VMAdminUserName
      adminPassword: VMAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: OSDisk
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    
  }
}
