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

val="${USE_BUILTIN_CONFIG:-}"

if [ "$val" = "true" ] || [ "$val" = "TRUE" ] || [ "$val" = "1" ]; then
    cp /etc/opencode-base.jsonc /home/www-data/.config/opencode/opencode.jsonc
fi

PHP_IMAGE=""
PROJECT_NETWORK=""
PROJECT_NETWORK_FULL_NAME=""

if [ -n "$PHP_CONTAINER" ]; then
    PHP_IMAGE=$(docker ps -a --format '{{.Image}}' --filter "name=${PHP_CONTAINER}" | head -n 1)

    if [ -z "$PHP_IMAGE" ]; then
        PHP_IMAGE=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep "${PHP_CONTAINER}" | head -n 1)
    fi
fi

if [ -n "$PROJECT_NETWORK" ]; then
    PROJECT_NETWORK_FULL_NAME=$(docker network ls --format '{{.Name}}' | grep ${PROJECT_NETWORK} )
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

val="${INSTALL_OPENWIKI:-}"
if [ -n "$val" ] && [ "$val" != "false" ] && [ "$val" != "FALSE" ] && [ "$val" != "0" ]; then
    # Check if OpenWiki is already installed
    if command -v openwiki >/dev/null 2>&1; then
        OPENWIKI_VERSION=$(openwiki --version 2>/dev/null || true)

        echo -e "\nOpenWiki is already installed: ${OPENWIKI_VERSION}"
    else
        echo -e "\nInstalling OpenWiki..."

        if npm install -g openwiki@latest; then
            echo -e "\nOpenWiki installed successfully."

            OPENWIKI_VERSION=$(openwiki --version 2>/dev/null || true)

            if [ -n "$OPENWIKI_VERSION" ]; then
                echo "Installed version: ${OPENWIKI_VERSION}"
            fi
        else
            echo -e "\nFailed to install OpenWiki."
            exit 1
        fi
    fi
else
  echo -e "\nSkipping OpenWiki installation."
fi


val="${INSTALL_OPENCHAMBER:-}"
if [ -n "$val" ] && [ "$val" != "false" ] && [ "$val" != "FALSE" ] && [ "$val" != "0" ]; then
    # Check if OpenChamber is already installed
    if command -v openchamber >/dev/null 2>&1; then
        OPENCHAMBER_VERSION=$(openchamber --version 2>/dev/null)

        echo "OpenChamber is already installed: ${OPENCHAMBER_VERSION}"
    else
        echo "OpenChamber is not installed. Installing..."

        if npm install -g @openchamber/web; then
            echo "OpenChamber installed successfully."

            OPENCHAMBER_VERSION=$(openchamber --version 2>/dev/null || true)

            if [ -n "$OPENCHAMBER_VERSION" ]; then
                echo "Installed version: ${OPENCHAMBER_VERSION}"
            fi
        else
            echo "Failed to install OpenChamber."
            exit 1
        fi
    fi

    # Start OpenChamber
    if [ -n "$OPENCHAMBER_UI_PASSWORD" ]; then
        openchamber \
            --lan \
            --port "${OPENCHAMBER_PORT}" \
            --ui-password "${OPENCHAMBER_UI_PASSWORD}"
    else
       echo -e "\nYou must define the `OPENCHAMBER_UI_PASSWORD` before starting OpenChamber."
    fi

else
  echo -e "\nSkipping OpenChamber installation."
fi

# keep container alive
exec "$@"