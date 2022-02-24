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
                git credentialsId: 'github-access', 
                url: 'https://github.com/halilili/kubernetes-ssh-deployment'
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
                withSonarQubeEnv('sonarqube-8.5.1') { 
                  sh "mvn sonar:sonar"
                }
            }
        }
        
        
        stage('Jmeter Unit Testing') {
            steps{
                
                sh "/home/ubuntu/jmeter/apache-jmeter-5.4.3/bin/jmeter.sh -n -t /home/ubuntu/jmeter/apache-jmeter-5.4.3/bin/examples/CSVSample.jmx -l test.jtl"
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
       
       
       stage("Prepare Deployment Tag"){
           steps{
               sh "chmod +x changeTag.sh"
               sh "./changeTag.sh ${docker_tag}"
           }
       }
       
       stage("SSH Deployment To AWS Kuberntes"){
           steps{
               
               sshagent(['aws-server']) {
                    sh 'scp -o StrictHostKeyChecking=no k8s/services.yml k8s/deployment-node-app.yml ubuntu@172.31.11.22:/home/ubuntu/k8s/'
                    script {
                        try{
                            sh "ssh ubuntu@172.31.11.22 kubectl apply -f k8s/."
                        }
                        catch(error)
                        {
                            sh "ssh ubuntu@172.31.11.22 kubectl apply -f k8s/."
                        }
                    }
               }
           }
       }
       
       /*
       stage("SSH Deployment To Local Kuberntes"){
           steps{
               
              sshagent(['mylaptop-ssh-access']) {
                    sh 'scp -o StrictHostKeyChecking=no k8s/services.yml k8s/node-app-pod.yml hasan@192.168.178.21:home/hasan/k8s/'
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
       */
  }
  
}

def latestVersion(){
    def commitVersion = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitVersion
}

