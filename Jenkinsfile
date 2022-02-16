pipeline {
    agent any
    
    tools {
      maven 'MavenBuild'
    }
    
    environment {
      docker_tag = latestVersion()
    }
    
    
  stages{
      
      stage ('SCM Clone')
        {
            steps{
               git credentialsId: 'github-access', url: 'https://github.com/halilili/docker-k8s-ssh-deployment'
            }
        }
        
        
        stage ('Maven Clean Package')
        {
            steps{
                sh "mvn clean package"
            }
        }
        
        stage('SonarQube Analysis') {
            steps{
                echo "SonarQube Analysis Stage"
            }
        }
    
        
        
       stage('Docker Build'){
           steps{
               sh "docker build . -t hassanali70826/my-app:${docker_tag}"
           }
       }
       
       stage('DockerHub Push'){
           steps{
               withCredentials([string(credentialsId: 'docker-password', variable: 'dockerHubPassword')]) {
                    sh "docker login -u hassanali70826 -p ${dockerHubPassword}"
               }
              
               sh "docker push hassanali70826/my-app:${docker_tag}"
           }
       }
       
       stage("SSH Deployment To Kuberntes"){
           steps {
               sh "chmod +x changeTag.sh"
               sh "./changeTag.sh ${docker_tag}"
               
               sshagent(['mylaptop-ssh-access']) {
                   
                    sh 'scp -o StrictHostKeyChecking=no services.yml node-app-pod.yml hasan@192.168.178.21:home/hasan/'
                   
                    script {
                        try{
                            
                            sh "ssh hasan@192.168.178.21 kubectl apply -f ."
                        }
                        catch(error)
                        {
                            sh "ssh hasan@192.168.178.21 kubectl create -f ."
                        }
                    }
               }
           }
       }
       
  }
  
}

def latestVersion(){
    def commitVersion = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitVersion
}

