USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1394/10/07
-- Viewed By	 : 
-- Last Modifier : 
-- Last Modified : 
-- Description   : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_InProduceProducts_Grouped]
		@SelectedProds	Int = 0,
		@SelectedAcnt1	Int = 0, 
		@SelectedAcnt2	Int = 0, 
		@SelectedAcnt3	Int = 0, 
		@SelectedAcnt4	Int = 0,
		@DocDateFr		Char(10) = Null,
		@DocDateTo		Char(10) = Null,
		@RepOptions		Varchar(10) = '',  -- bit array options
		@RepInfo		NVarchar(100) = '1@1@1',
		@ExtraParams	NVarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(Max)
DECLARE @StrWhere	NVarChar(Max)
DECLARE @StrWhere2	NVarChar(Max)
DECLARE @StrWhere3	NVarChar(Max)


DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct VarChar(20);
DECLARE @CustomersAcntPartNumber AS Tinyint;
DECLARE @StartLayerIndex AS TINYINT;
DECLARE @LayerLen AS TINYINT;

DECLARE @ShowZeroRemain	Bit;
DECLARE @ShowByBatchNo	Bit;

BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	IF (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	set @RepOptions = '';
	IF (@SelectedProds	Is Null)	set @SelectedProds = 0;

	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ShowZeroRemain = Substring(@RepOptions, 1, 1)
	SET @ShowByBatchNo  = Substring(@RepOptions, 2, 1)

	DECLARE @SelectedStore2	Int 
	DECLARE @ShowType	Int 
	
	SET @SelectedStore2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ShowType		 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	
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
	SET @StrWhere = '1 = 1';
	SET @StrWhere2 = '1 = 1';
	SET @StrWhere3 = '1 = 1';
	
	IF (@SelectedProds > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'S1.ProductID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'H.ProductID') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'GoodsID') 
	End
	
	IF (@SelectedAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'S1.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	End
	IF (@SelectedAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'S1.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	End
	IF (@SelectedAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'S1.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	End
	IF (@SelectedAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'S1.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	End
		
	IF (@DocDateFr is not null) 
	Begin
		SET @StrWhere = @StrWhere + ' AND (S1.DocDate < ''' + @DocDateFr + ''')'
		SET @StrWhere2 = @StrWhere2 + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	End
	ELSE
		SET @StrWhere = ' 1 = 2 '

	Declare @strFrom NVarchar(50) = ''
	Declare @strJoin NVarchar(50) = ''
	Declare @strSGroup NVarchar(50) = ''
	Declare @strOn NVarchar(50) = ''
	Declare @strSelectBatch NVarchar(50) = ''
	IF @ShowByBatchNo = 1
		Begin
			Set @strFrom = ',H.BatchNo'
			Set @strJoin = ',BatchNo'
			Set @strSGroup = ',S1.BatchNo'
			Set @strOn = ' And R1.BatchNo = S1.BatchNo'
			Set @strSelectBatch = ',SRTo.BatchNo BatchNoTo,SRFrom.BatchNo BatchNoFrom'
		End
	else
		Begin
			Set @strFrom = ''
			Set @strJoin = ''
			Set @strSGroup = ''
			Set @strOn = ''
			Set @strSelectBatch = ''
		End
	
	--IF (@DocDateTo is not null)
	--Begin
	--	SET @StrWhere = @StrWhere + ' AND (S1.DocDate <= ''' + @DocDateTo + ''')'
	--	SET @StrWhere2 = @StrWhere2 + ' AND (S1.DocDate <= ''' + @DocDateTo + ''')'
	--End

	-- Select Section ----------------------------------------------------------
	
	--,isull(B.StoreID,'''') as StoreIDGoods,isull(C.StoreID,'''') as StoreIDProduct
	SET @StrSelect = '
	SELECT SRFrom.AcntCode ProducerAcntCode, [pub].[GetCodeName](SRFrom.AcntCode, ' + STR(@LangID) + ') As ProducerAcntName, SRFrom.ProductID, 
		   [pub].[funGetGoodsName](SRFrom.ProductID, ' + STR(@LangID) + ') As ProductName, IsNull(SRTo.SendCount,0) SendTo, IsNull(SRTo.ReciveCount,0) ReciveTo, 
		   IsNull(SRFrom.SendCount,0) SendFrom, IsNull(SRFrom.ReciveCount,0) ReciveFrom,
		  (IsNull(SRTo.SendCount,0) + IsNull(SRFrom.SendCount,0)) - (IsNull(SRTo.ReciveCount,0) + IsNull(SRFrom.ReciveCount,0)) As Remain,
		  SRTo.DocDesc DocDescTo, SRFrom.DocDesc DocDescFrom '+@strSelectBatch+'
	FROM
	(
		--====== Send & Recive To Date
		SELECT S1.AcntCode, S1.ProductID, IsNull(SUM(S1.ProductCount),0) As SendCount, IsNull(SUM(R1.ReciveCount),0) As ReciveCount,
			   S1.DocDesc '+@strSGroup+'
		FROM 
			(
			 Select H.AcntCode,   Case When PGD.SerialNo IS NULL Then IsNull(H.ProductID,0) Else PGD.ProductID End As ProductID, 
					SUM(Case When PGD.SerialNo IS NULL Then IsNull(H.ProductCount,0) Else PGD.SubUnitQuantity End) As ProductCount,
					H.DocDesc'+@strFrom+'
			 From inv.tblStorageDocsHdr H
			 LEFT JOIN prd.tblProductGroupsDtl PGD								   
			 On H.BaseSerialNo = PGD.SerialNo AND H.ProcessID = 70
			 Where ((ProcessID = 70) OR (ProcessID = 75)) AND ' + @StrWhere2 + ' 
			 Group By H.AcntCode,Case When PGD.SerialNo IS NULL Then IsNull(H.ProductID,0) Else PGD.ProductID End,
					  H.DocDesc'+@strFrom+'
			) S1
		Left Join 
			(
			 Select AcntCode, GoodsID As ProductID, SUM(GoodsQuantity) As ReciveCount'+@strJoin+'
			 From inv.tblStorageDocsDtl
			 Where ProcessID = 80 AND ' + @StrWhere3 + '
			 Group By AcntCode,GoodsID'+@strJoin+'
			) R1
			ON S1.AcntCode = R1.AcntCode And S1.ProductID = R1.ProductID'+@strOn+'
		/*Where ' + @StrWhere + '*/
		Group By S1.AcntCode, S1.ProductID, S1.DocDesc'+@strSGroup+'
	) SRTo
	Right Join 
	(
	--========================================================
		--====== Send & Recive From Date
		SELECT S1.AcntCode, S1.ProductID, IsNull(SUM(S1.ProductCount),0) As SendCount, IsNull(SUM(R1.ReciveCount),0) As ReciveCount,
			   S1.DocDesc'+@strSGroup+'
		FROM 
			(
			 Select H.AcntCode, Case When PGD.SerialNo IS NULL Then IsNull(H.ProductID,0) Else PGD.ProductID End As ProductID, 
					SUM(Case When PGD.SerialNo IS NULL Then IsNull(H.ProductCount,0) Else PGD.SubUnitQuantity End) As ProductCount,
					H.DocDesc'+@strFrom+'
			 From inv.tblStorageDocsHdr H
			 LEFT JOIN prd.tblProductGroupsDtl PGD								   
			 On H.BaseSerialNo = PGD.SerialNo AND H.ProcessID = 70
			 Where ((ProcessID = 70) OR (ProcessID = 75)) AND ' + @StrWhere2 + ' 
			 Group By H.AcntCode,Case When PGD.SerialNo IS NULL Then IsNull(H.ProductID,0) Else PGD.ProductID End,
					  H.DocDesc'+@strFrom+'
			) S1
		Left Join 
			(
			 Select AcntCode, GoodsID As ProductID, SUM(GoodsQuantity) As ReciveCount'+@strJoin+'
			 From inv.tblStorageDocsDtl
			 Where ProcessID = 80 AND ' + @StrWhere3 + '
			 Group By AcntCode,GoodsID'+@strJoin+'
			) R1
			ON S1.AcntCode = R1.AcntCode And S1.ProductID = R1.ProductID'+@strOn+'
		/*Where ' + @StrWhere2 + '*/
		Group By S1.AcntCode, S1.ProductID, S1.DocDesc'+@strSGroup+'
	) SRFrom
	ON SRTo.AcntCode = SRFrom.AcntCode And SRTo.ProductID = SRFrom.ProductID
	Inner Join inv.tblGoodsDtl G ON G.GoodsID = SRFrom.ProductID' 
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	---------------------------------------------------------------------------
END
GO
