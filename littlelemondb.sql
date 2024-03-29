-- MySQL Script generated by MySQL Workbench
-- Thu Mar 14 22:41:23 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema LittleLemonDB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema LittleLemonDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `LittleLemonDB` DEFAULT CHARACTER SET utf8 ;
USE `LittleLemonDB` ;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Customers` (
  `CustomerID` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(45) NOT NULL,
  `LastName` VARCHAR(45) NOT NULL,
  `PhoneNumber` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Staff` (
  `StaffID` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(45) NOT NULL,
  `LastName` VARCHAR(45) NOT NULL,
  `Role` VARCHAR(45) NOT NULL,
  `Salary` DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (`StaffID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Bookings` (
  `BookingID` INT NOT NULL AUTO_INCREMENT,
  `BookingDate` DATETIME NOT NULL,
  `ReservationDate` DATETIME NOT NULL,
  `TableNumber` INT NOT NULL,
  `NumberOfGuests` INT NOT NULL,
  `CustomerID` INT NOT NULL,
  `StaffID` INT NOT NULL,
  PRIMARY KEY (`BookingID`),
  INDEX `customer_id_fk_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `staff_id_fk_idx` (`StaffID` ASC) VISIBLE,
  CONSTRAINT `customer_id_fk`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customers` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `staff_id_fk`
    FOREIGN KEY (`StaffID`)
    REFERENCES `LittleLemonDB`.`Staff` (`StaffID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`MenuTypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`MenuTypes` (
  `MenuTypeID` INT NOT NULL AUTO_INCREMENT,
  `MenuType` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`MenuTypeID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Cuisines`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Cuisines` (
  `CuisineID` INT NOT NULL AUTO_INCREMENT,
  `Cuisine` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CuisineID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Menus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Menus` (
  `MenuID` INT NOT NULL AUTO_INCREMENT,
  `MenuName` VARCHAR(45) NOT NULL,
  `MenuTypeID` INT NOT NULL,
  `CuisineID` INT NOT NULL,
  `Price` DECIMAL(6,2) NOT NULL,
  PRIMARY KEY (`MenuID`),
  INDEX `menutype_id_fk_idx` (`MenuTypeID` ASC) VISIBLE,
  INDEX `cuisine_id_fk_idx` (`CuisineID` ASC) VISIBLE,
  CONSTRAINT `menutype_id_fk`
    FOREIGN KEY (`MenuTypeID`)
    REFERENCES `LittleLemonDB`.`MenuTypes` (`MenuTypeID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `cuisine_id_fk`
    FOREIGN KEY (`CuisineID`)
    REFERENCES `LittleLemonDB`.`Cuisines` (`CuisineID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Orders` (
  `OrderID` INT NOT NULL AUTO_INCREMENT,
  `OrderDate` DATETIME NOT NULL,
  `MenuID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `TotalCost` DECIMAL(6,2) NOT NULL,
  `BookingID` INT NOT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `booking_id_fk_idx` (`BookingID` ASC) VISIBLE,
  INDEX `menu_id_fk_idx` (`MenuID` ASC) VISIBLE,
  CONSTRAINT `booking_id_fk`
    FOREIGN KEY (`BookingID`)
    REFERENCES `LittleLemonDB`.`Bookings` (`BookingID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `menu_id_fk`
    FOREIGN KEY (`MenuID`)
    REFERENCES `LittleLemonDB`.`Menus` (`MenuID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`DeliveryStatuses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`DeliveryStatuses` (
  `DeliveryStatusID` INT NOT NULL AUTO_INCREMENT,
  `Status` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`DeliveryStatusID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`OrderDeliveryStatuses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`OrderDeliveryStatuses` (
  `OrderDeliveryStatusID` INT NOT NULL AUTO_INCREMENT,
  `OrderID` INT NOT NULL,
  `DeliveryDate` DATETIME NOT NULL,
  `DeliveryStatusID` INT NOT NULL,
  PRIMARY KEY (`OrderDeliveryStatusID`),
  INDEX `order_id_fk_idx` (`OrderID` ASC) VISIBLE,
  INDEX `deliverystatus_id_fk_idx` (`DeliveryStatusID` ASC) VISIBLE,
  CONSTRAINT `order_id_fk`
    FOREIGN KEY (`OrderID`)
    REFERENCES `LittleLemonDB`.`Orders` (`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `deliverystatus_id_fk`
    FOREIGN KEY (`DeliveryStatusID`)
    REFERENCES `LittleLemonDB`.`DeliveryStatuses` (`DeliveryStatusID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
