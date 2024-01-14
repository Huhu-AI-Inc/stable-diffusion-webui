DevAccount := 146525178697
Port := 5000
Region := us-west-2
Stage := prod
GPU_ID := 7
ServiceName := huhuai-prod-inf-api-t2i-${MODEL_NAME}-selfhost
ContainerImageName := ${DevAccount}.dkr.ecr.${Region}.amazonaws.com/${ServiceName}:latest

.PHONY: build
build:
	docker build -f Dockerfile -t ${ContainerImageName} .

.PHONY: run
run:
	docker run -d \
        	--name 't2i-gpu-${GPU_ID}' \
	  	--env AWS_ACCOUNT_ID='${DevAccount}' \
	  	--env MODEL_NAME=${MODEL_NAME} \
		--env LOAD_TILE=${LOAD_TILE} \
        	--env CUDA_VISIBLE_DEVICES=${GPU_ID} \
		--env REGION=${Region} \
		--env GPU_ID=${GPU_ID} \
	  	-v ~/.aws:/root/.aws \
	  	-p ${Port}:5000 --gpus all ${ContainerImageName}

.PHONY: push
push:
	aws ecr get-login-password --region ${Region} | docker login --username AWS --password-stdin ${DevAccount}.dkr.ecr.${Region}.amazonaws.com
	docker push ${ContainerImageName}

.PHONY: clean
clean:
	docker rmi -f $$(sudo docker images | grep ${ServiceName} | awk '{print $$3}')
	rm -rf packages
