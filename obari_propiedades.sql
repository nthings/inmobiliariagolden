CREATE DATABASE  IF NOT EXISTS `obari` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `obari`;
-- MySQL dump 10.13  Distrib 5.5.53, for debian-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: obari
-- ------------------------------------------------------
-- Server version	5.5.53-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `propiedades`
--

DROP TABLE IF EXISTS `propiedades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `propiedades` (
  `idpropiedades` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tipo` varchar(45) DEFAULT NULL,
  `nombrepropiedad` varchar(100) DEFAULT NULL,
  `precio` double DEFAULT NULL,
  `m2` double DEFAULT NULL,
  `recamaras` int(11) DEFAULT NULL,
  `baños` int(11) DEFAULT NULL,
  `descripcion` varchar(1000) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `latitud` double DEFAULT NULL,
  `longitud` double DEFAULT NULL,
  `renta` tinyint(1) DEFAULT '1',
  `vendida` tinyint(1) DEFAULT NULL,
  `fechaventa` date DEFAULT NULL,
  `fechacreacion` date DEFAULT NULL,
  `url` varchar(100) DEFAULT '../picture.png',
  `asesores_idasesores` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`idpropiedades`,`asesores_idasesores`),
  KEY `fk_propiedades_asesores_idx` (`asesores_idasesores`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `propiedades`
--

LOCK TABLES `propiedades` WRITE;
/*!40000 ALTER TABLE `propiedades` DISABLE KEYS */;
INSERT INTO `propiedades` VALUES (41,'casa','Excelente casa en Fracc. Brisas',850000,250,2,1,'Casa accesible en fracc. brisas','Sicilia #123 Fracc. Brisas',24.052418814954926,-104.60641097553253,0,0,'2016-11-03','2016-11-01','/fotoscasas/8d17125e06d3adb5850e671774a60bda',8),(42,'terreno','Terreno En Carretera México',2000000,1500,0,0,'Terreno excelente para agricultura','Carretera México Km 15',24.026073929391917,-104.57266671420899,0,0,NULL,'2016-11-04','/fotoscasas/93fcbc6ce872caa07b4abaf60f9639ba',8);
/*!40000 ALTER TABLE `propiedades` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-11-04 13:33:55
