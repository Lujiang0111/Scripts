# ollama大模型

> 参考资料：
>
> <https://hub.docker.com/r/ollama/ollama>
>
> <https://github.com/open-webui/open-webui>

## 创建目录

```shell
# config dir
rm -rf /mnt/ssd/docker/ollama
mkdir -p /mnt/ssd/docker/ollama
chmod 777 /mnt/ssd/docker/ollama
rm -rf /mnt/ssd/docker/open-webui
mkdir -p /mnt/ssd/docker/open-webui
chmod 777 /mnt/ssd/docker/open-webui
```

## Docker compose

```yaml
services:
  ollama:
    volumes:
      - /mnt/ssd/docker/ollama:/root/.ollama
    container_name: ollama
    restart: unless-stopped
    image: ollama/ollama:latest
    ports:
      - 51434:11434
    environment:
      - OLLAMA_KEEP_ALIVE=30m
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    volumes:
      - /mnt/ssd/docker/open-webui:/app/backend/data
    ports:
      - 51435:8080
    environment:
      - OLLAMA_BASE_URLS=http://host.docker.internal:51434
      - WEBUI_SECRET_KEY=
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped
```

## 部署模型

+ 在<https://ollama.com>上查阅模型列表，这里以`deepseek-r1:32b-qwen-distill-q4_K_M`为例：

```shell
docker exec -it ollama ollama run deepseek-r1:32b-qwen-distill-q4_K_M
```

## open-webui地址

```shell
http://IP:51435
```
