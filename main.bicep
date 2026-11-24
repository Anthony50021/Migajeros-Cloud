param location string = 'chilecentral'
@secure()
param vmAdminPassword string
@secure()
param sqlAdminPassword string

// Módulo 1: Red
module network 'modules/network.bicep' = {
  name: 'deploy-network'
  params: {
    location: location
  }
}

// Módulo 2: Cómputo
module compute 'modules/compute.bicep' = {
  name: 'deploy-compute'
  params: {
    location: location
    subnetId: network.outputs.computeSubnetId
    adminPassword: vmAdminPassword
  }
}

// Módulo 3: Base de Datos
module database 'modules/database.bicep' = {
  name: 'deploy-database'
  params: {
    location: location
    sqlAdminPassword: sqlAdminPassword
    subnetId: network.outputs.databaseSubnetId
    vnetId: network.outputs.vnetId
  }
}