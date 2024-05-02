set password_encryption=md5;

CREATE USER dart WITH SUPERUSER PASSWORD 'dart';
CREATE USER darttrust WITH SUPERUSER ;
CREATE DATABASE dart_test;
GRANT ALL PRIVILEGES ON DATABASE dart_test TO dart;
ALTER USER postgres with PASSWORD 'dart';
ALTER USER dart with PASSWORD 'dart';