#docker run -it --rm -v "%cd%:/workspace" --entrypoint sh 
#docker run -it --rm -v "%cd%:/workspace" ./cmd.sh
FROM hashicorp/terraform:1.9.8

WORKDIR /workspace
RUN apk add --no-cache aws-cli jq
ENTRYPOINT /bin/sh