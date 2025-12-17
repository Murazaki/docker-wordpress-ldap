ARG WORDPRESS_VERSION="6.9.0"
ARG PHP_VERSION="8.4"
ARG PHPCGI_PROVIDER="apache"

FROM wordpress:${WORDPRESS_VERSION}-php${PHP_VERSION}-${PHPCGI_PROVIDER}

ARG WORDPRESS_VERSION
ARG PHP_VERSION
ARG PHPCGI_PROVIDER

RUN <<-EOF
	set -x 
	if [[ $PHPCGI_PROVIDER == *"alpine"* ]]; then
		# ldap lib \
		apk add --update --no-cache \
			libldap && \
			# Dependencies to build ldap \
			apk add --update --no-cache --virtual .php-ldap-deps \
			openldap-dev && \
			docker-php-ext-configure ldap && \
			docker-php-ext-install ldap && \
			apk del .php-ldap-deps && \
			php -m;
	else
		apt-get update \
			&& apt-get install -y --no-install-recommends libldap2-dev \
			&& rm -rf /var/lib/apt/lists/* \
			&& docker-php-ext-configure ldap --with-libdir=lib/$(uname -m)-linux-gnu/ \
			&& docker-php-ext-install ldap \
			&& apt-get purge -y --auto-remove libldap2-dev
	fi
EOF

COPY custom.ini $PHP_INI_DIR/conf.d/
