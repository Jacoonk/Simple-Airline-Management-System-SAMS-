-- CS4400: Introduction to Database Systems: Monday, September 11, 2023
-- Simple Airline Management System Course Project Database TEMPLATE (v0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Please enter your team number and names here
-- Team 73 - Jack Ganem, Shangqing Zong, Jason Lin, Thomas Taye, Melak Alemu

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */

CREATE TABLE Locations
(
	locationID varchar(100) not null,
    primary key (locationID)
);

CREATE TABLE Route
(
	routeID varchar(100) not null,
    primary key (routeID)
);

CREATE TABLE Airline 
(
	airlineID varchar(100) not null,
    revenue int not null,
    primary key (airlineID)
);

CREATE TABLE Flight 
(
	flightID varchar(100) not null,
    cost int not null,
    routeID varchar(100) not null,
    primary key (flightID),
    constraint fk1 foreign key (routeID) references Route (routeID)
);

CREATE TABLE Person
(
	personID varchar(100) not null,
    firstName varchar(100) not null,
    lastName varchar(100),
    locationID varchar(100) not null,
    primary key (personID),
    constraint fk2 foreign key (locationID) references Locations (locationID)
);

CREATE TABLE Passenger 
(
	personID varchar(100) not null,
    miles int not null,
    funds int not null,
    primary key (personID),
    constraint fk3 foreign key (personID) references Person (personID)
);

CREATE TABLE Vacation
(
	personID varchar(100) not null,
    destination varchar(3) not null,
    sequence int not null, -- unclear
    primary key (personID, destination, sequence),
    constraint fk4 foreign key (personID) references Passenger (personID)
);

CREATE TABLE Pilot
(
	taxID varchar(12) not null unique,
    personID varchar(100) not null,
    experience int not null,
    flightID varchar(100), -- removed not null
    primary key (personID),
    constraint fk5 foreign key (personID) references Person (personID),
    constraint fk6 foreign key (flightID) references Flight (flightID)
);

CREATE TABLE License
(
	licenseName varchar(100) not null,
    personID varchar(100) not null,
    primary key (licenseName, personID),
    constraint fk7 foreign key (personID) references Pilot (personID)
);

CREATE TABLE Airplane
(
	tailNumber varchar(100) not null,
	airlineID varchar(100) not null,
	locationID varchar(100),  -- got rid of not null
	speed int not null,
	seatCapacity int not null,
	primary key (tailNumber, airlineID), 
	constraint fk8 foreign key (airlineID) references Airline (airlineID),
	constraint fk9 foreign key (locationID) references Locations (locationID)
);

CREATE TABLE Prop 
(
	tailNumber varchar(100) not null,
    airlineID varchar(100) not null,
    numProps int not null,
    skids boolean not null,
    primary key (tailNumber, airlineID),
    constraint fk10 foreign key (tailNumber, airlineID) references Airplane (tailNumber, airlineID)
);

CREATE TABLE Jet
(
	tailNumber varchar(100) not null,
	airlineID varchar(100) not null,
	numEngines int not null,
	primary key (tailNumber, airlineID),
    constraint fk11 foreign key (airlineID, tailNumber) references Airplane (airlineID, tailNumber)
);

CREATE TABLE Airport
(
	airportID varchar(3) not null,
	airportName varchar(100) not null,
	city varchar(100) not null,
	state varchar(100) not null,
	country varchar(3) not null,
	locationID varchar(100), -- removed no null
	primary key (airportID),
	constraint fk12 foreign key (locationID) references Locations (locationID)
);

CREATE TABLE Leg
(
	legID varchar(100) not null,
	distance int not null,
	arrives varchar(3) not null,
	departs varchar(3) not null,
	primary key (legID),
	constraint fk13 foreign key (arrives) references Airport (airportID),
    constraint fk14 foreign key (departs) references Airport (airportID)
);


CREATE TABLE Contain
(
	routeID varchar(100) not null, 
	legID varchar(100) not null,
	sequence int not null,
	primary key (routeID, legID, sequence),
	constraint fk15 foreign key (routeID) references Route (routeID),
    constraint fk16 foreign key (legID) references Leg (legID)
);

CREATE TABLE Supports
(
	tailNumber varchar(100) not null,
    airlineID varchar(100) not null,
    flightID varchar(100) not null,
    nextTime time not null, -- check this
    progress int not null,
    in_flight boolean not null,
    primary key (tailNumber, airlineID, flightID),
    constraint fk17 foreign key (tailNumber, airlineID) references Airplane (tailNumber, airlineID),
    constraint fk18 foreign key (flightID) references Flight (flightID)
);

INSERT INTO `Locations` (`locationID`) VALUES ('plane_1');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_13');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_18');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_20');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_5');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_6');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_7');
INSERT INTO `Locations` (`locationID`) VALUES ('plane_8');
INSERT INTO `Locations` (`locationID`) VALUES ('port_1');
INSERT INTO `Locations` (`locationID`) VALUES ('port_10');
INSERT INTO `Locations` (`locationID`) VALUES ('port_11');
INSERT INTO `Locations` (`locationID`) VALUES ('port_12');
INSERT INTO `Locations` (`locationID`) VALUES ('port_13');
INSERT INTO `Locations` (`locationID`) VALUES ('port_14');
INSERT INTO `Locations` (`locationID`) VALUES ('port_15');
INSERT INTO `Locations` (`locationID`) VALUES ('port_16');
INSERT INTO `Locations` (`locationID`) VALUES ('port_17');
INSERT INTO `Locations` (`locationID`) VALUES ('port_18');
INSERT INTO `Locations` (`locationID`) VALUES ('port_2');
INSERT INTO `Locations` (`locationID`) VALUES ('port_20');
INSERT INTO `Locations` (`locationID`) VALUES ('port_21');
INSERT INTO `Locations` (`locationID`) VALUES ('port_22');
INSERT INTO `Locations` (`locationID`) VALUES ('port_23');
INSERT INTO `Locations` (`locationID`) VALUES ('port_3');
INSERT INTO `Locations` (`locationID`) VALUES ('port_4');
-- INSERT INTO `Locations` (`locationID`) VALUES ('port_5');
INSERT INTO `Locations` (`locationID`) VALUES ('port_6');
INSERT INTO `Locations` (`locationID`) VALUES ('port_7');

INSERT INTO `Route` (`routeID`) VALUES ('americas_hub_exchange');
INSERT INTO `Route` (`routeID`) VALUES ('americas_one');
INSERT INTO `Route` (`routeID`) VALUES ('americas_three');
INSERT INTO `Route` (`routeID`) VALUES ('americas_two');
INSERT INTO `Route` (`routeID`) VALUES ('big_europe_loop');
INSERT INTO `Route` (`routeID`) VALUES ('euro_north');
INSERT INTO `Route` (`routeID`) VALUES ('euro_south');
INSERT INTO `Route` (`routeID`) VALUES ('germany_local');
INSERT INTO `Route` (`routeID`) VALUES ('pacific_rim_tour');
INSERT INTO `Route` (`routeID`) VALUES ('south_euro_loop');
INSERT INTO `Route` (`routeID`) VALUES ('texas_local');

INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('Air_France',29000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('American',52000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('British Airways',24000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('China Southern Airlines',14000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('Delta',53000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('Japan Airlines',9000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('KLM',29000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('Korean Air Lines',10000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('Lufthansa',35000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('Ryanair',10000);
INSERT INTO `Airline` (`airlineID`, `revenue`) VALUES ('United',48000);

INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n106js','Delta','plane_1',800,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n110jn','Delta',NULL,800,5);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n118fm','Air_France',NULL,400,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n127js','Delta',NULL,600,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n156sq','Ryanair',NULL,600,8);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n161fk','KLM','plane_13',600,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n180co','Korean Air Lines',NULL,600,5);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n225sb','American',NULL,800,8);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n249yk','China Southern Airlines',NULL,400,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n256ap','KLM',NULL,300,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n305fv','Japan Airlines','plane_20',400,6);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n330ss','United',NULL,800,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n337as','KLM',NULL,400,5);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n341eb','Ryanair','plane_18',400,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n353kz','Ryanair',NULL,400,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n380sd','United','plane_5',400,5);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n401fj','Lufthansa',NULL,300,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n443wu','Japan Airlines',NULL,800,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n448cs','American',NULL,400,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n451fi','Ryanair',NULL,600,5);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n454gq','China Southern Airlines',NULL,400,3);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n517ly','British Airways','plane_7',600,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n553qn','American',NULL,800,5);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n616lt','British Airways','plane_6',600,7);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n620la','Lufthansa','plane_8',800,4);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n653fk','Lufthansa',NULL,600,6);
INSERT INTO `Airplane` (`tailNumber`, `airlineID`, `locationID`, `speed`, `seatCapacity`) VALUES ('n815pw','Air_France',NULL,400,3);

INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('AMS','Amsterdam Schipol International','Amsterdam','Haarlemmermeer','NLD','port_11');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('ATL','Atlanta Hartsfield_Jackson International','Atlanta','Georgia','USA','port_1');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('BCN','Barcelona International','Barcelona','Catalonia','ESP','port_15');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('BER','Berlin Brandenburg Willy Brandt International','Berlin','Schonefeld','DEU','port_23');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('CAN','Guangzhou International','Guangzhou','Guangdong','CHN','port_7');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('CDG','Paris Charles de Gaulle','Roissy_en_France','Paris','FRA','port_12');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('DEN','Denver International','Denver','Colorado','USA',NULL);
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('DFW','Dallas_Fort Worth International','Dallas','Texas','USA','port_6');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('DXB','Dubai International','Dubai','Al Garhoud','UAE','port_2');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('FCO','Rome Fiumicino','Fiumicino','Lazio','ITA','port_16');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('FRA','Frankfurt International','Frankfurt','Frankfurt_Rhine_Main','DEU','port_13');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('HND','Tokyo International Haneda','Ota City','Tokyo','JPN','port_3');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('HOU','William P_Hobby International','Houston','Texas','USA','port_21');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('IAH','George Bush Intercontinental','Houston','Texas','USA','port_20');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('IST','Istanbul International','Arnavutkoy','Istanbul ','TUR',NULL);
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('LAX','Los Angeles International','Los Angeles','California','USA',NULL);
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('LGW','London Gatwick','London','England','GBR','port_17');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('LHR','London Heathrow','London','England','GBR','port_4');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('MAD','Madrid Adolfo Suarez_Barajas','Madrid','Barajas','ESP','port_14');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('MDW','Chicago Midway International','Chicago','Illinois','USA',NULL);
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('MUC','Munich International','Munich','Bavaria','DEU','port_18');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('NRT','Narita International','Narita','Chiba','JPN','port_22');
INSERT INTO `Airport` (`airportID`, `airportName`, `city`, `state`, `country`, `locationID`) VALUES ('ORD','O_Hare International','Chicago','Illinois','USA','port_10');

INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_1',400,'AMS','BER');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_10',1600,'CAN','HND');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_11',500,'CDG','BCN');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_12',600,'CDG','FCO');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_13',200,'CDG','LHR');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_14',400,'CDG','MUC');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_15',200,'DFW','IAH');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_16',800,'FCO','MAD');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_17',300,'FRA','BER');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_18',100,'HND','NRT');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_19',300,'HOU','DFW');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_2',3900,'ATL','AMS');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_20',100,'IAH','HOU');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_21',600,'LGW','BER');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_22',600,'LHR','BER');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_23',500,'LHR','MUC');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_24',300,'MAD','BCN');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_25',600,'MAD','CDG');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_26',800,'MAD','FCO');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_27',300,'MUC','BER');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_28',400,'MUC','CDG');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_29',400,'MUC','FCO');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_3',3700,'ATL','LHR');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_30',200,'MUC','FRA');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_31',3700,'ORD','CDG');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_4',600,'ATL','ORD');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_5',500,'BCN','CDG');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_6',300,'BCN','MAD');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_7',4700,'BER','CAN');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_8',600,'BER','LGW');
INSERT INTO `Leg` (`legID`, `distance`, `arrives`, `departs`) VALUES ('leg_9',300,'BER','MUC');

INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_one','leg_1',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('pacific_rim_tour','leg_10',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_south','leg_11',4);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('south_euro_loop','leg_12',4);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('big_europe_loop','leg_13',5);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_three','leg_14',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_north','leg_14',4);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('texas_local','leg_15',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('big_europe_loop','leg_16',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_north','leg_16',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('south_euro_loop','leg_16',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('germany_local','leg_17',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('pacific_rim_tour','leg_18',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('texas_local','leg_19',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_one','leg_2',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('texas_local','leg_20',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_south','leg_21',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_two','leg_22',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('big_europe_loop','leg_23',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_north','leg_24',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('south_euro_loop','leg_24',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('big_europe_loop','leg_25',4);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_south','leg_26',6);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_north','leg_27',5);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_south','leg_28',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('big_europe_loop','leg_29',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_two','leg_3',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('germany_local','leg_30',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_three','leg_31',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('americas_hub_exchange','leg_4',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_north','leg_5',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('south_euro_loop','leg_5',3);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_south','leg_6',5);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('pacific_rim_tour','leg_7',1);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_north','leg_8',6);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('euro_south','leg_9',2);
INSERT INTO `Contain` (`routeID`, `legID`, `sequence`) VALUES ('germany_local','leg_9',1);

INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('ba_51',100,'big_europe_loop');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('ba_61',200,'americas_two');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('dl_10',200,'americas_one');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('ja_35',300,'pacific_rim_tour');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('km_16',400,'euro_south');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('lf_20',300,'euro_north');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('ry_34',100,'germany_local');
INSERT INTO `Flight` (`flightID`, `cost`, `routeID`) VALUES ('un_38',200,'americas_three');

INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n106js','Delta',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n110jn','Delta',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n127js','Delta',4);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n156sq','Ryanair',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n161fk','KLM',4);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n180co','Korean Air Lines',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n225sb','American',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n305fv','Japan Airlines',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n330ss','United',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n337as','KLM',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n380sd','United',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n443wu','Japan Airlines',4);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n451fi','Ryanair',4);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n517ly','British Airways',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n553qn','American',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n616lt','British Airways',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n620la','Lufthansa',4);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n653fk','Lufthansa',2);
INSERT INTO `Jet` (`tailNumber`, `airlineID`, `numEngines`) VALUES ('n815pw','Air_France',2);

INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p1','Jeanne','Nelson','port_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p10','Lawrence','Morgan','port_3');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p11','Sandra','Cruz','port_3');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p12','Dan','Ball','port_3');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p13','Bryant','Figueroa','port_3');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p14','Dana','Perry','port_3');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p15','Matt','Hunt','port_10');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p16','Edna','Brown','port_10');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p17','Ruby','Burgess','port_10');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p18','Esther','Pittman','port_10');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p19','Doug','Fowler','port_17');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p2','Roxanne','Byrd','port_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p20','Thomas','Olson','port_17');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p21','Mona','Harrison','plane_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p22','Arlene','Massey','plane_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p23','Judith','Patrick','plane_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p24','Reginald','Rhodes','plane_5');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p25','Vincent','Garcia','plane_5');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p26','Cheryl','Moore','plane_5');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p27','Michael','Rivera','plane_8');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p28','Luther','Matthews','plane_8');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p29','Moses','Parks','plane_13');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p3','Tanya','Nguyen','port_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p30','Ora','Steele','plane_13');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p31','Antonio','Flores','plane_13');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p32','Glenn','Ross','plane_13');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p33','Irma','Thomas','plane_20');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p34','Ann','Maldonado','plane_20');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p35','Jeffrey','Cruz','port_12');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p36','Sonya','Price','port_12');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p37','Tracy','Hale','port_12');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p38','Albert','Simmons','port_14');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p39','Karen','Terry','port_15');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p4','Kendra','Jacobs','port_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p40','Glen','Kelley','port_20');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p41','Brooke','Little','port_3');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p42','Daryl','Nguyen','port_4');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p43','Judy','Willis','port_14');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p44','Marco','Klein','port_15');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p45','Angelica','Hampton','port_16');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p5','Jeff','Burton','port_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p6','Randal','Parks','port_1');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p7','Sonya','Owens','port_2');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p8','Bennie','Palmer','port_2');
INSERT INTO `Person` (`personID`, `firstName`, `lastName`, `locationID`) VALUES ('p9','Marlene','Warner','port_3');

INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p21',771,700);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p22',374,200);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p23',414,400);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p24',292,500);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p25',390,300);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p26',302,600);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p27',470,400);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p28',208,400);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p29',292,700);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p30',686,500);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p31',547,400);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p32',257,500);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p33',564,600);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p34',211,200);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p35',233,500);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p36',293,400);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p37',552,700);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p38',812,700);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p39',541,400);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p40',441,700);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p41',875,300);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p42',691,500);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p43',572,300);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p44',572,500);
INSERT INTO `Passenger` (`personID`, `miles`, `funds`) VALUES ('p45',663,500);

INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('330-12-6907','p1',31,'dl_10');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('769-60-1266','p10',15,'lf_20');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('369-22-9505','p11',22,'km_16');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('680-92-5329','p12',24,'ry_34');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('513-40-4168','p13',24,'km_16');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('454-71-7847','p14',13,'km_16');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('153-47-8101','p15',30,'ja_35');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('598-47-5172','p16',28,'ja_35');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('865-71-6800','p17',36,NULL);
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('250-86-2784','p18',23,NULL);
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('386-39-7881','p19',2,NULL);
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('842-88-1257','p2',9,'dl_10');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('522-44-3098','p20',28,NULL);
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('750-24-7616','p3',11,'un_38');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('776-21-8098','p4',24,'un_38');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('933-93-2165','p5',27,'ba_61');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('707-84-4555','p6',38,'ba_61');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('450-25-5617','p7',13,'lf_20');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('701-38-2179','p8',12,'ry_34');
INSERT INTO `Pilot` (`taxID`, `personID`, `experience`, `flightID`) VALUES ('936-44-6941','p9',13,'lf_20');

INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p1');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p10');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p11');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p11');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p12');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p13');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p14');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p15');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p15');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('testing','p15');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p16');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p17');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p17');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p18');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p19');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p2');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p2');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p20');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p3');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p4');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p4');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p5');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p6');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p6');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p7');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p8');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('jets','p9');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('props','p9');
INSERT INTO `License` (`licenseName`, `personID`) VALUES ('testing','p9');

INSERT INTO `Prop` (`tailNumber`, `airlineID`, `numProps`, `skids`) VALUES ('n118fm','Air_France',2,0);
INSERT INTO `Prop` (`tailNumber`, `airlineID`, `numProps`, `skids`) VALUES ('n249yk','China Southern Airlines',2,0);
INSERT INTO `Prop` (`tailNumber`, `airlineID`, `numProps`, `skids`) VALUES ('n256ap','KLM',2,0);
INSERT INTO `Prop` (`tailNumber`, `airlineID`, `numProps`, `skids`) VALUES ('n341eb','Ryanair',2,1);
INSERT INTO `Prop` (`tailNumber`, `airlineID`, `numProps`, `skids`) VALUES ('n353kz','Ryanair',2,1);
INSERT INTO `Prop` (`tailNumber`, `airlineID`, `numProps`, `skids`) VALUES ('n448cs','American',2,1);

INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n106js','Delta','dl_10','08:00:00',1,1);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n161fk','KLM','km_16','14:00:00',6,1);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n305fv','Japan Airlines','ja_35','09:30:00',1,1);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n341eb','Ryanair','ry_34','15:00:00',0,0);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n380sd','United','un_38','14:30:00',2,1);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n517ly','British Airways','ba_51','11:30:00',0,0);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n616lt','British Airways','ba_61','09:30:00',0,0);
INSERT INTO `Supports` (`tailNumber`, `airlineID`, `flightID`, `nextTime`, `progress`, `in_flight`) VALUES ('n620la','Lufthansa','lf_20','11:00:00',3,1);

INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p21','AMS',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p22','AMS',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p23','BER',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p24','CDG',2);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p24','MUC',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p25','MUC',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p26','MUC ',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p27','BER',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p28','LGW',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p29','FCO',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p29','LHR',2);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p30','FCO',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p30','MAD',2);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p31','FCO',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p32','FCO',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p33','CAN',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p34','HND',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p35','LGW',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p36','FCO',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p37','CDG',3);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p37','FCO',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p37','LGW',2);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p38','MUC',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p39','MUC',1);
INSERT INTO `Vacation` (`personID`, `destination`, `sequence`) VALUES ('p40','HND',1);




