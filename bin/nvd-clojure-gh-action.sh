set -e

mkdir -p ~/.ssh
eval $(ssh-agent)
echo -e "${SSH_PRIVATE_KEY}\n" | ssh-add -
ssh-keyscan github.com >> ~/.ssh/known_hosts

if [ -z "$DIRECTORIES" ]; then
    cd /nvd
    bin/nvd-clojure.sh /github/workspace
else
    for dir in $DIRECTORIES; do
        cd /nvd
        PROJECT=$dir bin/nvd-clojure.sh /github/workspace/$dir
    done
fi
