.PHONY: build show clean push phpv rebuild check php

build: php

check: Dockerfile docker-php-entrypoint docker-php-ext-configure docker-php-ext-enable docker-php-ext-install
	@docker ps >/dev/null

rebuild: clean build

php: check 5.2.4 5.2.5 5.2.6 5.2.8 5.2.9 5.2.10 5.2.11 5.2.12 5.2.13 5.2.14 5.2.15 5.2.16 5.2.17 5.3.0 5.3.1 5.3.2 5.3.3 5.3.4 5.3.5 5.3.6 5.3.7 5.3.8 5.3.9 5.3.10 5.3.11 5.3.12 5.3.13 5.3.14 5.3.15 5.3.16 5.3.17 5.3.18 5.3.19 5.3.20 5.3.21 5.3.22 5.3.23 5.3.24 5.3.25 5.3.26 5.3.27 5.3.28 5.3.29 5.4.0 5.4.1 5.4.2 5.4.3 5.4.4 5.4.5 5.4.6 5.4.7 5.4.8 5.4.9 5.4.10 5.4.11 5.4.12 5.4.13 5.4.14 5.4.15 5.4.16 5.4.17 5.4.18 5.4.19 5.4.20 5.4.21 5.4.22 5.4.23 5.4.24 5.4.25 5.4.26 5.4.27 5.4.28 5.4.29 5.4.30 5.4.31 5.4.32 5.4.33 5.4.34 5.4.35 5.4.36 5.4.37 5.4.38 5.4.39 5.4.40 5.4.41 5.4.42 5.4.43 5.4.44 5.4.45 5.5.0 5.5.1 5.5.2 5.5.3 5.5.4 5.5.5 5.5.6 5.5.7 5.5.8 5.5.9 5.5.10 5.5.11 5.5.12 5.5.13 5.5.14 5.5.15 5.5.16 5.5.17 5.5.18 5.5.19 5.5.20 5.5.21 5.5.22 5.5.23 5.5.24 5.5.25 5.5.26 5.5.27 5.5.28 5.5.29 5.5.30 5.5.31 5.5.32 5.5.33 5.5.34 5.5.35 5.5.36 5.5.37 5.5.38 5.6.0 5.6.1 5.6.2 5.6.3 5.6.4 5.6.5 5.6.6 5.6.7 5.6.8 5.6.9 5.6.10 5.6.11 5.6.12 5.6.13 5.6.14 5.6.15 5.6.16 5.6.17 5.6.18 5.6.19 5.6.20 5.6.21 5.6.22 5.6.23 5.6.24 5.6.25 5.6.26 5.6.27 5.6.28 5.6.29 5.6.30
#	docker build -t t4cc0re/legacy-php:5.3 --pull --no-cache .
#	docker build -t t4cc0re/legacy-php:5.2 --pull --no-cache --build-arg PHP_VERSION="5.2.17" .

show:
	@docker images -a t4cc0re/legacy-php; exit 0

clean:
	@docker rmi --force `docker images -q t4cc0re/legacy-php` 2> /dev/null; exit 0
	@rm -f ./5.*

push:
	@docker push t4cc0re/legacy-php

phpv:
	docker run -it t4cc0re/legacy-php:5.2 php -v
	docker run -it t4cc0re/legacy-php:5.3 php -v

# >= 5.2.4
5.%: check
	docker build -t t4cc0re/legacy-php:$@ --pull --no-cache --build-arg PHP_VERSION="$@" . | tee $@.log
	touch $@

