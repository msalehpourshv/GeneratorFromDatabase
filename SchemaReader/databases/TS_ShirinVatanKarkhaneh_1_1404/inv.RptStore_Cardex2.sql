USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/05/04
-- Viewed By	 : 
-- Last Modified : 1393/08/14
-- Last Modifier : Hamid
-- Description	 : کارت کالا 2
-- ==============================================
Create PROCEDURE [inv].[RptStore_Cardex2] 
	@GoodsID			VarChar(20),
	@StoreID			VarChar(20) = Null,
	@UnitID				VarChar(20) = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@VolumeRowNo		int = 0,
	@SelectedStore		int = 0,
	@IncludeAcntName	Bit = 1, -- Include Acnt Name Column
	@PhysicallyEffected	Bit = Null, 
	@RepOptions			VarChar(20) = '111001101',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		nvarchar(500) = ''
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(MAX);
Declare @StrFrom	NVarChar(MAX);
Declare @StrWhere	NVarChar(MAX);
Declare @StrRemain	NVarChar(MAX);
Declare @StrYear	Char(4);

Declare @TrnPID	VarChar(20)
Declare @BuySalePID	VarChar(20)
Declare @BlcPID		VarChar(20)
Declare @DateField	varchar(10)
Declare @Qty1Str	nvarchar(2000)
Declare @Qty2Str	nvarchar(2000)
Declare @Prc1Str	nvarchar(2000)
Declare @Prc2Str	nvarchar(2000)
Declare @GoodsAmount varchar(20)

Declare @IncludeQuantity	Bit; -- Include Quantity Column
Declare @IncludePrice		Bit; -- Include Price Column
Declare @IncludeDescDtl		Bit; -- Include Dtl Desc Column
Declare @IncludeDescHdr		Bit; -- Include Hdr Desc Column
Declare @IncludeZeroAmount	Bit; -- Include Rows with Zero Amount
Declare @GroupByStore		Bit; -- Group By StoreID
Declare @ShowPrim			Bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@ProductSerialID	Int;
DECLARE	@BatchNo			Varchar(20);
DECLARE	@ExpireDate			Varchar(10);
DECLARE @OtherFiscalYear		varchar(1)

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	If @IncludeQuantity   Is Null Set @IncludeQuantity = 1;
	If @IncludePrice      Is Null Set @IncludePrice    = 1;
	If @IncludeAcntName   Is Null Set @IncludeAcntName = 0;
	If @IncludeDescDtl    Is Null Set @IncludeDescDtl  = 0;
	If @IncludeDescHdr    Is Null Set @IncludeDescHdr  = 0;
	If @IncludeZeroAmount Is Null Set @IncludeZeroAmount = 0;
	If @ShowPrim Is Null		  Set @ShowPrim = 1;
	if @UnitID is null set @UnitID = '01'

	SET @IncludeQuantity	= Substring(@RepOptions, 1, 1);
	SET @IncludePrice		= Substring(@RepOptions, 2, 1);
	SET @IncludeDescDtl		= Substring(@RepOptions, 3, 1);
	SET @IncludeDescHdr		= Substring(@RepOptions, 4, 1);
	SET @IncludeZeroAmount	= Substring(@RepOptions, 5, 1);
	SET @GroupByStore		= Substring(@RepOptions, 6, 1);
	SET @ShowPrim			= Substring(@RepOptions, 7, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	Set @TrnPID	= '120,125' -- انتقال کالا بین انبار
--	Set @StrBuySale				= '55, 60, 90, 100' -- خرید و فروش
	Set @BlcPID	= '140, 145, 150, 155' -- تعدیل انبار
	
	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	SET @StrYear = LTrim(RIGHT(db_name(), 4))
	
	SET @ProductSerialID = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @BatchNo		 = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @ExpireDate		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	-- ------------------------------------------------------
	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'

	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'
	-- ------------------------------------------------------
	set @Qty1Str = 'D.GoodsQuantity'
	set @Prc1Str = 'D.' + @GoodsAmount
	set @Qty2Str = 'case when (SU.MainUnitValue is null or UnitValue is null) then D.GoodsQuantity else case when (D.SubUnitID = ''' + LTrim(@UnitID) + ''') then D.SubUnitQuantity else GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end end'
	set @Prc2Str = 'case when (D.GoodsQuantity = 0 or SubUnitQuantity = 0) then 0 else (D.' + @GoodsAmount + ' * D.GoodsQuantity) / (' + @Qty2Str +') end'

	-- Where Clause -----------------------------------------
	Select @StrWhere = ' D.EnterKind <>0 AND (D.GoodsID = ''' + @GoodsID + ''') '

	IF @OtherFiscalYear = '0'
		SET @StrWhere = @StrWhere +' AND (D.FiscalYear = ' + @StrYear + ')'
	If (@PhysicallyEffected Is Not Null)
		If (@PhysicallyEffected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@IncludeZeroAmount = 0)
		SET @StrWhere = @StrWhere + ' AND (D.' + @GoodsAmount + ' <> 0) '

	SET @StrRemain = @StrWhere 

	if (@IncludePrice = 1)
		SET @DateField = 'DocDate'
		--set @DateField = 'VchDate2'
	else
		SET @DateField = 'DocDate'
	
	If (@DocDateTo Is Not Null) OR (@DocDateFr Is Not Null)
		If (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.' + @DateField + ' = ''' + @DocDateFr + ''')'
		Else
		Begin
			If (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.' + @DateField + ' >= ''' + @DocDateFr + ''')'
			If (@DocDateTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.' + @DateField + ' <= ''' + @DocDateTo + ''')'
		End
	------------------------------------------------------------
	declare @unit nvarchar (50)

	set @unit = '';

	select @unit = isnull(UnitName , '')
	from inv.tblUnitsDtl 
	where UnitID = (select UnitID from inv.tblGoods where GoodsID = @GoodsID)

	-- From Clause ---------------------------------------------
	SET @StrFrom = 'inv.tblStorageDocsDtl D
		inner join inv.tblGoods G on (G.GoodsID = ''' + @GoodsID + ''') 
		LEFT JOIN pub.tblProcess PC ON D.ProcessID = PC.ProcessID AND D.ProcessNo = PC.ProcessNo 
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.SubUnitID = ''' + Ltrim(@UnitID) + ''' 
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo' 
		
	--Print 'ProductSerialID ' + LTrim(RTrim(Str(@ProductSerialID)))
	--Print 'BatchNo ' + LTrim(RTrim(@BatchNo))
	--Print 'ExpireDate ' + LTrim(RTrim(@ExpireDate))
				
	--IF @ProductSerialID <> '' OR @BatchNo <> '' OR @ExpireDate <> ''
	IF @BatchNo <> '' OR @ExpireDate <> ''
	Begin
		SET @StrFrom = @StrFrom + '
		INNER JOIN inv.tblStorageDocsSerials SS ON SS.ProcessID = D.ProcessID AND SS.ProcessNo = D.ProcessNo AND SS.FiscalYear = D.FiscalYear AND SS.SerialNo = D.SerialNo ' + 
                    'And SS.ProductSerialID = ' + LTrim(RTrim(Str(@ProductSerialID))) +
					Case When @BatchNo <> '' Then ' And SS.BatchNo = ''' + LTrim(RTrim(@BatchNo)) + '''' Else '' End +
					Case When @ExpireDate <> '' Then ' And SS.ExpireDate = ''' + LTrim(RTrim(@ExpireDate)) + '''' Else '' End
	End				  
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	begin try
		drop table ##tbl_Cardex2
	end try
	begin catch
	end catch

	SET @StrSelect = '
	SELECT D.ProcessID, D.ProcessNo, IsNull(PC.ProcessName, '''') ProcessName, D.' + @DateField + ' as DocDate, 
		D.FiscalYear, D.SerialNo, D.StoreID, D.EnterKind, H.VchNo, 
		(SELECT StoreName FROM inv.tblStoresDtl I WHERE I.StoreID = D.StoreID) StoreName,
		Case When D.BaseProcessID = 93 Then D.BaseProcessID Else 0 End As PhrProcessID,
		Case When D.BaseProcessID = 93 Then D.BaseProcessNo Else 0 End As PhrProcessNo,
		Case When D.BaseProcessID = 93 Then D.BaseFiscalYear Else 0 End As PhrFiscalYear,
		Case When D.BaseProcessID = 93 Then D.BaseSerialNo Else 0 End As PhrSerialNo,		
		CASE WHEN D.EnterKind > 0 THEN ' + @Qty1Str + ' else 0 end AS Quantity1In, CASE WHEN D.EnterKind < 0 THEN ' + @Qty1Str + ' else 0 end AS Quantity1Out, 
		CASE WHEN D.EnterKind > 0 THEN ' + @Qty2Str + ' else 0 end AS Quantity2In, CASE WHEN D.EnterKind < 0 THEN ' + @Qty2Str + ' else 0 end AS Quantity2Out, 
		CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc1Str + ' ELSE (' + @Qty1Str + ' * ' + @Prc1Str + ') END AS Amount1In, 
		CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc2Str + ' ELSE (' + @Qty2Str + ' * ' + @Prc2Str + ') END AS Amount2In, 
		CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc1Str + ' ELSE (' + @Qty1Str + ' * ' + @Prc1Str + ') END AS Amount1Out, 
		CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc2Str + ' ELSE (' + @Qty2Str + ' * ' + @Prc2Str + ') END AS Amount2Out, 
		CASE WHEN D.ProcessID IN(' + @TrnPID + ') THEN pub.GetStoreName(D.StoreID2, 1) ELSE IsNull(pub.GetCodeName(D.AcntCode, 1), CAST(''-'' AS NVarChar(50))) END AS AcntName,
		H.DocDesc, D.DescDtl, VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName,
		D.Var1, D.Var2, D.Var3, D.Var4, H.DriverID, DR.FirstName, DR.LastName,
		D.SubUnitQuantity / (Case When D.VirtualQuantity=0 Then 1 Else D.VirtualQuantity End) Averge
	INTO ##tbl_Cardex2
	FROM ' + @StrFrom + '
	LEFT JOIN pub.tblDriversDtl DR on H.DriverID = DR.DriverID and DR.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere 

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	If (@DocDateFr Is Not Null) And (@ShowPrim = 1)
	begin
		SET @StrSelect = '
		INSERT INTO ##tbl_Cardex2
		SELECT 0, 0, ''مانده'', ''' + @DocDateFr + ''', 0, 0, D.StoreID, 0, 0,
			(SELECT StoreName FROM inv.tblStoresDtl I WHERE I.StoreID = D.StoreID) StoreName,0, 0, 0, 0,
			SUM(CASE WHEN D.EnterKind > 0 THEN ' + @Qty1Str + ' ELSE 0 END) AS Quantity1In, 
			SUM(CASE WHEN D.EnterKind > 0 THEN ' + @Qty2Str + ' ELSE 0 END) AS Quantity2In, 
			SUM(CASE WHEN D.EnterKind < 0 THEN ' + @Qty1Str + ' ELSE 0 END) AS Quantity1Out, 
			SUM(CASE WHEN D.EnterKind < 0 THEN ' + @Qty2Str + ' ELSE 0 END) AS Quantity2Out, 
			SUM(CASE WHEN D.EnterKind < 0 THEN 0 ELSE CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc1Str + ' ELSE (' + @Qty1Str + ' * ' + @Prc1Str + ') END	END) AS Amount1In,
			SUM(CASE WHEN D.EnterKind < 0 THEN 0 ELSE CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc2Str + ' ELSE (' + @Qty2Str + ' * ' + @Prc2Str + ') END	END) AS Amount2In,
			SUM(CASE WHEN D.EnterKind > 0 THEN 0 ELSE CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc1Str + ' ELSE (' + @Qty1Str + ' * ' + @Prc1Str + ') END	END) AS Amount1Out,
			SUM(CASE WHEN D.EnterKind > 0 THEN 0 ELSE CASE WHEN D.ProcessID IN(' + @BlcPID + ') THEN ' + @Prc2Str + ' ELSE (' + @Qty2Str + ' * ' + @Prc2Str + ') END	END) AS Amount2Out,
			''-'' AS AcntName, ''-'' AS DocDesc, ''-'' AS DescDtl, 0 As VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName, 
			D.Var1, D.Var2, D.Var3, D.Var4, H.DriverID, DR.FirstName, DR.LastName,
			D.SubUnitQuantity / (Case When D.VirtualQuantity = 0 Then 1 Else D.VirtualQuantity End) Averge
		FROM  ' + @StrFrom + '
		LEFT JOIN pub.tblDriversDtl DR on H.DriverID = DR.DriverID and DR.LanguageID = ' + @LangID + '
		WHERE ' + @StrRemain + ' AND (D.' + @DateField + ' < ''' + @DocDateFr + ''') 
		GROUP BY D.StoreID, D.Var1, D.Var2, D.Var3, D.Var4, H.DriverID, DR.FirstName, DR.LastName,
				 D.SubUnitQuantity, D.VirtualQuantity '

		Print @StrSelect;
		Exec sp_executesql @StrSelect;
	end

	SET @StrSelect = '
	SELECT T.*, G.TechnicalSpecifications, G.TechnicalNo, G.MiscSpecifications, G.GoodsLength, G.GoodsWidth, G.GoodsHeight, G.GoodsWeight
	FROM ##tbl_Cardex2 T inner join inv.tblGoods G on (G.GoodsID = ''' + @GoodsID + ''')	'

	SET @StrSelect = '
	select T.*, S.SetPoint, S.MaxPoint, S.FitPoint,inv.GetGoodsPlaceNameFromStore(S.StoreID,S.DocRowNo,1) RecDesc
	from 
	(' + @StrSelect + '
	) T 
		left join (select StoreID, GoodsID, min(RowNo) MinRowNo from inv.tblGoodsStatusDtl group by StoreID, GoodsID) S0 on S0.StoreID = T.StoreID and S0.GoodsID = ''' + Ltrim(@GoodsID) + ''' 
		left join inv.tblGoodsStatusDtl S on S.StoreID = S0.StoreID and S.GoodsID = ''' + Ltrim(@GoodsID) + ''' and S.RowNo = S0.MinRowNo '

	If (@GroupByStore = 1)
	SET @StrSelect = @StrSelect + '
	ORDER BY StoreID, ' + @DateField + ', VolumeRowNo '
	Else
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @DateField + ', VolumeRowNo '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
