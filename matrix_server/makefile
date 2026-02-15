include .env
# port forwarding for physical device development
forward_up:
	bash commands/port_forwarding.sh up
forward_down:
	bash commands/port_forwarding.sh down
# creates an admin user
create_admin:
	docker exec -it synapse-server register_new_matrix_user http://localhost:${SYNAPSE_HOST_PORT} -c /configuration/homeserver.yaml --admin