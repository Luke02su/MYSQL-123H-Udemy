ALTER TABLE CLIENTE2.SUPPLIER ENGINE = MYISAM;
alter table product drop constraint fk_product_Supplier1;
set foreign_key_checks = 0;
set foreign_key_checks = 1;
describe product;
ALTER TABLE CLIENTE2.SUPPLIER ENGINE = INNODB;

alter table cliente2.product 
ADD constraint fk_product_Supplier1 FOREIGN KEY (supplierid) REFERENCES supplier(id) ON UPDATE CASCADE ON DELETE CASCADE;

select * from product;
select * from supplier;
