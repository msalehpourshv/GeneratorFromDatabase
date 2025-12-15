USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hamid
-- Create date   : 393/08/15
-- Viewed By	 : 
-- Last Modified : 1393/08/15
-- Last Modifier : TakroSystem/Hamid
-- Description   : برگ سفارش خرید کالا
-- =============================================
Create PROCEDURE [inv].[RptStore_StorageDocsSerials]
	@GoodsID			Varchar(20)		= Null,
	@Store				Varchar(20)		= Null,
	@FromExpDate		Varchar(20)		= Null,
	@ToExpDate			Varchar(20)		= Null,
	@FromPrdSerialID	Varchar(20)		= Null,
	@ToPrdSerialID		Varchar(20)		= Null,
	@FromBatchNo		Varchar(20)		= Null,
	@ToBatchNo			Varchar(20)		= Null,
	@ExtraParams		NVarChar(200)	= Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @LanguageID TinyInt;
 
DECLARE @DocDateFr  Char(10);
DECLARE @DocDateTo  Char(10);

BEGIN --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set @StrSelect = ''
	Set @StrWhere = ' 1 = 1 '
	Set @StrWhere2 = ' 1 = 1 '
	 
	Set NoCount On;

	SET @DocDateFr	= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @DocDateTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 2));

	-- I N I T ----------------------------------------------------------------
	If (@LanguageID Is Null)	SET @LanguageID = 1

	-- W H E R E --------------------------------------------------------------
	IF (@FromExpDate Is Not Null And @FromExpDate <> '')
		Set @StrWhere = @StrWhere + ' And a.ExpireDate >= ''' + LTrim(RTrim(@FromExpDate)) + ''''
		
	IF (@ToExpDate Is Not Null And @ToExpDate <> '')
		Set @StrWhere = @StrWhere + ' And a.ExpireDate <= ''' + LTrim(RTrim(@ToExpDate)) + ''''		
	
	IF (@FromPrdSerialID Is Not Null And @FromPrdSerialID <> '' And LTrim(RTrim(@FromPrdSerialID)) <> '0')
		Set @StrWhere = @StrWhere + ' And a.PSerialNo >= ' + LTrim(RTrim(@FromPrdSerialID)) + ''	

	IF (@ToPrdSerialID Is Not Null And @ToPrdSerialID <> '' And LTrim(RTrim(@ToPrdSerialID)) <> '0')
		Set @StrWhere = @StrWhere + ' And a.PSerialNo <= ' + LTrim(RTrim(@ToPrdSerialID)) + ''	

	IF (@FromBatchNo Is Not Null And @FromBatchNo <> '')
		Set @StrWhere = @StrWhere + ' And a.BatchNo >= ''' + LTrim(RTrim(@FromBatchNo)) + ''''
	IF (@ToBatchNo Is Not Null And @ToBatchNo <> '')
		Set @StrWhere = @StrWhere + ' And a.BatchNo <= ''' + LTrim(RTrim(@ToBatchNo)) + ''''
-------------------------------------------------------------------------------------------------------------------
	IF (@DocDateFr Is Not Null And @DocDateFr <> '')
		Set @StrWhere2 = @StrWhere2 + ' And d.DocDate >= ''' + LTrim(RTrim(@DocDateFr)) + ''''
		
	IF (@DocDateTo Is Not Null And @DocDateTo <> '')
		Set @StrWhere2 = @StrWhere2 + ' And d.DocDate <= ''' + LTrim(RTrim(@DocDateTo)) + ''''	

	IF (@GoodsID Is Not Null And @GoodsID <> '')
		Set @StrWhere2 = @StrWhere2 + ' And d.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''	
	IF (@Store Is Not Null And @Store <> '' And @Store <> '-')
		Set @StrWhere2 = @StrWhere2 + ' And d.StoreID = ''' + LTrim(RTrim(@Store)) + ''''	

		--select @StrWhere2,@StrWhere

		-- S E L E C T ------------------------------------------------------------
 
		Set @StrSelect = '
		
		SELECT a.ProductSerialID,
			   a.BatchNo,
			   ISNULL(Cast(a.PSerialNo As NVarchar(50)),'''') ProductSerialNo,
			   ISNULL(P.SerialPrefix,''0'') SerialPrefix,
			   a.ContainerID,
			   a.ContainerStoresID,
			   a.ProductionDate,
			   a.[ExpireDate],
			   SUM(NPC* case When d.EnterKind=0 then a.EnterKind else d.EnterKind end ) Quantity,
			   IsNull([inv].[funGetBatchName](a.BatchNo,1),'''') as  BatchName,
			   IsNull(inv.funGetContainerName(ContainerID,1),'''') as  ContainerName,
			   IsNull(inv.funGetContainerStoresName(ContainerStoresID,1),'''')  ContainerStoresName,
			   IsNull([pub].[funChangeDate_PersianToGergorian](a.[ProductionDate]),'''') As GProductionDate,
			   IsNull([pub].[funChangeDate_PersianToGergorian](a.[ExpireDate]),'''') As GExpireDate,
			   ( SELECT Top 1 d.GoodsPrice
				 FROM inv.tblStorageDocsSerials aa 
				 Right join inv.tblStorageDocsDtl d ON aa.ProcessID = d.ProcessID 
												   AND aa.ProcessNo = d.ProcessNo 
												   AND aa.FiscalYear = d.FiscalYear 
												   AND aa.SerialNo = d.SerialNo 
												   AND aa.DocRowNo = d.DocRowNo 
				 WHERE aa.ProductSerialID = a.ProductSerialID 
				   AND aa.BatchNo = a.BatchNo 
				   AND aa.PSerialNo = a.PSerialNo 
				   AND aa.ContainerID = a.ContainerID 
				   AND aa.ContainerStoresID = a.ContainerStoresID 
				   AND aa.ProductionDate = a.ProductionDate 
				   AND aa.ExpireDate = a.ExpireDate 
				 ORDER BY DocDate desc, VolumeRowNo desc) AS GoodsPrice
		FROM 
		(SELECT *,
				Case when NumberPerContainer = 0 then 1 else NumberPerContainer end NPC  
		 FROM inv.tblStorageDocsSerials a 
		 WHERE ' + @StrWhere + '	)a
		 INNER JOIN (SELECT * 
					 FROM inv.tblStorageDocsDtl d
					 WHERE ' + @StrWhere2 + '	) d ON a.ProcessID = d.ProcessID 
												   AND a.ProcessNo = d.ProcessNo 
												   AND a.FiscalYear = d.FiscalYear 
												   AND a.SerialNo = d.SerialNo 
												   AND a.DocRowNo = d.DocRowNo
		 LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = a.ProductSerialID		
	 	 GROUP BY a.ProductSerialID, a.BatchNo, a.PSerialNo, ISNULL(P.SerialPrefix,''0''), a.ContainerID, a.ContainerStoresID, a.ProductionDate, a.[ExpireDate]
		 HAVING SUM(NPC* case When d.EnterKind=0 then a.EnterKind else d.EnterKind end ) <> 0 '
		
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
