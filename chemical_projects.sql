-- -----------------------------------------

DROP SCHEMA IF EXISTS chemical_projects;
CREATE SCHEMA IF NOT EXISTS chemical_projects;
USE chemical_projects;

-- -----------------------------------------------------
-- Create all nine table entails.
-- Additional indices for a given table will be listed below that table.


CREATE TABLE Customer(
 customerName VARCHAR(30) NOT NULL,
 street VARCHAR(35) NOT NULL,
 city VARCHAR(20) NOT NULL,
 country VARCHAR(30) NOT NULL,
 contactFName VARCHAR(15) NOT NULL,
 contactLName VARCHAR(15) NOT NULL,
 contactPhone VARCHAR(15),
 contactEmail VARCHAR(30) NOT NULL,
 PRIMARY KEY (customerName)
);

CREATE INDEX contactFNameInd ON Customer(contactFName);
CREATE INDEX contactLNameInd ON Customer(contactLName);
-- Non-unique index as it's possible to have two contacts from different companies with the same first or last name

CREATE TABLE Staff(
 employeeId INT UNSIGNED AUTO_INCREMENT NOT NULL,
 fName VARCHAR(15) NOT NULL,
 lName VARCHAR(15) NOT NULL,
 dob DATE NOT NULL,
 street VARCHAR(35) NOT NULL,
 city VARCHAR(20) NOT NULL,
 staffPhone VARCHAR(15) NOT NULL,
 staffEmail VARCHAR(25) NOT NULL,
 salary VARCHAR(7) NOT NULL,
 workLead BOOLEAN NOT NULL,
 specialty VARCHAR(40),
 analyst BOOLEAN NOT NULL,
 grade VARCHAR(1),
 managerId INT UNSIGNED,
 PRIMARY KEY (employeeId),
 CONSTRAINT fk_mgrId FOREIGN KEY (managerId) REFERENCES Staff(employeeId) 
	ON UPDATE CASCADE
	ON DELETE SET NULL
);

CREATE TABLE Project(
 projectName VARCHAR(60) NOT NULL,
 screenType VARCHAR(15) NOT NULL,
 deadline DATE NOT NULL,
 customerName VARCHAR(30) NOT NULL,
 overseer INT UNSIGNED,
 PRIMARY KEY (projectName),
 CONSTRAINT fk_customerName FOREIGN KEY (customerName) REFERENCES Customer(customerName)
	ON UPDATE CASCADE
	ON DELETE NO ACTION,
 CONSTRAINT fk_overseer FOREIGN KEY (overseer) REFERENCES Staff(employeeId)
	ON UPDATE CASCADE
	ON DELETE SET NULL
);
# Some scientific projects have verbose long names, hence 60 character project name.
# The records of Customers with associated projects generally speaking shouldn't be deleted, there's a legal requirement to hold 
# this information for many years. Due to fk_customerName you can't accidentally delete a customer who had associated projects.

CREATE INDEX screenTypeInd ON Project(screenType);
# Non-unique index as it's possible to have different projects that have the same type of screen.

CREATE TABLE Experiment(
 exptName VARCHAR(50) NOT NULL,
 consumables VARCHAR(40),
 glassware VARCHAR(30),
 PRIMARY KEY (exptName)
);
# Consumables & glassware may or may not be required, therefore null values allowed

CREATE TABLE Instrument( 
 instrumentName VARCHAR(30) NOT NULL,
 location VARCHAR(20) NOT NULL,
 manufacturer VARCHAR(20) NOT NULL,
 maintenanceDate DATE NOT NULL,
 PRIMARY KEY (instrumentName)
);

CREATE INDEX instrumentLocationInd ON Instrument(location);
# Non-unique index as it's possible to have multiple instruments in the same place.

CREATE TABLE carriesOut(
 exptName VARCHAR(50) NOT NULL,
 employeeId INT UNSIGNED NOT NULL,
 PRIMARY KEY (exptName, employeeId),
 CONSTRAINT fk_employeeId FOREIGN KEY (employeeId) REFERENCES Staff(employeeId)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
 CONSTRAINT fk_exptName_carriesOut FOREIGN KEY (exptName) REFERENCES Experiment(exptName)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

CREATE TABLE trainingCompleted(
 training VARCHAR(40) NOT NULL,
 analyst INT UNSIGNED NOT NULL,
 PRIMARY KEY (training),
 CONSTRAINT fk_analyst FOREIGN KEY (analyst) REFERENCES Staff(employeeId)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

CREATE TABLE entails(
 projectName VARCHAR(60) NOT NULL,
 exptName VARCHAR(50) NOT NULL,
 hours INT UNSIGNED,
 PRIMARY KEY (projectName, exptName),
 CONSTRAINT fk_projectName FOREIGN KEY (projectName) REFERENCES Project(projectName)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
 CONSTRAINT fk_exptName_entails FOREIGN KEY (exptName) REFERENCES Experiment(exptName)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
# A project can be defined before work on it begins, therefore the hours spent on any project can be null.

CREATE TABLE uses(
 instrumentName VARCHAR(30) NOT NULL,
 exptName VARCHAR(45) NOT NULL,
 PRIMARY KEY (instrumentName, exptName),
 CONSTRAINT fk_instrumentName FOREIGN KEY (instrumentName) REFERENCES Instrument(instrumentName)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
 CONSTRAINT fk_exptName_uses FOREIGN KEY (exptName) REFERENCES Experiment(exptName)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Populating tables

INSERT INTO Customer VALUES
('DeathStar Securities', '123 Townville', 'Sitty', 'Lahndland', 'Moff', 'Tarkan', '000082-3456789', 'Grand-Moff@NotAMoon.zap'),
('Megacorp', '321 Villillage', 'Sitty', 'Lanhdland', 'Abercrombie', 'Fizzwidget', '000083-4567890', 'A.Fizz@Mega.corp'),
('DentalChem', '42 Wallaby Way', 'Sydney', 'Australia', 'Philip', 'Sherman', '006181-2345678', 'DefinitelyNotFrom@Pixar.com');

INSERT INTO Staff VALUES 
('1', 'Rex', 'Steel', '1980-01-01', '44 Townplace', 'Metropolis', '087-7777777', 'R.Steel@Research.comp', '50000', '1', 'Amorphous solid production', '0', NULL, NULL),
('2', 'Bill', 'Bobson', '1990-02-02', '55 Placetown', 'Metropolis', '086-6666666', 'B.Bobson@Research.comp', '30000', '0', NULL, '1', '2', '1'),
('3', 'Grant', 'Mustang', '1980-10-10', '1 Excellenceville', 'Flexton', '085-5555555', 'G.Mustang@Research.comp', '45000', '1', 'Salt & cocrystal screening', '0', NULL, '1'),
('4', 'Janet', 'Janeson', '1990-01-01', '55 Placetown', 'Metropolis', '083-3333333', 'J.Janeson@Research.comp', '30000', '0', NULL, '1', '2', '3');

INSERT INTO Project VALUES 
('Polymorph Screen of TK-421', 'Basic', '2022-01-01', 'DeathStar Securities', '1'),
('Crystallisation Development of RYNO_02', 'Comprehensive', '2023-12-30', 'Megacorp', '3'),
('Salt Screen of FishTankCleaner_2003', 'Basic', '2024-06-30', 'DentalChem', '3'),
('Co-crystal Screen of N080DY 4551GNED', 'Comprehensive', '2023-11-20', 'Megacorp', NULL);

INSERT INTO Experiment VALUES 
('Lyophilization of TK-421', NULL, 'Lyophilisation flask'),
('X-ray Powder Diffraction of RYNO_02', 'XRD foil', NULL),
('Temperature Cycle of FishTankCleaner_2003', 'HPLC vial cap', 'HPLC vial');

INSERT INTO Instrument VALUES 
('Freeze Drier', 'Lab 4-1', 'Chilli Instruments', '2023-11-22'),
('X Ray Powder Diffractometer', 'Lab 1-5', 'Panalytikal', '2025-01-01'),
('Temperature Cycler & IR Probe', 'Lab 4-2', 'Chilli Instruments', '2023-09-02');

INSERT INTO trainingCompleted VALUES 
('Polymorph screening techniques 101', '2'),
('Crystallisation development processes', '4'),
('Bob B.: Salt screening techniques', '2'),
('Jane J.: Salt screening techniques', '4');

INSERT INTO entails VALUES 
('Polymorph Screen of TK-421', 'Lyophilization of TK-421', '5'),
('Crystallisation Development of RYNO_02', 'X-ray Powder Diffraction of RYNO_02', '6'),
('Salt Screen of FishTankCleaner_2003', 'Temperature Cycle of FishTankCleaner_2003', '1');

INSERT INTO uses VALUES 
('Freeze Drier', 'Lyophilization of TK-421'),
('X Ray Powder Diffractometer', 'X-ray Powder Diffraction of RYNO_02'),
('Temperature Cycler & IR Probe', 'Temperature Cycle of FishTankCleaner_2003');

INSERT INTO carriesOut VALUES 
('Lyophilization of TK-421', '2'),
('X-ray Powder Diffraction of RYNO_02', '4'),
('Temperature Cycle of FishTankCleaner_2003', '4');

-- -----------------------------------------
 -- Creating two views:
 -- ongoingProjectsView is designed for work leads and gives a summary overview of all current projects, their associated clients, and project deadlines.
 -- analystAssignments is designed for analysts and provides a more granular view ongoing experiments, who's running them, using what instruments and where.

CREATE OR REPLACE VIEW ongoingProjectsView AS 
	SELECT customerName AS "Client", projectName AS "Project", screenType AS "Screen Type", CONCAT(fName, ' ', lName) AS "Project Overseer", deadline AS "Deadline", hours AS "Hours Spent"
	FROM Project NATURAL JOIN entails 
	NATURAL JOIN Customer
	JOIN staff 
	ON Project.overseer = staff.employeeId
	ORDER BY deadline, hours;

CREATE OR REPLACE VIEW analystAssignmentsView AS 
	SELECT CONCAT(fName, ' ', lName) AS "Analyst", grade AS "Grade", CONCAT(staffEmail, ' (', staffPhone, ')') AS "Contact", projectName AS "Assigned Project", exptName AS "Associated Experiment", instrumentName AS "Instrument Employed", location AS "Instrument Location"
	FROM Project NATURAL JOIN entails 
	NATURAL JOIN Experiment
    NATURAL JOIN carriesOut
    JOIN Staff
    ON carriesOut.employeeId = Staff.employeeId
	NATURAL JOIN uses
    NATURAL JOIN Instrument
	ORDER BY analyst, projectName, exptName;

-- -----------------------------------------
-- Creating two users:
-- User 'WorkLead' has full access to the database.
-- User 'Analyst' has full view access to the database, but for security purposes can only modify tables relevant to their work.
-- While analyst modify access is quite limited, work leads can grant additional accesses as required.

DROP USER WorkLead, Analyst;

CREATE USER WorkLead IDENTIFIED BY 'secret';
GRANT ALL ON chemical_projects.* TO WorkLead WITH GRANT OPTION;

CREATE USER Analyst IDENTIFIED BY 'test123';
GRANT SELECT ON chemical_projects.* TO Analyst;
GRANT INSERT, UPDATE, DELETE ON Experiment TO Analyst;
GRANT INSERT, UPDATE, DELETE ON Instrument TO Analyst;
GRANT INSERT, UPDATE, DELETE ON uses TO Analyst;
GRANT INSERT, UPDATE, DELETE ON carriesOut TO Analyst;

-- -----------------------------------------
-- Creating trigger & table to record changes to the Project table.
-- Useful to capture changes to deadlines, the project screen type, or the overseer assigned to it.
-- Changes to a project's associated customer are highly unlikely, so customerName is ommited for efficiency.

CREATE TABLE project_history (
	projectName VARCHAR(60) NOT NULL,
	screenType VARCHAR(15) NOT NULL,
	deadline DATE NOT NULL,
	overseer INT UNSIGNED,
    action VARCHAR(20) NOT NULL,
    dateOfChange DATETIME NOT NULL
);

Delimiter %%
CREATE TRIGGER before_project_update 
	BEFORE UPDATE ON project
    FOR EACH ROW
BEGIN
	INSERT INTO project_history
    SET projectName = old.projectName,
	screenType = old.screenType,
	deadline = old.deadline,
	overseer = old.overseer,
    action = 'Update',
    dateOfChange = NOW();
END %%
delimiter ;

-- -----------------------------------------
-- Creating trigger & table to monitor changes to instruments' maintenance date.
-- Data on when instrument maintenance was performed must be captured to adhere to pharmaceutical GMP requirements.

CREATE TABLE instrument_maintenance_history (
	instrumentName VARCHAR(30) NOT NULL,
	action VARCHAR(20) NOT NULL,
    oldMaintenanceDate DATE NOT NULL,
    dateOfChange DATETIME NOT NULL
);

Delimiter %%
CREATE TRIGGER before_instrument_maintenance_update 
	BEFORE UPDATE ON Instrument
    FOR EACH ROW
BEGIN
	INSERT INTO instrument_maintenance_history
    SET instrumentName = old.instrumentName,
    action = 'Update',
	oldMaintenanceDate = old.maintenanceDate,
	dateOfChange = NOW();
END %%
delimiter ;

-- -----------------------------------------

COMMIT;