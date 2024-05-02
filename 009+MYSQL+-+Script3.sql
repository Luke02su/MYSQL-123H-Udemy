/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/
==================================================================================*/

-- -----------------------------------------------------
-- Schema CLIENTE2
-- -----------------------------------------------------
-- DDL: 
CREATE SCHEMA IF NOT EXISTS `CLIENTE2` ;
USE `CLIENTE2` ;

-- -----------------------------------------------------
-- Table `CLIENTE`.`Supplier`
-- -----------------------------------------------------
CREATE TABLE  IF NOT EXISTS `CLIENTE2`.`supplier` (
  `id` int NOT NULL ,
  `companyname` varchar(40)  NULL,
  `contactname` varchar(50)  NULL,
  `contacttitle` varchar(40) NULL,
  `city` varchar(40)  NULL,
  `country` varchar(40) NULL,
  `phone` varchar(30)  NULL,
  `fax` varchar(30) NULL,
  PRIMARY KEY (`id`)
) ;



-- -----------------------------------------------------
-- Table `CLIENTE`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CLIENTE2`.`product` (
  `id` INT NOT NULL ,
  `productname` VARCHAR(50) NULL,
  `supplierid` INT NOT NULL,
  `unitprice` DECIMAL(12,2) NULL,
  `package` VARCHAR(30) NULL,
  `isdiscontinued` BIT NULL,
  PRIMARY KEY (`id`),
  -- INDEX `fk_product_Supplier1_idx` (`supplierid` ASC) VISIBLE,
  CONSTRAINT `fk_product_Supplier1`
    FOREIGN KEY (`supplierid`)
    REFERENCES `CLIENTE2`.`Supplier` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT);


-- -----------------------------------------------------
-- Table `CLIENTE`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CLIENTE2`.`customer` (
  `id` INT NOT NULL ,
  `firstname` VARCHAR(40) NULL,
  `lastname` VARCHAR(40) NULL,
  `city` VARCHAR(40) NULL,
  `country` VARCHAR(40) NULL,
  `phone` VARCHAR(20) NULL,
  PRIMARY KEY (`id`));


-- -----------------------------------------------------
-- Table `CLIENTE`.`order`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CLIENTE2`.`order` (
  `id` INT NOT NULL ,
  `orderdate` DATETIME NULL,
  `ordernumber` VARCHAR(10) NULL,
  `customerid` INT NOT NULL,
  `totalamount` DECIMAL(12,2) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_order_customer1_idx` (`customerid` ASC) VISIBLE,
  CONSTRAINT `fk_order_customer1`
    FOREIGN KEY (`customerid`)
    REFERENCES `CLIENTE2`.`customer` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT);


-- -----------------------------------------------------
-- Table `CLIENTE`.`orderitem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CLIENTE2`.`orderitem` (
  `id` INT NOT NULL ,
  `orderid` INT NOT NULL,
  `productid` INT NOT NULL,
  `unitprice` DECIMAL(12,2) NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_orderitem_product1_idx` (`productid` ASC) VISIBLE,
  INDEX `fk_orderitem_order1_idx` (`orderid` ASC) VISIBLE,
  CONSTRAINT `fk_orderitem_product1`
    FOREIGN KEY (`productid`)
    REFERENCES `CLIENTE2`.`product` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_orderitem_order1`
    FOREIGN KEY (`orderid`)
    REFERENCES `CLIENTE2`.`order` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT);
    
-- DML:

INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(1,'Maria','Anfefeefeders','Berlin','Germany','030-0074321');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(2,'Ana','Truefeejillo','México D.F.','Mexico','(56) 555-4729');
INSERT INTO Customer (id,FirstName,LastName,City,Country,Phone)VALUES(3,'Antonio','Moreddno','México D.F.','Mexico','(56) 555-3932');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(4,'Thomas','Hadddrdy','London','UK','(256) 555-7788');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(5,'Christina','Beddfrglund','Luleå','Sweden','0921-12 34 65');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(6,'Hanna','Moos','Mannhddddseim','Germany','0621-08460');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(7,'Frédérique','Citgggdeseaux','Strasbourg','France','88.60.15.31');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(8,'Martín','Sommfefer','Madrid','Spain','(91) 555 22 82');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(9,'Laurence','Lefefebihan','Marseille','France','91.24.45.40');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(10,'Elizabeth','Lifefessncoln','Tsawassen','Canada','(604) 555-4729');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(11,'Victoria','Ashscceworth','London','UK','(256) 555-1212');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(12,'Patricio','Siggrmpson','Buenos Aires','Argentina','(1) 135-5555');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(13,'Francisco','Chggrggrang','México D.F.','Mexico','(5) 555-3392');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(14,'Yang','Waggrng','Bern','Switzerland','0452-076545');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(15,'Pedro','Afddronso','Sao Paulo','Brazil','(11) 555-7647');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(16,'Elizabeth','Brvvdown','London','UK','(256) 555-2282');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(17,'Sven','Ottffvflieb','Aachen','Germany','0241-039123');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(18,'Janine','Labvvfrune','Nantes','France','40.67.88.88');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(19,'Ann','Devfvfon','London','UK','(256) 555-0297');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(20,'Roland','Menffvdel','Graz','Austria','7675-3425');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(21,'Aria','Crvvvuz','Sao Paulo','Brazil','(11) 555-9857');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(22,'Diego','Roffvel','Madrid','Spain','(91) 555 94 44');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(23,'Martine','Radcddvvncé','Lille','France','20.16.10.16');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(24,'Maria','Lavfvfrsson','Bräcke','Sweden','0695-34 67 21');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(25,'Peter','Frvfvanken','München','Germany','089-0877310');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(26,'Carine','Scvffhmitt','Nantes','France','40.32.21.21');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(27,'Paolo','Accfffffcorti','Torino','Italy','011-4988260');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(28,'Lino','Roccccdriguez','Lisboa','Portugal','(1) 354-2534');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(29,'Eduardo','Saavvvvedra','Barcelona','Spain','(93) 203 4560');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(30,'José','Pedvvro Freyre','Sevilla','Spain','(95) 555 82 82');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(31,'André','Fovvvdnseca','Campinas','Brazil','(11) 555-9482');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(32,'Howard','Snyddder','Eugene','USA','(503) 555-7555');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(33,'Manuel','Pervveira','Caracas','Venezuela','(2) 283-2951');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(34,'Mario','Ponvvdtes','Rio de Janeiro','Brazil','(21) 555-0091');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(35,'Carlos','Hevvddrnández','San Cristóbal','Venezuela','(5) 555-1340');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(36,'Yoshi','Latvvddimer','Elgin','USA','(503) 555-6874');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(37,'Patricia','McKvdvdvenna','Cork','Ireland','2967 542');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(38,'Helen','Benvvddvnett','Cowes','UK','(198) 555-8888');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(39,'Philip','Crfffamer','Brandenburg','Germany','0555-09876');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(40,'Daniel','Toccenini','Versailles','France','30.59.84.10');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(41,'Annette','Roccccculet','Toulouse','France','61.77.61.10');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(42,'Yoshi','Tanncccamuri','Vancouver','Canada','(604) 555-3392');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(43,'John','Stecccel','Walla Walla','USA','(509) 555-7969');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(44,'Renate','Mcdessner','Frankfurt a.M.','Germany','069-0245984');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(45,'Jaime','Yorccdres','San Francisco','USA','(415) 555-5938');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(46,'Carlos','Goccnzález','Barquisimeto','Venezuela','(9) 331-6954');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(47,'Felipe','Izccdquierdo','I. de Margarita','Venezuela','(8) 34-56-12');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(48,'Fran','Wilcddson','Portland','USA','(503) 555-9573');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(49,'Giovanni','Rocddvelli','Bergamo','Italy','035-640230');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(50,'Catherine','Decccwey','Bruxelles','Belgium','(02) 201 24 67');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(51,'Jean','Fresccdnière','Montréal','Canada','(514) 555-8054');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(52,'Alexander','Feccduer','Leipzig','Germany','0342-023176');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(53,'Simon','Crowcdther','London','UK','(56) 555-7733');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(54,'Yvonne','Monccddcccada','Buenos Aires','Argentina','(1) 135-5333');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(55,'Rene','Phiccddllips','Anchorage','USA','(907) 555-7584');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(56,'Henriette','Pccddfalzheim','Köln','Germany','0221-0644327');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(57,'Marie','Beccddrtrand','Paris','France','(1) 42.34.22.66');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(58,'Guillermo','Fcddcernández','México D.F.','Mexico','(5) 552-3745');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(59,'Georg','Pipccddps','Salzburg','Austria','6562-9722');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(60,'Isabel','de Caccddstro','Lisboa','Portugal','(1) 356-5634');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(61,'Bernardo','Baccdtista','Rio de Janeiro','Brazil','(21) 555-4252');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(62,'Lúcia','Carccddvalho','Sao Paulo','Brazil','(11) 555-1189');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(63,'Horst','Klccddoss','Cunewalde','Germany','0372-035188');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(64,'Sergio','Gutccddiérrez','Buenos Aires','Argentina','(1) 123-5555');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(65,'Paula','Wccddilson','Albuquerque','USA','(505) 555-5939');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(66,'Maurizio','Moccddroni','Reggio Emilia','Italy','0522-556721');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(67,'Janete','Liccdmeira','Rio de Janeiro','Brazil','(21) 555-3412');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(68,'Michael','Hccddolz','Genève','Switzerland','0897-034214');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(69,'Alejandra','Cacddddmino','Madrid','Spain','(91) 745 6200');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(70,'Jonas','Bccddcergulfsen','Stavern','Norway','07-98 92 35');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(71,'Jose','Paccddccvarotti','Boise','USA','(208) 555-8097');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(72,'Hari','Kumccddar','London','UK','(56) 555-1717');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(73,'Jytte','Pccdcdetersen','Kobenhavn','Denmark','31 12 34 56');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(74,'Dominique','Peccddrrier','Paris','France','(1) 47.55.60.10');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(75,'Art','Braccddunschweiger','Lander','USA','(307) 555-4680');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(76,'Pascale','Caddcdrtrain','Charleroi','Belgium','(071) 23 67 22 20');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(77,'Liz','Nixeeeon','Portland','USA','(503) 555-3612');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(78,'Liu','Weeeong','Butte','USA','(406) 555-5834');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(79,'Karin','Joecesephs','Münster','Germany','0251-031259');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(80,'Miguel','Angdeel Paolino','México D.F.','Mexico','(5) 555-2933');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(81,'Anabela','Domieedngues','Sao Paulo','Brazil','(11) 555-2167');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(82,'Helvetius','Naeddgy','Kirkland','USA','(206) 555-8257');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(83,'Palle','Ibsedden','Århus','Denmark','86 21 32 43');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(84,'Mary','Savdedeley','Lyon','France','78.32.54.86');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(85,'Paul','Heeeddeenriot','Reims','France','26.47.15.10');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(86,'Rita','Müleddler','Stuttgart','Germany','0711-020361');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(87,'Pirkko','Koseddekitalo','Oulu','Finland','981-443655');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(88,'Paula','Pareeddente','Resende','Brazil','(14) 555-8122');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(89,'Karl','Jabloedednski','Seattle','USA','(206) 555-4112');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(90,'Matti','Kartdeetunen','Helsinki','Finland','90-224 8858');
INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)VALUES(91,'Zbyszek','Piesddeedtrzeniewicz','Warszawa','Poland','(26) 642-7012');

INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(1,'Exotic Liquids','CharlDDDDSotte Cooper','London','UK','(56) 555-2222',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(2,'New Orleans Cajun Delights','ShelDDDSSley Burke','New Orleans','USA','(100) 555-4822',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(3,'Grandma Kelly''s Homestead','RegEEWina Murphy','Ann Arbor','USA','(313) 555-5735','(313) 555-3349');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(4,'Tokyo Traders','YosEEEhi Nagase','Tokyo','Japan','(03) 3555-5011',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(5,'Cooperativa de Quesos ''Las Cabras''','AntoEEenio del Valle Saavedra','Oviedo','Spain','(98) 598 76 54',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(6,'Mayumi''s','Mayueedfemi Ohno','Osaka','Japan','(06) 431-7877',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(7,'Pavlova, Ltd.','Ian Devefeling','Melbourne','Australia','(03) 444-2343','(03) 444-6588');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(8,'Specialty Biscuits, Ltd.','Peter Wilsefeon','Manchester','UK','(161) 555-4448',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(9,'PB Knäckebröd AB','Lars Peterefeson','Göteborg','Sweden','031-987 65 43','031-987 65 91');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(10,'Refrescos Americanas LTDA','Carlos Diafefez','Sao Paulo','Brazil','(56) 555 4640',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(11,'Heli Süßwaren GmbH & Co. KG','Petra Winefekler','Berlin','Germany','(010) 9984510',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(12,'Plutzer Lebensmittelgroßmärkte AG','Martin Beefein','Frankfurt','Germany','(069) 992755',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(13,'Nord-Ost-Fisch Handelsgesellschaft mbH','Sven Peteefersen','Cuxhaven','Germany','(04721) 8713','(04721) 8714');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(14,'Formaggi Fortini s.r.l.','Elio Rosfeesi','Ravenna','Italy','(0544) 60323','(0544) 60603');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(15,'Norske Meierier','Beate Vilfefeeid','Safndvika','Norway','(0)2-953010',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(16,'Bigfoot Breweries','Cheryl Sayfeeffelor','Bend','USA','(503) 555-9931',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(17,'Svensk Sjöföda AB','Michael Björn','Stockholm','Sweden','08-123 45 67',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(18,'Aux joyeux ecclésiastiques','Guylène Noffedier','Paris','France','(1) 03.83.00.68','(1) 03.83.00.62');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(19,'New England Seafood Cannery','Robb Merchffeant','Boston','USA','(617) 555-3267','(617) 555-3389');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(20,'Leka Trading','Chandra Lefeka','Singapore','Singapore','555-8787',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(21,'Lyngbysild','Niels Peteffersen','Lyngby','Denmark','43844108','43844115');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(22,'Zaanse Snoepfabriek','Dirk Luchffete','Zaandam','Netherlands','(12345) 1212','(12345) 1210');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(23,'Karkki Oy','Anne Heikkofefffeeffenen','Lappeenranta','Finland','(953) 10956',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(24,'G''day, Mate','Wendy Mackenzie','Sydney','Australia','(02) 555-5914','(02) 555-4873');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(25,'Ma Maison','Jean-Guy Lauzon','Montréal','Canada','(514) 555-9022',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(26,'Pasta Buttini s.r.l.','Giovanni Giudfffici','Salerno','Italy','(089) 6547665','(089) 6547667');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(27,'Escargots Nouveaux','Marie Delaefemare','Montceau','France','85.57.00.07',NULL);
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(28,'Gai pâturage','Eliane Noz','Annefefecy','France','38.76.98.06','38.76.98.58');
INSERT INTO Supplier (Id,CompanyName,ContactName,City,Country,Phone,Fax)VALUES(29,'Forêts d''érables','Chantal Gouffeelet','Ste-Hyacinthe','Canada','(514) 555-2955','(514) 555-2921');

INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(1,'Chai',1,18.00,'10 boxes x 20 bags',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(2,'Chang',1,19.00,'24 - 12 oz bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(3,'Aniseed Syrup',1,10.00,'12 - 550 ml bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(4,'Chef Anton''s Cajun Seasoning',2,22.00,'48 - 6 oz jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(5,'Chef Anton''s Gumbo Mix',2,21.35,'36 boxes',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(6,'Grandma''s Boysenberry Spread',3,25.00,'12 - 8 oz jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(7,'Uncle Bob''s Organic Dried Pears',3,30.00,'12 - 1 lb pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(8,'Northwoods Cranberry Sauce',3,40.00,'12 - 12 oz jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(9,'Mishi Kobe Niku',4,97.00,'18 - 500 g pkgs.',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(10,'Ikura',4,31.00,'12 - 200 ml jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(11,'Queso Cabrales',5,21.00,'1 kg pkg.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(12,'Queso Manchego La Pastora',5,38.00,'10 - 500 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(13,'Konbu',6,6.00,'2 kg box',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(14,'Tofu',6,23.25,'40 - 100 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(15,'Genen Shouyu',6,15.50,'24 - 250 ml bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(16,'Pavlova',7,17.45,'32 - 500 g boxes',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(17,'Alice Mutton',7,39.00,'20 - 1 kg tins',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(18,'Carnarvon Tigers',7,62.50,'16 kg pkg.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(19,'Teatime Chocolate Biscuits',8,9.20,'10 boxes x 12 pieces',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(20,'Sir Rodney''s Marmalade',8,81.00,'30 gift boxes',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(21,'Sir Rodney''s Scones',8,10.00,'24 pkgs. x 4 pieces',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(22,'Gustaf''s Knäckebröd',9,21.00,'24 - 500 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(23,'Tunnbröd',9,9.00,'12 - 250 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(24,'Guaraná Fantástica',10,4.50,'12 - 355 ml cans',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(25,'NuNuCa Nuß-Nougat-Creme',11,14.00,'20 - 450 g glasses',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(26,'Gumbär Gummibärchen',11,31.23,'100 - 250 g bags',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(27,'Schoggi Schokolade',11,43.90,'100 - 100 g pieces',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(28,'Rössle Sauerkraut',12,45.60,'25 - 825 g cans',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(29,'Thüringer Rostbratwurst',12,123.79,'50 bags x 30 sausgs.',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(30,'Nord-Ost Matjeshering',13,25.89,'10 - 200 g glasses',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(31,'Gorgonzola Telino',14,12.50,'12 - 100 g pkgs',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(32,'Mascarpone Fabioli',14,32.00,'24 - 200 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(33,'Geitost',15,2.50,'500 g',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(34,'Sasquatch Ale',16,14.00,'24 - 12 oz bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(35,'Steeleye Stout',16,18.00,'24 - 12 oz bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(36,'Inlagd Sill',17,19.00,'24 - 250 g  jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(37,'Gravad lax',17,26.00,'12 - 500 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(38,'Côte de Blaye',18,263.50,'12 - 75 cl bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(39,'Chartreuse verte',18,18.00,'750 cc per bottle',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(40,'Boston Crab Meat',19,18.40,'24 - 4 oz tins',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(41,'Jack''s New England Clam Chowder',19,9.65,'12 - 12 oz cans',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(42,'Singaporean Hokkien Fried Mee',20,14.00,'32 - 1 kg pkgs.',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(43,'Ipoh Coffee',20,46.00,'16 - 500 g tins',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(44,'Gula Malacca',20,19.45,'20 - 2 kg bags',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(45,'Rogede sild',21,9.50,'1k pkg.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(46,'Spegesild',21,12.00,'4 - 450 g glasses',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(47,'Zaanse koeken',22,9.50,'10 - 4 oz boxes',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(48,'Chocolade',22,12.75,'10 pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(49,'Maxilaku',23,20.00,'24 - 50 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(50,'Valkoinen suklaa',23,16.25,'12 - 100 g bars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(51,'Manjimup Dried Apples',24,53.00,'50 - 300 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(52,'Filo Mix',24,7.00,'16 - 2 kg boxes',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(53,'Perth Pasties',24,32.80,'48 pieces',1);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(54,'Tourtière',25,7.45,'16 pies',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(55,'Pâté chinois',25,24.00,'24 boxes x 2 pies',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(56,'Gnocchi di nonna Alice',26,38.00,'24 - 250 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(57,'Ravioli Angelo',26,19.50,'24 - 250 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(58,'Escargots de Bourgogne',27,13.25,'24 pieces',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(59,'Raclette Courdavault',28,55.00,'5 kg pkg.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(60,'Camembert Pierrot',28,34.00,'15 - 300 g rounds',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(61,'Sirop d''érable',29,28.50,'24 - 500 ml bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(62,'Tarte au sucre',29,49.30,'48 pies',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(63,'Vegie-spread',7,43.90,'15 - 625 g jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(64,'Wimmers gute Semmelknödel',12,33.25,'20 bags x 4 pieces',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(65,'Louisiana Fiery Hot Pepper Sauce',2,21.05,'32 - 8 oz bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(66,'Louisiana Hot Spiced Okra',2,17.00,'24 - 8 oz jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(67,'Laughing Lumberjack Lager',16,14.00,'24 - 12 oz bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(68,'Scottish Longbreads',8,12.50,'10 boxes x 8 pieces',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(69,'Gudbrandsdalsost',15,36.00,'10 kg pkg.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(70,'Outback Lager',7,15.00,'24 - 355 ml bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(71,'Flotemysost',15,21.50,'10 - 500 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(72,'Mozzarella di Giovanni',14,34.80,'24 - 200 g pkgs.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(73,'Röd Kaviar',17,15.00,'24 - 150 g jars',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(74,'Longlife Tofu',4,10.00,'5 kg pkg.',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(75,'Rhönbräu Klosterbier',12,7.75,'24 - 0.5 l bottles',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(76,'Lakkalikööri',23,18.00,'500 ml',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(77,'Original Frankfurter grüne Soße',12,13.00,'12 boxes',0);
INSERT INTO Product (Id,ProductName,SupplierId,UnitPrice,Package,IsDiscontinued)VALUES(78,'Stroopwafels',22,9.75,'24 pieces',0);

INSERT INTO cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(1,'2012-01-01',78,1863.40,'542379');
INSERT INTO cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(2,'2012-01-01',78,1863.40,'542379');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(3,'2012-01-01',34,1813.00,'542380');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(4,'2012-01-01',84,670.80,'542381');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(5,'2012-01-02',76,3730.00,'542382');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(6,'2012-01-03',34,1444.80,'542383');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(7,'2012-01-04',14,625.20,'542384');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(8,'2012-01-01',68,2490.50,'542385');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(9,'2012-01-01',88,517.80,'542386');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(10,'2012-01-03',35,1119.90,'542387');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(11,'2012-01-04',20,2018.60,'542388');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(12,'2012-01-04',13,100.80,'542389');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(13,'2012-01-02',56,1746.20,'542390');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(14,'2012-01-01',61,448.00,'542391');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(15,'2012-01-01',65,624.80,'542392');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(16,'2012-01-01',20,2464.80,'542393');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(17,'2012-01-03',24,724.50,'542394');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(18,'2012-01-07',7,1176.00,'542395');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(19,'2021-01-01',87,364.80,'542396');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(20,'2021-01-01',25,4031.00,'542397');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(21,'2012-01-04',33,1101.20,'542398');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(22,'2020-01-01',89,676.00,'542399');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(23,'2012-01-02',87,1376.00,'542400');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(24,'2012-01-02',75,48.00,'542401');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(25,'2019-01-01',65,1456.00,'542402');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(26,'2012-01-02',63,2142.40,'542403');
INSERT into cliente2.Order (Id,OrderDate,CustomerId,TotalAmount,OrderNumber)VALUES(27,'2012-01-02',85,538.60,'542404');

INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(1,1,11,14.00,12);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(2,1,42,9.80,10);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(3,1,72,34.80,5);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(4,2,14,18.60,9);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(5,2,51,42.40,40);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(6,3,41,7.70,10);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(7,3,51,42.40,35);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(8,3,65,16.80,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(9,4,22,16.80,6);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(10,4,57,15.60,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(11,4,65,16.80,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(12,5,20,64.80,40);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(13,5,33,2.00,25);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(14,5,60,27.20,40);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(15,6,31,10.00,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(16,6,39,14.40,42);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(17,6,49,16.00,40);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(18,7,24,3.60,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(19,7,55,19.20,21);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(20,7,74,8.00,21);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(21,8,2,15.20,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(22,8,16,13.90,35);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(23,8,36,15.20,25);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(24,8,59,44.00,30);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(25,9,53,26.20,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(26,9,77,10.40,12);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(27,10,27,35.10,25);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(28,10,39,14.40,6);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(29,10,77,10.40,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(30,11,2,15.20,50);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(31,11,5,17.00,65);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(32,11,32,25.60,6);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(33,12,21,8.00,10);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(34,12,37,20.80,1);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(35,13,41,7.70,16);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(36,13,57,15.60,50);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(37,13,62,39.40,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(38,13,70,12.00,21);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(39,14,21,8.00,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(40,14,35,14.40,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(41,15,5,17.00,12);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(42,15,7,24.00,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(43,15,56,30.40,2);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(44,16,16,13.90,60);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(45,16,24,3.60,28);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(46,16,30,20.70,60);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(47,16,74,8.00,36);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(48,17,2,15.20,35);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(49,17,41,7.70,25);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(50,18,17,31.20,30);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(51,18,70,12.00,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(52,19,12,30.40,12);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(53,20,40,14.70,50);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(54,20,59,44.00,70);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(55,20,76,14.40,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(56,21,29,99.00,10);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(57,21,72,27.80,4);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(58,22,33,2.00,60);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(59,22,72,27.80,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(60,23,36,15.20,30);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(61,23,43,36.80,25);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(62,24,33,2.00,24);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(63,25,20,64.80,6);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(64,25,31,10.00,40);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(65,25,72,27.80,24);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(66,26,10,24.80,24);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(67,26,31,10.00,15);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(68,26,33,2.00,20);
INSERT into cliente2.OrderItem (Id,OrderId,ProductId,UnitPrice,Quantity)VALUES(69,26,40,14.70,60);

-- -----------------------------------------------------
-- SELECTS
-- -----------------------------------------------------

USE CLIENTE2;

SELECT FirstName, LastName, City 
FROM Customer;
-- Comando GO funciona apenas no SQL SERVER. Trocar por ; em todos os bancos relacionais, inclusive SQL SERVER

SELECT *
  FROM Customer;

SELECT Id, FirstName, LastName, City, Country, Phone
  FROM Customer
 WHERE Country = 'Sweden';


SELECT CompanyName, ContactName, City, Country
  FROM Supplier
 ORDER BY CompanyName;

SELECT CompanyName, ContactName, City, Country
  FROM Supplier
 ORDER BY CompanyName DESC;


SELECT Country, City, FirstName, LastName
  FROM Customer
 ORDER BY Country, City DESC;

-- SELECT TOP
-- Problem: List the top 10 most expensive products ordered by price, mas funciona apenas SQL SERVER. NO MYSQL, MariaDB, Postgresql usar LIMIT
SELECT id, ProductName, UnitPrice, Package
  FROM Product
 ORDER BY UnitPrice DESC
 LIMIT 3; -- TOP usa-se no SQL SERVER
 
 SELECT Id, ProductName, UnitPrice, Package
  FROM Product
 ORDER BY UnitPrice DESC
 LIMIT 5;


-- SQL SELECT DISTINCT
-- Problem: List all unique supplier countries in alphabetical order.

SELECT DISTINCT Country
  FROM Supplier
ORDER BY COUNTRY;

-- SQL MAX and MIN
-- Problem: Find the cheapest product

SELECT *,UnitPrice -- pega tudo e a tabela UnitPrice, duplicando-a
  FROM Product ORDER BY UNITPRICE ASC
LIMIT 1;

SELECT MIN(UnitPrice)
  FROM Product;

-- Problem: Find the largest order placed in 2014

SELECT MAX(TotalAmount)
  FROM `Order` -- colchetes usa-se no SQL Server
 WHERE YEAR(OrderDate) = 2012; -- função´padrão para especificar o ano (desde que o tipo primitivo seja DATE ou algo parecido)
 
 SELECT MAX(TotalAmount)
  FROM cliente2.Order
 WHERE YEAR(OrderDate) = 2012;
 -- Entre colchete apenas no SQL SERVER  e se retirar vai entender que eh palavra reservada do Order by e vai dar erro.

SELECT MAX(TotalAmount)
  FROM cliente2.Order
 WHERE YEAR(OrderDate) = 2012;
-- Para resolver, colocar antes da tabela o nome do banco

-- SQL SELECT COUNT, SUM, and AVG

SELECT COUNT(Id)
  FROM Customer;

SELECT SUM(TotalAmount) -- soma todas as vendas da coluna no ano de 2012
  FROM cliente2.Order
 WHERE YEAR(OrderDate) = 2012;

SELECT AVG(TotalAmount) as media
  FROM cliente2.Order;
  
-- SQL WHERE AND, OR, NOT Clause

SELECT Id, FirstName, LastName, City, Country
  FROM Customer 
   WHERE FirstName = 'Ana' AND LastName = 'rosa';

SELECT Id, FirstName, LastName, City, Country
  FROM Customer
 WHERE Country = 'Spain' or  Country = 'France';

 SELECT Id, FirstName, LastName, City, Country
  FROM Customer
 WHERE NOT Country = 'USA';

 -- The SQL WHERE IN
-- Problem: List all suppliers from the USA, UK, OR Japan
SELECT Id, CompanyName, City, Country
  FROM Supplier
 WHERE Country IN ('USA', 'UK', 'Japan'); -- funciona como OR

-- Problem: List all products that are not exactly $10, $20, $30, $40, or $50
SELECT Id, ProductName, UnitPrice
  FROM Product
 WHERE UnitPrice NOT IN (10,20,30,40,50);

-- Problem: List all orders that are  between $50 and $15000
SELECT Id, OrderDate, CustomerId, TotalAmount
  FROM cliente2.Order
 WHERE (TotalAmount >= 50 AND TotalAmount <= 15000) -- TotalAmount BETWEEN 50 AND 15000
 ORDER BY TotalAmount DESC;

 -- Problem: List all orders that are not between $50 and $15000
SELECT Id, OrderDate, CustomerId, TotalAmount
  FROM cliente2.Order
 WHERE NOT (TotalAmount >= 50 AND TotalAmount <= 15000) -- negação
 ORDER BY TotalAmount DESC;

-- SQL WHERE BETWEEN
-- Problem: List all products between $10 and $20
SELECT Id, ProductName, UnitPrice
  FROM Product
 WHERE UnitPrice BETWEEN 10 AND 20
 ORDER BY UnitPrice;

SELECT Id, ProductName, UnitPrice
  FROM Product
 WHERE UnitPrice NOT BETWEEN 5 AND 100 -- negação de beetween
 ORDER BY UnitPrice;

-- Problem: Get the number of orders and amount sold between Jan 1, 2013 and Jan 31, 2013.
SELECT COUNT(Id) as qtvendas , SUM(TotalAmount) as valortotal -- contando os ids e somando as vendas
  FROM cliente2.Order
 WHERE OrderDate BETWEEN '2010/01/01' AND '2013/12/31';

-- SQL WHERE LIKE
-- Problem: List all products with names that start with 'Ca'
SELECT Id, ProductName, UnitPrice, Package
  FROM Product
 WHERE ProductName LIKE '%na%'; -- %x% entre-- igual é diferente de LIKE %

-- Problem: List all products that start with 'Cha' or 'Chan' and have one more character.
SELECT Id, ProductName, UnitPrice, Package
  FROM Product
 WHERE ProductName LIKE 'Cha_' OR ProductName LIKE 'Chan_'; -- começa assim, depois tenha apenas um caractere depois

-- SQL WHERE IS NULL
-- Problem: List all suppliers that have no fax number
SELECT Id, CompanyName, Phone, Fax 
  FROM Supplier
 WHERE Fax IS NULL; -- muito útil saber quais campos estão nulos para ser preenchido

-- Problem: List all suppliers that do have a fax number
SELECT Id, CompanyName, Phone, Fax 
  FROM Supplier
 WHERE Fax IS NOT NULL; -- quais não estão nulos
 

-- SQL GROUP BY
-- Problem: List the number of customers in each country.

select country, id, firstname from Customer;

SELECT  Country , COUNT(Id) as qtclientes
  FROM Customer
 GROUP BY Country; -- agrupar por country, senão dá erro

-- SQL Alias
-- Problem: List total customers in each country. Display results with easy to understand column headers.
SELECT C.Country AS Nation, COUNT(C.Id) AS TotalCustomers
  FROM Customer C -- neste caso não há necessidade de usar AS
 GROUP BY C.Country;

 -- Problem: List the number of customers in each country sorted high to low
SELECT  Country , COUNT(Id) as numberclients
  FROM Customer
 GROUP BY Country
 ORDER BY numberclients desc; -- ou usar COUNT(Id) diretamente
 
 select * from cliente2.Order;
 
 -- Problem: Trazer numero de vendas e soma de vendas por cliente
 SELECT customerid, COUNT(Id) as qtvendas , SUM(TotalAmount) as valortotal,  AVG(TotalAmount) as mediavendas, MIN(TotalAmount) as menorvenda, MAX(TotalAmount) as maiorvenda
  FROM cliente2.Order
 WHERE OrderDate BETWEEN '2010/01/01' AND '2013/12/31'
 GROUP BY customerid -- chave estrangeira (foreign key)
 order by qtvendas desc;

-- conta quantas vezes o cliente teve uma venda, agrupa por customerid etc.
 SELECT customerid, firstname, COUNT(`order`.Id) as qtvendas , SUM(TotalAmount) as valortotal,  AVG(TotalAmount) as mediavendas, MIN(TotalAmount) as menorvenda, MAX(TotalAmount) as maiorvenda
  FROM cliente2.Order
INNER JOIN customer ON customerid = customer.id -- JOIN (FOREIGN KEY)
 WHERE OrderDate BETWEEN '2010/01/01' AND '2013/12/31'
 GROUP BY customerid -- chave estrangeira (foreign key)
 order by qtvendas desc, customerid asc;

-- INNER JOIN	
-- Vamos gerar o modelo de dados do banco cliente2 como apoio as consultas com join

select *
from cliente2.customer C JOIN cliente2.order O-- JOIN e INNER JOIN é a mesma coisa (Traz dados que existam nas duas tabelas.)
ON C.id=O.customerid;

SELECT *
FROM product AS 
p JOIN orderitem AS oi ON p.id = oi.productid 
JOIN `order` AS o ON o.id = orderid;

SELECT C.firstname, C.lastname, O.totalamount
FROM cliente2.customer C INNER JOIN cliente2.order O
ON C.id = O.customerid;

SELECT OrderNumber, TotalAmount, FirstName, LastName, City, Country
  FROM cliente2.Order JOIN Customer
    ON cliente2.Order.CustomerId = cliente2.Customer.Id;
    
    -- OU UMA OUTRA FORMA DE RODAR O MESMO CODIGO SERIA COM A UTILIZACAO DOS ALIAS, CONFORME DEMONSTRADO NA VIDEO AULA
    
select o.ordernumber, o.totalamount, c.firstname,c.lastname, c.city,c.country
from cliente2.order O INNER JOIN cliente2.customer C
ON O.customerid = C.ID;


-- E AGORA SE QUISEEMOS TRAZER DADOS DE MAIS TABELAS 

SELECT  O.OrderNumber, OrderDate AS Datetime, 
       P.ProductName, I.Quantity, I.UnitPrice 
  FROM cliente2.Order O 
  INNER JOIN OrderItem I ON O.Id = I.OrderId -- não importa a ordem dos joins, desde que as tabelas estejam vinculados
  INNER JOIN Product P ON P.Id = I.ProductId
ORDER BY O.OrderNumber;


SELECT O.OrderNumber, CONVERT(O.OrderDate, date) AS Data, -- conversão na consulta DATETIME p/ date -- SQL SERVER é ao contrário CONVERT(date, O.OrderDate)
       P.ProductName, I.Quantity, I.UnitPrice 
  FROM cliente2.Order O 
  JOIN OrderItem I ON O.Id = I.OrderId 
  JOIN Product P ON P.Id = I.ProductId
ORDER BY O.OrderNumber;
-- A FUNCAO CONVERT no SQL SERVER, primeiro vem para qual tipo quer converter, mas se rodar desta forma no mysql da erro.

SELECT O.OrderNumber, CONVERT(O.OrderDate, date) AS Data, 
       P.ProductName, I.Quantity, I.UnitPrice 
  FROM cliente2.Order O 
  JOIN OrderItem I ON O.Id = I.OrderId 
  JOIN Product P ON P.Id = I.ProductId
ORDER BY O.OrderNumber;
-- A mesma funcao no MYSQL, mas deve invester a order dos parametros da funcao CONVERT

-- Problema: Listas o total de pedidos ordenado dos maiores para menores pedidos
SELECT  C.FirstName, C.LastName, SUM(O.TotalAmount) AS SOMA
  FROM cliente2.Order O 
  INNER JOIN Customer C ON O.CustomerId = C.Id
 GROUP BY C.FirstName, C.LastName -- agrupar para não ter repetição
 ORDER BY SOMA DESC;

-- LEFT JOIN
-- Problema: liste todos os clientes, independentemente de terem feito pedidos ou não

SELECT c.FirstName, c.LastName, c.City, c.Country, o.OrderNumber, o.TotalAmount
  FROM Customer C LEFT JOIN cliente2.Order O -- retorna valores nulos pois há customers que não tem dados correlacionados com order
    ON O.CustomerId = C.Id
 ORDER BY TotalAmount;

-- RIGHT JOIN
-- Problema: Liste os clientes que não fizeram pedidos

SELECT FirstName, LastName, City, Country,  TotalAmount
  FROM cliente2.Order O RIGHT JOIN Customer C
    ON O.CustomerId = C.Id;

SELECT FirstName, LastName, City, Country,  TotalAmount
  FROM cliente2.Order O RIGHT JOIN Customer C
    ON O.CustomerId = C.Id
    WHERE TotalAmount IS NULL;

-- SQL UNION
-- Problema: Liste todas as empresas, incluindo fornecedores e clientes.

SELECT 'Customer' As Type,  
       FirstName + ' ' + LastName AS ContactName, -- Usar CONCAT() no MySQL
       City, Country, Phone
  FROM Customer
UNION -- mesmo tipo primitivo dos atributos e quantidade de colunas entre ambas consultas
SELECT 'Supplier', 
       ContactName, City, Country, Phone
  FROM Supplier;
  -- Mesmo comando que o SQL SERVER, nao da erro mas repare quanto tento concatenar as strings firstname e lastiname com espaco.

-- usar no mysql a funcao CONCAT 
SELECT 'Customer' As Type, 
       CONCAT(firstName, ' ', LastName) AS ContactName, -- usando ' ' espaço em branco para separar firstname de lastname 
       City, Country, Phone
  FROM Customer
UNION
SELECT 'Supplier', 
       ContactName, City, Country, Phone
  FROM Supplier;
  

-- SQL SUBQUERIE
-- Problema: liste produtos com quantidades de pedido maiores que 10.

SELECT ProductName
  FROM Product
 WHERE Id IN (1,2); -- subquery dentro da mesma tabela

SELECT ProductName -- normalmente JOIN é mais rápido
  FROM Product P
 WHERE Id IN (SELECT O.ProductId -- retorna a subquey p/ query externa, comparando com o id IN (outra tabela)
                FROM OrderItem O
               WHERE Quantity > 10);
               
SELECT ProductName
  FROM Product P
 WHERE Id NOT IN (SELECT O.ProductId -- retorna a subquey p/ query externa, comparando com o id IN (outra tabela)
                FROM OrderItem O
               WHERE Quantity > 10);
               
SELECT O.ProductId
FROM OrderItem O
WHERE Quantity > 10;
               

-- Problema: Liste todos os clientes com seu número total de pedidos

SELECT c.ID, FirstName, LastName, 
       OrderCount = (SELECT COUNT(O.Id) 
                       FROM cliente2.Order O 
                      WHERE O.CustomerId = C.Id)
  FROM Customer C ; -- SQL SERVER
  -- NO SQL SERVER poderia ser assim, mas no MYSQL vai dar erro devido a criacao do campo ORDERCOUNT
 
 -- ira para cada cliente, ler a tabela de ordens e vai veirificar a quantidade de pedidos.
 SELECT FirstName, LastName,
      (SELECT COUNT(O.Id) 
                       FROM cliente2.Order O 
                      WHERE O.CustomerId = C.Id)  as OrderCount -- MySQL
  FROM Customer C ;
  
-- SQL EXISTS SUBQUERIE
-- Problema: Encontre fornecedores com produtos acima de $ 100.

SELECT  CompanyName
  FROM Supplier
 WHERE EXISTS -- muito usado também (Ideal usar EXISTS ou NOT EXISTS ao invés de IN, pois perde menos performance.)
       (SELECT 1 -- (poductname) aqui como nao vou trazer productname poderia colocar valor 1 para se referir a verdadeiro
          FROM Product
         WHERE Product.SupplierId = Supplier.Id -- passando id de supplier
           AND UnitPrice > 100)	;
           
SELECT  CompanyName
  FROM Supplier s
 WHERE s.id IN (SELECT p.supplierid -- menos performática que o exemplo de cima
          FROM Product p
           WHERE p.UnitPrice > 100)	;

SELECT productname -- não quero saber o nome do produto, mas o fornecedor
FROM Product
WHERE UnitPrice > 100;
		
-- Problema: E com NOT EXIST, posso encontrar fornecedores com produtos abaixo e igual de $ 100.
           
SELECT CompanyName
  FROM Supplier
 WHERE NOT EXISTS -- oposto
       (SELECT ProductName
          FROM Product
         WHERE Product.SupplierId = Supplier.Id 
           AND UnitPrice > 100)	;

-- Pode-se ter várias subquerys. Sempre que possível, evitar subquery, preferir os JOINS.
 
-- SQL HAVING 
-- Problema: liste o número de clientes em cada país, exceto os EUA, classificados do alto para o baixo. Inclui apenas países com 9 ou mais clientes.
SELECT  Country , COUNT(Id) as qt
  FROM Customer
 WHERE Country <> 'USA' -- ou !=
 GROUP BY Country
HAVING qt >= 9 -- usa-se junto com group by, depois dele (parecido com WHERE, mas não se pode usar where aqui)
 ORDER BY qt DESC; -- SQL server dá erro usando apelido
 
 SELECT  Country , COUNT(Id) as qt
  FROM Customer
 WHERE Country <> 'USA' -- AND qt >= 9 (não funciona)
 GROUP BY Country
 ORDER BY qt DESC;

-- Problema: liste todos os clientes com pedidos médios entre $ 1000 e $ 1200.
SELECT FirstName, LastName, AVG(TotalAmount) as media
  FROM cliente2.Order O 
  JOIN Customer C ON O.CustomerId = C.Id
    GROUP BY FirstName, LastName
      HAVING media BETWEEN 1000 AND 1200; -- filtragem de group by

-- SQL SELECT INTO 
-- Problema: Copie todos os fornecedores dos EUA para uma nova tabela SupplierUSA.

SELECT * INTO SupplierUSA -- não funciona no MySQL, apenas SQL Server
  FROM Supplier
 WHERE Country = 'USA';
 -- NO SQL SERVER, voce consegue crar uma tabela inexistente com select into mas no MYSQL nao funciona
 
 CREATE TABLE IF NOT EXISTS SupplierUSA
 SELECT * FROM Supplier 
 WHERE Country = 'USA';
 -- Para criar uma tabela nova no MYSQL a partir de dados vindos de outra tabela 

 select * from SupplierUSA; -- tabela criado a partir de outra
 select * from Supplier; -- tabela original
 
 drop table SupplierUSA; -- apaga a estrutura da tabela, não somente os dados

-------------------------------
------ UPDATES
-------------------------------

select * from Supplier where Id = 2;

UPDATE Supplier
   SET City = 'Oslo', 
       Phone = '(0)1-953530', 
       Fax = '(0)1-953555'
 WHERE Id = 2; -- CUIDADO. Fazer backup antes. importante especificar WHERE, caso contrário todos os dados serim atualizados
 
select * from Supplier where Id = 2;

-- TRANSACOES

select * from Product;

-- begin transaction, so funciona no SQL SERVER
-- Para iniciar uma transação, você usa a instrução START TRANSACTION. O BEGIN é o apelido de START TRANSACTION.

START TRANSACTION;
UPDATE Product
   SET IsDiscontinued = 0 
      where IsDiscontinued=1;
select * from Product;

-- SE AO RODAR RECEBER ESTE ERRO:
-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 
-- Para nao dar este erro, no where teria que usar o campo de chave primaria ou incluir o SET abaixo para desligar esta restricao e depois ligar

-- Poderiamos forcar tambem no where passar uma busca com a PK da tabela, desta forma, desde que nao tenha valor de pk com 0
START TRANSACTION;
UPDATE Product
   SET IsDiscontinued = 0 
      where IsDiscontinued=1 and id<>0;
select * from Product;

-- para desfazer antes de gravar definitivamente, rodar ROLLBACK denteo da TRANSACAO
ROLLBACK;
select * from Product;

-- E AGORA DE UMA FORMA DIFERENTE SEM COLOCAR A PK NO WHERE

SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;
UPDATE Product
   SET IsDiscontinued = 0 
      where IsDiscontinued=1;
select * from Product;
SET SQL_SAFE_UPDATES = 1;

-- Rollback tran Funnciona apenas no SQL SERBER
-- Para MYSQL apenas ROLLBACK ou COMMIT
ROLLBACK;
select * from Product;

-- UMA OUTRA FORMA ALTERNATIVA PARA RESOLVER DE FORMA GERAL PARA TODOS OS COMANDOS QUE CHEGAM, É NO WORKBENCH MUDAR O PARAMETRO
-- MySQL Workbench => [Edit] => [Preferences] => [SQL EDITOR]. NA ULTIMA OPCAO DESLIGAR E DAR RESTART NO SERVIC MYSQL.

START TRANSACTION;
UPDATE Product
   SET IsDiscontinued = 0 
      where IsDiscontinued=1;
select * from Product;

-- ALTERAR O PARAMETRO no workbench, ABRIR SERVICOS DO WINDOWS, PARAR O MYSQL E DAR START E RODAR NOVAMENTE

START TRANSACTION;
UPDATE Product
   SET IsDiscontinued = 0 
      where IsDiscontinued=1;
select * from Product;
ROLLBACK;

-- --------

-- POSSO USAR APENAS O BEGIN AO INVES DO START TRANSACTON, AGORA NAO PRECISO MAIS COLOCAR A PK NO WHERE OU USAR SQL_SAFE_UPDATES = 0 PARA NAO DAR ERRO

BEGIN ;
UPDATE Product 
   SET IsDiscontinued = 1, ProductName = 'TESTE'  
 WHERE UnitPrice = 97.00;
select * from Product;

COMMIT;
select * from Product;

-------------------------------
------ DELETES
-------------------------------

select * from orderitem;
BEGIN;
DELETE FROM orderitem ;
select * from orderitem;

ROLLBACK;
select * from orderitem;

-------------------------------
------ TRUNCATE TABLE
-------------------------------

 CREATE TABLE neworderitem SELECT * FROM orderitem;
 SELECT * FROM neworderitem;

TRUNCATE TABLE neworderitem;
SELECT * FROM neworderitem;

-------------------------------
------ INSERT INTO
-------------------------------

INSERT INTO Customer (id, FirstName, LastName, City, Country, Phone) 
VALUES (100,'Craig', 'Smith', 'New York', 'USA', '1-01-993 2800');

select * from Customer;

-- vamos inserir algumas linhas na tabela abaixo, comecando proximo valor livre para pk id
-- Podemos dar insert com resultado de um select e vamos aprender mais duas functions

INSERT INTO Customer (FirstName, LastName, City, Country, Phone)
SELECT LEFT(ContactName, 5), 
       SUBSTRING(ContactName, 2, 2), 
       City, Country, Phone
  FROM Supplier
 WHERE CompanyName = 'Bigfoot Breweries';
 
 -- FUNCIONOU? 
 
 -- vamos alterar a coluna id que é uma PK em customer. Vamos alterar para colocar a caracteristica auto incremental na columa
 ALTER TABLE Customer MODIFY id INTEGER NOT NULL AUTO_INCREMENT;
 
 -- se der erro e uma mensagem que nao posso alterar a coluna id por ser uma fk de outra tabela
 -- Error Code: 1833. Cannot change column 'id': used in a foreign key constraint 'fk_order_customer1' of table 'cliente2.order'
 -- desabilite na sessao a fk. O ideal eh fazer sem o sistema estar no ar para evitar qualquer problema de integridade referencial no milisegundo que esta sendo desligado
SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE `cliente2`.`customer` CHANGE COLUMN `id` `id` INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT = 200;
SET FOREIGN_KEY_CHECKS = 1;
-- agora ja poder rodar o mesmo comando que o id sera gerado a partir do valor 102

INSERT INTO Customer (FirstName, LastName, City, Country, Phone)
SELECT LEFT(ContactName, 5), 
       SUBSTRING(ContactName, 11, 3), 
       City, Country, Phone
  FROM Supplier
 WHERE CompanyName = 'Bigfoot Breweries';
 
select * from Customer;

-- ------------------------------------fim