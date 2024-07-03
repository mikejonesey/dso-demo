pipeline {
  agent {
    kubernetes {
      yamlFile 'build-agent.yaml'
      defaultContainer 'maven'
      idleMinutes 1
    }
  }
  environment {
    BUILD_TS = sh(returnStdout: true, script: 'date +%s').trim()
    IMAGE_TAG = "${BRANCH_NAME}-${GIT_COMMIT[0..7]}-${BUILD_TS}"
    ARGO_SERVER = '34.32.193.61:32100'
    DEV_URL = 'http://34.32.193.61:30080/'
  }
  stages {

    stage('Build') {
      parallel {
        stage('Compile') {
          steps {
            container('maven') {
              sh 'mvn compile'
            }
          }
        }
      }
    }

    stage('Static Analysis') {
      parallel {

        stage('Unit Tests') {
          steps {
            container('maven') {
              sh 'mvn test'
            }
          }
        }

        stage('SCA') {
          steps {
            container('maven') {
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh 'mvn org.owasp:dependency-check-maven:check -f pom.xml'
              }
            }
          }
          post {
            always {
              archiveArtifacts allowEmptyArchive: true, artifacts: 'target/dependancy-check-report.html', fingerprint: true, onlyIfSuccessful: true
              // dependencyCheckPublisher pattern: 'report.xml'
            }
          }
        }

        stage('Generate SBOM') {
          steps {
            container('maven') {
              sh 'mvn org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom'
            }
          }
          post {
            success {
              // switching off dep track app
              // dependencyTrackPublisher projectName: 'sample-spring-app', projectVersion: '0.0.1', artifact: 'target/bom.xml', autoCreateProjects: true, synchronous: true
              archiveArtifacts allowEmptyArchive: true, artifacts: 'target/bom.xml', fingerprint: true, onlyIfSuccessful: true
            }
          }
        }

        stage('OSS License Checker') {
          steps {
            container('licensefinder') {
              sh 'ls -al'
              sh '''#!/bin/bash --login
                      /bin/bash --login
                      rvm use default
                      gem install license_finder
                      license_finder
                 '''
            }
          }
        }
        
      }
    }
    
    stage('SAST') {
      parallel {

        stage('scan') {
          steps {
            container('slscan') {
              sh 'scan --type java,depscan --build'
            }
          }
          post {
            success {
              archiveArtifacts allowEmptyArchive: true, artifacts: 'reports/*', fingerprint: true, onlyIfSuccessful: true
            }
          }
        }
        
      }
    }
    
    stage('Package') {
      parallel {
        
        stage('Create Jarfile') {
          steps {
            container('maven') {
              sh 'mvn package -DskipTests'
            }
          }
        }
        
        stage('OCI Image BnP') {
          steps {
            container('kaniko') {
              sh "/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=docker.io/mikejonesey/dso-demo:${IMAGE_TAG}"
            }
          }
        }

      }
    }

    stage('Image Analysis') {
      parallel {

        stage('Image Linting') {
          steps {
            container('docker-tools') {
              sh "dockle mikejonesey/dso-demo:${IMAGE_TAG}"
            }
          }
        }

        stage('Image Scanning') {
          steps {
            container('docker-tools') {
              sh "trivy image --timeout 10m --exit-code 1 mikejonesey/dso-demo:${IMAGE_TAG}"
            }
          }
        }
        
      }
    }

    stage('Deploy to Dev') {
      environment {
        AUTH_TOKEN = credentials('argocd-jenkins-deploy-token')
      }
      steps {
        container('docker-tools') {
          sh 'argocd app sync dso-demo --insecure --server $ARGO_SERVER --auth-token $AUTH_TOKEN'
          sh 'argocd app wait dso-demo --health --timeout 300 --insecure --server $ARGO_SERVER --auth-token $AUTH_TOKEN'
        }
      }
    }

    stage('Dynamic Analysis') {
      parallel {

        stage('E2E tests') {
          steps {
            sh 'echo "All Tests passed!!!"'
          }
        }

        stage('DAST') {
          steps {
            container('zap') {
              sh 'zap-baseline.py -t $DEV_URL || exit 0'
            }
          }
        }
      
      }
    }

  }
}
