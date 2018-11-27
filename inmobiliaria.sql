-- MySQL dump 10.13  Distrib 5.7.24, for Linux (x86_64)
--
-- Host: localhost    Database: inmobiliariagolden
-- ------------------------------------------------------
-- Server version	5.7.24-0ubuntu0.18.10.1

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
-- Table structure for table `asesores`
--

DROP TABLE IF EXISTS `asesores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asesores` (
  `idasesores` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `username` varchar(45) NOT NULL,
  `password` char(60) NOT NULL,
  `socio` tinyint(1) DEFAULT NULL,
  `foto` varchar(100) DEFAULT '../picture.png',
  `admin` tinyint(1) DEFAULT '0',
  `color` varchar(7) DEFAULT NULL,
  PRIMARY KEY (`idasesores`),
  UNIQUE KEY `username_UNIQUE` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asesores`
--

LOCK TABLES `asesores` WRITE;
/*!40000 ALTER TABLE `asesores` DISABLE KEYS */;
INSERT INTO `asesores` VALUES (1,'admin','6182587545','admin','$2a$10$EYw76f0NZ1EMRifrauVSV.BEf7Z0rONv9mihv3XmDLvSBP9mwBPiO',1,'../picture.png',1,'#FF4336'),(23,'Xóchitl Beatriz Lara Miranda','6181194886','xolara','$2a$10$aIgdHjEaXZOJxp9uGyp8mO3BdEyvMu741izobk0.4gLOlsUG3IQVi',1,'../picture.png',0,'#CB67CC');
/*!40000 ALTER TABLE `asesores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `citas`
--

DROP TABLE IF EXISTS `citas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `citas` (
  `idcita` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `inicio` datetime NOT NULL,
  `fin` datetime NOT NULL,
  `asesores_idasesores` int(10) unsigned NOT NULL,
  PRIMARY KEY (`idcita`),
  KEY `asesores_idasesores` (`asesores_idasesores`),
  CONSTRAINT `citas_ibfk_1` FOREIGN KEY (`asesores_idasesores`) REFERENCES `asesores` (`idasesores`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `citas`
--

LOCK TABLES `citas` WRITE;
/*!40000 ALTER TABLE `citas` DISABLE KEYS */;
/*!40000 ALTER TABLE `citas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fotos`
--

DROP TABLE IF EXISTS `fotos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fotos` (
  `idfotos` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(200) DEFAULT '../picture.png',
  `propiedades_idpropiedades` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`idfotos`),
  KEY `fk_fotos_1_idx` (`propiedades_idpropiedades`) USING BTREE,
  CONSTRAINT `fotos_ibfk_1` FOREIGN KEY (`propiedades_idpropiedades`) REFERENCES `propiedades` (`idpropiedades`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fotos`
--

LOCK TABLES `fotos` WRITE;
/*!40000 ALTER TABLE `fotos` DISABLE KEYS */;
INSERT INTO `fotos` VALUES (1,'/fotoscasas/c4e05e2adc037463e53404a25eeaa4e4',126),(2,'/fotoscasas/2e1ef149701933a872dd1f4b9beb10a5',126),(3,'/fotoscasas/de2630a0058516bf0e3ead2dbcbd33ec',126),(4,'/fotoscasas/0a7361884c08e1cf386c123656d2833f',126),(5,'/fotoscasas/0249ba11ffd604d04125b3ad899f75bf',126),(6,'/fotoscasas/2baac01ea6cacc13f07348d7a9569a09',126),(7,'/fotoscasas/023d6fa6e820004c9a9881cefb71abdf',126),(8,'/fotoscasas/5d23a441f2bc081b1eeab23d02d92691',126);
/*!40000 ALTER TABLE `fotos` ENABLE KEYS */;
UNLOCK TABLES;

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
  `metrosconstruidos` double DEFAULT NULL,
  `recamaras` int(11) DEFAULT '0',
  `baños` varchar(11) DEFAULT '0',
  `cochera` int(11) DEFAULT '0',
  `descripcion` varchar(1000) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `latitud` double DEFAULT NULL,
  `longitud` double DEFAULT NULL,
  `renta` tinyint(1) DEFAULT '1',
  `vendida` tinyint(1) DEFAULT '0',
  `fechaventa` date DEFAULT NULL,
  `fechacreacion` date DEFAULT NULL,
  `url` varchar(100) DEFAULT '../picture.png',
  `asesores_idasesores` int(10) unsigned NOT NULL,
  PRIMARY KEY (`idpropiedades`,`asesores_idasesores`),
  KEY `asesores_idasesores` (`asesores_idasesores`),
  CONSTRAINT `propiedades_ibfk_1` FOREIGN KEY (`asesores_idasesores`) REFERENCES `asesores` (`idasesores`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `propiedades`
--

LOCK TABLES `propiedades` WRITE;
/*!40000 ALTER TABLE `propiedades` DISABLE KEYS */;
INSERT INTO `propiedades` VALUES (126,'casa','CASA  DE UNA PLANTA EN VENTA',720000,120,75,2,'1',1,'EXCELENTE PROPIEDAD UBICADA EN ZONA TRANQUILA, SE ENCUENTRA EN MUY BUENAS CONDICIONES,LAS RECAMARAS MUY AMPLIAS Y CLOSETS, COCINA INTEGRAL CON CUBIERTA DE MÁRMOL Y BARRA DESAYUNADORA, DOS PATIOS, UNO PEQUEÑO DE LAVANDERÍA Y OTRO AMPLIO PARA MASCOTAS U OTRAS NECESIDADES, MAYORES INFORMES Y CITAS AL 6181194886 O AL TEL DE OFICINA 6188120631 ','FRACC ATENAS',24.0450048,-104.59684870000001,0,0,NULL,'2018-11-26','/fotoscasas/709d680a1bc7fe1680814f700f7e0a62',23);
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

-- Dump completed on 2018-11-27 18:46:10
