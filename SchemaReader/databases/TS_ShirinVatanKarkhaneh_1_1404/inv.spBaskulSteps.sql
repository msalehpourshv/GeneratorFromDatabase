USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1396/04/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE  inv.spBaskulSteps 
	@ProcessID		int = 0,
	@DocDate		Char(10) = Null,
	@CallType1		Tinyint = 1,
	@ExtraParams	NVarChar(500) = Null
	
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;
DECLARE @IsCancel	Bit;

declare @intLangID int
	SET @intLangID = pub.funGetCurrentLanguageID()
	SET @IsCancel		  = LTrim(pub.funSplitString(@ExtraParams, '@', 1));

----    اطلاعات در باسکول در تاریخ
	
	Select   *
	,isnull((Select  FirstName+' '+ LastName  from pub.tblDriversDtl Where DriverID=a.DriverID and  LanguageID=@intLangID), '')DriverName
	,isnull((Select  VehicleTypeName  from sal.tblVehicleTypesDtl Where VehicleTypeID=a.VehicleTypeID and  LanguageID=@intLangID) , '')VehicleTypeName
	, Case when Step=1 then 'نوبت دهی' else Case when Step=2 then 'توزین اولیه' else Case when Step=3 then 'توزین کامل' else 'اتمام باسکول' end end end State
	,pub.funLockStatus(ProcessID, ProcessNo, FiscalYear, SerialNo, 0, 0) +' '+
	pub.funLockStatus(BaseProcessID, BaseProcessNo, BaseFiscalYear, SerialNo, 0, 0) AS Locked  
	 FROM         inv.tblBaskulSalesHdr a
	  Where  ProcessID =@ProcessID  and DocDate=@DocDate and Step=@CallType1
	  and 	   IsCancel=@IsCancel
----    اطلاعات در تخلیه و بارگیری در تاریخ
	

END
GO
