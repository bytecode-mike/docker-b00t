CREATE TABLE item (
	id BIGINT NOT NULL AUTO_INCREMENT,
	checked bit(1),
	description varchar(255),
	PRIMARY KEY (id)
);

insert into item (checked, description) values (0, 'When the stars threw down their spears ');
insert into item (checked, description) values (0, 'And water-d heaven with their tears:');
insert into item (checked, description) values (0, 'Did he smile his work to see?  ');
insert into item (checked, description) values (0, 'Did he who made the Lamb make thee?  ');