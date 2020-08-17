# Ver: 1.1 by Endial Fang (endial@126.com)
#
# 当前 Docker 镜像的编译脚本

app_name := colovu/keepalived

# 生成镜像TAG，类似：<镜像名>:<分支名>-<Git ID>  或 <镜像名>:latest-<年月日>-<时分秒>
current_subversion:=$(shell if [[ -d .git ]]; then git rev-parse --short HEAD; else date +%y%m%d-%H%M%S; fi)
current_tag:=$(shell if [[ -d .git ]]; then git rev-parse --abbrev-ref HEAD | sed -e 's/master/latest/'; else echo "latest"; fi)-$(current_subversion)

# Sources List: default / tencent / ustc / aliyun / huawei
build-arg:=--build-arg apt_source=tencent

# 设置本地下载服务器路径，加速调试时的本地编译速度
local_ip:=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $$2}'|tr -d "addr:"`
build-arg+=--build-arg local_url=http://$(local_ip)/dist-files/

.PHONY: build clean clearclean

build:
	@echo "Build $(app_name):$(current_tag)"
	@docker build --force-rm $(build-arg) -t $(app_name):$(current_tag) .
	@echo "Add tag: $(app_name):latest"
	@docker tag $(app_name):$(current_tag) $(app_name):latest

# 清理悬空的镜像（无TAG）及停止的容器 
clean:
	@echo "Clean untaged images and stoped containers..."
	@docker ps -a | grep "Exited" | awk '{print $$1}' | xargs docker rm
	@docker images | grep '<none>' | awk '{print $$3}' | xargs docker rmi -f

clearclean: clean
	@echo "Clean all images for current application..."
	@docker images | grep "$(app_name)" | awk '{print $$3}' | xargs docker rmi -f
