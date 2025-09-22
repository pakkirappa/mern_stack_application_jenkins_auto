#!/usr/bin/env groovy

/**
 * Jenkins Shared Library for MERN Stack Application
 * This library contains common functions used across Jenkins pipelines
 */

def sendSlackNotification(String message, String color = 'good', String channel = '#deployments') {
    try {
        slackSend(
            channel: channel,
            color: color,
            message: message
        )
    } catch (Exception e) {
        echo "Failed to send Slack notification: ${e.getMessage()}"
    }
}

def getGitInfo() {
    def gitCommit = env.GIT_COMMIT ?: sh(
        script: 'git rev-parse HEAD',
        returnStdout: true
    ).trim()
    
    def gitCommitShort = gitCommit.take(8)
    def gitBranch = env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'main'
    def gitAuthor = sh(
        script: 'git log -1 --pretty=format:"%an"',
        returnStdout: true
    ).trim()
    
    return [
        commit: gitCommit,
        commitShort: gitCommitShort,
        branch: gitBranch,
        author: gitAuthor
    ]
}

def buildDockerImage(String imageName, String dockerfile = 'Dockerfile', String context = '.') {
    def buildArgs = [
        "BUILD_NUMBER=${env.BUILD_NUMBER}",
        "GIT_COMMIT=${env.GIT_COMMIT}",
        "BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    ].join(' --build-arg ')
    
    sh """
        docker build \\
            --build-arg ${buildArgs} \\
            -f ${dockerfile} \\
            -t ${imageName}:${env.BUILD_NUMBER} \\
            -t ${imageName}:latest \\
            ${context}
    """
}

def pushDockerImage(String imageName, String registry = env.DOCKER_REGISTRY) {
    withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh """
            echo \$DOCKER_PASS | docker login ${registry} -u \$DOCKER_USER --password-stdin
            docker push ${registry}/${imageName}:${env.BUILD_NUMBER}
            docker push ${registry}/${imageName}:latest
        """
    }
}

def runHealthChecks(String baseUrl = 'http://localhost:5000') {
    def endpoints = [
        '/ping',
        '/health',
        '/alive',
        '/ready'
    ]
    
    def results = [:]
    
    endpoints.each { endpoint ->
        try {
            sh "curl -f ${baseUrl}${endpoint}"
            results[endpoint] = 'PASS'
            echo "✅ Health check passed: ${endpoint}"
        } catch (Exception e) {
            results[endpoint] = 'FAIL'
            echo "❌ Health check failed: ${endpoint}"
        }
    }
    
    return results
}

def deployToKubernetes(String namespace, String imageName, String imageTag) {
    sh """
        kubectl set image deployment/mern-backend mern-backend=${imageName}:${imageTag} -n ${namespace}
        kubectl rollout status deployment/mern-backend -n ${namespace} --timeout=300s
    """
}

def runSecurityScan(String imageName) {
    try {
        sh """
            if command -v trivy &> /dev/null; then
                trivy image --exit-code 0 --severity HIGH,CRITICAL ${imageName}
            else
                echo "Trivy not available, skipping security scan"
            fi
        """
    } catch (Exception e) {
        echo "Security scan failed: ${e.getMessage()}"
        currentBuild.result = 'UNSTABLE'
    }
}

def archiveBuildArtifacts() {
    try {
        archiveArtifacts(
            artifacts: [
                'frontend/build/**/*',
                'backend/dist/**/*',
                'build-report.json',
                'test-results.xml'
            ].join(','),
            allowEmptyArchive: true,
            fingerprint: true
        )
    } catch (Exception e) {
        echo "Failed to archive artifacts: ${e.getMessage()}"
    }
}

def publishTestResults() {
    try {
        // Publish test results
        if (fileExists('test-results.xml')) {
            publishTestResults([
                testResultsPattern: 'test-results.xml'
            ])
        }
        
        // Publish coverage
        if (fileExists('coverage/lcov.info')) {
            publishCoverage([
                adapters: [lcovAdapter('coverage/lcov.info')],
                sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
            ])
        }
    } catch (Exception e) {
        echo "Failed to publish test results: ${e.getMessage()}"
    }
}

def notifyBuildResult(String appName, Map gitInfo) {
    def status = currentBuild.result ?: 'SUCCESS'
    def color = [
        'SUCCESS': 'good',
        'UNSTABLE': 'warning',
        'FAILURE': 'danger'
    ][status]
    
    def emoji = [
        'SUCCESS': '🎉',
        'UNSTABLE': '⚠️',
        'FAILURE': '❌'
    ][status]
    
    def message = """
        ${emoji} ${appName} build ${status.toLowerCase()}!
        📋 Build: ${env.BUILD_NUMBER}
        🔧 Commit: ${gitInfo.commitShort} by ${gitInfo.author}
        🌿 Branch: ${gitInfo.branch}
        📊 Duration: ${currentBuild.durationString}
        🔗 Logs: ${env.BUILD_URL}console
    """.stripIndent().trim()
    
    sendSlackNotification(message, color)
}

def cleanup() {
    try {
        // Clean up Docker images older than 24 hours
        sh '''
            docker image prune -f --filter "until=24h"
            docker system prune -f
        '''
        
        // Clean up test artifacts
        sh '''
            rm -rf coverage/
            rm -rf test-results/
            rm -f build-report.json
        '''
    } catch (Exception e) {
        echo "Cleanup failed: ${e.getMessage()}"
    }
}

return this