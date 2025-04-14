-- Library Mangement System 

--creating branch table
drop table if exists branch;
create table branch
(
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_adress varchar(55),
	contact_no varchar(10)
);

drop table if exists employees;
create table employees
(
	emp_id varchar(10) primary key,
	emp_name varchar(25),
	position varchar(15),
	salary int,
	branch_id varchar(10)		--fk
);

drop table if exists books;
create table books
(
	isbn varchar(20) primary key,
	book_title varchar(75),
	category varchar(55),
	rental_price float,
	status varchar(15),
	author varchar(35),
	publisher varchar(55)
);


drop table if exists members;
create table members
(
	member_id varchar(20) primary key,
	member_name varchar(25),
	member_address varchar(75),
	reg_date date
);

drop table if exists issued_status;
CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(10),   	--fk
    issued_book_name VARCHAR(75),
    issued_date DATE,
    issued_book_isbn VARCHAR(25),		--fk
    issued_emp_id VARCHAR(10)			--fk
);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10), --fk
    return_book_name VARCHAR(75),
    return_date DATE,
    return_book_isbn VARCHAR(20)
);

-- FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members  -- fk_members is just a name
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

Alter table books
alter column category type varchar(20)

Alter table branch
alter column contact_no type varchar(20)

ALTER TABLE branch
RENAME COLUMN branch_adress TO branch_address;


