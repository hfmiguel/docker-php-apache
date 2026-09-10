#!/bin/bash

# Check if variable is set and not empty
if [ -n "${GITHUB_ACCESS_TOKEN_MCP}" ]; then
    echo "Token found. Logging in to GitHub CLI..."
    echo "$GITHUB_ACCESS_TOKEN_MCP" | gh auth login --with-token --hostname github.com 2>&1
    gh auth setup-git
    echo "GitHub CLI authentication successful."
else
    echo "Warning: GITHUB_ACCESS_TOKEN_MCP is not set. Skipping GitHub CLI login."
fi

if [ -n "${OPENWIKI_PROVIDER}" ]; then
    echo "Openwiki provider detected. Openwiki will be allowed in the container"
    
    if [ -n "${OPENAI_COMPATIBLE_BASE_URL}" ]; then
      echo "Openwiki provider URL: ${OPENAI_COMPATIBLE_BASE_URL}"
    fi
    
    if [ -n "${OPENWIKI_MODEL_ID}" ]; then
      echo "Openwiki model: ${OPENWIKI_MODEL_ID}"
    fi
else
    echo "Warning: Openwiki provider not detected"
fi


PHP_IMAGE=""

if [ -n "$PHP_CONTAINER" ]; then
    PHP_IMAGE=$(docker ps -a --format '{{.Image}}' --filter "name=${PHP_CONTAINER}" | head -n 1)

    if [ -z "$PHP_IMAGE" ]; then
        PHP_IMAGE=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep "${PHP_CONTAINER}" | head -n 1)
    fi
fi


if [[ -n "$PHP_IMAGE" && -n "$OPENCODE_CONTAINER_NAME" && -n "$PROJECT_NETWORK_FULL_NAME" ]]; then
cat <<EOF > /usr/local/bin/php
#!/bin/sh
exec docker run --rm -i \
--volumes-from ${OPENCODE_CONTAINER_NAME} \
--network ${PROJECT_NETWORK_FULL_NAME} \
--workdir /var/www/project \
--env-file /var/www/project/.env \
"$PHP_IMAGE" php "\$@"
EOF
chmod +x /usr/local/bin/php

cat <<EOF > /usr/local/bin/composer
#!/bin/sh
exec docker run --rm -i \
--volumes-from ${OPENCODE_CONTAINER_NAME} \
--network ${PROJECT_NETWORK_FULL_NAME} \
--workdir /var/www/project \
--env-file /var/www/project/.env \
"$PHP_IMAGE" composer "\$@"
EOF
chmod +x /usr/local/bin/composer

cat <<EOF > /usr/local/bin/pest
#!/bin/sh
exec docker run --rm -i \
--volumes-from ${OPENCODE_CONTAINER_NAME} \
--network ${PROJECT_NETWORK_FULL_NAME} \
--workdir /var/www/project \
--env-file /var/www/project/.env \
"$PHP_IMAGE" vendor/bin/pest "\$@"
EOF
chmod +x /usr/local/bin/pest

cat <<EOF > /usr/local/bin/pint
#!/bin/sh
exec docker run --rm -i \
--volumes-from ${OPENCODE_CONTAINER_NAME} \
--network ${PROJECT_NETWORK_FULL_NAME} \
--workdir /var/www/project \
--env-file /var/www/project/.env \
"$PHP_IMAGE" vendor/bin/pint "\$@" 
EOF
chmod +x /usr/local/bin/pint

cat <<EOF > /usr/local/bin/run_phpcomposer_container
#!/bin/sh
exec docker run --rm -i \
--volumes-from ${OPENCODE_CONTAINER_NAME} \
--network ${PROJECT_NETWORK_FULL_NAME} \
--workdir /var/www/project \
--env-file /var/www/project/.env \
"$PHP_IMAGE" "\$@" 
EOF
chmod +x /usr/local/bin/run_phpcomposer_container

fi

if [ -n "$OPENCHAMBER_UI_PASSWORD" ]; then
  openchamber --lan --port ${OPENCHAMBER_PORT} --ui-password ${OPENCHAMBER_UI_PASSWORD}
fi

# keep container alive
exec "$@"