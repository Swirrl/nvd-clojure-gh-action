set -e

if [ -n "${SSH_PRIVATE_KEY}" ]; then
    mkdir -p ~/.ssh
    eval $(ssh-agent)
    echo -e "${SSH_PRIVATE_KEY}\n" | ssh-add -
    ssh-keyscan github.com >> ~/.ssh/known_hosts
fi

if [ -z "$DIRECTORIES" ]; then
    cd /nvd
    CREATE_ISSUE=true bin/nvd-clojure.sh /github/workspace
else
    for dir in $DIRECTORIES; do
        cd /nvd
         CREATE_ISSUE=true PROJECT=$dir bin/nvd-clojure.sh /github/workspace/$dir
    done
fi
