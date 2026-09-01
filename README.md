<img width="655" height="655" alt="image" src="https://github.com/user-attachments/assets/22d8f7c3-f1c1-4568-b67f-dd8c8ae658a5" />

GCP Terraform Cloud NAT Lab

Architecture Overview: Implements a secure custom VPC with segregated subnets across us-east1 and us-west1, coupled with a Cloud Router and Cloud NAT gateway to enable secure outbound internet access for private instances without external IP addresses.

Storage Configuration: Provisions a multi-region Cloud Storage bucket in US containing the initial file .png asset via native Terraform object management.

Remote Management: Executes all configuration workflows and infrastructure rollouts utilizing HCP Terraform workspaces.
