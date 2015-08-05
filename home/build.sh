#!/bin/bash

#halts the script if there are errors
set -e

#set variables that you reference in GO pipeline ENVIRONMENT VARIABLES tab
region="$REGION"
application_name="$APPLICATION_NAME"
deployment_group="$DEPLOYMENT_GROUP"
s3_bucket="$S3_BUCKET"

#creates the deploy push output (with variables defined in the GO pipeline) in the 'cmd' variable
cmd=$(aws \
--region "$region" \
deploy push \
--application-name "$application_name" \
--s3-location s3://"$s3_bucket"/"$application_name".zip \
--ignore-hidden-files)

#strips inital text line from the output of the aws push
cmd=$(echo "$cmd" | tail -n +2)

#adds the AWS 'region'
cmd=$(echo "$cmd" | sed "s/aws deploy/aws --region $region deploy/")

#adds the 'deployment group name'
cmd=$(echo "$cmd" | sed "s/<deployment-group-name>/$deployment_group/")

#strips out the 'description' field
cmd=$(echo "$cmd" | sed "s/--description <description>//")

#strips out the 'deployment config name'
cmd=$(echo "$cmd" | sed "s/-'-deployment-config-name <deployment-config-name>//")

# Creates the deployment script to run in the 'deploy' stage of the GO pipeline
tee "deploy.sh" > /dev/null <<EOF
#!/bin/bash
set -e
$cmd
EOF
