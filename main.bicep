@description('The IP Range for the Vnet')
param IpRangePrefix string='10.0.0.0/16'

@description('Location for all resources.')
param location string ='westus3'

@description('Address Range of Subnet 1')
param Subnet1AddressRange string='10.0.1.0/24'

@description('Address Range of Subnet 1')
param Subnet2AddressRange string='10.0.2.0/24'


@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'Test'
  'Prod'
])
param envoirnment string

@description('The name of Computer Deployed by VM')
param computername string='VanServer'

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

module KeyVault 'Keyvault.bicep'={
  name:'KeyVault'
  params:{
    location: location
    envoirnment: envoirnment
  }
}



module NetworkingResouces 'Network.bicep'={
  name:'Networking'
  

  params:{
    envoirnment:envoirnment
    location:location
    IpRangePrefix:IpRangePrefix 
    Subnet1AddressRange:Subnet1AddressRange
    Subnet2AddressRange: Subnet2AddressRange
    
  }
}





module VirtualMachine 'VirtualMachine.bicep'={
  name:'VirtualMachine'
  dependsOn:[
    NetworkingResouces
  ]
  params:{
    location: location
    VMAdminPassword: VMAdminPassword
    VMAdminUserName: VMAdminUserName
    VmSize: VmSize
    Vnetid: NetworkingResouces.outputs.vnetid
    computername: computername
    envoirnment: envoirnment
    subnetid: NetworkingResouces.outputs.mgmtsubnetid
  }
}



@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

module SQLDatabase 'SQLServer.bicep'={
  name:'SQLDatabase'
  dependsOn:[
    NetworkingResouces
  ]
  params:{
    location: location
    VnetId: NetworkingResouces.outputs.vnetid
    envoirnment: envoirnment
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
    subnetID: NetworkingResouces.outputs.sqlsubnetid
  }
}


module SynapseWorkspace 'Synapse.bicep'={
  name:'SynapseWorkspace'
  dependsOn:[
    SQLDatabase,NetworkingResouces
  ]
  params:{
    envoirnment: envoirnment
    location:location
    VnetId: NetworkingResouces.outputs.vnetid
    subnetID: NetworkingResouces.outputs.sqlsubnetid
    subnet2ID:NetworkingResouces.outputs.mgmtsubnetid
    
    
  }
}

@description('IP Adress of Next HopFirewall,Appliance, Router')
param nextHopIP string = '10.20.30.40'

module RouteTable 'RouteTable.bicep'={
  name:'RouteTable'
  params:{
    location: location    
    envoirnment: envoirnment
    nextHopIP:nextHopIP
    
     
    
  }
}

module StorageAccounts 'Storageacc.bicep'={
  name:'StorageAccounts'
  params:{
    location: location
    envoirnment:envoirnment
  }
}
