--drop table tb_Clients;
--drop table tb_Treaty;
--drop table tb_Treaty_Systems;
--drop table tb_Client_Status;

create table tb_Treaty_Systems(
	id	integer		not null,
	Name	varchar(50)	not null,
	primary key (id)
);

create table tb_Client_Status(
	id	integer		not null,
	Name	varchar(50) 	not null,
	primary key (id)
);

create table tb_Clients(
	id		integer		not null,
	fname		varchar(50) 	not null,
	mname		varchar(50) 	not null,
	lname		varchar(50) 	not null,
	RiskLevel	smallint	not null,
	Date_from	date		not null,
	Date_to		date		not null,
	Date_birth	date		not null,
	Status		integer		not null,
	primary key (id),
	constraint FK_tb_Client_Status foreign key (Status)
	references tb_Client_Status(id)
);

create table tb_Treaty(
	id		integer			not null,
	ClientId	integer			not null,
	SystemId	integer			not null,
	Rate		numeric(18,2)		not null,
	Closed		bit			not null,
	Amount		numeric(18,2)		not null,
	CCY		char(3)			null,
	ExRate		numeric(18,2)		null,
	primary key (id),
	constraint FK_tb_Clients foreign key (ClientId)
	references tb_Clients(id),
	constraint FK_tb_Treaty_System foreign key (SystemId)
	references tb_Treaty_Systems(id)
);
