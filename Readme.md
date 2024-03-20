# Construindo a imagem Docker

Para construir a imagem Docker, você precisa ter o Docker instalado em sua máquina. Depois de instalado, você pode construir a imagem usando o seguinte comando no terminal:

```
docker build -t <your user>/php-8.2-apache:latest .
```

Isso irá construir a imagem Docker e marcará a imagem com a tag `<your user>/php-8.2-apache:latest`.

# publicando a imagem Docker

Depois de construir a imagem, você pode publicá-la no Docker Hub. Para fazer isso, você precisa fazer login no Docker Hub usando o seguinte comando:

```
docker login
```

Depois de fazer login, você pode publicar a imagem usando o seguinte comando:

```
docker push <your user>/php-8.2-apache:latest
```
