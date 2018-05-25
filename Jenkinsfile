pipeline {
    agent {
        label "jenkins-jx-base"
    }
    environment {
        ORG         = 'jenkinsxio'
        APP_NAME    = 'builder-base'
        PUSH        = 'true'
    }
    stages {
        stage('CI Build and push snapshot') {
            when {
                branch 'PR-*'
            }
            environment {
                VERSION = "SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
                PUSH_LATEST = "false"
            }
            steps {
                container('jx-base') {
                    sh "./jx/scripts/build-images.sh"
                }
            }
        }
    
        stage('Build and Push Release') {
            when {
                branch 'master'
            }
            environment {
                PUSH_LATEST = "true"
            }
            steps {
                container('jx-base') {
                    sh "./jx/scripts/release.sh"
                }
            }
        }
    }
}
