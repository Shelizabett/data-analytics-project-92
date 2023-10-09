/* запрос для посчёта общего количества
 покупателей из таблицы customers: */
select COUNT(*) as customers_count
from customers
;

/* запрос для определения десяти лучших
 продавцов по суммарной выручке: */
select
	CONCAT(e.first_name, ' ', e.last_name) as name,
	COUNT(s.sales_id) as operations,
	ROUND(SUM(s.quantity * p.price), 0) as income
from sales s
join employees e
	on s.sales_person_id = e.employee_id
join products p
	on s.product_id = p.product_id
group by 1
order by 3 desc
limit 10
;

/* запрос для определения продавцов,
 чья средняя выручка за сделку меньше
 средней выручки за сделку по всем продавцам: */
select
	CONCAT(e.first_name, ' ', e.last_name) as name,
	ROUND(AVG(s.quantity * p.price), 0) as average_income
from sales s
join employees e
	on s.sales_person_id = e.employee_id
join products p
	on s.product_id = p.product_id
group by 1
having AVG(s.quantity * p.price) <
	(select AVG(s.quantity * p.price)
	from sales s
	join products p
		on s.product_id = p.product_id)
order by 2
;

/* запрос для получения информации о выручке по дням недели: */
with tab as (
	select
		CONCAT(e.first_name, ' ', e.last_name) as name,
		TO_CHAR(s.sale_date, 'fmday') as weekday,
		CASE WHEN TO_CHAR(s.sale_date, 'D') = '1'
			THEN 7 ELSE TO_CHAR(s.sale_date, 'D')::integer - 1 end,
		ROUND(SUM(s.quantity * p.price), 0) as income
	from sales s
	join employees e
		on s.sales_person_id = e.employee_id
	join products p
		on s.product_id = p.product_id
	group by 2, 3, 1
	order by 3, 1
)
select
	name,
	weekday,
	income
from tab
;

/* запрос для получения данных о возрастных группах покупателей: */
select
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		else '40+'
	end as age_category,
	count(*) as count
from customers
group by 1
order by 1
;

/* запрос для определения количества уникальных покупателей
 и выручки по месяцам: */
select
	TO_CHAR(s.sale_date, 'yyyy-mm') as date,
	sum(s.customer_id) as total_customers,
	round(sum(s.quantity * p.price),0) as income
from sales s
join products p
	on s.product_id = p.product_id
group by 1
order by 1
;

/* запрос для выведения списка покупателей,
 сделавших первую покупку в ходе проведения акций: */
with tab as (
	select distinct
		CONCAT(c.first_name, ' ', c.last_name) as customer,
		c.customer_id,
		min(s.sale_date) as sale_date,
		CONCAT(e.first_name, ' ', e.last_name) as seller,
		p.price
	from sales s
	join employees e
		on s.sales_person_id = e.employee_id
	join products p
		on s.product_id = p.product_id
	join customers c
		on c.customer_id = s.customer_id
	group by 1, 2, 4, 5
	having price = '0'
	order by 2
)
select
	customer,
	min(sale_date) as sale_date ,
	min(seller) AS seller
from tab
group by 1
order by 1
;