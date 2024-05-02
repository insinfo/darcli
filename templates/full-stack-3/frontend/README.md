#  Frontend


# desabilitar Sticky Scroll no Visual Studio Code


dart compile js -O0 -o build/web/main.dart.js web/main.dart


### If you have a build.yaml file, you can explicitly disable minification:

```yaml
targets:
  $default:
    builders:
      build_web_compilers|entrypoint:
        options:
          dart2js_args:
            - --no-minify
            - -O0

```

