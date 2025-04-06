# AI Summary Assistant Makefile

dev:
	docker-compose up --build backend frontend

prod:
	docker-compose down -v --remove-orphans
	docker-compose build
	docker-compose up -d

clean:
	docker-compose down -v --remove-orphans

clean-all:
	docker stop $$(docker ps -aq) || true
	docker rm $$(docker ps -aq) || true
	docker rmi -f $$(docker images -q) || true
	docker volume prune -f
	docker network prune -f
