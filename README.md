This repository contains the Jenkins job configurations used by Zephyr CI.

Jenkins Job Builder
-------------------------

Jenkins Job Builder (jjb) takes simple descriptions of Jenkins jobs in YAML
format, and uses them to configure Jenkins.

Homepage: http://ci.openstack.org/jjb.html

Job Configurations
-------------------------

In order to keep the jobs consistent, please follow this guideline:
 * Job name
   - lower case
   - avoid spacing
 * YAML
   - file name matching the job name

Workflow
-------------------------

Changes made to this repository are monitored and trigger an automatic
deployment on the Jenkins master instance (only jobs changes with last
commit(s) will be deployed).

Note: changes made through Jenkins web interface will be LOST.

To manually force a Jenkins job update:
* Install jenkins-job-builder package
* Copy provided jenkins_jobs.ini-sample to jenkins_jobs.ini
* Edit jenkins_jobs.ini user/password settings as appropriate
* Run the job builder in test mode:

    jenkins-jobs --conf=jenkins_jobs.ini test <job>.yaml

* Update the job on the Jenkins master:

    jenkins-jobs --conf=jenkins_jobs.ini update <job>.yaml
