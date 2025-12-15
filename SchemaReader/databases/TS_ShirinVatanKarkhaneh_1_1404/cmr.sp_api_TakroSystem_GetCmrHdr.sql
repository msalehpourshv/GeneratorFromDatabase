USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create  PROCEDURE cmr.sp_api_TakroSystem_GetCmrHdr

@Filter as NVARCHAR(50),
@Skip as NVARCHAR(50),
@MaxResultCount as NVARCHAR(50),
@AcntCode as NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
	
BEGIN TRY

	set @strQuery='select  AcntCode,DocDate,DocDesc,cast(FiscalYear as int)FiscalYear,cast(ProcessNo as int) ProcessNo,cast(ProcessID as int) as ProcessID,SerialNo,DocStep,h.StoreID,sd.StoreName
					FROM cmr.tblCMRHdr h
					left join inv.tblStoresDtl sd
					on h.StoreID=sd.StoreID 
					WHERE ProcessID=150 AND AcntCode='''+@AcntCode+''''
	
	if @Filter<>''
	begin

		set @strQuery=@strQuery+ ' AND  SerialNo like ''%'+@Filter+'%'''
	End

	SET @strQuery=@strQuery+' 
				   ORDER BY SerialNo DESC
				   OFFSET ' +@Skip +' Rows 
				   FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	PRINT @strQuery
	EXEC sp_executesql @strQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
