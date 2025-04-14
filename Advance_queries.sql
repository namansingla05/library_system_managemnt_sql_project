-- some advance queries
-- for this advance query we need some new rows that are of near date and need to add some new column
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');
 
ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');


UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;

select * from books;

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name,
book title, issue date, and days overdue.*/
select m.member_id,m.member_name,
b.book_title,ist.issued_date,rst.return_date,
case 
	when rst.return_date is null then current_date - ist.issued_date
	else rst.return_date - ist.issued_date 
	End as days_overdue
from members as m
join issued_status as ist
on m.member_id=ist.issued_member_id
left join return_status as rst
on ist.issued_id=rst.issued_id
join books as b
on ist.issued_book_isbn=b.isbn
where (CASE 
        WHEN rst.return_date IS NULL THEN CURRENT_DATE - ist.issued_date
        ELSE rst.return_date - ist.issued_date 
    END) > 30;


/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are
returned (based on entries in the return_status table).*/


select * from issued_status;
select * from books 
where isbn ='978-0-141-44171-6';

update books
set status='no'
where isbn='978-0-141-44171-6';
--now the book is returned buy status is no now on the basis of return we need to chnage this to yes

select * from issued_status
where issued_book_isbn='978-0-141-44171-6';

--now lets see this is returned or not

select * from return_status 
where issued_id='IS109';

update books
set status='yes'
where isbn='978-0-141-44171-6';
--book is returned and the book status is still showing no so we need to change this

--store procedure(when ever some enter the record in return table then it should be updated in books table also)


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
--variables datatype shoul be same even size 
LANGUAGE plpgsql --part of syntax
AS $$ --part of suntax
--evry line we need to use semicolon

DECLARE 
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO --storing temp variables into the temp var that was declared on the top in declare section
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;  --print like statement
    
END;
$$


-- Testing FUNCTION add_return_records

--issued_id = IS135;  storing for the refrence checked the book which status is no and not returned
--ISBN = WHERE isbn = '978-0-307-58837-1';

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals.*/

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 2 months*/
create table active_members as 
select m.*
from members as m
join issued_status as ist
on m.member_id=ist.issued_member_id
where current_date - interval '2 month' <= ist.issued_date;

select * from active_members;

--we can do it like this also
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2 order by no_book_issued desc;

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books equal to or more than twice with the status "damaged" in the books table.
Display the member name, and the number of times they've issued damaged books.*/

--we can show the damaged book title by using this as suquery
select m.*,count(ist.issued_id) as count_of_damaged_status
from issued_status as ist 
join members as m
on ist.issued_member_id=m.member_id
join return_status as rst
on ist.issued_id=rst.issued_id
where rst.book_quality='Damaged'
group by 1 having count(ist.issued_id)>=2;

--we can see that no one has returned the book with damagwed status with 2 or more than 2 times
select * from return_status;
select * from issued_status;

update return_status 
set book_quality='Damaged'
where issued_id='IS113';

update return_status 
set book_quality='Damaged'
where issued_id='IS110';

/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). If the book is available,
it should be issued, and the status in the books table should be updated to 'no'.If the book is not available (status = 'no'),
the procedure should return an error message indicating that the bookis currently not available.*/

CREATE OR REPLACE PROCEDURE stored(p_isbn varchar(20),p_issued_id varchar(10),p_issued_member_id varchar(10),p_issued_emp_id varchar(10))
LANGUAGE plpgsql
AS $$

DECLARE
	v_status VARCHAR(10);
	v_book_name varchar(75);
BEGIN
	select status from books where 
	isbn=p_isbn into v_status;

	select book_title from books where
	isbn=p_isbn into v_book_name;
	
	if v_status='yes' then 
	INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
	values
	(p_issued_id,p_issued_member_id,v_book_name,current_date,p_isbn,p_issued_emp_id);

	update books set status = 'no'
	where isbn=p_isbn;

	RAISE NOTICE 'Book records added successfully for book isbn : %', p_isbn;
	
	else
	RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_name: %', v_book_name; 
	end if;
	
END;
$$

SELECT * FROM books;
--"978-0-19-280551-1"
--"978-0-375-41398-8"
select * from issued_status;

call stored('978-0-19-280551-1','IS155','C101','E108');
call stored('978-0-375-41398-8','IS156','C102','E109');

select * from books where isbn = '978-0-19-280551-1';

/*Task 20: Create Table As Select(CTAS) Objective: Create a CTAS query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but
not returned within 30 days. The table should include: The number of overdue books. The total fines, with each
day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines*/

Drop table if exists overdue_books;
CREATE TABLE overdue_books AS
SELECT 
    m.member_id,
    m.member_name,
    COUNT(ob.issued_id) AS overdue_books_count,
    SUM(ob.days_overdue * 0.50) AS total_fine
FROM (
    SELECT 
        ist.issued_id,
        ist.issued_member_id,
        CASE 
            WHEN rst.return_date IS NULL THEN CURRENT_DATE - ist.issued_date
            ELSE rst.return_date - ist.issued_date
        END AS days_overdue
    FROM issued_status AS ist
    LEFT JOIN return_status AS rst ON ist.issued_id = rst.issued_id
    WHERE 
        (CASE 
        WHEN rst.return_date IS NULL THEN CURRENT_DATE - ist.issued_date
        ELSE rst.return_date - ist.issued_date 
    END) > 30
) AS ob
JOIN members AS m ON m.member_id = ob.issued_member_id
GROUP BY m.member_id, m.member_name;

select * from overdue_books;
