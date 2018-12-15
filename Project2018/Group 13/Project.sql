DROP DATABASE IF EXISTS Python_Project;
CREATE DATABASE IF NOT EXISTS Python_Project;
USE Python_Project;
CREATE TABLE IF NOT EXISTS CITIBIKE_TRIPDATA(
    #ID int NOT NULL AUTO_INCREMENT,
    tripduration MEDIUMINT,
    starttime datetime,
    stoptime datetime,
    start_station_id MEDIUMINT,
    start_station_name VARCHAR(30),
    start_station_latitude FLOAT,
    start_station_longitude FLOAT,
    end_station_id MEDIUMINT,
    end_station_name VARCHAR(30),
    end_station_latitude FLOAT,
    end_station_longitude FLOAT,
    bikeid MEDIUMINT,
    usertype VARCHAR(20),
    birth_year VARCHAR(6),
    gender TINYINT
#    PRIMARY KEY(ID)
  );
  
#LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201703-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201704-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201705-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201706-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201707-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201708 citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201709-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201710-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201711-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201712-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201801-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201802-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201803-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201804-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201805-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201806-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201807-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201808-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201809-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201810-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'C:/Users/Vineel/Documents/UB/Python Project/Data/newJC-201811-citibike-tripdata.csv' INTO TABLE  CITIBIKE_TRIPDATA FIELDS TERMINATED BY ','  ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

#UPDATE CITIBIKE_TRIPDATA SET Date = starttime(Date, '%Y-%c-%e %H:%i:%s');
#ALTER TABLE CITIBIKE_TRIPDATA MODIFY Date datetime;

#show variables like 'local_infile';
#SET GLOBAL local_infile = 1;