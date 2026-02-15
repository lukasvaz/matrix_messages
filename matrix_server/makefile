include dev.env
# docker commands
compose_up:
	docker compose --env-file ./dev.env up -d 
compose_down:
	docker compose --env-file ./dev.env down
logs:
	docker logs -f synapse-server	
exec:
	docker exec -it synapse-server bash
# dev commands: port forwarding for physical device development
forward_up:
	bash commands/port_forwarding.sh up
forward_down:
	bash commands/port_forwarding.sh down

#matrix commands: creates an admin user
create_admin:
	docker exec -it synapse-server register_new_matrix_user http://localhost:${SYNAPSE_HOST_PORT} -c /configuration/homeserver.yaml --admin
