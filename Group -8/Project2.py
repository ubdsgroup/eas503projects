import mysql.connector
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from efficient_apriori import apriori
from sklearn.metrics import f1_score
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score
from matplotlib import pyplot
from xgboost import plot_importance

cnx = mysql.connector.connect(user='root', password='root',
                              host='localhost',
                              database='project_schema')

if cnx.is_connected():
    print("Connected")
    
    
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

    
trainDf = pd.merge(orderPriorDf[['product_id','reordered','order_id']],ordersDf[['order_id', 'user_id']], on = 'order_id')

#productReorderProb = []
#userProductOrderCnt = []

colNames1 = ['productId','avgDaysForReorder','prodReorderProb', 'userReOrdercnt', 'userOrdercnt', 'daysSinceLastOrder', 'dow']
trainDataDf = pd.DataFrame(columns = colNames1)

testOrderItemsDf = pd.read_sql("""select * from order_products__train where order_id in (select order_id from orders2 where user_id = 140 and  eval_set = 'train')
""",con = cnx)

testOrdersDf = pd.read_sql("""select * from orders2 where user_id = 140 and  eval_set = 'train' """,con = cnx)

testDf = pd.merge(testOrderItemsDf[['product_id','reordered','order_id']],testOrdersDf[['order_id', 'user_id']], on = 'order_id')

noOfDaysForReorderDf = pd.read_sql("""select opm.product_id, o.user_id, o.order_number as order_number ,opm.reordered, opm.order_id , o.order_hour_of_day, 
 o.days_since_prior_order, o.order_dow, p.product_name
from project_schema.order_products__prior3 opm inner join project_schema.orders2 o on opm.order_id = o.order_id
inner join products p on p.product_id = opm.product_id
where user_id = 140
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
    dow = b.iloc[0]['order_dow']
    reorderdTrain.append(row[2])
    avgNoDaysForReorder = 0
    if(productId in toBePlottedProducts):
        avgNoDaysForReorder = toBePlottedProducts[productId]
    
    trainDataDf.loc[len(trainDataDf)] = [productId,avgNoDaysForReorder,prodReorderProb,userReOrdercnt,userOrdercnt,daysSinceLastOrder,dow]
    
model = XGBClassifier()
model.fit(trainDataDf, reorderdTrain)

testDataDf = pd.DataFrame(columns = colNames1)    
reorderdTest = []
userFilteredTestDf = testDf.loc[testDf['user_id'] == 140]
for row in userFilteredTestDf.itertuples(index=True, name='Pandas'):
    #print('inside')
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
    if(productId in toBePlottedProducts):
        avgNoDaysForReorder = toBePlottedProducts[productId]
    
    b = testOrdersDf.loc[(testOrdersDf['order_id'] == orderId) & (testOrdersDf['user_id'] == userId)]
    daysSinceLastOrder = b.iloc[0]['days_since_prior_order']
    dow = b.iloc[0]['order_dow']
    reorderdTest.append(row[2])
    testDataDf.loc[len(testDataDf)] = [productId, avgNoDaysForReorder,prodReorderProb,userReOrdercnt,userOrdercnt,daysSinceLastOrder,dow]
    
# make predictions for test data
preds = model.predict(testDataDf)

accuracy = accuracy_score(reorderdTest, preds)
print("Accuracy: %.2f%%" % (accuracy * 100.0))

#######################################################################################
pyplot.bar(range(len(model.feature_importances_)), model.feature_importances_)
plot_importance(model)
pyplot.show()