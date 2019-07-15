# ami-builder-configs
Configuration files for building various AMIs using ami-builder

Each time ami-builder-config code has a new commit & is merged, a new GitHub release is created and zipped
This gets picked up by Concourse pipeline job 'Ami-builder-release' which is monitoring every hour looking for a new release.
The Concourse pipeline order can be viewed in the docs folder for this repo.
The reason this is done this way is you can't have push notifications from GitHub into Crown and there are rate limits for polling GitHub
The Concourse pipeline job 'Upload-ami-buider-configs’ un-packs the new release and uploads the (config) files to an S3 bucket.
Inside the bucket there is a Kafka folder and a DKS folder respectively.

# REPO LOCATION
https://github.com/dwp/ami-builder-configs
https://github.ucds.io/dip/aws-management-infrastructure/blob/master/ci/jobs/build_amis/upload-ami-builder-configs.yml
https://github.ucds.io/dip/aws-management-infrastructure/tree/master/ci/jobs/build_amis

The config files will be downloaded from S3 via a provisioning.sh script by the 'ami_builder.py' script.
Packer requires a Jinja2.template file which get converted to packer.json.

# REPO LOCATION
https://github.com/dwp/ami-builder/blob/master/ami_builder.py

In order to configure the behaviour of the Lambda function, e.g. what source AMI to use, a payload file is required.
Please see link for Packer docs https://www.packer.io/docs/builders/amazon.html

As part of the ami-builder-configs-release Concourse pipeline job the 'ami-builder-configs-release'
calls the Ami-builder Lambda function which includes the manifest payload file.
It is here where Packer EC2 Instances are allowed HTTPS internet traffic outbound via NAT Gateway.

CloudWatch logs can be found in /aws/lambda/ami_builder.

# REPO LOCATION
https://github.ucds.io/dip/aws-management-infrastructure/blob/master/packer.tf

To trigger these builds manually from your terminal

fly -t concourse check-resource -r management/aim-builder-configs-release
fly -t concourse check-resource -r aws-crypto/dks-host-ami

Eg. to trigger a check on a pipeline in concourse. 'fly -t concourse check-resource -r pipeline/aim-builder-configs-release’
