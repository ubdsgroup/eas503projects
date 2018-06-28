# Author: Joseph Hadley
# Date Created: 2017-11-29
# Date Modified: 2017-11-29
# Description:  Use SQL to get data and make plots using basemap using plotting
#               function
#------------------------------------------------------------------------------
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import pandas as pd
from mpl_toolkits.basemap import Basemap
import pymysql as pymysql
#import mpld3 as mpld3
#------------------------------------------------------------------------------
#                               Functions
#------------------------------------------------------------------------------
# parse string of coordinates into list of flaot64 numpy arrays
def parseCoord(coord):
    parsedCoord = []
    for i in range(len(coord)):
        tmp = coord[i]
        tmp = tmp.replace(tmp[0],"")
        tmp = tmp.replace(tmp[len(tmp)-1],"")
        # remove \n's
        tmp = tmp.replace('\n',"")
        # remove extra spaces to split correctly
        tmp = ' '.join(tmp.split())
        # split
        tmp = tmp.split(" ")
        # convert each item in list to float
        tmp = list(map(float, tmp))
        parsedCoord.append(np.array(tmp,dtype = np.float64))
    return parsedCoord
#--------------------------------End-FUNC--------------------------------------
def basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap):
    # clear the variable patches
    xCoord = borderBounds[0]
    yCoord = borderBounds[1]
    patches = []
    fig, ax = plt.subplots(figsize=(20,10)) # create a subplot
    plt.title(title)
    # create the base map
    m = Basemap(projection = "lcc", lon_0 = mapBounds[0],lat_0 = mapBounds[1],\
        resolution = 'l',llcrnrlat = mapBounds[2],llcrnrlon = mapBounds[3],\
        urcrnrlat = mapBounds[4],urcrnrlon = mapBounds[5])
    # Create patches
    for i in range(0,77):
        # Put Coordinates on the map axis
        X, Y  = m(xCoord[i], yCoord[i])
        xy = np.vstack([X,Y]).T
        # create polygon in the axis
        polygon = Polygon( xy, True)
        patches.append(polygon)
    # Add Border to boundaries
    for i in range(len(xCoord)):
        m.plot(xCoord[i],yCoord[i], latlon = True, color = 'k',linewidth = 1,zorder = 3)
    # Color Patches
    p = PatchCollection(patches, cmap=cmap, zorder=2)
    colors = data
    p.set_array(np.array(colors))
    #grab current axis and place polygons
    plt.gca().add_collection(p)
    plt.gca().axis("off")
    # add a colorbar
    cax = fig.add_axes([0.65, 0.125, 0.01, 0.75]) # Where to place ColorBar
    norm = mpl.colors.Normalize(vmin = data.min(),vmax = data.max()) # normalize data for colorbar
    cb = mpl.colorbar.ColorbarBase(cax, cmap = cmap,norm = norm,orientation = 'vertical') # colorbar settings
    cb.set_label(cbLabel) # place the colorbar
    #plt.savefig('foo.png', bbox_inches='tight')
    plt.show()
#------------------------------------------------------------------------------
#                               Get Data
#------------------------------------------------------------------------------
path = "~/Documents/Programs/Python/eas503-project/data/"
f1 = "CommunityCoord.csv"
dfCoord = pd.read_csv(path + f1)
# get Boundary Coordinates of Community Areas
dfCoord = dfCoord.sort_values("communityName") # sort by alphabetical order
dfCoord = dfCoord.reset_index(drop = True)
xCoord = dfCoord['comXCoordinates']
yCoord = dfCoord['comYCoordinates']
xCoord = parseCoord(xCoord)
yCoord = parseCoord(yCoord)

pw = 'Hadleyj1'

# Setup sql connection
connection = pymysql.connect(host='localhost',
                             user='root',
                             password=pw,
                             db='ChicagoEnergy',
                             charset='utf8mb4',
                              )
districtsQuery = '''SELECT * FROM Districts'''
# Queries to get data of interest
resTotKwhQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_KWH) AS TOT_KWH
	FROM CensusBlocks
	WHERE BUILDING_TYPE = 'Residential'
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
comTotKwhQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_KWH) AS TOT_KWH
	FROM CensusBlocks
	WHERE BUILDING_TYPE = 'Commercial'
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
indTotKwhQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_KWH) AS TOT_KWH
	FROM CensusBlocks
	WHERE BUILDING_TYPE = 'Industrial'
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
totKwhQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_KWH) AS TOT_KWH
	FROM CensusBlocks
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
resTotThermQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_THERMS) AS TOT_THERM
	FROM CensusBlocks
	WHERE BUILDING_TYPE = 'Residential'
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
comTotThermQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_THERMS) AS TOT_THERM
	FROM CensusBlocks
	WHERE BUILDING_TYPE = 'Commercial'
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
indTotThermQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_THERMS) AS TOT_THERM
	FROM CensusBlocks
	WHERE BUILDING_TYPE = 'Industrial'
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
totThermQuery = '''SELECT COMMUNITY_AREA_NAME,SUM(TOTAL_THERMS) AS TOT_THERM
	FROM CensusBlocks
	GROUP BY COMMUNITY_AREA_NAME
	ORDER BY COMMUNITY_AREA_NAME;'''
# Use pandas and SQL queries above to grab data to plot
districts = pd.read_sql(sql = districtsQuery,con = connection)
resTotKwh = pd.read_sql(sql = resTotKwhQuery, con = connection)
comTotKwh = pd.read_sql(sql = comTotKwhQuery, con = connection)
indTotKwh = pd.read_sql(sql = indTotKwhQuery, con = connection)
totKwh = pd.read_sql(sql = totKwhQuery, con = connection)
resTotTherm = pd.read_sql(sql = resTotThermQuery, con = connection)
comTotTherm = pd.read_sql(sql = comTotThermQuery, con = connection)
indTotTherm = pd.read_sql(sql = indTotThermQuery, con = connection)
totTherm = pd.read_sql(sql = totThermQuery, con = connection)
# close connection to database
connection.close()

districts.head()
#------------------------------------------------------------------------------
#                               Make Plot(s)
#------------------------------------------------------------------------------
# Initialze variables to use plotting function
lon_0 = -87
lat_0 = 42
llX = 41.6
llY = -87.95
urX = 42.05
urY = -87.4
mapBounds = [lon_0,lat_0,llX,llY,urX,urY]
borderBounds = [xCoord,yCoord]
cmap = mpl.cm.viridis
#Community Data and coordinates are put in alphabetical order so don't need to merge

#%% # Residentaial power
data = resTotKwh['TOT_KWH']
title = "Residential Power Usage"
cbLabel = "Power Usage (Kwh)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
# commercial Power
#%%
data = comTotKwh['TOT_KWH']
title = "Commercial Power Usage"
cbLabel = "Power Usage (Kwh)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
# Industrial Power
#%%
data = indTotKwh['TOT_KWH']
title = "Industrial Power Usage"
cbLabel = "Power Usage (Kwh)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
# Total Power
#%%
data = totKwh['TOT_KWH']
title = "Total Power Usage"
cbLabel = "Power Usage (Kwh)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
# Plot heat data0

#%% # Residentaial heat
data = resTotTherm['TOT_THERM']
title = "Residential Heat Usage"
cbLabel = "Heat Usage (Therms)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
# commercial heat
#%%
data = comTotTherm['TOT_THERM']
title = "Commercial Heat Usage"
cbLabel = "Heat Usage (Therms)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
# Industrial Power
#%%
data = indTotTherm['TOT_THERM']
title = "Industrial Heat Usage"
cbLabel = "Heat Usage (Therms)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
#%%
data = totTherm['TOT_THERM']
title = "Total Heat Usage"
cbLabel = "Heat Usage (Therms)"
basemapPlotColormap(data,mapBounds,borderBounds,title,cbLabel,cmap)
#%%
