import mysql.connector
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from efficient_apriori import apriori
from sklearn.metrics import f1_score
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score

cnx = mysql.connector.connect(user='root', password='root',
                              host='localhost',
                              database='project_schema')

if cnx.is_connected():
    print("Connected")
    
#query = """select  o.product_id , p.product_name, count(o.product_id) cnt
#            from order_products__prior o inner join products p 
#            on o.product_id = p.product_id 
#            group by o.product_id
#            order by cnt desc 
#            LIMIT  10"""
    
query = """select a.product_id , p.product_name, a.cnt
from 
(select  o.product_id , count(o.product_id) cnt
from  order_products__prior o
 group by o.product_id
order by cnt desc 
LIMIT  10) a
inner join products p 
on p.product_id = a.product_id"""
            
       
cursor = cnx.cursor()

cursor.execute(query)
l1 = []
l2 = []
for (product_id, product_name, cnt) in cursor:
    l1.append(cnt)
    l2.append(product_name)

plt.bar(np.arange(len(l1)), l1, align='center', alpha=0.75)
plt.xticks(rotation='vertical')
plt.xticks(np.arange(len(l1)), l2)


##############################################################################
#cnt_srs = orders_df.groupby("user_id")["order_number"].aggregate(np.max).reset_index()
#cnt_srs = cnt_srs.order_number.value_counts()



   
#plt.figure(figsize=(12,8))
#productsDf.plot(productsDf['Total_no_of_orders'].index, productsDf['No_of_users'].values, alpha=0.8)

### Plot 1 ####
# No of Users by their total Orders
user_order_df = pd.read_sql('''select a.noOfOrders as Total_no_of_orders, 
  count(a.user_id) as No_of_users from (select user_id, max(order_number) noOfOrders
from orders group by user_id order by noOfOrders) as a
group by a.noOfOrders ;''', con=cnx)
    
plot1=user_order_df.plot.bar(x='Total_no_of_orders', y='No_of_users', rot=1)

#### Plot 2 ####
# Distribution of products across Aisle and department

products_df = pd.read_sql('''select p.aisle as Aisle,p.department as Department,count(p.product_name) as Products from (
select temp.*,d.department from (select p.*,a.aisle from products p left join aisles a on p.aisle_id=a.aisle_id) as temp left join
departments as d on temp.department_id=d.department_id) as p
group by p.aisle,p.department;''', con=cnx)
  
aisle_df = pd.read_sql('''select p.aisle as Aisle,count(p.product_name) as Products from (
select temp.*,d.department from (select p.*,a.aisle from products p left join aisles a on p.aisle_id=a.aisle_id) as temp left join
departments as d on temp.department_id=d.department_id) as p
group by p.aisle;''', con=cnx)
  
department_df = pd.read_sql('''select p.department as Department,count(p.product_name) as Products from (
select temp.*,d.department from (select p.*,a.aisle from products p left join aisles a on p.aisle_id=a.aisle_id) as temp left join
departments as d on temp.department_id=d.department_id) as p
group by p.department;''', con=cnx)
    
import squarify

squarify.plot(sizes=products_df['Products'], label=products_df["Aisle"], alpha=0.7)
plt.axis('off')
plt.show()

squarify.plot(sizes=products_df['Products'], label=products_df["Department"], alpha=0.7)
plt.axis('off')
plt.show()

cmap = matplotlib.cm.Blues
mini=min(department_df['Products'])
maxi=max(department_df['Products'])
norm = matplotlib.colors.Normalize(vmin=mini, vmax=maxi)
colors = [cmap(norm(value)) for value in department_df['Products']]
 
# Change color
squarify.plot(sizes=department_df['Products'], label=department_df["Department"], alpha=.8, color=colors )
plt.axis('off')
plt.show()


##### Plot 3 ####
# Frequency of orders by day of the week

dow_df = pd.read_sql('''select order_dow ,count(*) Total_orders, sum(reordered) Re_ordered_no, (sum(reordered)/count(*))*100 as Reorder_percent
from
(select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
#where user_id = 182401 ) src1
) src1
group by order_dow
order by order_dow;;''', con=cnx)


##################################
## Orders by Department.
##################################

ordersByDeptDf = pd.read_sql('''select d.department_id, d.department,count(*) orders
from project_schema.order_products__prior3 opm 
inner join products p on p.product_id = opm.product_id inner join departments d on p.department_id = d.department_id
group by d.department_id
''', con=cnx)

labels = ordersByDeptDf['department'].values
sizes = ordersByDeptDf['orders'].values

 
# Plot
plt.pie(sizes,  labels=labels, 
        autopct='%1.1f%%', shadow=True, startangle=140)
 
plt.axis('equal')
plt.show()

##################################
## Products by Department.
##################################

productsByDeptDf = pd.read_sql('''select d.department_id, d.department,count(*) products
from products p inner join departments d on p.department_id = d.department_id
group by d.department_id
''', con=cnx)

labels = productsByDeptDf['department'].values
sizes = productsByDeptDf['products'].values

 
# Plot
plt.pie(sizes,  labels=labels, 
        autopct='%1.1f%%', shadow=True, startangle=140)
 
plt.axis('equal')
plt.show()

#######################################################################################
# Last time order vs first time order
#######################################################################################

userReorderHistoryByItemDf = pd.read_sql("""select user_id, product_id, count(*) totalNoOfOrders, sum(reordered) noOfReordered,
        	   min(order_number) fistTimeOrder, max(order_number) lastTimeOrder
                from
                (select opm.product_id, o.user_id, o.order_number,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, 
                 o.order_dow
                from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
                where user_id = 182401)src1
                group by product_id, user_id;
                """,con = cnx)
                
                
plt.plot(userReorderHistoryByItemDf['fistTimeOrder'], userReorderHistoryByItemDf['lastTimeOrder'])
 
#######################################################################################
# Cart position vs Reorder Probability
#######################################################################################

cartPosVsReorderProbDf = pd.read_sql("""select add_to_cart_order, count(*) totalOrders, sum(reordered) reorderCount
                                                from project_schema.order_products__prior3
                                                group by add_to_cart_order
                                                order by add_to_cart_order
                """,con = cnx)
                
                
plt.scatter(cartPosVsReorderProbDf['add_to_cart_order'], cartPosVsReorderProbDf['reorderCount']/cartPosVsReorderProbDf['totalOrders'])
 
#################################################################################################
# Avg no of days for item reorder.
#################################################################################################


noOfDaysForReorderDf = pd.read_sql("""select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow, p.product_name
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
inner join products p on p.product_id = opm.product_id
where user_id = 182401
order by order_number""",con = cnx)

ordersByUserDf = pd.read_sql("""select * from orders2 where user_id = 182401 order by order_number""",con = cnx)

uniqueProductIds = noOfDaysForReorderDf.product_id.unique()

tempDf = noOfDaysForReorderDf.loc[noOfDaysForReorderDf['product_id'] == 7781]

toBePlottedProducts = {}
for productId in uniqueProductIds:
    rowIndexes = noOfDaysForReorderDf.index[noOfDaysForReorderDf['product_id'] == productId].values
    if(len(rowIndexes) > 2):
        noOfDaysBetweenReorder = []
        for index in range(1,len(rowIndexes)):
            currOderNum = noOfDaysForReorderDf.iloc[rowIndexes[index],]['order_number']
            prevOderNum = noOfDaysForReorderDf.iloc[rowIndexes[index - 1],]['order_number']
            noOfDaysBetweenReorder.append(sum(ordersByUserDf.loc[(ordersByUserDf['order_number'] >= prevOderNum) & (ordersByUserDf['order_number'] <= currOderNum)]['days_since_prior_order']))
            
        toBePlottedProducts[noOfDaysForReorderDf.loc[noOfDaysForReorderDf['product_id'] == productId].iloc[0]['product_name']]= sum(noOfDaysBetweenReorder)/len(noOfDaysBetweenReorder)
        
plt.bar(np.arange(len(list(toBePlottedProducts.values()))), list(toBePlottedProducts.values()), align='center', alpha=0.75)
plt.xticks(rotation='vertical')
plt.xticks(np.arange(len(list(toBePlottedProducts.values()))), list(toBePlottedProducts.keys()))

plt.show()
        







