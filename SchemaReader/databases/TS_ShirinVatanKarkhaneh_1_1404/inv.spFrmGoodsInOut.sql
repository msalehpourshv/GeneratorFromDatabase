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
Create PROCEDURE  [inv].[spFrmGoodsInOut] 
	@DocDate		Char(10) = Null,
	@CallType1		Tinyint = 1
	
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;


----    اطلاعات در باسکول در تاریخ

if @CallType1=1
	Select  ProcessID,SerialNo, FiscalYear, TransporterID2,DriverID 
	 , ( Select FirstName +' '+LastName  from pub.tblDriversDtl b Where a.DriverID=b.DriverID )DriverName 
	 ,case when ProcessID=192 then 'تخلیه' else 'بارگیری' end C    
	  from inv.tblStorageDocsHdr a  
	  Where  C2=1 and ProcessID in (192 ,193)  and DocDate=@DocDate
----    اطلاعات در تخلیه و بارگیری در تاریخ
	
if @CallType1=2
	Select ProcessID,SerialNo, FiscalYear, TransporterID2,DriverID  , ( Select FirstName +' '+LastName  from pub.tblDriversDtl b Where a.DriverID=b.DriverID )DriverName 
	,case when ProcessID=192 then 'تخلیه' else 'بارگیری' end C    from inv.tblStorageDocsHdr a  
	Where C2=2 and ProcessID in(192,193)  and DocDate=@DocDate
----    اطلاعات در انتظار خروج در تاریخ
	
if @CallType1=3
	Select  SerialNo, FiscalYear, TransporterID2,DriverID,ProcessID 
	 , ( Select FirstName +' '+LastName  from pub.tblDriversDtl b Where a.DriverID=b.DriverID )DriverName 
	  from inv.tblStorageDocsHdr a  Where  C2=3 and ProcessID in(192,193)  and DocDate=@DocDate
----    اطلاعات   خروج در تاریخ  
if @CallType1=10
	Select  ProcessID,SerialNo, FiscalYear, TransporterID2,DriverID  , ( Select FirstName +' '+LastName  from pub.tblDriversDtl b Where a.DriverID=b.DriverID )DriverName  from inv.tblStorageDocsHdr a  Where  C2=4 and ProcessID in(192,193)  and DocDate=@DocDate
----    اطلاعات در تخلیه در تاریخ

if @CallType1=4
	Select  SerialNo, FiscalYear, TransporterID2,DriverID  , ( Select FirstName +' '+LastName  from pub.tblDriversDtl b Where a.DriverID=b.DriverID )DriverName  from inv.tblStorageDocsHdr a 
	 Where C2=2 and ProcessID=192   and    DocDate=@DocDate
----    اطلاعات در بارگیری در تاریخ
if @CallType1=5
	Select  SerialNo, FiscalYear, TransporterID2,DriverID  , ( Select FirstName +' '+LastName  from pub.tblDriversDtl b Where a.DriverID=b.DriverID )DriverName  from inv.tblStorageDocsHdr a  
	Where C2=2 and ProcessID=193   and    DocDate=@DocDate
----   تعداد ورودی در تاریخ
if @CallType1=6
Select Count(*) from inv.tblStorageDocsHdr Where ProcessID in (192,193  ) and DocDate=@DocDate 
----   تعداد خروجی در تاریخ
if @CallType1=7
Select Count(*) from inv.tblStorageDocsHdr Where C2=4 and ProcessID in (192,193 )    and DocDate=@DocDate 


----   تعداد  تخلیه  در تاریخ
if @CallType1=8
 Select Count(*) from inv.tblStorageDocsHdr Where  C2=2 and ProcessID=192   and DocDate=@DocDate 
----   تعداد  بارگیری در تاریخ
if @CallType1=9
 Select Count(*) from inv.tblStorageDocsHdr Where C2=2 and ProcessID=193   and DocDate=@DocDate 
END
GO
