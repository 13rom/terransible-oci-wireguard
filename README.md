# Wireguard on Oracle Cloud Infrastructure (OCI)

This project contains Terraform configuration files and Ansible playbook for deploying a containerized Wireguard VPN server to an always-free OCI instance. Wireguard container includes both the server and the WireGuard Easy web user interface.

## Requirements

Before starting, create an Oracle Cloud Account and gather the following information:
  * Oracle API signing key
  * User OCID
  * Tenancy OCID
  * Compartment OCID
  * Oracle Region and Free Tier Availability Domain

Next, go to the `./terraform` directory, copy the `terraform.tfvars.example` file to `terraform.tfvars` and update **ALL** of the values above the Optional section at the bottom.

## Deploy
1. Run the terraform deploy:
   ```shell
   $ make deploy
   ```
   confirm by typing `yes` and wait for finish. When it is complete you should see a couple of new files:
   ```
   ./ansible/inventory/oci-inventory - ansible host configuration
   ./ansible/files/.env - docker-compose environment variables file
   ./.ssh/config - ssh config for connecting to the server host
   ```

2. Check server availability:
   ```shell
   $ make ping
   ```
   make sure it returns a `pong`

3. Run Ansible software installation and setup:
   ```shell
   $ make provision
   ```

4. Find the Wireguard server Web UI address:
   ```shell
   $ make output
   ...
   wireguard_ui_address = "http://<address>:<port>"
   ```
5. Navigate to `http://<address>:<port>` to set up the VPN clients
