use sakila;
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'Actor Name' FROM actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name='Joe';
-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor
where last_name like '%Gen%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor
where last_name like '%Li%' order by last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
select * from actor;
alter table actor  add column Description blob after actor_id;
 select * from actor
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
select * from actor;
alter table actor drop column description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
Select last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name) from actor group by last_name having count(last_name)>1;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name ='HARPO' where first_name ='GROUCHO';
select * from actor
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name ='GROUCHO' where first_name = 'HARPO';
select * from actor;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe sakila.address

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, address.address
from staff left join address on staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.first_name, staff.last_name, sum(payment.amount) as 'Total'
from staff left join payment on staff.staff_id = payment.staff_id
group by staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.title, count(film_actor.actor_id) as 'total' 
from film left join film_actor on film.film_id =film_actor.film_id
group by film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- select f.title, count(i.film_id) 
-- from film f left join  inventory i on f.film_id=i.film_id 
-- group by f.title 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as 'total'
from customer c left join payment p on c.customer_id= p.customer_id
group by c.first_name, c.last_name
order by c.last_name




-- -- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from film;

select title from film where (title like 'K%' or title like 'Q%')
and language_id=1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor where actor_id
in (select actor_id from film_actor where film_id
	in (select film_id from film where title ='Alone Trip'))
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select customer_id,first_name, last_name, email
from customer
join address on (customer.address_id = address.address_id)
join city on (address.city_id=city.city_id)
join country on (city.country_id=country.country_id)


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title from film 
join film_category on (film.film_id=film_category.film_id)
join category on (film_category_id=category.category_id)
-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Num_of_Rentals'
FROM  film f
JOIN inventory i ON (f.film_id= i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title ORDER BY Num_of_Rentals DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) 
FROM payment p
JOIN staff s ON (p.staff_id=s.staff_id)
GROUP BY store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id);
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
SELECT c.name AS "Top_Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 30;
-- 8b. How would you display the view that you created in 8a?
SELECT* FROM Top_Five;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five




