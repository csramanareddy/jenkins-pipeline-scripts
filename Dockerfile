#FROM jenkins/jenkins:lts-jdk11 as RUNTIME
FROM jenkinsci/blueocean:latest as RUNTIME

# Install dependencies
USER root

# hadolint ignore=DL3018
RUN apk add --no-cache make openjdk8-jre

#ARG CERT_NAME=${CERT_NAME:-"NABLA.crt"}
#ARG CERT_URL=${CERT_URL:-"http://albandrieu.com/download/certs/"}
ENV JAVA_HOME /opt/java/openjdk/

RUN echo ${JAVA_HOME}
#RUN ls -lrta /opt/java/
#RUN ls -lrta /opt/java/openjdk
#RUN which java

#COPY ${CERT_URL}/NABLA.crt /usr/local/share/ca-certificates/NABLA.crt
#COPY ${CERT_URL}/${CERT_NAME} /usr/local/share/ca-certificates/${CERT_NAME}
#RUN update-ca-certificates
#RUN apk add --no-cache ca-certificates && \
#    update-ca-certificates

#RUN ln -sf /etc/ssl/certs/java/cacerts ${JAVA_HOME}/jre/lib/security/cacerts

# Update Java certs
#RUN keytool -v -noprompt \
#    -keystore ${JAVA_HOME}/jre/lib/security/cacerts \
#    -importcert \
#    -trustcacerts \
#    -file /usr/local/share/ca-certificates/${CERT_NAME} \
#    -alias test \
#    -keypass changeit \
#    -storepass changeit

# drop back to the regular jenkins user - good practice
USER jenkins

RUN mkdir $JENKINS_HOME/configs
COPY --chown=jenkins src/test/jenkins/jenkins.yaml $JENKINS_HOME/configs/jenkins.yaml
ENV CASC_JENKINS_CONFIG=$JENKINS_HOME/configs

ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false

ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8080
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no"

# Install plugins
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy \
  && /usr/local/bin/install-plugins.sh \
  groovy-events-listener-plugin:1.014 \
  configuration-as-code \
 # configuration-as-code-support \
  blueocean \
  job-dsl \
  cloudbees-folder \
  workflow-aggregator \
  pipeline-utility-steps \
  generic-webhook-trigger \
  pipeline-maven \
  locale \
  sonar \
  ws-cleanup \
  ansicolor \
  timestamper \
  groovy-postbuild \
  git-changelog \
  docker \
  prometheus:latest \
  envinject \
  artifactdeployer \
  nodenamecolumn \
  summary_report \
  docker-commons \
  publish-over-cifs \
  progress-bar-column-plugin \
  thinBackup \
  token-macro \
  jobConfigHistory \
  scons \
  downstream-buildview \
  clamav \
  deploy \
  naginator \
  build-publisher \
  xvfb \
  windows-slaves \
  m2release \
  git \
  scm-api \
  maven-repo-cleaner \
  ssh-agent \
  robot \
  environment-script \
  stepcounter \
  plugin-usage-plugin \
  cvs \
  jira \
  fail-the-build-plugin \
  workflow-step-api \
  checkmarx \
  aqua-security-scanner \
  whitesource \
  matrix-combinations-parameter \
  jobtype-column \
  batch-task \
  configurationslicing \
  parameterized-trigger \
  sounds \
  job-exporter \
  preSCMbuildstep \
  fitnesse \
  dashboard-view \
  gatling \
  saferestart \
  build-timestamp \
  job-node-stalker favorite exclusive-execution build-pipeline-plugin postbuild-task skip-certificate-check maven-info \
  node-iterator-api \
  ssh publish-over-ssh ssh-slaves ssh-credentials \
  stashNotifier sitemonitor build-metrics distfork \
  promoted-builds flexible-publish \
  computer-queue-plugin throttle-concurrents \
  read-only-configurations ant countjobs-viewstabbar \
  email-ext credentials cobertura nodejs audit-trail \
  text-finder-run-condition versioncolumn global-build-stats mapdb-api plot jquery show-build-parameters \
  conditional-buildstep maven-plugin view-job-filters rebuild \
  matrix-project performance groovy claim docker-build-step \
  join tap nodelabelparameter \
  custom-tools-plugin translation sidebar-link bulk-builder \
  mttr Exclusion subversion antisamy-markup-formatter \
  covcomplplot greenballs dropdown-viewstabbar-plugin \
  nested-view external-monitor-job docker-build-publish \
  project-stats-plugin \
  build-name-setter build-timeout \
  prereq-buildstep jacoco caliper-ci \
  dependencyanalyzer \
  chosen-views-tabbar port-allocator description-setter publish-over-ftp \
  build-environment \
  git-client authentication-tokens monitoring text-finder extended-choice-parameter built-on-column run-condition \
  lastfailureversioncolumn mask-passwords htmlpublisher hp-application-automation-tools-plugin \
  project-description-setter build-with-parameters \
  git-parameter javadoc build-failure-analyzer confluence-publisher script-security html5-notifier-plugin next-executions \
  jenkins-multijob-plugin matrix-auth testInProgress copy-data-to-workspace-plugin mailer \
  next-build-number qc multiple-scms job-import-plugin \
  junit files-found-trigger compact-columns build-keeper-plugin \
  pam-auth log-parser all-changes slave-status \
  parameterized-remote-trigger \
  jenkins-remote-build-trigger \
  jenkinslint \
  kubernetes

# deprecated plugins
#dry
#checkstyle
#violations
#violation-columns
#pmd
#warnings
#findbugs
#multi-branch-project -> workflow-multibranch
#tasks
#jquery-ui

COPY src/test/groovy/04-Executors.groovy /usr/share/jenkins/ref/init.groovy.d/04-Executors.groovy

# drop back to the regular jenkins user - good practice
USER jenkins

EXPOSE 8080 50000
