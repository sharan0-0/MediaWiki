# MEDIAWIKI PROBLEM STATEMENT

All the Code used and written in this repo are solely written by me and used all the opensoruce tools like Terraform and Ansible for IAAC and SCM

# Problem Statement
The problem statement was to build a complete End to End deployment of [MEDIAWIKI](https://www.mediawiki.org/wiki/MediaWiki) app with Infrastructure Up and Running and Software Configuration Integrated with it on the fly.

>  ### Terraform or any IaC tool with any Configuration Management tool integrated.

---

# Approach

The approach to solve the above problem was to use the most common IAAC tool `Terraform` with `Ansible` on top of it to setup infra and setup necessary utilities to make the application up and running

## Tools and Technologies Used
This Technologies used in this deployment is
* Yaml Scripting
* Python
* Shell Scripting
* Terraform
* Ansible Playbooks

# Installation

### Install Terraform

To install Terraform, find the [appropriate package](https://www.terraform.io/downloads.html) for your system and download it as a zip archive.

# :rocket: Launch
To get App up and running follow the below to launch your application `mediawiki` and the complete end to end infra setup

## Git clone

1. Clone the following Repo

```
git clone https://github.com/sharan0-0/MediaWiki.git

cd MediaWiki
```

2. Run the following command to run the `terraform` code

```
terraform init

terraform plan 

terraform apply -auto-approve


```
