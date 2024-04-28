/*Table creation queries*/
CREATE TABLE Property (
    Prop_ID int NOT NULL AUTO_INCREMENT,
    Prop_Code varchar(255) NOT NULL,
    Prop_Name varchar(255) NOT NULL,
    Prop_Address varchar(255),
    Prop_City varchar(255),
    Prop_State varchar(255),
    Prop_Zip int,
    PRIMARY KEY (Prop_ID)
);

CREATE TABLE Unit (
	Unit_ID int NOT NULL AUTO_INCREMENT,
    Unit_Name varchar(255) NOT NULL,
    Unit_Area int,
    Prop_ID int,
    PRIMARY KEY (Unit_ID),
    FOREIGN KEY (Prop_ID) REFERENCES Property(Prop_ID)
);


CREATE TABLE Person (
	Per_ID int NOT NULL AUTO_INCREMENT,
    Per_Code varchar(255) NOT NULL,
    Per_Type varchar(255) NOT NULL,
    ID_Num bigint(8) NOT NULL,
    Per_Name varchar(255),
    Contact_Num bigint(8),
    PRIMARY KEY (Per_ID)
);

CREATE TABLE Person_Email (
	Per_ID int NOT NULL,
    Email varchar(255) NOT NULL,
    CONSTRAINT PK_Person_Email PRIMARY KEY (Per_ID, Email),
    FOREIGN KEY (Per_ID) REFERENCES Person(Per_ID)
);

CREATE TABLE Tenant (
	Per_ID int NOT NULL,
    Occupation varchar(255),
    LeaseStart_Dt datetime,
    LeaseEnd_Dt datetime,
    LeaseTerm int,
    Prop_ID int,
    PRIMARY KEY (Per_ID),
	FOREIGN KEY (Per_ID) REFERENCES Person(Per_ID),
	FOREIGN KEY (Unit_ID) REFERENCES Unit(Unit_ID)
);

CREATE TABLE Vendor_Categ (
	Categ_ID int NOT NULL AUTO_INCREMENT,
    Categ_Desc varchar(255) NOT NULL,
    PRIMARY KEY (Categ_ID)
);

CREATE TABLE Vendor (
	Per_ID int NOT NULL,
    Ven_Add varchar(255),
    Pay_Method varchar(255),
    Categ_ID int,
    PRIMARY KEY (Per_ID),
	FOREIGN KEY (Per_ID) REFERENCES Person(Per_ID),
	FOREIGN KEY (Categ_ID) REFERENCES Vendor_Categ(Categ_ID)
);

CREATE TABLE PO_Header (
	PO_ID int NOT NULL AUTO_INCREMENT,
    TotalAmt int,
    ReqDt datetime,
    Ven_ID int NOT NULL,
    Ten_ID int NOT NULL,
    PRIMARY KEY (PO_ID),
	FOREIGN KEY (Ven_ID) REFERENCES Vendor(Per_ID),
	FOREIGN KEY (Ten_ID) REFERENCES Tenant(Per_ID)
);

CREATE TABLE PO_Detail (
	PODet_ID int NOT NULL AUTO_INCREMENT,
    PO_ID int NOT NULL,
    Det_Desc varchar(255),
    Quantity int,
    UnitPrice int,
    GrossAmt int,
    TaxAmt int,
    TotalAmt int,
    CONSTRAINT PK_PO_Detail PRIMARY KEY (PODet_ID, PO_ID),
    FOREIGN KEY (PO_ID) REFERENCES PO_Header(PO_ID)
);

CREATE TABLE Inv_Header (
	Inv_ID int NOT NULL AUTO_INCREMENT,
    Inv_Num int,
    TotalAmt int,
    BillingDt datetime,
    Ven_ID int NOT NULL,
    Ten_ID int NOT NULL,
    PRIMARY KEY (Inv_ID),
	FOREIGN KEY (Ven_ID) REFERENCES Vendor(Per_ID),
	FOREIGN KEY (Ten_ID) REFERENCES Tenant(Per_ID)
);

CREATE TABLE Inv_Detail (
	InvDet_ID int NOT NULL AUTO_INCREMENT,
    Inv_ID int NOT NULL,
    Det_Desc varchar(255),
    Quantity int,
    UnitPrice int,
    GrossAmt int,
    TaxAmt int,
    TotalAmt int,
    CONSTRAINT PK_Inv_Detail PRIMARY KEY (InvDet_ID, Inv_ID),
    FOREIGN KEY (Inv_ID) REFERENCES Inv_Header(Inv_ID)
);

/*Procedure to derive the amounts*/
CREATE PROCEDURE UpdatePOAmt (PO_ID INT) 
BEGIN 
UPDATE PO_Detail SET GrossAmt = Quantity * UnitPrice WHERE PO_ID = @PO_ID;
UPDATE PO_Detail SET TaxAmt = GrossAmt*0.1 WHERE PO_ID = @PO_ID;
UPDATE PO_Detail SET TotalAmt = GrossAmt + TaxAmt WHERE PO_ID = @PO_ID;
UPDATE PO_Header PO SET PO.TotalAmt= (SELECT sum(d.totalamt)
							 FROM po_detail d
WHERE d.po_id = po.po_id
GROUP BY d.po_id) 
WHERE PO.PO_ID = @PO_ID;
END;
CALL UpdatePOAmt(3728);

/*Procedure to derive the amounts*/
CREATE PROCEDURE UpdateInvAmt (Inv_ID INT)
BEGIN
UPDATE Inv_Detail SET GrossAmt = Quantity * UnitPrice WHERE Inv_ID = @Inv_ID;
UPDATE Inv_Detail SET TaxAmt = GrossAmt*0.1 WHERE Inv_ID = @Inv_ID;
UPDATE Inv_Detail SET TotalAmt = GrossAmt + TaxAmt WHERE Inv_ID = @Inv_ID;
UPDATE Inv_Header ih SET ih.TotalAmt = (SELECT sum(d.totalamt)
FROM inv_detail d
WHERE d.inv_id = ih.inv_id
GROUP BY d.inv_id)
        WHERE ih.inv_ID = @Inv_ID;
        END;
CALL UpdateInvAmt(1577);