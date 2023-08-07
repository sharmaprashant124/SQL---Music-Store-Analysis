/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

select title, last_name, first_name 
from employee
order by levels desc
limit 1

/* Q2: Which countries have the most Invoices? */

select billing_country, count(billing_country) as "Total_invoice"
from invoice
group by billing_country
order by "Total_invoice" desc

/* Q3: What are top 3 values of total invoice? */

select billing_country, total 
from invoice
order by total desc

/* Q4: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as total_invoice from invoice
group by billing_city
order by total_invoice desc
limit 1

/* Q5: Who is the best customer? The customer who 
has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) 
from customer
inner join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(total) desc
limit 1

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct first_name, last_name, email, genre.name
from customer
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select * from artist
select * from album
select artist.name as "Artist_Name",  count(track.name) from artist
join album on album.artist_id = artist.artist_id
join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.name
order by count(track.name) desc
limit 10
			
/* Q3: Return all the track names that have a song length
longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */

select name, milliseconds as length from track
where milliseconds > (select avg(milliseconds) from track)
order by length desc


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */


WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC


/* Q2: We want to find out the most popular music Genre 
for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that 
returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


with popular_genre as 
	(select count(invoice_line.quantity), customer.country, t2.name,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as "row_num"
	from invoice as t1
	join customer on customer.customer_id = t1.customer_id
	join invoice_line on invoice_line.invoice_id = t1.invoice_id
	join track on track.track_id = invoice_line.track_id
	join genre as t2 on t2.genre_id = track.genre_id
	group by  2,3
	order by 2 asc, 1 desc)
select * from popular_genre where row_num <=1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with abcd as
	(select t1.country, t1.first_name, t1.last_name, sum(t2.total),
	row_number() over(partition by t1.country order by sum(t2.total) desc) as "row_num"
	from customer as t1
	join invoice as t2 on t2.customer_id = t1.customer_id
	group by 1,2,3
	order by t1.country asc, sum(t2.total) desc)
select * from abcd where row_num = 1