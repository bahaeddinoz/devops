# devops
openpayd_sample
************ Enviroment ***************************
- install awscli
- install terraform
- install kops
- install kubectl
- install jq
- Used AWS
- Used vscode editor
- Used vagrant for local centos machine
- Used public DNS record and redirected NS to AWS.


************* Summary *****************************
- Terraform everthing related to VPC.
- Kops requests the resources created by Terraform
- Kops create k8s cluster with 1 master,2 nodes.
- kubectl deploy our sample application
- Python lambda function get all VPCs and subnet informations and write the DynamoDB.

************* Terraform Create VPC informations *****************************
- main.tf
- Created AWS profile and export it as enviroment variable
- Export my project and domain name as enviroment variable
- Create S3 buckets for my state files of terraform and kops
	aws s3 mb s3://terraform-state.${DOMAIN}
	aws s3 mb s3://kops-state.${DOMAIN}
- Create main.tf file.
- Create terraform workspace and select it.
	terraform workspace new ${PROJECT_NAME}
	terraform workspace select ${PROJECT_NAME}
- run: terraform init
- run: terraform apply -var "project_name=${PROJECT_NAME}" -var "domain=${DOMAIN}"

*********** Create K8s cluster *****************************************
- kops.txt
- Export kops state store to use in kops
	export KOPS_STATE_STORE=s3://kops-state.${DOMAIN}
- run kops script (output comes from Terraform) to create k8s cluster with kops
- Update kops cluster
	kops update cluster --name ${PROJECT_NAME}.${DOMAIN} --yes
- Validate cluster
	kops validate cluster

*********** Deploy Application *******************************************
- deployment.yaml
- check k8s is ready
	kubectl cluster-info
- create config map to upload html directory
	kubectl create configmap nginx-content --from-file=/root/devops.bahaddinozcelikc.com/deployment/contents
- Run deployment and service (5 replicas and LoadBalancer)
	kubectl apply -f  deployment_file.yaml
- Check Cluster name is ready and reach it with outside of local network with port 80.
	kubectl get pods,services,cm,nodes
	
************ Lambda Function ***********************************************
- my_function.py
