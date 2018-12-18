-- MySQL dump 10.13  Distrib 8.0.13, for Win64 (x86_64)
--
-- Host: localhost    Database: project_schema
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aisles`
--

DROP TABLE IF EXISTS `aisles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `aisles` (
  `aisle_id` int(11) DEFAULT NULL,
  `aisle` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `departments` (
  `department_id` int(11) DEFAULT NULL,
  `department` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_products__prior`
--

DROP TABLE IF EXISTS `order_products__prior`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `order_products__prior` (
  `product_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `add_to_cart_order` int(11) NOT NULL,
  `reordered` int(11) DEFAULT NULL,
  PRIMARY KEY (`product_id`,`order_id`),
  KEY `idx_order_products__prior_product_id` (`product_id`),
  KEY `idx_order_products__prior_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_products__prior3`
--

DROP TABLE IF EXISTS `order_products__prior3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `order_products__prior3` (
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `add_to_cart_order` int(11) DEFAULT NULL,
  `reordered` int(11) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `idx_order_products__prior3_order_id` (`order_id`),
  KEY `idx_order_products__prior3_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_products__train`
--

DROP TABLE IF EXISTS `order_products__train`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `order_products__train` (
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `add_to_cart_order` int(11) DEFAULT NULL,
  `reordered` int(11) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `idx_order_products__train_order_id` (`order_id`),
  KEY `idx_order_products__train_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orderproductsmillionrecords`
--

DROP TABLE IF EXISTS `orderproductsmillionrecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orderproductsmillionrecords` (
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `add_to_cart_order` int(11) DEFAULT NULL,
  `reordered` int(11) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `idx_orderproductsmillionrecords_product_id` (`product_id`),
  KEY `idx_orderproductsmillionrecords_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `eval_set` text,
  `order_number` int(11) DEFAULT NULL,
  `order_dow` int(11) DEFAULT NULL,
  `order_hour_of_day` text,
  `days_since_prior_order` text,
  PRIMARY KEY (`order_id`,`user_id`),
  KEY `idx_orders_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders2`
--

DROP TABLE IF EXISTS `orders2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders2` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `eval_set` text,
  `order_number` int(11) DEFAULT NULL,
  `order_dow` int(11) DEFAULT NULL,
  `order_hour_of_day` double DEFAULT NULL,
  `days_since_prior_order` double DEFAULT NULL,
  PRIMARY KEY (`order_id`,`user_id`),
  KEY `idx_orders2_order_id` (`order_id`),
  KEY `idx_orders2_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `product_name` text,
  `aisle_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmpo`
--

DROP TABLE IF EXISTS `tmpo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `tmpo` (
  `order_dow` varchar(50) DEFAULT NULL,
  `totalNoOfOrders` bigint(21) NOT NULL DEFAULT '0',
  `noOfReordered` decimal(32,0) DEFAULT NULL,
  `reorderpct` decimal(39,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-12-04 16:57:37
