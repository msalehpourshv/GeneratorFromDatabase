USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ Hadi Sadeghi
-- Create date   : 1400/06/31
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : لیست برگ انتقال شعب
-- ==============================================
Create PROCEDURE [inv].[SpGetBranchTransfersList]
	@BranchID		varchar(20) = '',
	@LanguageID		tinyint
WITH ENCRYPTION
AS

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,H.DocDate,H.DocDesc,StoreID,pub.GetStoreName(StoreID,@LanguageID) StoreName
	     ,(SELECT top 1 StationID from inv.tblStores a where a.StoreID=H.StoreID) FromStationID 
	FROM inv.tblStorageDocsHdr H
	inner join (
		select ProcessID,ProcessNo,FiscalYear,SerialNo
		from inv.tblStorageDocsHdr
		where ProcessID in( 123) and BranchID=@BranchID
		EXCEPT 
		select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
		from inv.tblStorageDocsHdr
		where ProcessID in( 124) ) B
	on H.ProcessID=B.ProcessID and H.ProcessNo=B.ProcessNo AND H.FiscalYear=B.FiscalYear and H.SerialNo=B.SerialNo

END
GO
