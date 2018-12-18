import mysql.connector
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

plt.show()
#
productsDf = pd.read_sql('SELECT product_id, product_name FROM products', con=cnx)
productsDict = dict(zip(productsDf.product_id, productsDf.product_name))

transactions = []

milOrderRecDf = pd.read_sql("""select * from project_schema.order_products__prior order by order_id limit 1000000""",con = cnx)

currOrderid = 0
currTrans = []
for row in milOrderRecDf.itertuples(index=True, name='Pandas'):
    if(currOrderid == row[2]):
        currTrans.append(productsDict[row[1]])
    
    else:
        transactions.append(currTrans)
        currOrderid = row[2]
        currTrans = []
        currTrans.append(productsDict[row[1]])
                
        
itemsets, rules = apriori(transactions, min_support=0.001,  min_confidence=0.01)

print(rules)

with open('rules.txt', 'w') as f:
    for item in rules:
        f.write("%s\n" % item)

orderPriorDf = pd.read_sql("""select * from project_schema.order_products__prior3""",con = cnx)
ordersDf = pd.read_sql("""select * from project_schema.orders2 where eval_set <> 'test'""",con = cnx)

#mergedData = pd.merge(orderPriorDf[['product_id','reordered','order_id']],ordersDf[['order_id', 'user_id']], on = 'order_id').groupby(['user_id', 'product_id']).sum()['reordered'].reset_index()

mergedData = pd.merge(orderPriorDf[['product_id','reordered','order_id']],ordersDf[['order_id', 'user_id']], on = 'order_id').groupby(['user_id', 'product_id']).agg({'reordered': ['sum','count']}).reset_index()
mergedData.columns = ['user_id', 'product_id', 'reOrderCount', 'orderCount']

productReorderProbDf = pd.read_sql("""select src1.product_id, reOrderCount, totalOrderCount, src1.reOrderCount/src1.totalOrderCount as reOrderProbability
from 
(select product_id, sum(reordered) as reOrderCount, count(*) as totalOrderCount
from project_schema.order_products__prior
group by product_id) src1;""",con = cnx)

#############################################################################################
#############################################################################################
#############################################################################################


## First version of model
# This predicts for a user given product id will he reorder.
# This works on model based per user

#############################################################################################
#############################################################################################
#############################################################################################

trainDf = pd.merge(orderPriorDf[['product_id','reordered','order_id']],ordersDf[['order_id', 'user_id']], on = 'order_id')

#productReorderProb = []
#userProductOrderCnt = []

colNames1 = ['prodReorderProb', 'userReOrdercnt', 'userOrdercnt', 'daysSinceLastOrder', 'dow']
trainDataDf = pd.DataFrame(columns = colNames1)

testOrderItemsDf = pd.read_sql("""select * from order_products__train where order_id in (select order_id from orders2 where user_id = 140 and  eval_set = 'train')
""",con = cnx)

testOrdersDf = pd.read_sql("""select * from orders2 where user_id = 140 and  eval_set = 'train' """,con = cnx)

testDf = pd.merge(testOrderItemsDf[['product_id','reordered','order_id']],testOrdersDf[['order_id', 'user_id']], on = 'order_id')



reorderdTrain = []
for row in trainDf.loc[trainDf['user_id'] == 140].itertuples(index=True, name='Pandas'):
    productId = row[1]
    userId = row[4]
    orderId = row[3]
    
    
    prodReorderProb = productReorderProbDf.loc[productReorderProbDf['product_id'] == productId].iloc[0]['reOrderProbability']
    a = mergedData.loc[(mergedData['product_id'] == productId) & (mergedData['user_id'] == userId)]
    userReOrdercnt = a.iloc[0]['reOrderCount']
    userOrdercnt = a.iloc[0]['orderCount']
    
    b = ordersDf.loc[(ordersDf['order_id'] == orderId) & (ordersDf['user_id'] == userId)]
    daysSinceLastOrder = b.iloc[0]['days_since_prior_order']
    dow = b.iloc[0]['days_since_prior_order']
    reorderdTrain.append(row[2])
    trainDataDf.loc[len(trainDataDf)] = [prodReorderProb,userReOrdercnt,userOrdercnt,daysSinceLastOrder,dow]
    
model = XGBClassifier()
model.fit(trainDataDf, reorderdTrain)

testDataDf = pd.DataFrame(columns = colNames1)    
reorderdTest = []
userFilteredTestDf = testDf.loc[testDf['user_id'] == 140]
for row in userFilteredTestDf.itertuples(index=True, name='Pandas'):
    print('inside')
    productId = row[1]
    userId = row[4]
    orderId = row[3]
    
    
    prodReorderProb = productReorderProbDf.loc[productReorderProbDf['product_id'] == productId].iloc[0]['reOrderProbability']
    a = mergedData.loc[(mergedData['product_id'] == productId) & (mergedData['user_id'] == userId)]
    if len(a) != 0:
        userReOrdercnt = a.iloc[0]['reOrderCount']
        userOrdercnt = a.iloc[0]['orderCount']
    else:
        userReOrdercnt = 0
        userOrdercnt = 0
    
    b = testOrdersDf.loc[(testOrdersDf['order_id'] == orderId) & (testOrdersDf['user_id'] == userId)]
    daysSinceLastOrder = b.iloc[0]['days_since_prior_order']
    dow = b.iloc[0]['days_since_prior_order']
    reorderdTest.append(row[2])
    testDataDf.loc[len(testDataDf)] = [prodReorderProb,userReOrdercnt,userOrdercnt,daysSinceLastOrder,dow]
    
# make predictions for test data
preds = model.predict(testDataDf)

accuracy = accuracy_score(reorderdTest, preds)
print("Accuracy: %.2f%%" % (accuracy * 100.0))


#################################################################################################
# Order Size vs Reorder probability
#################################################################################################
orderSizeVsReorderProbDf = pd.read_sql("""select src3.orderSize, avg(reOrderProb) reOrderProb
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
group by src3.orderSize""",con = cnx)

plt.plot(orderSizeVsReorderProbDf['orderSize'], orderSizeVsReorderProbDf['reOrderProb'])



#################################################################################################
# Avg No of days for reorder
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
        
#############################################################################################
#############################################################################################
#############################################################################################

## Second version of model
# dow of the week order probability.
# order size vs reorder probability.

#############################################################################################
#############################################################################################
#############################################################################################

def getUserReorderHistoryByItem(userId):
    query = """select user_id, product_id, count(*) totalNoOfOrders, sum(reordered) noOfReordered,
        	   min(order_number) fistTimeOrder, max(order_number) lastTimeOrder
                from
                (select opm.product_id, o.user_id, o.order_number,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, 
                 o.order_dow
                from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
                where user_id = 182401)src1
                group by product_id, user_id;
                """
    return pd.read_sql(query,con = cnx)
 
    
def getUserLast10OrdersHistory(userId):
    query = """select user_id, product_id, count(*) totalNoOfOrders, sum(reordered) noOfReordered,
            	   min(order_number) fistTimeOrder, max(order_number) lastTimeOrder
                from
                (select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
                from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
                where user_id = 182401 
                having order_number between 89 and 99) src1
                group by product_id, user_id
                order by product_id;
                """
    return pd.read_sql(query,con = cnx)
 
def getProdcutReorderByHoursOfTheDay(userId):
    query = """select user_id, product_id,order_hour_of_day ,count(*) totalNoOfOrders, sum(reordered) noOfReordered
                from
                (select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, o.days_since_prior_order, o.order_dow
                from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
                where user_id = 182401 ) src1
                group by product_id, user_id, order_hour_of_day
                order by product_id;
                """
    return pd.read_sql(query,con = cnx)

def getProductReorderByDayOfTheWeek(userId):
    query = """select order_dow ,count(*) totalNoOfOrders, sum(reordered) noOfReordered
                from
                (select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
                 o.days_since_prior_order, o.order_dow
                from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
                where user_id = 182401 ) src1
                #) src1
                group by order_dow
                order by order_dow;

                """
    return pd.read_sql(query,con = cnx)
 
def getAvgNoOfDaysForReorderAnItem(userId):
    query = """select user_id, product_id, avg(days_since_prior_order)
                from
                (select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
                 o.days_since_prior_order, o.order_dow
                from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
                where user_id = 182401 and opm.reordered = 1) src1
                #) src1
                group by product_id
                order by product_id;
                """
    return pd.read_sql(query,con = cnx)

    
userReorderHistoryByItem = getUserReorderHistoryByItem(182401)
last10OrderHistory = getUserLast10OrdersHistory(userId)
prodcutReorderByHoursOfTheDay = getProdcutReorderByHoursOfTheDay(userId)
productReorderByDayOfTheWeek = getProductReorderByDayOfTheWeek(userId)


#user182401 = megedData.loc[megedData['user_id'] == 182401]
#for row in trainDf.loc[trainDf['user_id'] == 182401].itertuples(index=True, name='Pandas'):
                    
        
                
    


    

    
    














