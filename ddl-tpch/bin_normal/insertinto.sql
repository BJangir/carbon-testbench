create database if not exists ${DB};
use ${DB};

drop table if exists ${TABLENAME};

insert into ${TABLENAME} as select * from ${SOURCE}.${TABLENAME};
