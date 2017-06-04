create database if not exists ${DB};
use ${DB};

drop table if exists customer;
insert into customer as select * from ${SOURCE}.customer;

