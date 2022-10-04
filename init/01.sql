CREATE USER  IF NOT EXISTS repl_user@'%' identified by 'P@ssw0rd';
GRANT ALL ON *.* to repl_user@'%';

CREATE USER IF NOT EXISTS app_user@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO app_user@'%';

CREATE USER IF NOT EXISTS maxuser@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO maxuser@'%';

CREATE DATABASE IF NOT EXISTS securedb;
USE securedb;
CREATE TABLE IF NOT EXISTS employee (id serial, nric varchar(15), name varchar(50), phone varchar(30), ts timestamp(6));
TRUNCATE TABLE employee;
INSERT INTO employee (nric, name, phone) values ('S7162688Z', 'James Bond', '91865991'),
                                                ('S8495678J', 'Bugs Bunny', '81931133'),
                                                ('S6866688F', 'Indiana Jones', '90065111'),
                                                ('S9712622G', 'Daffy Duck', '81110001'),
                                                ('S6562345X', 'John Carter', '99965312');

CREATE TABLE products(id serial, c varchar(100));