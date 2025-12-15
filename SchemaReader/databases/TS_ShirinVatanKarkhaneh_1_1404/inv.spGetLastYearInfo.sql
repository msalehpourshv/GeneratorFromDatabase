USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Mahdi Mostafavi
-- Create date   : 1404/01/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE  [inv].[spGetLastYearInfo] 
	@CurrentDBName		NVarChar (100) = Null,
	@CurrentFiscalYear	SmallInt
	
WITH ENCRYPTION
AS
BEGIN
DECLARE @StrSelect		Nvarchar (max) = ''
DECLARE @LastYearDBName	NVarChar (100) = ''
DECLARE @LastYearFiscalYear	SmallInt

SET NOCOUNT ON;
	
	EXEC [pub].[SpGetPrevDBName] @CurrentDBName,@LastYearDBName OUTPUT
	
	IF @LastYearDBName <> ''
	BEGIN
		SELECT @LastYearFiscalYear = CAST(SUBSTRING(@LastYearDBName, LEN(@LastYearDBName) -3, 4) AS smallint)
	END

	IF @LastYearFiscalYear is Null Set @LastYearFiscalYear = 0
	
	IF @LastYearFiscalYear <> 0
	BEGIN
		SET @StrSelect = '
				 ALTER TABLE inv.tblStorageDocsHdr DISABLE TRIGGER trgStorageDocsHdrInsert
				 ALTER TABLE inv.tblStorageDocsDtl DISABLE TRIGGER trgStorageDocsDtlInsert
				 
				 ALTER TABLE inv.tblStorageDocsHdr DISABLE TRIGGER trgStorageDocsHdrDelete
				 ALTER TABLE inv.tblStorageDocsDtl DISABLE TRIGGER trgStorageDocsDtlDelete
				 
				 ----------------------------
				 DELETE FROM '+@CurrentDBName+'.sal.tblSaleOrderHdr
				 WHERE FiscalYear <= '+ LTrim(RTrim(str(@LastYearFiscalYear))) +'
				 
				 DELETE FROM '+@CurrentDBName+'.sal.tblSaleOrderDtl
				 WHERE FiscalYear <= '+ LTrim(RTrim(str(@LastYearFiscalYear))) +'
				 -----------------------------------------
				 
				 INSERT INTO '+@CurrentDBName+'.sal.tblSaleOrderHdr
				 SELECT * 
				 FROM '+@LastYearDBName+'.sal.tblSaleOrderHdr
				 WHERE FiscalYear <= '+ LTrim(RTrim(str(@LastYearFiscalYear))) +' 
				   AND ProcessID in (190,191)
				 
				 
				 INSERT INTO '+@CurrentDBName+'.sal.tblSaleOrderDtl
				 SELECT * 
				 FROM '+@LastYearDBName+'.sal.tblSaleOrderDtl
				 WHERE FiscalYear <= '+ LTrim(RTrim(str(@LastYearFiscalYear))) +' 
				   AND ProcessID in (190,191)
				 -----------------------------------------
				 
				 DELETE FROM '+@CurrentDBName+'.inv.tblStorageDocsHdr
				 WHERE ProcessID = 50  
				   AND FiscalYear = '+ LTrim(RTrim(str(@CurrentFiscalYear))) +'
				 
				 DELETE FROM '+@CurrentDBName+'.inv.tblStorageDocsDtl
				 WHERE ProcessID = 50 
				   AND FiscalYear = '+ LTrim(RTrim(str(@CurrentFiscalYear))) +'
				 
				 
				 DELETE FROM '+@CurrentDBName+'.inv.tblStorageDocsHdr
				 WHERE FiscalYear <= '+ LTrim(RTrim(str(@LastYearFiscalYear))) +'
				 
				 DELETE FROM '+@CurrentDBName+'.inv.tblStorageDocsDtl
				 WHERE FiscalYear <= '+ LTrim(RTrim(str(@LastYearFiscalYear))) +'
				 -------------------------------------------
				 
				 INSERT INTO inv.tblStorageDocsHdr
				 SELECT * 
				 FROM '+@LastYearDBName+'.inv.tblStorageDocsHdr
				 
				 INSERT INTO inv.tblStorageDocsDtl
				 SELECT * 
				 FROM '+@LastYearDBName+'.inv.tblStorageDocsDtl
				 
				 ----------------------------
				 ALTER TABLE inv.tblStorageDocsHdr ENABLE TRIGGER trgStorageDocsHdrInsert
				 ALTER TABLE inv.tblStorageDocsDtl ENABLE TRIGGER trgStorageDocsDtlInsert
				 
				 ALTER TABLE inv.tblStorageDocsHdr ENABLE TRIGGER trgStorageDocsHdrDelete
				 ALTER TABLE inv.tblStorageDocsDtl ENABLE TRIGGER trgStorageDocsDtlDelete '

		PRINT @StrSelect
		EXEC sp_executesql @StrSelect
	END 
END
GO
