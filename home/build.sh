#!/bin/bash
set -e
#set default region
region="$REGION"

application_name="$APPLICATION_NAME"

deployment_group="$DEPLOYMENT_GROUP"

s3_bucket="$S3_BUCKET"

cmd=$(aws \
--region "$region" \
deploy push \
--application-name "$application_name" \
--s3-location s3://"$s3_bucket"/"$application_name".zip \
--ignore-hidden-files)

#Strips text line off the output from the aws push command
cmd=$(echo "$cmd" | tail -n +2)

#add region to command
cmd=$(echo "$cmd" | sed "s/aws deploy/aws --region $region deploy/")
cmd=$(echo "$cmd" | sed "s/<deployment-group-name>/$deployment_group/")

cmd=$(echo "$cmd" | sed "s/--description <description>//")

# Create the deployment script
tee "deploy.sh" > /dev/null <<EOF
#!/bin/bash
set -e
$cmd
EOF
