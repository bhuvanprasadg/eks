init:
	terraform init

plan: init
	terraform plan -out plan.out -var-file ./env.auto.tfvars -no-color | tee plan.txt

apply: plan
	terraform apply plan.out