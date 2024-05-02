# darcli - A Dart project generator

<!-- ![darcli banner](https://raw.githubusercontent.com/insinfo/darcli/master/site/banner_darcli.jpg) -->

[![Pub package](https://img.shields.io/pub/v/darcli.svg)](https://pub.dev/packages/darcli)

<!-- [![Coverage status](https://coveralls.io/repos/insinfo/darcli/badge.svg?branch=master)](https://coveralls.io/r/insinfo/darcli?branch=master) -->


## Helps you get set up!

darcli helps you get your Dart projects set up and ready for the big show.
It's a Dart project scaffolding generator, inspired by tools like Web Starter
Kit and Yeoman.

Dart-savvy IDEs and editors use darcli behind the scenes to get project templates,
but you can also use darcli on the command line (`darcli`).

## darcli templates
* `console-simple` - A simple command-line application.
* `console-full` - A command-line application sample.
* `package-simple` - A starting point for Dart libraries or applications.
* `server-shelf` - A web server built using the shelf package.
* `web-angular` - A web app with material design components.
* `web-simple` - A web app that uses only core Dart libraries.
* `web-stagexl` - A starting point for 2D animation and games.

## Installation

If you want to use darcli on the command line,
install it using `pub global activate`:

```console
> dart pub global activate darcli
```

To update darcli, use the same `dart pub global activate` command.

## Usage

darcli generates a project skeleton into the current directory.
For example, here's how you create a package with darcli:

```console
> mkdir fancy_project
> cd fancy_project
> darcli package-simple
```

Here's how you list all of the project templates:

```console
> darcli
```

## Goals

* Opinionated and prescriptive; minimal to no options
* Support for server and client apps
* The best way to create a new Dart project
* Distributed as a pub package

## Issues and bugs

Please file reports on the
[GitHub issue tracker](https://github.com/insinfo/darcli/issues).

