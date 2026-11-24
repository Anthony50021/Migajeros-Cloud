pipeline {
    agent any
    environment {
        AZURE_RG        = 'rg-migajeros-cloud'
        AZURE_LOCATION  = 'chilecentral'
        VM_PASS         = credentials('VM_ADMIN_PASSWORD')
        SQL_PASS        = credentials('SQL_ADMIN_PASSWORD')
    }
    stages {
        stage('Validar Sintaxis Bicep') {
            steps {
                echo 'Validando que los archivos Bicep compilen correctamente...'
                bat 'call az bicep build --file main.bicep'
            }
        }
        stage('Crear Grupo de Recursos') {
            steps {
                echo "Verificando/Creando Grupo de Recursos ${AZURE_RG}..."
                bat 'call az group create --name %AZURE_RG% --location %AZURE_LOCATION%'
            }
        }
        stage('Desplegar Infraestructura') {
            steps {
                echo 'Iniciando despliegue de Infraestructura 3-Tier en Azure...'
                bat '''
                    call az deployment group create ^
                      --resource-group %AZURE_RG% ^
                      --template-file main.bicep ^
                      --parameters location=%AZURE_LOCATION% vmAdminPassword="%VM_PASS%" sqlAdminPassword="%SQL_PASS%"
                '''
            }
        }
    }
    post {
        success {
            echo '==================================================='
            echo '¡Despliegue de Infraestructura completado con éxito!'
            echo '==================================================='
        }
        failure {
            echo '==================================================='
            echo 'Ocurrió un error durante el despliegue.'
            echo '==================================================='
        }
    }
}
