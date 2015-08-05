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
cmd=$(echo "$cmd" | sed "s/--deployment-config-name <deployment-config-name>//")

# Creates the deployment script to run in the 'deploy' stage of the GO pipeline
tee "deploy.sh" > /dev/null <<EOF
#!/bin/bash
set -e
$cmd

output=\$($cmd)
deployment_id=\$(echo "\$output" | jq -r .deploymentId)
echo
echo "Deploying ${application_name} ..."
echo "Deployment ID: \$deployment_id"
echo
echo "Waiting for CodeDeploy to complete..."
echo

while true; do
  deployment_info=\$(aws --region $region deploy get-deployment --deployment-id \$deployment_id)
  deployment_status=\$(echo "\$deployment_info" | jq -r .deploymentInfo.status)
  case "\$deployment_status" in
    Succeeded|Skipped)
      echo "Deployment \$deployment_status"
      exit 0
      ;;
    Created|InProgress|Pending)
      echo "Deployment \$deployment_status"
      echo "Sleeping for 30s before next status check..."
      sleep 30
      ;;
    *)
      echo "Deployment status: \$deployment_status"
      errorCode=\$(echo "\$deployment_info" | jq -r .deploymentInfo.errorInformation.code)
      errorMessage=\$(echo "\$deployment_info" | jq -r .deploymentInfo.errorInformation.message)
      if [ -n "\$errorCode" ]; then
        echo "\$errorCode: \$errorMessage"
      fi
      exit 1
      ;;
  esac
done
EOF
