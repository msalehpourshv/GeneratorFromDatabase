USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/03/21
-- Viewed By	 : 
-- Last Modified : 1391/03/21
-- Last Modifier : TakroSystem\Zia
-- Description   : <Store Stock>
-- ==============================================
Create PROCEDURE [sal].[RptSaleOrder_SalableBalance]
	@ProcessNo		Int = 0,
	@SelectedStore	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@VisitorCode1	Int = 0,
	@VisitorCode2	Int = 0,
	@VisitorCode3	Int = 0,
	@VisitorCode4	Int = 0,
	@FiscalFr		Int = NULL,
	@SerialFr		Int = NULL,
	@FiscalTo		Int = NULL,
	@SerialTo		Int = NULL,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@BalanceDate	Char(10) = Null,
	@RepOptions		VarChar(20) = '112',
	@SortFields		VarChar(100) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhere2			NVarChar(max);
DECLARE @StrWhere3			NVarChar(max);
DECLARE @StrWhereX			NVarChar(max);
DECLARE @StrWhereG			NVarChar(max);
DECLARE @StrRemainTbl		NVarChar(max);
DECLARE @StrWhereH			NVarChar(max);
DECLARE @StrYear			Char(4);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;

DECLARE @ShowPE0			Bit;
DECLARE @ShowPE1			Bit;
DECLARE @MaxStep			int;
DECLARE @round_val			int;

DECLARE @Balance	Bit;
DECLARE @NegativeBalance	Bit;
DECLARE @GetRemainSaleOrder	Bit;

DECLARE @UseSecondUnit	Bit;
DECLARE @ShowAllGoods	Bit;
DECLARE @ShowAllStores	Bit;
DECLARE @GroupByStoreID	Bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	
	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	--==============
	SET @GetRemainSaleOrder = 'False'
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	SELECT @round_val = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimals'	
		
	-- Init Variables ----------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '112';
		
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;
	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;
	IF (@FiscalFr	Is Null)	SET @SerialFr = Null;
	IF (@FiscalTo	Is Null)	SET @SerialTo = Null;
	IF (@SerialFr	Is Null)	SET @FiscalFr = Null;
	IF (@SerialTo	Is Null)	SET @FiscalTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ShowPE0			= Substring(@RepOptions, 1, 1);
	SET @ShowPE1			= Substring(@RepOptions, 2, 1);
	SET @MaxStep			= Substring(@RepOptions, 3, 1);
	SET @NegativeBalance	= Substring(@RepOptions, 4, 1);
	SET @UseSecondUnit		= Substring(@RepOptions, 5, 1);
	SET @ShowAllGoods		= Substring(@RepOptions, 6, 1);
	SET @Balance			= Substring(@RepOptions, 7, 1);
	SET @GroupByStoreID		= Substring(@RepOptions, 8, 1);
	SET @ShowAllStores		= Substring(@RepOptions, 9, 1);

 	SET @StrYear = LTrim(RIGHT(db_name(), 4));
	
	--Set @GetRemainSaleOrder = 'True'
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '(D.FiscalYear = ' + @StrYear + ')';
	SET @StrWhereX = '(D.ProcessID = 180) AND (D.ProcessNo = '+ LTrim(RTrim(Str(@ProcessNo)))+')';
	SET @StrWhereG = '1 = 1'
	SET @StrWhereH = '1 = 1'
	SET @StrWhere2 = '1 = 1'
	SET @StrWhere3 = ''
	
	SET @StrRemainTbl = '(SELECT a.* FROM sal.tblSaleOrderDtl a
						  INNER JOIN
						  (
						   SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
						   WHERE ProcessID=180 ' + 
						   Case When @GetRemainSaleOrder = 'False' Then '
						   EXCEPT
						   SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
						   WHERE BaseProcessID = 180 AND ProcessID = 90 ' Else '' End + '
						  ) A ON A.ProcessID=a.ProcessID AND A.ProcessNo=a.ProcessNo AND A.FiscalYear=a.FiscalYear AND 
							     A.SerialNo=a.SerialNo) D '
								     
	-- ============================================
	If (@ShowPE0 = 0) And (@ShowPE1 = 1)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		SET @StrWhere2 = @StrWhere2 + ' AND (D.PhysicallyEffected = 1)'
	End
	If (@ShowPE1 = 0) And (@ShowPE0 = 1)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'
		SET @StrWhere2 = @StrWhere2 + ' AND (D.PhysicallyEffected = 0)'
	End

	If (@BalanceDate Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @BalanceDate + ''')'

	If (@SelectedGoods > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	End
	If (@SelectedStore > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'DD.StoreID') 
	End
	-- sor --
	If (@SelectedGoods > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
				
	If (@DocDateFr Is Not Null)
	Begin
		SET @StrWhereX = @StrWhereX + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
		--SET @StrWhereH = @StrWhereH + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	End
	If (@DocDateTo Is Not Null)
	Begin
		SET @StrWhereX = @StrWhereX + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		--SET @StrWhereH = @StrWhereH + ' AND (H.DocDate<=''' + @DocDateTo + ''')'
	End

	If (@FiscalFr Is Not Null)
	Begin
		SET @StrWhereX = @StrWhereX + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')) '
		--SET @StrWhereH = @StrWhereH + ' AND (H.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialFr)) + ')) '
	End
	If (@FiscalTo Is Not Null)
	Begin
		SET @StrWhereX = @StrWhereX + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')) '
		--SET @StrWhereH = @StrWhereH + ' AND (H.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialTo)) + ')) '
	End
		
	IF	(@VisitorCode1 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'D.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'D.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'D.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'D.VisitorAcntCode')
		
	If (@SelectedAcnt1 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereX = @StrWhereX + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	----------------------------------------------------------------------------------
	-- Select Clause -----------------------------------------------------------------
	create table #tbl_Sor_SalableBalance_ALL
	(
		GoodsID	varchar(20) collate arabic_cs_as,
		StoreID	varchar(20) collate arabic_cs_as
	);

	create table #tbl_Sor_SalableBalance_BLC
	(
		GoodsID	varchar(20) collate arabic_cs_as,
		Balance	float,
		StoreID	varchar(20) collate arabic_cs_as,
		SubUnitID	varchar(20) collate arabic_cs_as,
		SubUnitID2	varchar(20) collate arabic_cs_as
	);
	
	create table #tbl_Sor_SalableBalance_SOR
	(
		GoodsID		varchar(20) collate arabic_cs_as,
		Step1Qty	float,
		Step2Qty	float,
		CanceledQty	float,
		SoldQty		float,
		SubUnitID	varchar(20) collate arabic_cs_as,
		SubUnitID2	varchar(20) collate arabic_cs_as,
		StoreID	varchar(20) collate arabic_cs_as,
		Balance	float
	);
	
	create table #tbl_UsedOrders
	(
		ProcessNo	Int,
		ProcessID	Int,
		FiscalYear	Int,
		SerialNo	Int,
		StoreID	varchar(20) collate arabic_cs_as
	);

	--=========
	IF @GetRemainSaleOrder = 'False'
	Begin	
		SET @StrSelect = '
		INSERT INTO #tbl_UsedOrders(ProcessID, ProcessNo, FiscalYear, SerialNo)
		SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo 
		FROM sal.tblSaleOrderHdr H
		WHERE ' + @StrWhereH + '
		EXCEPT
		SELECT *
		FROM 
		(
			Select H.BaseProcessID, H.BaseProcessNo, H.BaseFiscalYear, H.BaseSerialNo 
			From inv.tblStorageDocsHdr H
			Inner Join sal.tblSaleOrderHdr SO ON SO.ProcessID = H.BaseProcessID And SO.ProcessNo = H.BaseProcessNo And
												 SO.FiscalYear = H.BaseFiscalYear And SO.SerialNo = H.BaseSerialNo
			UNION
			Select H.BaseOrderProcessID, H.BaseOrderProcessNo, H.BaseOrderFiscalYear, H.BaseOrderSerialNo 
			From sal.tblDistributionsDtl H
			Inner Join sal.tblSaleOrderHdr SO ON SO.ProcessID = H.BaseOrderProcessID And SO.ProcessNo = H.BaseOrderProcessNo And
												 SO.FiscalYear = H.BaseOrderFiscalYear And SO.SerialNo = H.BaseOrderSerialNo									 
		) A
		--======================'

		 Print @StrSelect;
		Exec sp_executesql @StrSelect;
		
		SET @StrRemainTbl =
			'(SELECT a.* 
			  FROM sal.tblSaleOrderDtl a
			  INNER JOIN
				 (
					SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
					WHERE ProcessID=180 ' + 
				    Case When @GetRemainSaleOrder = 'False' Then '
				    EXCEPT
				    SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				    WHERE BaseProcessID = 180 AND ProcessID = 90 ' Else '' End + '
				 ) A ON A.ProcessID=a.ProcessID AND A.ProcessNo=a.ProcessNo AND A.FiscalYear=a.FiscalYear AND 
						A.SerialNo=a.SerialNo			
			  INNER JOIN #tbl_UsedOrders b On a.ProcessID=b.ProcessID AND a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear AND
											 a.SerialNo=b.SerialNo
			 ) D'
	END
	
	--Select * From #tbl_UsedOrders
	
	--=========	
	--SET @ShowAllGoods = 'False'
	IF @ShowAllGoods = 'False'
		SET @StrSelect = '
		INSERT INTO #tbl_Sor_SalableBalance_BLC (GoodsID, Balance, StoreID)
		SELECT D.GoodsID, SUM(D.GoodsQuantity * EnterKind) Balance, StoreID
		FROM inv.tblStorageDocsDtl D
		WHERE ' + @StrWhere + ' 
		GROUP BY D.GoodsID,StoreID
		-- =================================='
	ELSE
		SET @StrSelect = '
		INSERT INTO #tbl_Sor_SalableBalance_BLC(GoodsID, Balance, StoreID)
		SELECT D.GoodsID, IsNull(Sum(GoodsQuantity * EnterKind),0), IsNull(StoreID,'''')
		FROM inv.tblGoods D
		LEFT JOIN inv.tblStorageDocsDtl DD ON  DD.GoodsID = D.GoodsID 
		WHERE ' + @StrWhere2 + ' ' + @StrWhere3 + ' 
		AND (Select Count(*) 
		FROM inv.tblGoods G 
		WHERE Len(G.GoodsID) > len(D.GoodsID) AND
		SUBSTRING(D.GoodsID, 1, len(D.GoodsID)) = SUBSTRING(G.GoodsID, 1, len(D.GoodsID))) = 0
		--And LEN(D.GoodsID) = ' + LTrim(RTrim(Str(@str_GoodsSum))) + '
		GROUP BY D.GoodsID,StoreID
		-- =================================='	

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	
	IF @GetRemainSaleOrder = 'True'
		SET @StrWhereG = 'WHERE (Round(T.SoldQty,' + str(@round_val) + ') < Round(T.Step1 - T.CanceledQty,' + str(@round_val) + '))'
	Else
		SET @StrWhereG = 'WHERE Round(T.SoldQty, ' + str(@round_val) + ') <= 0 And Round(T.Step1 - T.CanceledQty, ' + str(@round_val) + ') >= 0'	
			
	SET @StrSelect = '
	INSERT INTO #tbl_Sor_SalableBalance_SOR(GoodsID, Step1Qty, Step2Qty, CanceledQty, SoldQty, SubUnitID, SubUnitID2,StoreID)
	Select 	GoodsID, IsNull(Sum(Step1),0) Step1, IsNull(Sum(Step2),0) Step2, IsNull(Sum(CanceledQty),0) CanceledQty, 
			IsNull(Sum(SoldQty),0) SoldQty, SubUnitID, SubUnitID,StoreID
	From
	(
		Select ORD.*, IsNull((
								Select sum(GoodsQuantity) 
								From inv.tblStorageDocsDtl 
								Where (ProcessID=90) 
									and (BaseProcessID=ORD.ProcessID) 
									and (BaseProcessNo=ORD.ProcessNo) 
									and (BaseFiscalYear=ORD.FiscalYear) 
									and (BaseSerialNo=ORD.SerialNo) 
									and (BaseDocRowNo=ORD.DocRowNo)
								),0) SoldQty
		From
		(
			SELECT	ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, D.GoodsID,StoreID,
					IsNull((
							Select Sum(inv.funGetGoodsQuantityFromSubUnit(GoodsID,SubUnitID,ConfirmQuantity))
							From sal.tblSaleOrderDtl R
							Where (R.ProcessID=D.ProcessID)
							  and (R.ProcessNo=D.ProcessNo)
							  and (R.FiscalYear=D.FiscalYear) 
							  and (R.SerialNo=D.SerialNo) 
							  and (R.DocRowNo=D.DocRowNo)
					),0) ' + Case When @GetRemainSaleOrder = 'True' Then '
					- (
						SELECT	IsNull(Sum(GoodsQuantity), 0)
						FROM	sal.tblSaleOrderDtl
						WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND 
								BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
					   )' Else '' End + 'AS Step1, SubUnitID,
					0 Step2,
					(
						SELECT	IsNull(Sum(GoodsQuantity), 0)
						FROM	sal.tblSaleOrderDtl
						WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND 
								BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
					 ) CanceledQty					
			FROM	' + @StrRemainTbl + '
			WHERE   (D.DocStep < ' + ltrim(str(@MaxStep)) + ') and ' + @StrWhereX + '
			
			UNION ALL
			
			SELECT	ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, D.GoodsID, StoreID,0 Step1, SubUnitID,
					IsNull((
							Select sum(ConfirmQuantity)
							From sal.tblSaleOrderDtl R
							Where (R.ProcessID=D.ProcessID)
							  and (R.ProcessNo=D.ProcessNo)
							  and (R.FiscalYear=D.FiscalYear) 
							  and (R.SerialNo=D.SerialNo) 
							  and (R.DocRowNo=D.DocRowNo)
					),0) ' + Case When @GetRemainSaleOrder = 'True' Then '
					- (
						SELECT	IsNull(Sum(GoodsQuantity), 0)
						FROM	sal.tblSaleOrderDtl
						WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND 
								BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
					   )' Else '' End + 'AS Step2, 0 CanceledQty				
			FROM	' + @StrRemainTbl + '
			WHERE   (D.DocStep = ' + ltrim(str(@MaxStep)) + ') and ' + @StrWhereX + '
		) ORD
	) T
	' + @StrWhereG + '
	GROUP BY T.GoodsID, T.SubUnitID,StoreID
	--======================'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
 
	--Set @UseSecondUnit = 1
	IF @UseSecondUnit = 1
		UPDATE #tbl_Sor_SalableBalance_SOR 
		SET SubUnitID = SU.SubUnitID
		FROM   #tbl_Sor_SalableBalance_SOR
		LEFT JOIN 
		(
		 Select GoodsID, SubUnitID, UnitValue, MainUnitValue
		 From inv.tblSubUnitsDtl
		 Where ShowInInvoice = 1 
		) SU ON SU.GoodsID = #tbl_Sor_SalableBalance_SOR.GoodsID
		WHERE SU.UnitValue IS NOT NULL
	ELSE
		UPDATE #tbl_Sor_SalableBalance_SOR 
		SET SubUnitID = GH.UnitID
		FROM   #tbl_Sor_SalableBalance_SOR
		LEFT JOIN 
		(
		 Select GoodsID, UnitID
		 From inv.tblGoods
		) GH ON GH.GoodsID = #tbl_Sor_SalableBalance_SOR.GoodsID
					
	--Select * From #tbl_Sor_SalableBalance_SOR
	------------------------------------------------------------
	Insert Into #tbl_Sor_SalableBalance_ALL(GoodsID,StoreID)
	Select Distinct T.GoodsID,StoreID
	From
	(
		Select GoodsID,StoreID
		From #tbl_Sor_SalableBalance_BLC 
		Union 
		Select GoodsID,StoreID
		From #tbl_Sor_SalableBalance_SOR
	) T
	
	-----------------------------------------------------------------

	UPDATE #tbl_Sor_SalableBalance_SOR
	SET Balance=0

	IF @ShowAllStores = 0
		UPDATE #tbl_Sor_SalableBalance_SOR
		SET Balance=b.Balance
		FROM #tbl_Sor_SalableBalance_SOR a
		INNER JOIN #tbl_Sor_SalableBalance_BLC b
		ON a.GoodsID = b.GoodsID AND a.StoreID = b.StoreID
	ELSE
		UPDATE #tbl_Sor_SalableBalance_SOR
		SET Balance=b.Balance
		FROM #tbl_Sor_SalableBalance_SOR a
		INNER JOIN (SELECT GoodsID,ISNULL(SUM(Balance),0) Balance FROM #tbl_Sor_SalableBalance_BLC GROUP BY GoodsID) b
		ON a.GoodsID = b.GoodsID 


	DELETE #tbl_Sor_SalableBalance_BLC
	FROM #tbl_Sor_SalableBalance_BLC a
	INNER JOIN #tbl_Sor_SalableBalance_SOR b
	ON a.GoodsID = b.GoodsID AND a.StoreID = b.StoreID
	
	UPDATE #tbl_Sor_SalableBalance_BLC
	SET SubUnitID= b.SubUnitID, SubUnitID2= b.SubUnitID2
	FROM #tbl_Sor_SalableBalance_BLC a
	INNER JOIN #tbl_Sor_SalableBalance_SOR b
	ON a.GoodsID = b.GoodsID  

	INSERT INTO #tbl_Sor_SalableBalance_SOR
	SELECT 
	GoodsID ,0	Step1Qty,0	Step2Qty,0	CanceledQty,0	SoldQty	,SubUnitID	,SubUnitID2	,StoreID	,Balance
	FROM #tbl_Sor_SalableBalance_BLC
 


	--Select * From #tbl_Sor_SalableBalance_ALL ORDER BY GoodsID
	--Select * From #tbl_Sor_SalableBalance_SOR ORDER BY GoodsID
	--Select * From #tbl_Sor_SalableBalance_BLC ORDER BY GoodsID
	------------------------------------------------------------
	

	SELECT 	GoodsID	, DescDtl GoodsName	,SubUnitID	, DescDtl UnitName	,cast(GoodsQuantity as float ) Balance	, DescDtl BarCode	,cast(GoodsQuantity as float )  Step1Qty	
	, cast(GoodsQuantity as float )  Step2Qty	,cast(GoodsQuantity as float )  CanceledQty	,cast(GoodsQuantity as float )  SoldQty ,StoreID
	INTO #tbl_Sor_SalableBalance
	FROM inv.tblStorageDocsDtl
	WHERE 1=0

	SET @StrSelect = ' insert   into #tbl_Sor_SalableBalance
	SELECT GoodsID, GoodsName,
		   Case When SubUnitID <> ''0'' Then SubUnitID Else SubUnitIDG End SubUnitID, 
		   Case When SubUnitID <> ''0'' Then SorUnitName  Else GoodsUnitName  End UnitName, 
		   Case When SubUnitID <> ''0'' Then Balance   Else BalanceG   End Balance, 
		   BarCode, Step1Qty, Step2Qty, CanceledQty, SoldQty, StoreID
	FROM 
	(
		SELECT	O.GoodsID, [pub].[funGetGoodsName](O.GoodsID, ' + LTrim(RTrim(@LangID)) + ') GoodsName, O.StoreID,
				GH.UnitID SubUnitIDG, IsNull(O.SubUnitID, '''') SubUnitID,
				IsNull([inv].[FunGetGoodsBarCode] (O.GoodsID), '''') BarCode,
				inv.funGetUnitNameWithGoodsID(O.GoodsID,' + LTRIM(RTrim(Str(@LangID))) + ') AS GoodsUnitName,
				IsNull(CASE WHEN SU.SubUnitID = '''' OR SU.SubUnitID Is Null OR SU.SubUnitID <> O.SubUnitID THEN U.UnitName	ELSE U2.UnitName END, 0) SorUnitName, O.Balance BalanceG,
				IsNull(CASE WHEN SU.SubUnitID = '''' OR SU.SubUnitID Is Null OR SU.SubUnitID <> O.SubUnitID THEN O.Balance ELSE O.Balance * SU.UnitValue / SU.MainUnitValue END, 0) Balance,
				IsNull(CASE WHEN SU.SubUnitID = '''' OR SU.SubUnitID Is Null OR SU.SubUnitID <> O.SubUnitID THEN SUM(O.Step1Qty)	 ELSE SUM(O.Step1Qty) * SU.UnitValue / SU.MainUnitValue END, 0) Step1Qty,
				IsNull(CASE WHEN SU.SubUnitID = '''' OR SU.SubUnitID Is Null OR SU.SubUnitID <> O.SubUnitID THEN SUM(O.Step2Qty)	 ELSE SUM(O.Step2Qty) * SU.UnitValue / SU.MainUnitValue END, 0) Step2Qty,
				IsNull(CASE WHEN SU.SubUnitID = '''' OR SU.SubUnitID Is Null OR SU.SubUnitID <> O.SubUnitID THEN SUM(O.CanceledQty) ELSE SUM(O.CanceledQty) * SU.UnitValue / SU.MainUnitValue END, 0) CanceledQty,
				IsNull(CASE WHEN SU.SubUnitID = '''' OR SU.SubUnitID Is Null OR SU.SubUnitID <> O.SubUnitID THEN SUM(O.SoldQty)	 ELSE SUM(O.SoldQty) * SU.UnitValue / SU.MainUnitValue END, 0) SoldQty
				
		FROM	#tbl_Sor_SalableBalance_SOR O 
		LEFT  JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(O.GoodsID,' + LTrim(RTrim(Str(@str_Goods))) + ' + 1, ' + LTrim(RTrim(Str(@str_GoodsSum))) + ') AND GH.PartNumber = ' + LTRIM(STR(@UnitPart)) + '
		LEFT  JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(O.GoodsID,' + LTrim(RTrim(Str(@str_Goods))) + ' + 1, ' + LTrim(RTrim(Str(@str_GoodsSum))) + ') AND GD.PartNumber = ' + LTRIM(STR(@UnitPart)) + '
		LEFT  JOIN inv.tblUnitsDtl  U  ON U.UnitID   = GH.UnitID
		LEFT  JOIN inv.tblUnitsDtl U2  ON U2.UnitID  = O.SubUnitID
		--Left  join inv.tblSubUnitsDtl SU ON SU.GoodsID = O.GoodsID AND SU.ShowInInvoice = 1 and GH.PartNumber = ' + LTRIM(STR(@UnitPart)) + '
		LEFT JOIN 
		(
		 Select GoodsID, SubUnitID, UnitValue, MainUnitValue
		 From inv.tblSubUnitsDtl
		 Where ShowInInvoice = 1 
		) SU ON SU.GoodsID = O.GoodsID

		GROUP BY O.GoodsID,O.StoreID, GD.GoodsName, U.UnitName, U2.UnitName, GH.UnitID, SU.UnitValue, SU.MainUnitValue, O.Balance, O.SubUnitID, SU.SubUnitID
		Having 1 = 1
		 --And 
			--  Case When ' + LTrim(RTrim(Str(@NegativeBalance))) + ' = 1 Then 
			--			(IsNull(SUM(O.Balance),0) - (IsNull(SUM(O.Step1Qty),0) + (IsNull(SUM(O.Step2Qty),0))))
			--   Else 0 End <= 0
			--   and (' + LTrim(RTrim(Str(@Balance))) + '=0 or IsNull(SUM(O.Balance),0)>0)
		--ORDER BY ' + Case When @ShowAllGoods = 'False' Then '' Else 'SubUnitID, ' End + ' O.GoodsID, GD.GoodsName, U.UnitName 
	) A
	ORDER BY ' + Case When @ShowAllGoods = 'False' Then '' Else 'SubUnitID, ' End + ' GoodsID, GoodsName, SorUnitName 
	'
	
		-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	------------------------------------------------------------
	if @ShowAllGoods='False'
		delete from #tbl_Sor_SalableBalance
		where Step1Qty+Step2Qty-SoldQty<=0

	 
	if @GroupByStoreID ='True'
		select * from #tbl_Sor_SalableBalance 
		Group by GoodsID	,GoodsName	,SubUnitID	,UnitName	,BarCode,Balance,Step1Qty,Step2Qty,CanceledQty,SoldQty,StoreID
		having 1=1 And 
			  Case When  @NegativeBalance= 1 Then (IsNull(SUM(Balance),0) - (IsNull(SUM(Step1Qty),0) + (IsNull(SUM(Step2Qty),0))))
			   Else 0 End <= 0
			   and ( LTrim(RTrim(Str(@Balance))) =0 or IsNull(SUM(Balance),0)>0)
		ORDER BY GoodsID, GoodsName
	else	
		select GoodsID	,GoodsName	,SubUnitID	,UnitName	,Sum(Balance)	Balance ,BarCode	,Sum(Step1Qty)	Step1Qty,Sum(Step2Qty)Step2Qty	,Sum(CanceledQty)	CanceledQty,Sum(SoldQty)	SoldQty,'' StoreID
		from #tbl_Sor_SalableBalance 
		Group by GoodsID	,GoodsName	,SubUnitID	,UnitName	,BarCode
		having 1=1 And 
			  Case When  @NegativeBalance= 1 Then (IsNull(SUM(Balance),0) - (IsNull(SUM(Step1Qty),0) + (IsNull(SUM(Step2Qty),0))))
			   Else 0 End <= 0
			   and ( LTrim(RTrim(Str(@Balance))) =0 or IsNull(SUM(Balance),0)>0)
		ORDER BY GoodsID, GoodsName	
	------------------------------------------------------------
END
GO
