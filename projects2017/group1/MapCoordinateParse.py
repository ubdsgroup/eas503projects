# Author: Joseph Hadley
# Date Created: 2017-11-14
# Last Modified: 2017-11-29
# Description: Take Chicago Census Block Data found at: https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Census-Blocks-2010/mfzt-js4n/data
#       and exporting the csv file.Parses the Geometry points from the csv file
#       and then finds the centroid of each of the census blocks. This data is
#       then exported as a csv file named: 'CensusCentroid.csv'

# Last Modified: 2017-11-19
# Description: Take Chicago Census Block, District, and Community area map
#       coordinate data and parse it and its key and export the result as a csv.
#       For the census block data, the centroid of is found instead and is
#       exported instead of the boundaries.
# Data:
#       Community Area : https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6/data
#       Districts :      https://data.cityofchicago.org/Public-Safety/Boundaries-Police-Districts-current-/fthy-xz3r/data
#       Census Block :   https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Census-Blocks-2010/mfzt-js4n/data
# Resources:
#       Polygon Centroid Formula: https://en.wikipedia.org/wiki/Centroid

#---------------------------Import Libraries----------------------------------
# python 3.6
import numpy as np #V1.13.3
import pandas as pd #V0.20.3
import matplotlib.pyplot as plt #V2.1.0
from shapely.ops import cascaded_union
import pymysql as pymysql
#-------------------------------Functions------------------------------------
# pandas wants to truncate data when using to_csv due to how it reads numpy arrays
#   as strings so extend threshold that numpy prints
np.set_printoptions(threshold= 5000)
#-----------------------------------------------------------------------------
#                                  Functions
#-----------------------------------------------------------------------------
# Parse Coordinate's from data and return coordinates as an array of floats
def parseGeomData(csv,path_to_csv):
        # read csv
        df = pd.read_csv(path_to_csv + csv)
        geom = df['the_geom'] # grab coordinate column
        # Create a list to store the coordinates to
        coordinates = []
        # go through each entry and parse the coordinates
        for i in range(0,len(geom)):
            tmp_geom = geom[i]
            # remove main set of Parenthesis and MULTIPOLYGON
            tmp_geom = tmp_geom.replace('MULTIPOLYGON (((',"")
            tmp_geom = tmp_geom.replace(')))',"")
            # get rid of stray parenthesis
            tmp_geom = tmp_geom.replace(')',"")
            tmp_geom = tmp_geom.replace('(',"")
            # split at each coordinate
            tmp_geom = tmp_geom.split(', ')

            for j in range(len(tmp_geom)):

                # split the two coordinates
                tmp = tmp_geom[j].split(" ")
                # convert strings to float
                x = float(tmp[0])
                y = float(tmp[1])
                tmp_geom[j] = [x,y]
            # put new seperated float coordinates into a list
            coordinates.append(np.array(tmp_geom))
        return coordinates
#--------------------------End of Function--------------------------------------
# find centroid of polygon given x and y coordinates
def getCentroidForPolygon(x,y):
    tmpA = []
    tmpCx = []
    tmpCy = []

    # Find Centroid using formula found on wikipedia
    for i in range(0,len(x)-1):
        tmpA.append(x[i]*y[i+1]-x[i+1]*y[i])
        tmpCx.append((x[i]+x[i+1])*tmpA[i])
        tmpCy.append((y[i]+y[i+1])*tmpA[i])

    A = (1/2)*sum(tmpA)
    Cx = (1/(6*A))*sum(tmpCx)
    Cy = (1/(6*A))*sum(tmpCy)

    return Cx,Cy
#--------------------------End of Function--------------------------------------
# get x and y coordinates as list from Coordinates
#Use centroid function above to find centroid of each block
def xyFromList(coordinates):
    xCoord = []
    yCoord = []
    for i in range(len(coordinates)):
        tmp = coordinates[i]
        # Pull X and Y coordinates
        x = tmp[:,0]
        y = tmp[:,1]
        # Store the coordinates seperately
        xCoord.append(x)
        yCoord.append(y)
    return xCoord,yCoord
#--------------------------End of Function--------------------------------------

#-------------------------------------------------------------------------------
#                      Parse and get Centroid for Census Block
#-------------------------------------------------------------------------------
# give file paths
### Things that you should change to run yourself
path_to_csv = "~/Documents/Programs/Python/eas503-project/data/"
csv1 = 'rawData/CensusBlockMapCoordinates.csv'
csv2 = 'rawData/CommAreas.csv'
# create dataFrame
df1 = pd.read_csv(path_to_csv + csv1)

# Use Parse function above to parse the data
blockCoordinates = parseGeomData(csv1,path_to_csv)
blockID = df1['GEOID10'] # grab block number

# Initialize centroid variables
Cx = []
Cy = []
#Use centroid function above to find centroid of each block
for i in range(len(blockCoordinates)):
    block = blockCoordinates[i]
    # Pull X and Y coordinates from the block
    x = block[:,0]
    y = block[:,1]
    tmp = getCentroidForPolygon(x,y)
    # Store the centroids
    Cx.append(tmp[0])
    Cy.append(tmp[1])

#plot 20 random blocks to see if centroid is in center

'''
r = np.random.randint(0,len(blockCoordinates),20)

fig,ax = plt.subplots(10,2,figsize = (8,20))

for i in range(len(r)):
    plt.subplot(10,2,i+1)
    block = blockCoordinates[r[i]]
    x = block[:,0]
    y = block[:,1]
    plt.plot(x,y)
    plt.plot(Cx[r[i]],Cy[r[i]],'o')

plt.tight_layout()
plt.show()
# Generally not too bad, however not in bounds for some of the goofy shaped ones
# Create a dataframe with all of the variables of interest
'''
# Create a dataframe with all of the variables of interest
centroidDict = {"Cx":Cx,"Cy":Cy,"blockID":blockID}
centroidDf = pd.DataFrame(centroidDict)
# export dataframe as a csv

centroidDf.to_csv(path_to_csv + 'CensusCentroid.csv')
#-------------------------------------------------------------------------------
#                 Parse the Community Area Coordinates
#-------------------------------------------------------------------------------
# create dataFrame
df2 = pd.read_csv(path_to_csv + csv2)
# CHANGE OHARE to O'Hare to match the other data
df2["COMMUNITY"][74] = "O'HARE"

# Get Desired Features

comNum = df2["AREA_NUMBE"]
comName = df2["COMMUNITY"]
comArea = df2['SHAPE_AREA']
comCoord = parseGeomData(csv2,path_to_csv)
[comX,comY] = xyFromList(comCoord)
# create dictionary and dataframe
comDict = {"comXCoordinates": comX,"comYCoordinates": comY, \
    "communityNumber":comNum, "communityName": comName,"communityArea":comArea}
comDf = pd.DataFrame(comDict)
# export as a csv
comDf.to_csv(path_to_csv + 'CommunityCoord.csv')

tmp = comDf['comXCoordinates']
#-------------------------------------------------------------------------------
#                 Create Zoning District Coordinates
#-------------------------------------------------------------------------------
# Define each community area in each of the 9 districts
path = "~/Desktop/"
f = 'comArea.txt'

df4 = pd.read_csv(path + f)

df4['District'].value_counts()

pw = 'Hadleyj1'
connection = pymysql.connect(host='localhost',
                             user='root',
                             password=pw,
                             db='ChicagoEnergy',
                             charset='utf8mb4',
                              )

northNumQ = '''SELECT * FROM DistrictKey WHERE District = 'North' '''
southNumQ = '''SELECT * FROM DistrictKey WHERE District = 'South' '''
southWestNumQ = '''SELECT * FROM DistrictKey WHERE District = 'SouthWest' '''
farSouthNumQ = '''SELECT * FROM DistrictKey WHERE District = 'FarSouth' '''
farNorthNumQ = '''SELECT * FROM DistrictKey WHERE District = 'FarNorth' '''
westNumQ = '''SELECT * FROM DistrictKey WHERE District = 'West' '''
northwestNumQ = '''SELECT * FROM DistrictKey WHERE District = 'NorthWest' '''
farSouthWestNumQ = '''SELECT * FROM DistrictKey WHERE District = 'FarSouthWest' '''
centralNumQ = '''SELECT * FROM DistrictKey WHERE District = 'Central' '''

northNum = pd.read_sql(sql = northNumQ, con = connection)
southNum = pd.read_sql(sql = southNumQ, con = connection)
southWestNum = pd.read_sql(sql = southWestNumQ, con = connection)
farSouthNum = pd.read_sql(sql = farSouthNumQ, con = connection)
farNorthNum = pd.read_sql(sql = farNorthNumQ, con = connection)
westNum = pd.read_sql(sql = westNumQ, con = connection)
northWestNum = pd.read_sql(sql = northwestNumQ, con = connection)
farSouthWestNum = pd.read_sql(sql = farSouthWestNumQ, con = connection)
centralNum = pd.read_sql(sql = centralNumQ, con = connection)

connection.close()

northNum

northSide = pd.merge(northNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
southSide = pd.merge(southNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
southWestSide = pd.merge(southWestNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
farSouthSide = pd.merge(farSouthNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
farNorthSide = pd.merge(farNorthNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
westSide = pd.merge(westNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
northWestSide = pd.merge(northWestNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
farSouthWestSide = pd.merge(farSouthWestNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
centralSide = pd.merge(centralNum,df2,left_on = "ComNum",right_on = "AREA_NUMBE")
