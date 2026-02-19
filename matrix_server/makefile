ENV_FILE ?= dev.env
include $(ENV_FILE)
# docker commands
compose_up:
	docker compose --env-file $(ENV_FILE) up -d	
compose_down:
	docker compose --env-file $(ENV_FILE) down
compose_logs:
	docker logs -f synapse-server	
exec:
	docker exec -it synapse-server bash
# dev commands: port forwarding for physical device development
forward_up:
	bash commands/port_forwarding.sh up
forward_down:
	bash commands/port_forwarding.sh down

#matrix commands: creates an admin user
matrix_create_admin:
	docker exec -it synapse-server register_new_matrix_user http://localhost:${SYNAPSE_HOST_PORT} -c /configuration/homeserver.yaml --admin
matrix_create_room:
	bash commands/matrix/create_room.sh	
matrix_list_rooms:
	bash commands/matrix/list_rooms.sh
matrix_delete_room:
	bash commands/matrix/delete_room.sh
matrix_list_users:
	bash commands/matrix/list_users.sh
matrix_create_default_spaces:
	bash commands/matrix/create_default_spaces.sh
matrix_add_child:
	bash commands/matrix/add_child.sh < /dev/tty > /dev/tty