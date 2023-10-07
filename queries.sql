select COUNT(*) as customers_count
from customers
/* запрос для посчёта общего количества
 покупателей из таблицы customers */
;

select
	CONCAT(e.first_name, ' ', e.last_name) as name,
	COUNT(s.sales_id) as operations,
	SUM(s.quantity * p.price) as income
from sales s
join employees e
	on s.sales_person_id = e.employee_id
join products p
	on s.product_id = p.product_id
group by 1
order by 3 desc
limit 10
/* запрос для определения десяти лучших
 продавцов по суммарной выручке */
;

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
/* запрос для определения продавцов,
 чья средняя выручка за сделку меньше
 средней выручки за сделку по всем продавцам */
;

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
/* запрос для получения информации о выручке по дням недели */
;