CREATE TABLE todo (
	id BIGINT NOT NULL AUTO_INCREMENT,
	checked bit(1),
	description varchar(255),
	PRIMARY KEY (id)
);

insert into todo (checked, description) values (0, 'Roll an immense boulder up a hill.');
insert into todo (checked, description) values (1, 'Roll an immense boulder down a hill.');