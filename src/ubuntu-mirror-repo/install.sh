#!/bin/sh
set -e

echo "Activating feature 'ubuntu-mirror-repo'"
echo "The provided mirror is: ${MIRROR}"


# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

cat > /usr/local/bin/using-mirror-repo \
<< EOF
#!/bin/sh
#!/bin/sh
echo "The mirror is ${MIRROR}"

if [ -z "$MIRROR" ]; then
    echo "Mirror should not be empty."
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine the os version"
    exit 1
fi

if [ "$NAME" != "Ubuntu" ]; then
    exit 1
fi

if test "$VERSION_ID" \< "24.04"; then
    echo "sed -i \"s#http://archive.ubuntu.com#${MIRROR}#g\" /etc/apt/sources.list"
    echo "sed -i \"s#http://security.ubuntu.com#${MIRROR}#g\" /etc/api/sources.list"
else
    echo "sed -i \"s#http://archive.ubuntu.com#${MIRROR}#g\" /etc/apt/sources.list.d/ubuntu.sources"
    echo "sed -i \"s#http://security.ubuntu.com#${MIRROR}#g\" /etc/api/sources.list.d/ubuntu.sources"
fi
EOF

chmod +x /usr/local/bin/using-mirror-repo
