
drop table t1 cascade;
drop table _bak_t1 cascade;

create table t1(c1 int PRIMARY KEY)
PARTITION BY RANGE(c1)
(
    PARTITION P1 VALUES LESS THAN (2000),
    PARTITION P2 VALUES LESS THAN (3000),
    PARTITION P3 VALUES LESS THAN (4000),
    PARTITION P4 VALUES DEFAULT
);