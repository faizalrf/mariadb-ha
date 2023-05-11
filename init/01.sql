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

CREATE TABLE sales_202301(id serial, c varchar(100), shard_key int default 202301);
CREATE TABLE sales_202302(id serial, c varchar(100), shard_key int default 202302);
CREATE TABLE sales_202303(id serial, c varchar(100), shard_key int default 202303);
CREATE TABLE sales_202304(id serial, c varchar(100), shard_key int default 202304);

INSERT INTO sales_202301(c) values ('Sales for 202301');
INSERT INTO sales_202302(c) values ('Sales for 202302');
INSERT INTO sales_202303(c) values ('Sales for 202303');
INSERT INTO sales_202304(c) values ('Sales for 202304');

CREATE TABLE big_table(id serial, c varchar(100));
INSERT INTO big_table (c) select concat('Data-', seq) from seq_1_to_1000000;
