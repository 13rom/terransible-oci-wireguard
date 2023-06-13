.PHONY: deploy provision connect

deploy:
	cd terraform && terraform apply

provision:
	cd ansible && ansible-playbook oci_main.yml

connect:
	ssh -F .ssh/config wireguard