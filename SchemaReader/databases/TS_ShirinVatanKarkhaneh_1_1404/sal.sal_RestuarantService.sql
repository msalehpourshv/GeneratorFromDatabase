USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1394/08/17
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier :  
-- Description	 :  
-- ----------------------------------------------
--   
-- ==============================================
CREATE PROCEDURE [sal].[sal_RestuarantService]
	 
			
WITH ENCRYPTION
AS
begin

SELECT      s.TableID as SalonID, 
s.TableName AS SalonName, d.PartyDate, d.StartTime, d.EndTime, d.PersonQty, 
p.ReasonName,
case when d.MealType=0 then 'ندارد ' else
	case when d.MealType=1 then 'نهار ' else
         case when d.MealType=2 then 'شام ' else  'سایر'           end end end as MealTypeName
,case when d.DayType=1 then 'عادی ' else
	case when d.DayType=1 then 'پنجشنبه جمعه ' else 'اعیاد' end end as DayTypeName
,
d.SerialNo, d.ProcessID, d.BranchID, d.RowNo, d.DocRowNo, d.SalonID, d.PlusCount, d.PlusCost, d.SalonPrice, d.StartTimeMen, d.EndTimeMen, 
d.IsRestaurant, d.ReasonID
, d.MealType, d.DayType, d.FiscalYear, d.ProcessNo 
	        
FROM         sal.tblRestaurantContractDtl3 AS d INNER JOIN
                      sal.tblTablesDtl AS s ON d.SalonID = s.TableID LEFT OUTER JOIN
                      sal.tblPartyReasonDtl AS p ON d.ReasonID = p.ReasonID

ORDER BY d.DocRowNo
    
    
END
GO
