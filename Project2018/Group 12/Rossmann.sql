show databases;
DROP DATABASE IF EXISTS Rossmann_Store;
CREATE DATABASE IF NOT EXISTS Rossmann_Store;
USE Rossmann_Store;
show tables;

CREATE TABLE IF NOT EXISTS Store(
  Store INT,
  StoreType varchar(64),
  Assortment varchar(64),
  CompetitionDistance varchar(64),
  CompetitionOpenSinceMonth varchar(64),
  CompetitionOpenSinceYear varchar(64),
  Promo2 INT,
  Promo2SinceWeek varchar(64),
  Promo2SinceYear varchar(64),
  PromoInterval char(64),
  PRIMARY KEY(Store)
  );
LOAD DATA LOCAL INFILE 'store.csv' INTO TABLE  Store FIELDS TERMINATED BY ','  ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

select * from Store;

CREATE TABLE Sales(
  Store INT,
  Date VARCHAR(64),
  DayOfWeek INT,
  Sales INT,
  Customers INT,
  Open INT,
  Promo INT,
  StateHoliday varchar(64),
  SchoolHoliday INT,
  PRIMARY KEY(Store,Date),
  FOREIGN KEY (Store)  REFERENCES Store (Store)
  );
LOAD DATA LOCAL INFILE 'train.csv' INTO TABLE  Sales FIELDS TERMINATED BY ',' ESCAPED BY '"' IGNORE 1 LINES;
UPDATE Sales SET Date = STR_TO_DATE(Date, '%c/%e/%Y');
ALTER TABLE Sales MODIFY Date date;

CREATE TABLE IF NOT EXISTS Rossmann_Store_DataWarehouse(
  Store int,
  Date VARCHAR(10),
  DayOfWeek int,
  Sales int,
  Customers int,
  Open int,
  Promo int,
  StateHoliday char(1),
  SchoolHoliday int,
  StoreType char(1),
  Assortment char(1),
  CompetitionDistance int,
  CompetitionOpenSinceMonth int,
  CompetitionOpenSinceYear int,
  Promo2 int,
  Promo2SinceWeek int,
  Promo2SinceYear int,
  PromoInterval char(64),
  PRIMARY KEY(Store,Date)
  );
  LOAD DATA LOCAL INFILE 'store_data_DW.csv' INTO TABLE  Store FIELDS TERMINATED BY ','  ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
  UPDATE Rossmann_Store_DataWarehouse SET Date = STR_TO_DATE(Date, '%c/%e/%Y');
  ALTER TABLE Rossmann_Store_DataWarehouse MODIFY Date date;

select count(*) from store where trim(CompetitionDistance) = '';


Select * from Sales where Sales = 0 and Open = 0;
select count(*) as Rows_SalesData_afterDeletion from Sales;

select * from Store where trim(Promo2SinceWeek) = "";


CREATE TABLE IF NOT EXISTS Rossmann_Store_DataWarehouse(
  Store int,
  Date VARCHAR(10),
  DayOfWeek int,
  Sales int,
  Customers int,
  Open int,
  Promo int,
  StateHoliday char(1),
  SchoolHoliday int,
  StoreType char(1),
  Assortment char(1),
  CompetitionDistance int,
  CompetitionOpenSinceMonth int,
  CompetitionOpenSinceYear int,
  Promo2 int,
  Promo2SinceWeek int,
  Promo2SinceYear int,
  PromoInterval char(64),
  PRIMARY KEY(Store,Date)
  );
  UPDATE Sales SET Date = STR_TO_DATE(Date, '%c/%e/%Y');
ALTER TABLE Sales MODIFY Date date;


select PromoInterval from Store limit 10;



select * from Rossmann_Store_DataWarehouse;

select sa.Store as Store, Date, DayOfWeek, Sales, Customers, Open, Promo, StateHoliday, SchoolHoliday, StoreType, Assortment, CompetitionDistance, CompetitionOpenSinceMonth, CompetitionOpenSinceYear, Promo2, Promo2SinceWeek, Promo2SinceYear, PromoInterval from Sales sa join Store st on sa.Store = st.Store;



show tables;
select * from Rossmann_Store_DataWarehouse

