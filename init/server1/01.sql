CREATE USER  IF NOT EXISTS repl_user@'%' identified by 'P@ssw0rd';
GRANT ALL ON *.* to repl_user@'%';

CREATE USER IF NOT EXISTS app_user@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO app_user@'%';

CREATE USER IF NOT EXISTS maxuser@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO maxuser@'%';
