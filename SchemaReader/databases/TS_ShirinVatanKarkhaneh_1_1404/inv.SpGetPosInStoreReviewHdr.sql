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
Create PROCEDURE inv.SpGetPosInStoreReviewHdr
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
	DECLARE @StrWhereGoods NVarChar(MAX) = ' WHERE (1=1) '

	IF @StoreID is not Null AND @StoreID <> '' AND @StoreID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @StoreID

	IF @GoodsID is not Null AND @GoodsID <> '' AND @GoodsID <> ' AND (1=1)'
		SET @StrWhereGoods = @StrWhereGoods + @GoodsID

	IF @ContainerID is not Null AND @ContainerID <> '' AND @ContainerID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @ContainerID

	IF @ContainerStoresID is not Null AND @ContainerStoresID <> '' AND @ContainerStoresID <> ' AND (1=1)'
		SET @StrWhereMain = @StrWhereMain + @ContainerStoresID
		
	SET @StrSelect = '
	SELECT aa.StoreID,
		   [pub].[GetStoreName](aa.StoreID, ' + LTrim(RTrim(Str(@LangID))) + ') StoreName,
		   aa.ContainerStoresID,
		   inv.funGetContainerStoresName(aa.ContainerStoresID, ' + LTrim(RTrim(Str(@LangID))) + ') ContainerStoresName,
		   ISNULL(b.CountInPos,0) CountInPos,
		   ISNULL(SUM(Cnt),0) CntUse
	FROM( SELECT COUNT(*) Cnt,
				 ContainerStoresID, 
				 StoreID, 
				 ContainerID, 
				 ProcessID, 
				 ProcessNo, 
				 FiscalYear, 
				 SerialNo,
				 DocAtomRowNo
		  FROM ( SELECT	ContainerStoresID,
						StoreID,
						ContainerID, 
						ProcessID, 
						ProcessNo, 
						FiscalYear, 
						SerialNo,
						DocAtomRowNo
				 FROM inv.tblStorageDocsSerials a 
				 ' + @StrWhereMain + '			
				 GROUP BY ContainerStoresID, StoreID, ContainerID, ProcessID, ProcessNo, FiscalYear, SerialNo, DocAtomRowNo
				 HAVING SUM(NumberPerContainer * EnterKind) <> 0 ) a
		  GROUP BY ContainerStoresID, StoreID, ContainerID, ProcessID, ProcessNo, FiscalYear, SerialNo, DocAtomRowNo ) aa
	INNER JOIN inv.tblStorageDocsDtl D ON D.ProcessID = aa.ProcessID 
									  AND D.ProcessNo = aa.ProcessNo
									  AND D.FiscalYear = aa.FiscalYear
									  AND D.SerialNo = aa.SerialNo
									  AND D.DocRowNo = aa.DocAtomRowNo
	LEFT JOIN inv.tblContainerPosInStores b ON aa.ContainerStoresID = b.ContainerStoresID 
										   AND aa.StoreID = b.StoreID
	' + @StrWhereGoods + '
	GROUP BY aa.ContainerStoresID, aa.StoreID ,b.CountInPos
	HAVING ISNULL(SUM(ISNULL(b.CountInPos,0) - Cnt),0) <> 0
	ORDER BY aa.StoreID, aa.ContainerStoresID'

	PRINT @StrSelect		
	EXEC sp_executesql @StrSelect;
	
END
GO
