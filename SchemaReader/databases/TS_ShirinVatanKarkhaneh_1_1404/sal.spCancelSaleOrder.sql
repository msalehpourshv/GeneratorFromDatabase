USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/04/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[spCancelSaleOrder] 
	@CurrentDocDate	Char(10),
	@DocDate		Char(10),
	@FromDocStep	TINYINT, 	
	@ToDocStep		TINYINT 	
WITH ENCRYPTION
 AS
BEGIN
	
	DECLARE @ProcessID	INT
	DECLARE @ProcessNo	INT
	DECLARE @FiscalYear INT
	DECLARE @SerialNo	INT
	DECLARE	@StrQuery	NVarChar(2000)
	DECLARE	@AcntCode	VarChar(20)
	
	Declare	Cursor_SaleOrder CURSOR FOR
	SELECT DISTINCT  ProcessID,ProcessNo,FiscalYear, SerialNo, AcntCode 
	FROM ((
	SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, AcntCode 
	FROM sal.tblSaleOrderDtl
	WHERE ProcessID=180 AND DocDate<@DocDate AND DocStep>= @FromDocStep AND DocStep<=@ToDocStep
EXCEPT
	SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear, BaseSerialNo, BaseDocRowNo, AcntCode  
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID=90)
EXCEPT
	SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear, BaseSerialNo, BaseDocRowNo, AcntCode  
	FROM sal.tblSaleOrderDtl
	WHERE ProcessID=185
	) A 

	Open  Cursor_SaleOrder; 

	Fetch NEXT From Cursor_SaleOrder Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo, @AcntCode 

	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @StrQuery = 'sal.SpSumSaleOrderRemain ''' + @AcntCode + ''',''' + @CurrentDocDate + ''',' + ltrim(str(@FiscalYear)) + ',' + ltrim(str(@ProcessNo)) + ', ' + ltrim(str(@SerialNo)) + ',''TRUE'',1'
			
			PRINT @StrQuery
			EXEC sp_executesql @StrQuery;
				
			Fetch NEXT From Cursor_SaleOrder Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo, @AcntCode
		END
	Close Cursor_SaleOrder;
	Deallocate Cursor_SaleOrder; 
END
GO
