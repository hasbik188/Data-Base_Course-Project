-- Запросы на создание БД и таблиц

create database mts;

CREATE TABLE IF NOT EXISTS mts.`Город` (
  `Код_города` CHAR(5) NOT NULL,
  `Название_города` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Код_города`)
);

CREATE TABLE IF NOT EXISTS mts.`Клиент` (
  `Номер_телефона` CHAR(11) NOT NULL,
  `Фамилия` VARCHAR(45) NOT NULL,
  `Имя` VARCHAR(45) NOT NULL,
  `Отчество` VARCHAR(45) NULL,
  `Дата_регистрации` DATE NOT NULL,
  `Адрес_регистрации` VARCHAR(45) NOT NULL,
  `Код_города` CHAR(5) NOT NULL,

  PRIMARY KEY (`Номер_телефона`),
  CONSTRAINT `fk_Клиент_Город1`
    FOREIGN KEY (`Код_города`)
    REFERENCES `Город` (`Код_города`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS mts.`Тариф` (
  `Код_тарифа` INT NOT NULL AUTO_INCREMENT,
  `Стоимость_мин` DECIMAL(12,2) NOT NULL,
  `Льготная_стоимость_мин` DECIMAL(12,2) NOT NULL,
  `Дата_тарифа` DATE NOT NULL,
  `Код_города` CHAR(5) NOT NULL,

  PRIMARY KEY (`Код_тарифа`, `Код_города`),
  CONSTRAINT `fk_Тариф_Город1`
    FOREIGN KEY (`Код_города`)
    REFERENCES `Город` (`Код_города`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS mts.`Звонок` (
  `Код_звонка` INT NOT NULL AUTO_INCREMENT,
  `Дата_звонка` DATE NOT NULL,
  `Время_звонка` TIME NOT NULL,
  `Длительность_звонка` INT NOT NULL,
  `Номер_телефона` CHAR(11) NOT NULL,
  `Код_тарифа` INT NOT NULL,
  `Код_города` CHAR(5) NOT NULL,

  PRIMARY KEY (`Код_звонка`),
  CONSTRAINT `fk_Звонок_Клиент1`
    FOREIGN KEY (`Номер_телефона`)
    REFERENCES `Клиент` (`Номер_телефона`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Звонок_Тариф1`
    FOREIGN KEY (`Код_тарифа` , `Код_города`)
    REFERENCES `Тариф` (`Код_тарифа` , `Код_города`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS mts.`Квитанция` (
  `Код_квитанции` INT NOT NULL AUTO_INCREMENT,
  `Дата_выставления` DATETIME NOT NULL,
  `Дата_оплаты` DATETIME NOT NULL,
  `Сумма_к_оплате` DECIMAL(12,2) NOT NULL,
  `Код_звонка` INT NOT NULL,

  PRIMARY KEY (`Код_квитанции`),
  CONSTRAINT `fk_Квитанция_Звонок1`
    FOREIGN KEY (`Код_звонка`)
    REFERENCES `Звонок` (`Код_звонка`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);