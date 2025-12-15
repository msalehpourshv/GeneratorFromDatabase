USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : 
-- Create date   : 1404/05/14
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.SpGetPosInStoreReviewDtl
	@StoreID			NVarChar(MAX),
	@GoodsID			NVarChar(MAX),
	@ContainerID		NVarChar(MAX),
	@ContainerStoresID	NVarChar(MAX),
	@LangID				TinyInt
WITH ENCRYPTION
As 
BEGIN
	DECLARE @StrSelect	   NVarChar(MAX) = ''
	DECLARE @StrWhereMain  NVarChar(MAX) = ' WHERE (1=1) '

	IF @StoreID is not Null AND @StoreID <> '' AND @StoreID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @StoreID

	IF @GoodsID is not Null AND @GoodsID <> '' AND @GoodsID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @GoodsID

	IF @ContainerID is not Null AND @ContainerID <> '' AND @ContainerID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @ContainerID

	IF @ContainerStoresID is not Null AND @ContainerStoresID <> '' AND @ContainerStoresID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @ContainerStoresID
	
	

	SET @StrSelect = '
	SELECT a.StoreID,
		   [pub].[GetStoreName](a.StoreID,' + LTrim(RTrim(Str(@LangID))) + ') StoreName,
		   ContainerStoresID,
		   inv.funGetContainerStoresName(ContainerStoresID,' + LTrim(RTrim(Str(@LangID))) + ') ContainerStoresName,
		   ContainerID,
		   inv.funGetContainerName(ContainerID, ' + LTrim(RTrim(Str(@LangID))) + ') ContainerName,
		   D.GoodsID,
		   [pub].[GetGoodsName](D.GoodsID, ' + LTrim(RTrim(Str(@LangID))) + ') GoodsName,
		   SUM(NumberPerContainer * D.EnterKind) Qty
	FROM inv.tblStorageDocsSerials a
	INNER JOIN inv.tblStorageDocsDtl D ON D.ProcessID = a.ProcessID 
									  AND D.ProcessNo = a.ProcessNo
									  AND D.FiscalYear = a.FiscalYear
									  AND D.SerialNo = a.SerialNo
									  AND D.DocRowNo = a.DocAtomRowNo
	' + @StrWhereMain + '
	GROUP BY ContainerStoresID, a.StoreID, ContainerID, D.GoodsID
	HAVING SUM(NumberPerContainer * D.EnterKind) <> 0 '

	PRINT @StrSelect		
	EXEC sp_executesql @StrSelect;
	
END
GO
