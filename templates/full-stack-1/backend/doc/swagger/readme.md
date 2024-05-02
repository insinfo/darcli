para gerar os arquivos do swagger automaticamente 
instalar o mitmproxy web https://mitmproxy.org/
fazer a captura e depois usar o mitmproxy2swagger https://github.com/alufers/mitmproxy2swagger#mitmproxy
para gerar o arquivo swagger_gen usar o mitmproxy2swagger assim

```console
-i .\flows -o ./swagger_gen.yaml  -p http://localhost:3350/api/v1 -f flow
```

edite o arquivo swagger_gen.yaml e remova o ignore: prefixo e depois execute novamente 

```console
-i .\flows -o ./swagger_gen.yaml  -p http://localhost:3350/api/v1 -f flow
```
