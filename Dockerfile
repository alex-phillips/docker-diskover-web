FROM lsiobase/alpine:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
	php7 \
	php7-curl \
	php7-json \
	php7-mbstring \
	php7-openssl \
	php7-phar \
	php7-session && \
 apk add --no-cache --virtual=build-dependencies \
	git && \
 echo "**** install composer ****" && \
 php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
 php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
 php composer-setup.php && \
 php -r "unlink('composer-setup.php');" && \
 mv composer.phar /usr/bin/composer && \
 /usr/bin/composer self-update && \
 echo "**** install diskover-web ****" && \
 git clone https://github.com/shirosaidev/diskover-web.git /app/diskover-web && \
 echo "**** install composer packages ****" && \
 cd /app/diskover-web && \
 /usr/bin/composer install && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
