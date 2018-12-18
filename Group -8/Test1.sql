#SELECT * FROM products;

#select  o.product_id , p.product_name, count(o.product_id) cnt
#from products p  inner join  order_products__prior o
#on p.product_id = o.product_id 
#group by o.product_id
#order by cnt desc 
#LIMIT  10

select a.product_id , p.product_name, a.cnt
from 
(select  o.product_id , count(o.product_id) cnt
from  order_products__prior o
 group by o.product_id
order by cnt desc 
LIMIT  10) a
inner join products p 
on p.product_id = a.product_id;

select count(*) from project_schema.order_products__prior;

select count(distinct order_id) from (select * from project_schema.order_products__prior order by order_id limit 1000000) src1;

select count(*) from project_schema.order_products__prior order by order_id limit 1000000;

#insert into project_schema.orderproductsmillionrecords select * from project_schema.order_products__prior order by order_id limit 1000000

select src1.product_id, reOrderCount, totalOrderCount, src1.reOrderCount/src1.totalOrderCount as reOrderProbability
from 
(select product_id, sum(reordered) as reOrderCount, count(*) as totalOrderCount
from project_schema.order_products__prior
group by product_id) src1;

select src1.product_id, src1.user_id , sum(src1.reordered) as reOrderCount, count(*) as totalOrderCount
from
(select opm.product_id, o.user_id, opm.reordered 
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id) src1
group by src1.product_id, src1.user_id;

create temporary table src1 
select opm.product_id, o.user_id, opm.reordered 
from project_schema.order_products__prior opm inner join project_schema.orders2 o on opm.order_id = o.order_id;

select opm.product_id, o.user_id, sum(opm.reordered), count(*)
from project_schema.order_products__prior opm inner join project_schema.orders2 o on opm.order_id = o.order_id
group by o.user_id, opm.product_id;

insert into project_schema.orders2
select * from project_schema.orders order by user_id limit 100000;


select opm.product_id, o.user_id, opm.reordered
from project_schema.order_products__prior opm inner join project_schema.orders o on opm.order_id = o.order_id
where o.user_id = 1 and opm.product_id = 13176;

#####################################################################################################################
# No of orders by user
#####################################################################################################################
select user_id, max(order_number) as noOfOrders
from orders
group by user_id
having noOfOrders >50
order by user_id;

#####################################################################################################################
# Getting data for user with orders > 50
#####################################################################################################################
#insert into project_schema.orders2
select count(*) 
from orders o1
where o1.user_id in
(select o2.user_id
from orders o2
group by o2.user_id
having count(*) >50 
);

select * from orders2 ;

select * from orders2 where eval_set = 'train';
select * from order_products__train where order_id  in (select order_id from orders2 where user_id = 97952);
select distinct product_id from order_products__prior3 where order_id  in (select order_id from orders2 where user_id = 182401);

select * from order_products__prior3 where order_id = 3308524;

#ALTER TABLE project_schema.order_products__prior3
#ADD CONSTRAINT PK_Person PRIMARY KEY (order_id,product_id);

insert into project_schema.order_products__prior3 (order_id, product_id, add_to_cart_order, reordered)
select o1.order_id, o1.product_id, o1.add_to_cart_order, o1.reordered 
from project_schema.order_products__prior o1
where o1.order_id in (select order_id from project_schema.orders2);


select src1.product_id, src1.user_id , sum(src1.reordered) as reOrderCount, count(*) as totalOrderCount
from
(select opm.product_id, o.user_id, opm.reordered 
from project_schema.order_products__prior opm inner join project_schema.orders2 o on opm.order_id = o.order_id) src1
group by src1.product_id, src1.user_id;

select distinct user_id from orders2 where eval_set = 'train';

select * from order_products__train where order_id in (select order_id from orders2 where user_id = 140 and  eval_set = 'train');

select * from orders2 where user_id = 182401 and  eval_set = 'train';

##########################################################################################################################
## Most frequent customer(Top 10)
##########################################################################################################################
select user_id, max(order_number) noOfOrders
from orders
group by user_id
order by noOfOrders desc
limit 10;

##########################################################################################################################
## No of distinct orders by users
##########################################################################################################################
select src1.user_id , count(distinct product_id) as distinctProducts
from
(select opm.product_id, o.user_id, opm.reordered 
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id) src1
group by src1.user_id
order by distinctProducts desc
limit 10;

############################################################################################################################
# User reorder count
############################################################################################################################
select src1.user_id , sum(src1.reordered) as totalReorders, count(*) totalOrders
from
(select opm.product_id, o.user_id, opm.reordered 
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401) src1
group by src1.user_id;

select * from orders2
where user_id = 182401;


############################################################################################################################
# Order size vs reorder probability
############################################################################################################################
select src3.orderSize, avg(reOrderProb) reOrderProb
from
(select src2.order_id, orderSize, reorderCount, reorderCount/orderSize as reOrderProb
from
(select src1.order_id , count(*) orderSize , sum(src1.reordered) reorderCount
from 
(select opm.product_id, o.user_id, opm.reordered, opm.order_id 
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
#where user_id = 182401)src1
where o.order_number <> 1)src1
group by src1.order_id) src2) src3
group by src3.orderSize;


############################################################################################################################
# By user item last reorder, first time order 
############################################################################################################################

select user_id, product_id, count(*) totalNoOfOrders, sum(reordered) noOfReordered,
	   min(order_number) fistTimeOrder, max(order_number) lastTimeOrder
from
(select opm.product_id, o.user_id, o.order_number,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401)src1
group by product_id, user_id;

## last 10 orders.
select user_id, product_id, count(*) totalNoOfOrders, sum(reordered) noOfReordered,
	   min(order_number) fistTimeOrder, max(order_number) lastTimeOrder
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401 
having order_number between 89 and 99) src1
group by product_id, user_id
order by product_id;

### prodct reorder by hour
select user_id, product_id,order_hour_of_day ,count(*) totalNoOfOrders, sum(reordered) noOfReordered
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401 ) src1
group by product_id, user_id, order_hour_of_day
order by product_id;

### overall reorder by hour
select order_hour_of_day ,count(*) totalNoOfOrders, sum(reordered) noOfReordered
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
#where user_id = 182401 ) src1
) src1
group by order_hour_of_day
order by order_hour_of_day;

### overall reorder by days since last order
select days_since_prior_order ,count(*) totalNoOfOrders, sum(reordered) noOfReordered
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
#where user_id = 182401 ) src1
) src1
group by days_since_prior_order
order by days_since_prior_order;

### overall reorder by day of the week
select order_dow ,count(*) totalNoOfOrders, sum(reordered) noOfReordered
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401 ) src1
#) src1
group by order_dow
order by order_dow;


### Avg no of days for reordering an item
select user_id, product_id, avg(days_since_prior_order)
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401 and opm.reordered = 1) src1
#) src1
group by product_id
order by product_id;

######################################################
select * from information_schema.innodb_trx;
########################################################


### Avg no of days for reordering an item
select user_id, product_id, days_since_prior_order
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
where user_id = 182401 and opm.reordered = 1) src1
#) src1
group by product_id
order by product_id;


SELECT t.user_id,t.order_number,t.days_since_prior_order, @running_total := @running_total + t.days_since_prior_order AS cumulative_sum
    FROM orders2 as t
    JOIN (SELECT @running_total := 0) r
group by t.user_id
ORDER BY t.user_id,t.order_number;

set @SumVariable=0;

SELECT t.user_id,t.order_numb
er,t.days_since_prior_order, (@SumVariable := @SumVariable + t.days_since_prior_order) AS cumulative_sum
FROM (select * from orders2 
where user_id = 182401) t
ORDER BY t.user_id,t.order_number;

SELECT t.user_id,t.order_number,t.days_since_prior_order, 
(select sum(days_since_prior_order) from orders2 as s where s.user_id=t.user_id  and s.order_id<=t.order_id  ) as cum_sum
FROM orders2 as t
ORDER BY t.user_id,t.order_number;



select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow, p.product_name
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
inner join products p on p.product_id = opm.product_id
where user_id = 182401
order by order_number;

select * from orders2 where user_id = 182401 order by order_number;


##############################################################################################
# product ordered by distinct users.
##############################################################################################
select p.product_name, src1.product_id, src1.users
from products p inner join 
(select opm.product_id,count(distinct o.user_id) users
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
group by product_id
order by users desc
LIMIT 10) src1 on p.product_id = src1.product_id;


##############################################################################################
# Cart position vs Reorder Probability
##############################################################################################

select add_to_cart_order, count(*) totalOrders, sum(reordered) reorderCount
from project_schema.order_products__prior3
group by add_to_cart_order
order by add_to_cart_order;

##############################################################################################
# Products Word plot
##############################################################################################

select a.product_id , p.product_name, a.cnt
from 
(select  o.product_id , count(o.product_id) cnt
from  order_products__prior o
 group by o.product_id
order by cnt desc 
LIMIT  100) a
inner join products p 
on p.product_id = a.product_id;


select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow, p.product_name
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
inner join products p on p.product_id = opm.product_id
where user_id = 182401
order by order_number
limit 200;

select d.department, avg(src1.days_since_prior_order)
from
(select o.days_since_prior_order, opm.product_id
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
) src1 inner join products p on p.product_id = src1.product_id inner join departments d on p.department_id=d.department_id
group by d.department;

select d.department, avg(o.days_since_prior_order)
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
inner join products p on p.product_id = opm.product_id inner join departments d on p.department_id=d.department_id
group by d.department
order by order_number
limit 200;

select a.product_id , p.product_name, a.cnt
from 
(select  o.product_id , count(o.product_id) cnt
from  order_products__prior o
where o.reordered = 1
 group by o.product_id
order by cnt desc 
LIMIT  10) a
inner join products p 
on p.product_id = a.product_id;


#####################################################################
## Avg cart size of users
#####################################################################
select user_id, avg(cnt) cnt2
from 
(select user_id, o.order_id, count(*) cnt
from  order_products__prior3 opm inner join orders2 o on opm.order_id = o.order_id
where user_id between 1 and 100
group by user_id, o.order_id) src1
group by src1.user_id
order by cnt2;

select user_id, o.order_id, product_name, reordered
from  order_products__prior3 opm inner join orders2 o on opm.order_id = o.order_id inner join products p on p.product_id = opm.product_id
where user_id  = 50;

select user_id, count(*)
from orders2 
where user_id = 50
group by user_id;

select user_id, product_name, p.product_id , sum(reordered) reorderedCnt
from  order_products__prior3 opm inner join orders2 o on opm.order_id = o.order_id inner join products p on p.product_id = opm.product_id
where user_id  = 50
group by user_id, product_id
order by reorderedCnt desc;

select user_id, product_name, p.product_id , sum(reordered) reorderedCnt
from  order_products__prior3 opm inner join orders2 o on opm.order_id = o.order_id inner join products p on p.product_id = opm.product_id
where user_id  = 27
group by user_id, product_id
order by reorderedCnt desc;

select d.department_id, d.department,count(*) orders, sum(reordered)
from project_schema.order_products__prior3 opm 
inner join products p on p.product_id = opm.product_id inner join departments d on p.department_id = d.department_id
group by d.department_id;


