CREATE USER  IF NOT EXISTS repl_user@'%' identified by 'P@ssw0rd';
GRANT ALL ON *.* to repl_user@'%';
CREATE DATABASE IF NOT EXISTS `testdb`;
CREATE USER IF NOT EXISTS app_user@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO app_user@'%';
CREATE USER IF NOT EXISTS maxuser@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO maxuser@'%';
CREATE DATABASE IF NOT EXISTS testdb;
CREATE TABLE IF NOT EXISTS testdb.tab(id serial, c1 varchar(100), ts timestamp);
