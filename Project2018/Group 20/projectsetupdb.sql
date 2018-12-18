DROP DATABASE IF EXISTS food;
CREATE DATABASE IF NOT EXISTS food;
USE food;

CREATE TABLE IF NOT EXISTS FOOD_INSPECTIONS(
  Inspection_ID INT,
  DBA_Name VARCHAR(256),
  AKA_Name VARCHAR(256),
  License  INT,
  Facility_Type VARCHAR(256),
  Risk VARCHAR(256),
  Address VARCHAR(256),
  City VARCHAR(256),
  State VARCHAR(256),
  Zip INT,
  Inspection_Date VARCHAR(256),
  Inspection_Type VARCHAR(256),
  Results VARCHAR(256),
  Latitude FLOAT,
  Longitude FLOAT,
  Location CHAR(64),
  PRIMARY KEY(Inspection_ID)
);
LOAD DATA LOCAL INFILE 'C:/Users/Mohan/Documents/EAS503-Project/Food_Inspections_sql.csv' INTO TABLE FOOD_INSPECTIONS 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
UPDATE FOOD_INSPECTIONS SET Inspection_Date = STR_TO_DATE(Inspection_Date, '%c/%e/%Y');
ALTER TABLE FOOD_INSPECTIONS MODIFY Inspection_Date datetime;