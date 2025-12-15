USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1387/01/06
-- Viewed By	 : 
-- Last Modified : 1394/07/05
-- Last Modifier : TakroSystem\Hamid
-- Description	 : برگ انبار
-- ==============================================
Create PROCEDURE [inv].[RptStore_SentResToPrd]
	@ProcessID		Int = 70,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@AcntCode	Varchar(20)= Null,
	@ProductID	Varchar(20)= Null,
	@BatchNo	Varchar(20)= Null,
	@BaseSerialNo		Int = Null,
	@pmShowZeroDecimals		bit = 0,
	@pmQtyDecimals		Int = Null,
	@pmPrcDecimals		Int = Null
	
                     
WITH ENCRYPTION
AS

DECLARE @LanguageID		TinyInt;

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)

	-- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	IF (@ProcessNo Is Null)		SET @ProcessNo = 70;
	
	SET @StrWhere = '  '
	
	IF (@AcntCode is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.AcntCode = ''' + @AcntCode + ''')'
	IF (@FiscalYear is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear =  ' + str(@FiscalYear) + ')'
	IF (@SerialNo is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo =  ' + str(@SerialNo) + ')'
	IF (@ProductID is not null) 
	begin
		IF @ProcessID = 70
		SET @StrWhere = @StrWhere + ' AND (H.ProductID = ''' + @ProductID + ''')'
			IF @ProcessID = 80
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @ProductID + ''')'
		end 	
	IF (@BatchNo is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.BatchNo = ''' + @BatchNo + ''')'
	IF (@BaseSerialNo is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo = ' + str(@BaseSerialNo) + ')'
	
	-- Select Section ----------------------------------------------------------
	SET @StrSelect = ''
	
	-- SELECT Clause ----------------------------------------
	IF @ProcessID = 70
	SET @StrSelect = ' SELECT   H.*,[pub].[GetCodeName](	H.AcntCode,1)as  AcntName
	,[pub].[GetGoodsName](	H.ProductID, 	1)as ProductName 
	,[pub].[GetGoodsName](	D.GoodsID, 	1)as GoodsName 
	,[pub].[GetStoreName](H.StoreID,1)as StoreName
	
, D.*    FROM          inv.tblStorageDocsHdr AS H INNER JOIN
inv.tblStorageDocsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
H.SerialNo = D.SerialNo
WHERE      (H.ProcessID = 70 OR H.ProcessID = 75) '+ @StrWhere + '  '
	
		
	IF @ProcessID = 80

	SET @StrSelect = ' SELECT   H.*,[pub].[GetCodeName](	H.AcntCode,1)as  AcntName
	,[pub].[GetGoodsName](	H.ProductID, 	1)as ProductName 
	,[pub].[GetGoodsName](	D.GoodsID, 	1)as GoodsName 
	,[pub].[GetStoreName](H.StoreID,1)as StoreName
	
, D.*     FROM          inv.tblStorageDocsHdr AS H INNER JOIN
inv.tblStorageDocsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
H.SerialNo = D.SerialNo
WHERE      (H.ProcessID = 80 OR H.ProcessID = 80) '+ @StrWhere + '  '
	
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	
	------------------------------------------------------------
End
GO
