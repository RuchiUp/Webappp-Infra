# aws-infra

## This infrastructure is configured using Terraform   
## version control used is GIT  
## Cloud platform used is AWS    

The command to import the certificate in ACM is : 
aws acm import-certificate --profile demo --region us-west-2 --certificate file://xxxx.crt --private-key file://private.key --certificate-chain file://xxxxx-bundle
