.PHONY: deploy destroy provision connect

deploy:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy

provision:
	cd ansible && ansible-playbook oci_main.yml

connect:
	ssh -F .ssh/config wireguard