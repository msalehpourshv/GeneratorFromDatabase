USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/06/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : کارت کالا 3
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Cardex3]
	@GoodsID			VarChar(20),
	@UnitID				VarChar(20) = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedStore		Int = 0,
	@RepOptions			VarChar(10) = '111011111',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);
Declare @StrRemain	NVarChar(4000);
Declare @StrYear	Char(4);

Declare @StrTransPID	VarChar(20)
Declare @StrBuySale		VarChar(20)
Declare @StrStoreBalancingPID VarChar(20)
Declare @QtyStr		nvarchar(2000)
Declare @PrcStr		nvarchar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@ShowZeroAmount		Bit; -- Include Rows with Zero Amount
DECLARE	@GroupByStore		Bit; -- Group By StoreID
DECLARE	@ShowPrim			Bit;
DECLARE @OtherFiscalYear		varchar(1)

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowZeroAmount	= Substring(@RepOptions, 1, 1)
	SET @ShowPrim		= Substring(@RepOptions, 2, 1)
	SET @GroupByStore	= Substring(@RepOptions, 3, 1)

	Set @StrTransPID			= '120, 125' -- انتقال کالا بین انبار
	Set @StrBuySale				= '55, 60, 90, 100' -- خرید و فروش
	Set @StrStoreBalancingPID	= '140, 145, 150, 155' -- تعدیل انبار
	
	SET @StrYear = LTrim(RIGHT(db_name(), 4))
	-- ------------------------------------------------------
	if (@UnitID is null) 
	begin
		set @QtyStr = 'D.GoodsQuantity'
		set @PrcStr = 'D.GoodsPrice'
	end
	else
	begin
		set @QtyStr = 'case when (D.SubUnitID = ''' + LTrim(@UnitID) + ''') then D.SubUnitQuantity else GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end '
		set @PrcStr = 'case when (D.GoodsQuantity = 0 or SubUnitQuantity = 0) then 0 else (D.GoodsPrice * D.GoodsQuantity) / (' + @QtyStr +') end'
	end

	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'

	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'
	-- Where Clause -----------------------------------------
	Select @StrWhere = ' D.EnterKind <>0 AND (D.GoodsID = ''' + @GoodsID + ''') '

	IF @OtherFiscalYear = '0'
		SET @StrWhere = @StrWhere +' AND (D.FiscalYear = ' + @StrYear + ')'

	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@ShowZeroAmount = 0)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsPrice <> 0) '

	SET @StrRemain = @StrWhere 

	If (@DocDateTo Is Not Null) OR (@DocDateFr Is Not Null)
		If (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate = ''' + @DocDateFr + ''')'
		Else
		Begin
			If (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			If (@DocDateTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
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
		LEFT  JOIN pub.tblProcess PC ON D.ProcessID = PC.ProcessID AND D.ProcessNo = PC.ProcessNo 
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo '

	if (@UnitID is not null)
		SET @StrFrom = @StrFrom + '
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.SubUnitID = ''' + Ltrim(@UnitID) + ''' '
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	begin try
		drop table ##tbl_Cardex
	end try
	begin catch
	end catch
	
	SET @StrSelect = '
	SELECT D.ProcessID, D.ProcessNo, IsNull(PC.ProcessName, '''') ProcessName, 
		D.DocDate, D.FiscalYear, D.SerialNo, D.StoreID, D.StoreID2, D.EnterKind, 
		' + @QtyStr + ' AS QuantityIn, ' + @QtyStr + ' AS QuantityOut, 
		(SELECT StoreName FROM inv.tblStoresDtl I WHERE (I.StoreID = D.StoreID) AND (I.LanguageID = ' + @LangID + ')) StoreName,
		CASE WHEN (D.BaseSerialNo Is Not Null) THEN (LTrim(Str(D.BaseFiscalYear)) + ''/'' + LTrim(Str(D.BaseSerialNo))) ELSE ''-'' END AS RefSerial,
		CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (' + @QtyStr + ' * ' + @PrcStr + ') END AS PriceIn, 
		CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (' + @QtyStr + ' * ' + @PrcStr + ') END AS PriceOut, 
		CASE WHEN D.ProcessID IN(' + @StrTransPID + ') THEN pub.GetStoreName(D.StoreID2, ' + @LangID + ') ELSE IsNull(pub.GetCodeName(D.AcntCode, ' + @LangID + '), CAST(''-'' AS NVarChar(50))) END AS AcntName,
		H.DocDesc, D.DescDtl, VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName
	into ##tbl_Cardex
	FROM ' + @StrFrom + '
	WHERE ' + @StrWhere 

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	If (@DocDateFr Is Not Null) And (@ShowPrim = 1)
	begin
		SET @StrSelect = '
		insert into ##tbl_Cardex
		SELECT 0, 0, ''مانده'', ''' + @DocDateFr + ''', 0, 0, D.StoreID, '''', 0, 
			SUM(CASE WHEN EnterKind > 0 THEN ' + @QtyStr + ' ELSE 0 END) AS QuantityIn, 
			SUM(CASE WHEN EnterKind < 0 THEN ' + @QtyStr + ' ELSE 0 END) AS QuantityOut, 
			(SELECT StoreName FROM inv.tblStoresDtl I WHERE (I.StoreID = D.StoreID) AND (I.LanguageID = ' + @LangID + ')) StoreName,
			''-'' AS RefSerial,
			SUM(
				CASE WHEN (EnterKind < 0) 
				THEN 0 
				ELSE
					CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') 
					THEN ' + @PrcStr + '
					ELSE (' + @QtyStr + ' * ' + @PrcStr + ') 
					END
				END
				) AS PriceIn,
			SUM(
				CASE WHEN (EnterKind > 0) 
				THEN 0 
				ELSE
					CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') 
					THEN ' + @PrcStr + '  
					ELSE (' + @QtyStr + ' * ' + @PrcStr + ') 
					END
				END
				) AS PriceOut,
			''-'' AS AcntName, ''-'' AS DescHdr, ''-'' AS DescDtl, 0 As VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName
		FROM  ' + @StrFrom + '
		WHERE ' + @StrRemain + ' AND (D.DocDate < ''' + @DocDateFr + ''') 
		GROUP BY D.StoreID'

		print @StrSelect;
		Exec sp_executesql @StrSelect;
	end

	SET @StrSelect = '
	SELECT T.*, G.TechnicalSpecifications, G.TechnicalNo, G.MiscSpecifications, G.GoodsLength, G.GoodsWidth, G.GoodsHeight, G.GoodsWeight
	FROM ##tbl_Cardex T inner join inv.tblGoods G on (G.GoodsID = ''' + @GoodsID + ''')	'

	SET @StrSelect = '
	select T.*, S.SetPoint, S.MaxPoint, S.FitPoint ,inv.GetGoodsPlaceNameFromStore(S.StoreID,S.DocRowNo,1) RecDesc
	from 
	(' + @StrSelect + '
	) T 
		left join (select StoreID, GoodsID, min(RowNo) MinRowNo from inv.tblGoodsStatusDtl group by StoreID, GoodsID) S0 on S0.StoreID = T.StoreID and S0.GoodsID = ''' + Ltrim(@GoodsID) + ''' 
		left join inv.tblGoodsStatusDtl S on S.StoreID = S0.StoreID and S.GoodsID = ''' + Ltrim(@GoodsID) + ''' and S.RowNo = S0.MinRowNo '

	If (@GroupByStore = 1)
	SET @StrSelect = @StrSelect + '
	ORDER BY StoreID, DocDate, VolumeRowNo '
	Else
	SET @StrSelect = @StrSelect + '
	ORDER BY DocDate, VolumeRowNo '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
