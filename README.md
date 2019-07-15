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
Packer requires a Jinja2.template file which gets converted to packer.json.

# REPO LOCATION
https://github.com/dwp/ami-builder/blob/master/ami_builder.py

In order to configure the behaviour of the Lambda function, e.g. what source AMI to use, a payload file is required.
Please see link for Packer docs https://www.packer.io/docs/builders/amazon.html

```{
       "packer_template_bucket_region":  "eu-west-1",
       "packer_template_bucket":         "my-bucket-name",
       "packer_template_key":            "packer_template.json.j2",
       "provision_script_bucket_region": "eu-west-1",
       "provision_script_bucket":        "my-bucket-name",
       "provision_script_keys":          ["provision.sh"],
       "source_ami_virt_type":           "hvm",
       "source_ami_name":                "CentOS Linux 7 x86_64*",
       "source_ami_root_device_type":    "ebs",
       "source_ami_owner":               "679593333241",
       "instance_type":                  "t2.micro",
       "ssh_username":                   "centos",
       "subnet_id":                      "subnet-0a00aaa0",
       "ami_name":                       "my-first-ami"
   }```

As part of the ami-builder-configs-release Concourse pipeline job the 'ami-builder-configs-release'
calls the Ami-builder Lambda function which includes the manifest payload file.
It is here where Packer EC2 Instances are allowed HTTPS internet traffic outbound via a NAT.

CloudWatch logs can be found in /aws/lambda/ami_builder.

# REPO LOCATION
https://github.ucds.io/dip/aws-management-infrastructure/blob/master/packer.tf

To trigger these builds manually from your terminal

```fly -t concourse check-resource -r management/aim-builder-configs-release```
```fly -t concourse check-resource -r aws-crypto/dks-host-ami```

Eg to trigger a check on a pipeline in concourse, use
```'fly -t concourse check-resource -r pipeline/aim-builder-configs-release```
