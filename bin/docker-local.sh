PROJECT=${PROJECT-$(cd $1 && pwd -P)}
TMP=${TMP-$(mktemp -d)}
docker build -t nvd:latest .
docker run \
       --workdir /github/workspace \
       -v "${TMP}":"/github/home" \
       -v "${PROJECT}":"/github/workspace" \
       -e DIRECTORIES \
       -e BUILD_TOOL \
       -e GITHUB_TOKEN \
       -e SSH_PRIVATE_KEY \
       -e AWS_ACCESS_KEY_ID \
       -e AWS_SECRET_ACCESS_KEY \
       nvd:latest
