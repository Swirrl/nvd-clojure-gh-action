docker build -t nvd:latest -f Dockerfile.example .
docker run \
       -e SSH_PRIVATE_KEY="$(cat gh_id_rsa)" \
       -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
       -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
       nvd:latest
