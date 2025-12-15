USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/05/14
-- Viewed By	 : 
-- Last Modifier : TakroSystem\HSR
-- Last Modified : 1394/10/28
-- Description   : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProductStatus2]
	@SelectedProds	Int = 0,
	@SelectedStore	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@FiscalYearFr	int = null,
	@FiscalYearTo	int = null,	
	@SerialNo		int = null,
	@BatchNo		varchar(20) = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhere2	NVarChar(max)
DECLARE @StrWhere3	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct VarChar(20);
DECLARE @CustomersAcntPartNumber AS Tinyint;
DECLARE @StartLayerIndex AS TINYINT;
DECLARE @LayerLen AS TINYINT;

BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	IF (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	set @RepOptions = '';
	IF (@SelectedProds	Is Null)	set @SelectedProds = 0;
	IF (@SelectedStore	Is Null)	set @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	DECLARE @SelectedStore2	Int 
	DECLARE @ShowType	Int 
	DECLARE @WageType	Int 
	
	SET @SelectedStore2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ShowType		 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @WageType		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	
		
	SET @CustomersAcntPartNumber = 0
	SET @StartLayerIndex = 0
	SET @LayerLen = 0
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @CustomersAcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
			
	---------------------------------------------------------------------------
	-- Where Section ----------------------------------------------------------
	SET @StrWhere = ' 1 = 1 ';
	SET @StrWhere2 = ' 1 = 1 ';
	SET @StrWhere3 = ' 1 = 1 ';
	IF (@SelectedProds > 0)
		set @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'A.ProductID') 

	IF (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'A.StoreID') 
	IF (@SelectedStore2 > 0)
		set @StrWhere= @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'B.StoreID') 

	IF (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'A.AcntCode')
	IF (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'A.AcntCode')
	IF (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'A.AcntCode')

	IF (@SerialNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (A.SerialNo = ' + LTrim(Str(@SerialNo)) + ')'
	IF (@BatchNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (A.BatchNo = ''' + LTrim(Str(@BatchNo)) + ''')'
	IF (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@ShowType is not null and @ShowType =2)		
		SET @StrWhere2 = @StrWhere2 + ' AND IsNull((SELECT SUM(GoodsQuantity) FROM tblProduct b WHERE a.SerialNo=b.SerialNo AND a.AcntCode=b.AcntCode AND a.ProductID=b.ProductID ),0) >= ProductCount '
	IF (@ShowType is not null and @ShowType =3)		
		SET @StrWhere2 = @StrWhere2 + ' AND IsNull((SELECT SUM(GoodsQuantity) FROM tblProduct b WHERE a.SerialNo=b.SerialNo AND a.AcntCode=b.AcntCode AND a.ProductID=b.ProductID ),0)  < ProductCount '

	-- Select Section ----------------------------------------------------------
	
	--,isull(B.StoreID,'''') as StoreIDGoods,isull(C.StoreID,'''') as StoreIDProduct
	SET @StrSelect = '
	WITH tblProduct (AcntCode ,AcntName, FiscalYear, SerialNo, ProductID, ProductCount, StoreID, BaseSerialNo, SerialNo2,
					 GoodsID, GoodsQuantity, StoreID2, ProductName, GoodsName, StoreName, StoreName2, RowNo,
					 WageRateA, WageRateB, DocDesc1, DocDesc2,BatchNo,SendToDate,ReceiveDate)
	AS
	(
		SELECT AcntCode, AcntName, FiscalYear, SerialNo, ProductID, ProductCount, StoreID, BaseSerialNo, SerialNo2, GoodsID,
			   GoodsQuantity, StoreID2, ProductName, GoodsName, StoreName, StoreName2, RowNo, WageRateA, WageRateB,
			   DocDesc1, DocDesc2,BatchNo,SendToDate,ReceiveDate
	
		FROM (SELECT  A.AcntCode,[pub].[GetCodeName](A.AcntCode,'+ STR(@LangID) +') As AcntName, A.FiscalYear,  A.SerialNo, A.ProductID, 
					  A.ProductCount, A.StoreID, IsNull(B.BaseSerialNo,0)as BaseSerialNo, IsNull(B.SerialNo,0) AS SerialNo2,
					  IsNull(B.GoodsID,'''') as GoodsID, IsNull( B.GoodsQuantity,0)as GoodsQuantity, IsNull(B.StoreID , '''') AS StoreID2,
					  IsNull([pub].[funGetGoodsName](A.ProductID, '+ STR(@LangID) +'), '''') as ProductName,
					  IsNull([pub].[funGetGoodsName](B.GoodsID, '+ STR(@LangID) +'), '''') as GoodsName,
					  IsNull([pub].[GetStoreName](A.StoreID, '+ STR(@LangID) +'), '''') as StoreName,
					  IsNull([pub].[GetStoreName](B.StoreID, '+ STR(@LangID) +'), '''') as StoreName2,
					  80 ProcessID, A.ProcessNo ProcessNo,
					  Row_Number() over(Partition by A.FiscalYear,A.SerialNo,A.ProductID order by A.FiscalYear,A.SerialNo) RowNo,
					  IsNull( A.WageRate ,0)as WageRateA, IsNull(B.WageRate ,0) AS WageRateB, 
					  A.DocDesc DocDesc1, B.DocDesc DocDesc2,A.BatchNo,A.SendToDate, B.ReceiveDate
			  FROM (SELECT DISTINCT TOP 100 PERCENT H.WageRate, H.AcntCode, H.FiscalYear ,H.ProcessNo, H.SerialNo, H.DocDesc, 
						   Case When PGD.SerialNo IS NULL THEN IsNull(H.ProductID,0) ELSE PGD.ProductID END As ProductID, 
						   Case When PGD.SerialNo IS NULL THEN IsNull(H.ProductCount,0) ELSE PGD.SubUnitQuantity END As ProductCount, 
						   StoreID,H.BatchNo,H.DocDate As SendToDate
					FROM inv.tblStorageDocsHdr H
					LEFT JOIN prd.tblProductGroupsDtl PGD ON H.BaseSerialNo = PGD.SerialNo AND H.ProcessID = 70
					WHERE ((ProcessID = 70) OR(ProcessID = 75))
					ORDER BY ProductID
				   ) AS A 
			  LEFT OUTER JOIN
				(
					SELECT D.WageRate,H.AcntCode, D.BaseFiscalYear, D.BaseSerialNo, H.FiscalYear ,H.ProcessNo, H.SerialNo, D.GoodsID, 
						   IsNull(SUM(D.GoodsQuantity ), 0) AS GoodsQuantity, H.StoreID, H.DocDesc,H.BatchNo, H.DocDate As ReceiveDate
					FROM inv.tblStorageDocsHdr AS H 
					INNER JOIN inv.tblStorageDocsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
															 H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					WHERE (H.ProcessID = 80) 
					GROUP BY D.WageRate,H.AcntCode,D.BaseFiscalYear, D.BaseSerialNo,H.ProcessNo, H.FiscalYear ,H.SerialNo, 
							 D.GoodsID, H.StoreID, H.DocDesc,H.BatchNo,H.DocDate
				 ) AS B ON A.AcntCode = B.AcntCode AND A.ProductID=B.GoodsID 
				 AND ((A.FiscalYear = B.BaseFiscalYear AND A.ProcessNo=B.ProcessNo AND A.SerialNo = B.BaseSerialNo ) 
				 or  (A.BatchNo= B.BatchNo and A.BatchNo<>''''))
			  WHERE ' + @StrWhere  + '
		) A WHERE ' + @StrWhere3 + ')
		
		SELECT AcntCode, AcntName, FiscalYear,  SerialNo, ProductID, StoreID, BaseSerialNo, SerialNo2, GoodsID, GoodsQuantity,
			   StoreID2, ProductName, GoodsName, StoreName, StoreName2, RowNo,
			   CASE WHEN RowNo = 1 then ProductCount 
			   ELSE ProductCount - IsNull((SELECT SUM(GoodsQuantity) 
										   FROM tblProduct b 
										   WHERE a.SerialNo=b.SerialNo AND  a.FiscalYear=b.FiscalYear AND a.AcntCode=b.AcntCode AND 
												 a.ProductID=b.ProductID AND b.RowNo<a.RowNo),0) END ProductCount,
			   WageRateA,WageRateB,DocDesc1, DocDesc2,BatchNo,SendToDate,ReceiveDate
		FROM tblProduct a
		WHERE  ' + @StrWhere2  

	IF (@WageType is not null and @WageType =2)		
		SET @StrSelect = @StrSelect + ' AND  WageRateA=100'
	IF (@WageType is not null and @WageType =3)		
		SET @StrSelect = @StrSelect + ' AND WageRateB=100'

	
	SET @StrSelect =@StrSelect + 'ORDER BY SerialNo,BaseSerialNo' 
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	---------------------------------------------------------------------------
END
GO
