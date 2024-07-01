create database test;
use test;

CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);


-- Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.

Select UPPER(name) as Name
from artists


--2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

select title,Sum(total_amount) as Total_Sales
from sales
join artworks on sales.artwork_id=artworks.artwork_id
group by title
having title = 'Mona Lisa';




--3. Write a query to calculate the price of 'Starry Night' plus 10% tax.

select title,price+(price * 0.1) as Price
from artworks
where title = 'Starry Night'





--4. Write a query to extract the year from the sale date of 'Guernica'.
select title,DatePart(Year,sale_date) as Year
from sales 
join artworks on sales.artwork_id=artworks.artwork_id
where title='Guernica';






-- Section 2: 2 marks each

--5. Write a query to display artists who have artworks in multiple genres.

select a.artist_id ,name, a.genre 
from artworks a 
join artworks b on a.artist_id=b.artist_id AND a.genre!=b.genre
join artists on a.artist_id=artists.artist_id



--6. Write a query to find the artworks that have the highest sale total for each genre.

WITH sales_CTE
AS
(
select genre,sales.artwork_id,title,sum(total_amount) as total,
DENSE_RANK() over (partition by genre order by sum(total_amount) DESC) as rank 
from artworks join sales on artworks.artwork_id=sales.artwork_id
group by genre,sales.artwork_id,title
)
Select * from 
sales_CTE
where rank = 1




--7. Write a query to find the average price of artworks for each artist.

select artworks.artist_id,name , AVG(price) as Average
from artworks join artists on artworks.artist_id=artists.artist_id
group by artworks.artist_id,name






--8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
WITH high_CTE
As
(
select  sales.artwork_id,title,price,Sum(quantity) as Total_Quantity
from artworks join sales on artworks.artwork_id=sales.artwork_id
group by sales.artwork_id,title,price
)
select top(2) *
from high_CTE
Order by price DESC



--9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.

Select a.artist_id , name
from artworks a
join sales on a.artwork_id=sales.artwork_id
join artists on artists.artist_id=a.artist_id
where quantity > (Select AVG(Quantity)
                  from artworks b
				  join sales on b.artwork_id=sales.artwork_id
				  where a.artist_id=b.artist_id)





--10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

select artist_id , name ,birth_year
from artists a
where birth_year < (Select Avg(birth_year)
                    from artists b
					Where a.country=b.country)


--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.

select artworks.artist_id,name 
from artworks join artists on artworks.artist_id=artists.artist_id
where genre = 'Cubism'
Intersect
select artworks.artist_id,name 
from artworks join artists on artworks.artist_id=artists.artist_id
where genre = 'Surrealism'



--12. Write a query to find the artworks that have been sold in both January and February 2024.

select sales.artwork_id , title
from sales join artworks on sales.artwork_id=artworks.artwork_id
where format(sale_date,'yyyy-MM') = '2024-01'
Intersect
select sales.artwork_id , title 
from sales join artworks on sales.artwork_id=artworks.artwork_id
where format(sale_date,'yyyy-MM') = '2024-02'




--13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.

select a.Artist_id ,name , Avg(price) as Average
from artworks a join artists on a.artist_id=artists.artist_id
group by a.artist_id,name
having Avg(price) > All(Select price
                        from artworks
						where genre = 'Renaissance')



--14. Write a query to rank artists by their total sales amount and display the top 3 artists.

Select Top(3) a.artist_id , name , sum(total_amount) As total_sales
,DENSE_RANK() over ( order by sum(total_amount) DESC) as rank
from sales s join artworks a on s.artwork_id=a.artwork_id
join artists on artists.artist_id=a.artist_id
group by a.artist_id,name





--15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

Create NONCLUSTERED INDEX ix_sales on Sales(artwork_id)


select *
from sales
where artwork_id = 2




--### Section 3: 3 Marks Questions

--16.  Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.

Select a.artist_id,name , AVG(price) as Average
from artworks a join artists b on a.artist_id=b.artist_id
group by a.artist_id,name
having Avg(price) > (Select Avg(price)
                     from artworks)


insert into artworks values (6,'dneisufh',1,'Cubism',123456)


--17.  Write a query to create a view that shows artists who have created artworks in multiple genres.

Create view vWMultipleGenre
As
Select a.artist_id , name 
from artworks a
join artists on artists.artist_id=a.artist_id
group by a.artist_id,name
having Count(genre)>1


select *
from vWMultipleGenre;




--18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
select artwork_id , title
from artworks a
where price > (Select Avg(price)
               from artworks b
			   where a.artist_id=b.artist_id
			   group by artist_id
			   )




--### Section 4: 4 Marks Questions

--19.  Write a query to convert the artists and their artworks into JSON format.

Select artists.artist_id as 'artists.artist_id',
       name as 'artists.name',
	   country as 'artists.country',
	   birth_year as 'artists.birth_year',
	   artwork_id as 'artwork.artwork_id ',
	   title as 'artwork.title',
	   genre as 'artwork.genre',
	   price as 'artwork.price'
from artworks join artists on artworks.artist_id=artists.artist_id
for JSON Path, Root('Artworks')






--20.  Write a query to export the artists and their artworks into XML format.


Select artists.artist_id as [artist/artist_id],
       name as [artist/name],
	   country as [artist/country],
	   birth_year as [artist/birth_year],
	   artwork_id as [artwork/artwork_id],
	   title as [artwork/title],
	   genre as [artwork/genre],
	   price as [artwork/price]
from artworks join artists on artworks.artist_id=artists.artist_id
for XML Path('Artists'), Root('Artworks')





Select * from artists;
Select * from artworks;
Select * from sales;

--#### Section 5: 5 Marks Questions

--21. Create a stored procedure to add a new sale and update the total sales for the artwork. 
--Ensure the quantity is positive, and use transactions to maintain data integrity.

Alter procedure spUpdateSales
  @sale_id int , @artwork_id int ,@sale_date date , @quantity int 
As
Begin 
    Begin transaction;
	  Begin try 
	    if not exists (Select artwork_id 
		               from artworks
					   where artwork_id=@artwork_id)

		throw 60000,'artwork is not valid',1;

		if @quantity<=0
		 throw 60000,'quanity is not valis',1;


       Declare @total_amount decimal(10,2)
	   set @total_amount = (select price*@quantity
	                        from artworks
							where artwork_id=@artwork_id)

		Insert into sales values(@sale_id,@artwork_id,@sale_date,@quantity,@total_amount)

		Select Sum(total_amount) as Total_Sales
		from sales
		group by artwork_id
		having artwork_id=@artwork_id

	commit transaction;
    end try

	begin catch 
	  rollback;
	  print CONCAT('Error Number',ERROR_NUMBER());
	  print CONCAT('Error Message ',ERROR_MESSAGE());
	  print CONCAT('Error sate',ERROR_STATE());
	end catch
end;


EXEC spUpdateSales 5,6,'2024-03-20',2




--22. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

Create function dbo.CalculateTotalQuanity()
Returns @tableGenre table (Genre nvarchar(50), Quantity int)
As
Begin 
   Insert into @tableGenre
   Select genre,Sum(quantity) 
   from artworks a join sales s on a.artwork_id=s.artwork_id
   group by genre

return;
end;


Select *
from dbo.CalculateTotalQuanity();




--23. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

Create function dbo.CalculateAverage(@genre nvarchar(50))
Returns decimal(10,2)
as
begin 
   Declare @average decimal(10,2)
   set @average = (select Avg(total_amount)
                   from sales s join artworks a on s.artwork_id=a.artwork_id
				   group by genre
				   having genre = @genre)

Return @average;
End;

select genre,dbo.CalculateAverage('Impressionism') as Average
from artworks
where genre = 'Impressionism'



--24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.

Create table artworks_log (artwork_id int , title nvarchar(50) , Change_Description nvarchar(50));
Select  * from artworks_log

Alter trigger trg_Artworks
on artworks
After insert,update,delete
As
Begin 
	 
      Insert into artworks_log
      Select artwork_id,title,'Changed'
	  from inserted 
	
ENd







--25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.

select a.artist_id,name,sum(total_amount) as Total_sales
,NTILE(4) over (Order by Sum(total_amount) ) as Category
from sales s join artworks a on s.artwork_id=a.artwork_id
join artists on a.artist_id=artists.artist_id
group by a.artist_id,name





--### Normalization (5 Marks)

--26. **Question:**
--    Given the denormalized table `ecommerce_data` with sample data:

--| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
--| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
--| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
--| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
--| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
--| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

--Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.


Create table Customers 
(
   Customer_id int Primary Key,
   Customer_Name nvarchar(60) Not Null,
   Customer_email nvarchar(100) Not null Unique
)

Create table products 
( 
  product_id int Primary Key,
  product_name nvarchar(40) Not Null,
  product_category nvarchar(50) Not Null,
  product_price decimal(10,2) Not Null 
)

Create table orderDetails
(
  order_id int Primary Key,
  order_date date Not Null,
  order_quantity int Not Null,
  order_total_amount decimal(10,2) Not Null
)

Create table orders
(
   order_id int Foreign Key references orderDetails,
   product_id int foreign key references products,
   customer_id int foreign key references customers,
   Primary Key (order_id,product_id,customer_id) 

)

Alter table products
add constraint check  product_price >=0







--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.

