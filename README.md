# Azure VM Bootstrap

Infrastructure bootstrap and SSH hardening for an Ubuntu VM in Azure.

The project provisions a virtual machine with explicit networking,
applies SSH key-based access (no passwords),
and deploys a basic nginx setup with a Docker-backed service.

## What this project does

- Creates Azure VM with explicit Resource Group, VNet, Subnet and NSG
- Disables SSH password authentication (key-only access)
- Applies Ubuntu-safe SSH hardening
- Bootstraps nginx and Docker on the VM
- Keeps the setup reproducible and script-driven

## Project structure

config/
- variables and defaults
- helper functions (no direct execution)

scripts/
- provisioning and configuration steps
- executed by the main entrypoint script

cloud-init/
- cloud-init templates (optional / future use)

VMdeploy.sh
- main entrypoint script
- orchestrates provisioning and bootstrap steps

## Requirements

- Azure CLI
- Bash
- SSH key configured (`~/.ssh`)
- Access to an Azure subscription

## Usage

bash ./VMdeploy.sh


