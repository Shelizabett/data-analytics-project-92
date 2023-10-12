/* запрос для посчёта общего количества
 покупателей из таблицы customers: */
select COUNT(*) as customers_count
from customers
;

/* запрос для определения десяти лучших
 продавцов по суммарной выручке: */
select
	e.first_name||' '||e.last_name as name,
	COUNT(s.sales_id) as operations,
	FLOOR(SUM(s.quantity * p.price)) as income
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
	e.first_name||' '||e.last_name as name,
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
select
	e.first_name||' '||e.last_name as name,
	TO_CHAR((s.sale_date),'day') as weekday,
	ROUND(SUM(s.quantity * p.price), 0) as income
from sales s
join employees e
	on s.sales_person_id = e.employee_id
join products p
	on s.product_id = p.product_id
group by 2, 1, TO_CHAR((s.sale_date),'ID')
order by TO_CHAR((s.sale_date),'ID'), 1
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
	to_char(s.sale_date, 'yyyy-mm') as date,
	count(distinct s.customer_id) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from sales s
join products p
	on s.product_id = p.product_id
group by 1
order by 1
;

/* запрос для выведения списка покупателей,
 сделавших первую покупку в ходе проведения акций: */
with tab as (
	select
		distinct on (c.customer_id) s.sale_date as sale_date,
		c.customer_id,
		c.first_name||' '||c.last_name as customer,
		e.first_name||' '||e.last_name as seller,
		p.price
	from sales s
	join employees e
		on s.sales_person_id = e.employee_id
	join products p
		on s.product_id = p.product_id
	join customers c
		on c.customer_id = s.customer_id
	group by 2, 1, 3, 4, 5
	having price = '0'
	order by 2
)
select
	customer,
	sale_date,
	seller
from tab
;