Commands:
docker buildx create --name buildkit-lab6 --driver docker-container --driver-opt image=moby/buildkit:latest
docker buildx use buildkit-lab6

docker buildx build --ssh lab6_ssh=../lab6_ssh --tag ghcr.io/mediasm/pawcho6:lab6 --push .
