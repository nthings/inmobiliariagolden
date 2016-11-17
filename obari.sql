/*
Navicat MySQL Data Transfer

Source Server         : Obari
Source Server Version : 50713
Source Host           : 159.203.16.191:3306
Source Database       : obari

Target Server Type    : MYSQL
Target Server Version : 50713
File Encoding         : 65001

Date: 2016-11-17 11:42:06
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for asesores
-- ----------------------------
DROP TABLE IF EXISTS `asesores`;
CREATE TABLE `asesores` (
  `idasesores` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `username` varchar(45) NOT NULL,
  `password` char(60) NOT NULL,
  `socio` tinyint(1) DEFAULT NULL,
  `foto` varchar(100) DEFAULT '../picture.png',
  PRIMARY KEY (`idasesores`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of asesores
-- ----------------------------
INSERT INTO `asesores` VALUES ('8', 'Asesor de Prueba', '6182587545', 'admin', '$2a$10$XQu./ZFpPAXe7u9rGDkaaujTHcr5htosc3HXAICdxpYuIDXevyqU.', '1', '/fotoscasas/c3ae172f29eb4c32398a43d6dac87f68');

-- ----------------------------
-- Table structure for fotos
-- ----------------------------
DROP TABLE IF EXISTS `fotos`;
CREATE TABLE `fotos` (
  `idfotos` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(200) DEFAULT '../picture.png',
  `propiedades_idpropiedades` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`idfotos`),
  KEY `fk_fotos_1_idx` (`propiedades_idpropiedades`),
  CONSTRAINT `fk_fotos_1` FOREIGN KEY (`propiedades_idpropiedades`) REFERENCES `propiedades` (`idpropiedades`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of fotos
-- ----------------------------
INSERT INTO `fotos` VALUES ('52', '/fotoscasas/5a2a0a347a9517eb5eb5bac5fdc43bcf', '41');
INSERT INTO `fotos` VALUES ('53', '/fotoscasas/ee76d70427576b25670a1d028b11a330', '41');
INSERT INTO `fotos` VALUES ('54', '/fotoscasas/660ab6556f0f559ad25f41d2748913b8', '41');
INSERT INTO `fotos` VALUES ('55', '/fotoscasas/c01c832a2a25e271637629acd118ec4f', '41');
INSERT INTO `fotos` VALUES ('56', '/fotoscasas/31cace594302a2302e9cec20b7bc2bb0', '41');
INSERT INTO `fotos` VALUES ('57', '/fotoscasas/263bc0e9061d68420b082bea734a709a', '42');

-- ----------------------------
-- Table structure for propiedades
-- ----------------------------
DROP TABLE IF EXISTS `propiedades`;
CREATE TABLE `propiedades` (
  `idpropiedades` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tipo` varchar(45) DEFAULT NULL,
  `nombrepropiedad` varchar(100) DEFAULT NULL,
  `precio` double DEFAULT NULL,
  `m2` double DEFAULT NULL,
  `recamaras` int(11) DEFAULT '0',
  `baños` int(11) DEFAULT '0',
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
  `asesores_idasesores` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`idpropiedades`,`asesores_idasesores`),
  KEY `fk_propiedades_asesores_idx` (`asesores_idasesores`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of propiedades
-- ----------------------------
INSERT INTO `propiedades` VALUES ('41', 'casa', 'Excelente casa en Fracc. Brisas', '850000', '250', '2', '1', '2', 'Casa accesible en fracc. brisas', 'Sicilia #123 Fracc. Brisas', '24.052418814954926', '-104.60641097553253', '0', '0', '2016-11-16', '2016-11-01', '/fotoscasas/8d17125e06d3adb5850e671774a60bda', '8');
INSERT INTO `propiedades` VALUES ('42', 'terreno', 'Terreno En Carretera México', '2000000', '1500', '0', '0', '0', 'Terreno excelente para agricultura', 'Carretera México Km 15', '24.026073929391917', '-104.57266671420899', '0', '0', '2016-11-10', '2016-11-04', '/fotoscasas/93fcbc6ce872caa07b4abaf60f9639ba', '8');
