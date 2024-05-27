# Azure ML Infrastructure with Terraform and MLflow
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Terraform](https://img.shields.io/badge/terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![MLflow](https://img.shields.io/badge/MLflow-0077B5?style=for-the-badge&logo=mlflow&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

## 📖 Introduction

Welcome to my GitHub repository, where we set up a machine learning infrastructure on Azure using Terraform and MLflow. This project focuses on creating a scalable and efficient environment for data storage, model training, and model deployment. We use Terraform to provision resources in Azure Cloud, such as Azure Data Lake for storing raw data and an Azure Virtual Machine for hosting the MLflow Server. Our training scripts initially run locally but it also includes a script to train it in the azure cloud.

## 📦 Repo structure
```
.
├── .amlignore  # ignore files for azure ml
├── assets
├── data
│   └── raw
│       └── bank_churners.csv
├── README.md
├── requirements.txt
├── scripts
│   ├── train_model.py  # train the model  
│   └── cloud_compute.py  # run train_model.py in the azure cloud
└── terraform
    ├── compute.tf
    ├── customdata.tpl
    ├── main.tf
    ├── network.tf
    ├── outputs.tf
    ├── storage.tf
    └── variables.tf
# update tree structure: tree -a -I '*.backup|*.tfstate|nohup.out|catboost_info|.venv|.terraform|.idea|.git|*.hcl'
```

## 🚀 Setting Up Infrastructure
### Install prerequisites
#### Setup SSH keys
For the Mlflow server to be accessible you need to set up an ssh key. 
```bash
ssh-keygen -t rsa -f ~/.ssh/azurekey -N ""
```
#### Install the Azure CLI
[Install the Azure CLI on Linux | Microsoft Learn](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#install-azure-cli)
use `az account login` and `az account show` to verify the installation, use the result to set the environment variables in 
/etc/environment and reboot the system:
```bash
ARM_CLIENT_ID="YOUR_AZURE_CLIENT_ID"
ARM_CLIENT_SECRET="YOUR_AZURE_CLIENT_SECRET"
ARM_SUBSCRIPTION_ID="YOUR_AZURE_SUBSCRIPTION_ID"
ARM_TENANT_ID="YOUR_AZURE_TENANT_ID"
```
#### Install terraform
[Install Terraform | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
```bash
#### install python dependencies
pip install -r requirements.txt
```
### Setup the Azure resources with Terraform
Navigate to the `terraform` directory
```bash
cd terraform
```
#### Initialize Terraform
```bash
terraform init
terrraform plan
terraform apply # type yes to confirm and to apply changes
terraform refresh # wait a bit and then run this command it will show the ip of the MLflow server
```

## Training the model
### On your local machine
Navigate to the `scripts` directory and run:
```bash
python train_model.py
```
Go to the MLflow server at `http://<ip>:5000` and check the results.
### on the cloud
For now you have to create an azure workspace manualy, I still need to set up terraform to create this automatically.
Go to [ml.azure.com](https://ml.azure.com/) and create a workspace and a compute instance. The names you choose should also
be set in `cloud_compute.py`.
```bash
python cloud_compute.py
```
The terminal will give you links to the azure portal where you can check the status of the training. I took the lowest compute available and this took some time.
When complete go to the MLflow server at `http://<ip>:5000` and check the results.

## Hosting the model
Go to MLflow server at `http://<ip>:5000` and find the modeluri of the model you want to host.
Navigate to the `scripts` directory and run:
Log into the MLflow server and host the model on the MLflow server.
```bash
ssh adminuser@<ip> # authentication is handled by the ssh key
mlflow models serve -m <model_uri>
```
Your model will be hosted at `http://<ip>:5000/invocations`

## ⚡ Benefits and Use Cases
- **Scalability:** Seamlessly scale up or down with Azure resources.
- **Efficiency:** Faster model training with cloud-based compute resources.
- **Reproducibility:** MLflow provides easy tracking of experiments and results.
- **Fast Deployment:** Host your model with a single command on the MLflow server.


## 📌 Personal Situation
Learning about Terraform, Azure ML and MLflow and applying it in this project was done in 2 weeks.

## 🤝 Connect with me!
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/gerrit-geeraerts-143488141)
[![Stack Overflow](https://img.shields.io/badge/-Stackoverflow-FE7A16?style=for-the-badge&logo=stack-overflow&logoColor=white)](https://stackoverflow.com/users/10213635/gerrit-geeraerts)
[![Ask Ubuntu](https://img.shields.io/badge/-Askubuntu-dd4814?style=for-the-badge&logo=ubuntu&logoColor=white)](https://askubuntu.com/users/1097288/gerrit-geeraerts)
