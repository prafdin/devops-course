### Prerequsites
- Generate public and private keys on control VM.  
Rename public key 'id_rsa_ycloud.pub' and put public and private keys to ~/.ssh folder. 
- Clone repo 
```
git clone https://github.com/prafdin/devops-course.git ~/devops-course
```  
### Create VM 
```
cd ~/devops-course/simple_site/v1/terraform
terraform init
terraform apply -auto-approve
```
### Output IP of new VM
```
terraform output vm_address
```
### Upload site
```
cd ~/devops-course/simple_site/v1/ansible
```
Change ansible_host variable to output of terraform output command
```
ansible-playbook upload_site.yaml -i hosts.yaml
```
