-- Forward Engineer
/*-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema clube
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema clube
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `clube` DEFAULT CHARACTER SET utf8 ;
-- -----------------------------------------------------
-- Schema test
-- -----------------------------------------------------
USE `clube` ;

-- -----------------------------------------------------
-- Table `clube`.`tipoSocio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`tipoSocio` (
  `id_tipoSocio` INT NOT NULL AUTO_INCREMENT,
  `tipoSocio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_tipoSocio`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`tipoDependencia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`tipoDependencia` (
  `id_tipoDependencia` INT NOT NULL AUTO_INCREMENT,
  `tipoDependencia` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_tipoDependencia`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`socio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`socio` (
  `id_socio` INT NOT NULL AUTO_INCREMENT,
  `tipoSocio_id_tipoSocio` INT NOT NULL,
  `socio_id_socio` INT NOT NULL,
  `tipoDependencia_id_tipoDependencia` INT NOT NULL,
  `matricula` VARCHAR(10) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `dataNascimento` DATE NOT NULL,
  `sexo` VARCHAR(1) NULL,
  `endereco` VARCHAR(45) NULL,
  PRIMARY KEY (`id_socio`),
  UNIQUE INDEX `matricula_socio_UNIQUE` (`matricula` ASC) VISIBLE,
  INDEX `fk_socio_tipoSocio_idx` (`tipoSocio_id_tipoSocio` ASC) VISIBLE,
  INDEX `fk_socio_socio_idx` (`socio_id_socio` ASC) VISIBLE,
  INDEX `fk_socio_tipoDependencia_idx` (`tipoDependencia_id_tipoDependencia` ASC) VISIBLE,
  CONSTRAINT `fk_socio_tipoSocio1`
    FOREIGN KEY (`tipoSocio_id_tipoSocio`)
    REFERENCES `clube`.`tipoSocio` (`id_tipoSocio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_socio_socio1`
    FOREIGN KEY (`socio_id_socio`)
    REFERENCES `clube`.`socio` (`id_socio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_socio_tipoDependencia1`
    FOREIGN KEY (`tipoDependencia_id_tipoDependencia`)
    REFERENCES `clube`.`tipoDependencia` (`id_tipoDependencia`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`tipoContato`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`tipoContato` (
  `id_tipoContato` INT NOT NULL AUTO_INCREMENT,
  `tipoContatocol` VARCHAR(45) NULL,
  PRIMARY KEY (`id_tipoContato`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`contato`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`contato` (
  `id_contato` INT NOT NULL AUTO_INCREMENT,
  `socio_id_socio` INT NOT NULL,
  `contato` INT NOT NULL,
  `tipoContato_id_tipoContato` INT NOT NULL,
  INDEX `fk_contato_socio_idx` (`socio_id_socio` ASC) VISIBLE,
  PRIMARY KEY (`id_contato`),
  INDEX `fk_contato_tipoContato_idx` (`tipoContato_id_tipoContato` ASC) VISIBLE,
  CONSTRAINT `fk_contato_socio`
    FOREIGN KEY (`socio_id_socio`)
    REFERENCES `clube`.`socio` (`id_socio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_contato_tipoContato1`
    FOREIGN KEY (`tipoContato_id_tipoContato`)
    REFERENCES `clube`.`tipoContato` (`id_tipoContato`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`endereco`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`endereco` (
  `id_endereco` INT NOT NULL AUTO_INCREMENT,
  `pais` VARCHAR(45) NOT NULL,
  `sigla` CHAR(2) NULL,
  `estado` VARCHAR(45) NULL,
  `municipio` VARCHAR(45) NULL,
  `bairro` VARCHAR(45) NULL,
  `CEP` INT NULL,
  PRIMARY KEY (`id_endereco`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`socio-endereco`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`socio-endereco` (
  `socio_id_socio` INT NOT NULL,
  `endereco_id_endereco` INT NOT NULL,
  `enderecoPrincipal` VARCHAR(1) NULL,
  PRIMARY KEY (`socio_id_socio`, `endereco_id_endereco`),
  INDEX `fk_socio-endereco_endereco_idx` (`endereco_id_endereco` ASC) VISIBLE,
  CONSTRAINT `fk_socio-endereco_socio1`
    FOREIGN KEY (`socio_id_socio`)
    REFERENCES `clube`.`socio` (`id_socio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_socio-endereco_endereco1`
    FOREIGN KEY (`endereco_id_endereco`)
    REFERENCES `clube`.`endereco` (`id_endereco`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`tipoPagamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`tipoPagamento` (
  `id_tipoPagamento` INT NOT NULL AUTO_INCREMENT,
  `tipoPagamento` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_tipoPagamento`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clube`.`pagamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `clube`.`pagamento` (
  `id_pagamento` INT NOT NULL AUTO_INCREMENT,
  `socio_id_socio` INT NOT NULL,
  `tipoPagamento_id_tipoPagamento` INT NOT NULL,
  `dataPagamentoEfetiva` DATE NULL,
  `valorPagamento` DECIMAL(6,2) NULL,
  PRIMARY KEY (`id_pagamento`),
  INDEX `fk_pagamento_socio_idx` (`socio_id_socio` ASC) VISIBLE,
  INDEX `fk_pagamento_tipoPagamento_idx` (`tipoPagamento_id_tipoPagamento` ASC) VISIBLE,
  CONSTRAINT `fk_pagamento_socio1`
    FOREIGN KEY (`socio_id_socio`)
    REFERENCES `clube`.`socio` (`id_socio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_pagamento_tipoPagamento1`
    FOREIGN KEY (`tipoPagamento_id_tipoPagamento`)
    REFERENCES `clube`.`tipoPagamento` (`id_tipoPagamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;*/