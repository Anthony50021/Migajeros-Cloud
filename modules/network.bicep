param location string
param vnetName string = 'vnet-migajeros-cloud'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-compute' // Subred para la máquina virtual
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'snet-database' // Subred para el Private Endpoint de base de datos
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output computeSubnetId string = vnet.properties.subnets[0].id
output databaseSubnetId string = vnet.properties.subnets[1].id