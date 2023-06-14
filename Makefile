.PHONY: deploy destroy output provision connect ping

deploy:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy

output:
	cd terraform && terraform output

provision:
	cd ansible && ansible-playbook oci_main.yml

connect:
	ssh -F .ssh/config wireguard

ping:
	cd ./ansible && ansible oci -m ping