
# 
```console
 dbtoyaml -H localhost -p 5435 -U dart -W -n public -o teste.yaml --no-owner --no-privileges banco_teste 
 yamltodb -H localhost -p 5435 -U dart -W -n public -o teste.sql banco_teste2 teste.yaml
 psql -h localhost -p 5435 -U dart -W -f teste.sql  banco_teste2

```