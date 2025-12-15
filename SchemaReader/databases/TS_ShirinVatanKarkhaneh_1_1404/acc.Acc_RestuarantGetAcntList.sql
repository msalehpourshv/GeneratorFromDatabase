USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza	NP
-- Create date   : 1393/01/17
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier :  
-- Description	 :  
-- ----------------------------------------------
--   
-- ==============================================
create PROCEDURE [acc].[Acc_RestuarantGetAcntList]
	 
			
WITH ENCRYPTION
AS

declare @AcntPart as int;

SELECT @AcntPart=isnull(SettingValue,1) FROM pub.tblSettings 
		 WHERE SettingKey='AcntPartNumberForRemainCalculation'
		 
BEGIN
	
		select a.AcntCode,d.AcntName from acc.tblAcnt a
		inner join acc.tblAcntDtl d
		on a.AcntCode=d.AcntCode
		where a.PartNumber=@AcntPart  
    
END
GO
