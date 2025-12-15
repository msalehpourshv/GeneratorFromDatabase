USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hamid
-- Create date   : 393/08/15
-- Viewed By	 : 
-- Last Modified : 1394/11/21
-- Last Modifier : TakroSystem/ZiA
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[RptStore_StorageDocsSerials_Cardex]
	@ProcessID			Int = 90,  -- Default Is Sale
	@ProcessNo			Int = 1,
	@FiscalYear			Int = 93,
	@SerialNo			Int = 1,
	@DocRowNo			Int = 1,
	@FromPrdSerialID	Varchar(20) = Null,
	@ToPrdSerialID		Varchar(20) = Null,
	@FromBatchNo		Varchar(20) = Null,
	@ToBatchNo			Varchar(20) = Null,
	@FromExpDate		Varchar(20) = Null,
	@ToExpDate			Varchar(20) = Null	
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @HasSerial  Bit;

DECLARE @Count		Int;

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set @StrSelect = ''
	Set @StrWhere = ' 1=1 '
	Set @StrWhere2 = ' 1=1 '

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@LanguageID Is Null)	SET @LanguageID = 1
	
	if @ToPrdSerialID = '0'
	 set @ToPrdSerialID = ''

	if @FromPrdSerialID = '0'
	 set @FromPrdSerialID = ''
	-- W H E R E --------------------------------------------------------------
	IF (@FromPrdSerialID Is Not Null And @FromPrdSerialID <> '' )
		Set @StrWhere2 = @StrWhere2 + ' AND P.SerialNo >= ''' + LTrim(RTrim(@FromPrdSerialID)) + ''''
	IF (@ToPrdSerialID Is Not Null And @ToPrdSerialID <> '' )
		Set @StrWhere2 = @StrWhere2 + ' AND P.SerialNo <= ''' + LTrim(RTrim(@ToPrdSerialID)) + ''''	
		
	IF (@FromBatchNo Is Not Null And @FromBatchNo <> '')
		Set @StrWhere = @StrWhere + ' AND SS.BatchNo >= ''' + LTrim(RTrim(@FromBatchNo)) + ''''
	IF (@ToBatchNo Is Not Null And @ToBatchNo <> '')
		Set @StrWhere = @StrWhere + ' AND SS.BatchNo <= ''' + LTrim(RTrim(@ToBatchNo)) + ''''			

	IF (@FromExpDate Is Not Null And @FromExpDate <> '')
		Set @StrWhere = @StrWhere + ' AND SS.ExpireDate >= ''' + LTrim(RTrim(@FromExpDate)) + ''''
	IF (@ToExpDate Is Not Null And @ToExpDate <> '')
		Set @StrWhere = @StrWhere + ' AND SS.ExpireDate <= ''' + LTrim(RTrim(@ToExpDate)) + ''''	
		
	-- =============================================================
	Select @Count = COUNT(*)
	From inv.tblStorageDocsSerials SS
	LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
	Where SS.ProcessID = @ProcessID And SS.ProcessNo = @ProcessNo And 
		  SS.FiscalYear = @FiscalYear And SS.SerialNo = @SerialNo And 
		  SS.DocRowNo = @DocRowNo
	
	IF 	@Count > 0	  	
		Set @StrSelect = '
		SELECT SS.ProcessID, 
			   SS.ProcessNo, 
			   SS.FiscalYear, 
			   SS.SerialNo, 
			   ISNULL(P.ProductID,'''') As GoodsID,
			   SS.ProductSerialID ,
			   SS.BatchNo ,
			   ISNULL(Cast(SS.PSerialNo As NVarchar(50)),'''') ProductSerialNo,
			   ISNULL(P.SerialPrefix,''0'') SerialPrefix,
			   SS.ContainerID,
			   SS.ContainerStoresID,
			   SS.ProductionDate,
			   SS.[ExpireDate],
			   SUM(NPC* CASE WHEN D.ProcessID = 188 THEN 1 
							 WHEN D.ProcessID = 189 THEN -1  
							 ELSE D.EnterKind END) Quantity,
			   IsNull([inv].[funGetBatchName](SS.BatchNo,1),'''') as  BatchName,
			   IsNull(inv.funGetContainerName(SS.ContainerID,1),'''') as  ContainerName,
			   IsNull(inv.funGetContainerStoresName(SS.ContainerStoresID,1),'''')  ContainerStoresName,
			   IsNull([pub].[funChangeDate_PersianToGergorian](SS.[ProductionDate]),'''') As GProductionDate,
			   IsNull([pub].[funChangeDate_PersianToGergorian](SS.[ExpireDate]),'''') As GExpireDate				
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsSerials SS  ON SS.ProcessID = D.ProcessID 
												AND SS.ProcessNo = D.ProcessNo 
												AND SS.FiscalYear = D.FiscalYear 
												AND SS.SerialNo = D.SerialNo 
												AND SS.DocRowNo = D.DocRowNo
		INNER JOIN (SELECT *,
						   Case when NumberPerContainer = 0 then 1 else NumberPerContainer end NPC  
					FROM inv.tblStorageDocsSerials a 
					WHERE ' + @StrWhere + ') T ON T.ProcessID = D.ProcessID 
											  AND T.ProcessNo = D.ProcessNo 
											  AND T.FiscalYear = D.FiscalYear 
											  AND T.SerialNo = D.SerialNo 
											  AND T.DocRowNo = D.DocRowNo
											  AND T.AtomRowNo = SS.AtomRowNo
											  AND T.ContainerID = SS.ContainerID
											  AND T.ContainerStoresID = SS.ContainerStoresID
		LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
		WHERE SS.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' 
		  AND SS.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' 
		  AND SS.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) + ' 
		  AND SS.SerialNo = ' + LTrim(RTrim(Str(@SerialNo))) + ' 
		  AND SS.DocRowNo = ' + LTrim(RTrim(Str(@DocRowNo))) +' 
		  AND  '+  @StrWhere	+'
		  AND  '+  @StrWhere2	+'
		GROUP BY SS.ProcessID, SS.ProcessNo, SS.FiscalYear, SS.SerialNo, ISNULL(P.ProductID,''''),
				 SS.ProductSerialID ,SS.BatchNo ,SS.PSerialNo ,ISNULL(P.SerialPrefix,''0''),
				 SS.ContainerID ,SS.ContainerStoresID ,SS.ProductionDate ,SS.[ExpireDate] ,NPC, D.EnterKind
		HAVING SUM(NPC* CASE WHEN D.ProcessID = 188 THEN 1 
							 WHEN D.ProcessID = 189 THEN -1  
							 ELSE D.EnterKind END) <> 0'
	ELSE	
		Set @StrSelect = '
			SELECT D.ProcessID, 
				   D.ProcessNo, 
				   D.FiscalYear, 
				   D.SerialNo, 
				   ISNULL(D.GoodsID,'''') As GoodsID,
				   0 ProductSerialID, 
				   D.BatchNo, 
				   Cast('''' As NVarchar(50)) ProductSerialNo,
				   ''0'' SerialPrefix,
				   Cast('''' As NVarchar(20)) ContainerID,
				   CAST('''' as nvarchar(20)) As ContainerStoresID,
				   CAST('''' As char(10)) ProductionDate, 
				   CAST('''' As char(10)) ExpireDate,
				   CAST(0 As Decimal(28,4)) Quantity,
				   B.BatchName,cast('''' as nvarchar(50)) As ContainerName,
				   CAST('''' as nvarchar(50)) As ContainerStoresName, 
				   CAST('''' As char(10)) GProductionDate,
				   CAST('''' As char(10)) GExpireDate
			FROM inv.tblStorageDocsDtl D
			LEFT JOIN inv.tblBatchDtl B ON B.BatchNo = D.BatchNo AND B.LanguageID = 1  
			Where D.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' 
			  AND D.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' 
			  AND D.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) + ' 
			  AND D.SerialNo = ' + LTrim(RTrim(Str(@SerialNo))) + ' 
			  AND D.DocRowNo = ' + LTrim(RTrim(Str(@DocRowNo)))-- + @StrWhere
			  
	-- =============================================================
	Print @StrSelect;
	Exec sp_executesql @StrSelect;		
	
END
GO
