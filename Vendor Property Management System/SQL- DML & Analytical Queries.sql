DELIMITER //
/*Trigger for BEFORE INSERT*/
CREATE TRIGGER CalculateLeaseTerm_Insert
BEFORE INSERT ON Tenant
FOR EACH ROW
BEGIN
-- Calculate LeaseTerm
SET NEW.LeaseTerm = TIMESTAMPDIFF(MONTH, NEW.LeaseStart_Dt, NEW.LeaseEnd_Dt);
END;
//

/*Trigger for BEFORE UPDATE*/
CREATE TRIGGER CalculateLeaseTerm_Update
BEFORE UPDATE ON Tenant
FOR EACH ROW
BEGIN
 -- Calculate LeaseTerm
SET NEW.LeaseTerm = TIMESTAMPDIFF(MONTH, NEW.LeaseStart_Dt, NEW.LeaseEnd_Dt);
END;
//
DELIMITER ;

/*Fetching all the vendors whose total invoice amount is greater than the average total invoice amount.*/
SELECT v.Per_ID as Vendor_ID,
p.Per_Name as Vendor_Name,
AVG(i.TotalAmt) as VendorAverage
FROM Vendor v
INNER JOIN Person p ON v.Per_ID = p.Per_ID
INNER JOIN Inv_Header i ON v.Per_ID = i.Ven_ID
GROUP BY i.Ven_ID
HAVING VendorAverage > (SELECT AVG(TotalAmt)
						  FROM Inv_Header)
ORDER BY i.Ven_ID;

/*Fetch the PO ID, Amount, Request Date, Vendor Name, Tenant Name of Tenants with Pos created and residing in properties of the state North Carolina.*/
 SELECT po.PO_ID AS PO_ID, 
PO.TotalAmt AS POAmount, 
PO.ReqDt AS RequestDate, 
p1.Per_Name AS VendorName,
p2.Per_Name AS TenantName
FROM PO_Header PO
INNER JOIN Vendor v on PO.Ven_ID = v.Per_ID
INNER JOIN Tenant t on PO.Ten_ID = t.Per_ID
INNER JOIN Unit u on t.Unit_ID = u.Unit_ID
INNER JOIN Property p on u.Prop_ID = p.Prop_ID
INNER JOIN Person p1 on v.Per_ID = p1.Per_ID
INNER JOIN Person p2 on t.Per_ID = p2.Per_ID
WHERE p.PROP_STATE = 'North Carolina'

/*Calculate the average PO amount of the POs that belong to the Tenants residing in units with area which is greater than the average area of units of the properties in Boston.*/
SELECT avg(po.totalAmt) as AverageAmount
FROM PO_Header PO
INNER JOIN Tenant t on PO.Ten_ID = t.Per_ID
INNER JOIN Unit u on t.Unit_ID = u.Unit_ID
INNER JOIN Property p on u.Prop_ID = p.Prop_ID
WHERE u.Unit_Area > (SELECT avg(u.Unit_Area) FROM unit u
					INNER JOIN PROPERTY P on u.Prop_ID = p.Prop_ID
                    WHERE p.prop_city = 'Boston')


/*Fetch vendors with at least two invoices and their corresponding purchase orders.*/
SELECT v.Per_ID AS Vendor_ID, 
p.Per_Name AS Vendor_Name, 
COUNT(i.Inv_ID) AS Invoice_Count,
po.PO_ID AS POID, 
po.TotalAmt AS PO_Amount
FROM Vendor v
JOIN Person p ON v.Per_ID = p.Per_ID
LEFT JOIN Inv_Header i ON v.Per_ID = i.Ven_ID
JOIN (SELECT ph.Ven_ID, ph.PO_ID, SUM(pd.TotalAmt) AS TotalAmt
	  FROM PO_Header ph
      JOIN PO_Detail pd ON ph.PO_ID = pd.PO_ID
      GROUP BY ph.Ven_ID, ph.PO_ID
) po ON v.Per_ID = po.Ven_ID
GROUP BY v.Per_ID, p.Per_Name, po.PO_ID, po.TotalAmt
HAVING Invoice_Count >= 2;

/*Fetch the count of units based on areas. Term them as common spaces, less area, medium area, more area.*/
SELECT AreaAnalysis, Count(x.AreaAnalysis) AS Counts
FROM (SELECT u.unit_name as UnitName, 
			 p.prop_name as PropertyName,
             CASE WHEN u.unit_area < 1000 THEN 'Common Spaces'
				  WHEN u.unit_area BETWEEN 1000 AND 1250 THEN 'Less Area'
                  WHEN u.unit_area BETWEEN 1251 AND 1350 THEN 'Medium Area'
                  WHEN u.unit_area > 1351 THEN 'More Area'
			 END as AreaAnalysis
	   FROM Unit u
       INNER JOIN Tenant t ON u.Unit_ID = t.Unit_ID
       INNER JOIN PO_Header po ON t.Per_ID = po.Ten_ID
       INNER JOIN PO_Detail pd ON po.PO_ID = pd.PO_ID
       INNER JOIN Property p ON u.Prop_ID = p.Prop_ID
       WHERE pd.Det_Desc = 'Flooring Service') x
GROUP BY AreaAnalysis
ORDER BY Counts;

/*Calculate the sum of quantities requested per service.*/
SELECT Det_Desc as DescReq, Sum(Quantity) as TotalReq
FROM PO_Detail
GROUP BY Det_Desc;

/*Fetch the count of vendors providing each of the payment methods.*/
SELECT Pay_Method as PaymentMethod, Count(Per_ID) as CountMethod
FROM Vendor 
GROUP BY Pay_Method;