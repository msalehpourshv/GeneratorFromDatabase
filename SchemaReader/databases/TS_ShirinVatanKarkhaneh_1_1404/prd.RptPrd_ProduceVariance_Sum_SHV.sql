USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceVariance_Sum_SHV]
	@FiscalYearFr	int           = 0,
	@FiscalYearTo	int           = 0,
	@SerialNoFr		int           = 0,
	@SerialNoTo		int           = 0,
	@DocDateFr		char(10)      = null,
	@DocDateTo		char(10)      = null,
	@RepOptions		NVarChar(200) = '111',
	@RepInfo		NVarChar(100) = '1@1@1', -- bit array options
	@ProductID      Varchar(20) = Null,
	@ProductID_Fr   Varchar(20) = Null,
	@ProductID_To   Varchar(20) = Null,
	@Prd_Group		VarChar(20)   = '0404',
	@GoodsID        Varchar(20) = Null,
	@GoodsID_Fr		Varchar(20) = Null,
	@GoodsID_To		Varchar(20) = Null,
	@GoodsGroup		VarChar(20)   = '0404',
	@Rpt_By_Amnt    int           = 0,
	@Detailed_Rpt   int           = 0,
	@Grp_By_Serial  bit           = 0,
	@Grp_By_Date    bit           = 0,
	@Grp_By_Prd     bit           = 0,
	@Order_By_Date  bit           = 0

-- ============== @Detailed_Rpt   = 0 => Sum_Result
-- ============== @Detailed_Rpt   = 1 => Detailed_Result

WITH ENCRYPTION
AS
DECLARE @StrSelect	 NVarChar(MAX) = ''
DECLARE @StrFrom	 NVarChar(MAX) = ''
DECLARE @StrWhere	 NVarChar(MAX) = ''
DECLARE @ExtraParams NVarChar(2000)
--DECLARE	@GoodsID	 Varchar(20)

DECLARE	@Round		Int;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------
	set @ExtraParams=@RepOptions
	
	SET @RepOptions			= pub.funSplitString(@ExtraParams, '@', 1);
	--SET @GoodsID			= pub.funSplitString(@ExtraParams, '@', 2);
		
	IF @GoodsID = ''
		SET @GoodsID = Null

	-- SELECT SECTION -------------------------------
	--drop table #tbl_Prd_ProduceVariance_Total
	create table #tbl_Prd_ProduceVariance_Total
	(
		ProcessID		int	not null,
		ProcessNo		int	not null,
		FiscalYear		int	not null,
		SerialNo		int	not null,
		ProductID		varchar(20) collate arabic_cs_as,
		FormulaNo		int	not null,
		GoodsID			varchar(20)	collate arabic_cs_as,
		SentQuantity	float	not null,
		FormulaQuantity	float	not null,
		Kind			int,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		BaseDocRowNo	int not null,
		DocDate			char(10) collate arabic_cs_as not null,
		ProdQuantity	float	not null,
		GoodsAmount	    float	not null,
		ProductName		nvarchar(120) not null,
		GoodsName		nvarchar(120) not null,
		UnitName		NVarchar(50),
		ProductUnitName	NVarchar(50)
	);
	
	insert into #tbl_Prd_ProduceVariance_Total(ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, 
		SentQuantity, FormulaQuantity, Kind, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, 
		ProdQuantity, GoodsAmount, ProductName, GoodsName, UnitName, ProductUnitName)
	exec [prd].[RptPrd_ProduceVariance_SHV] @FiscalYearFr,@FiscalYearTo,@SerialNoFr,@SerialNoTo,@DocDateFr,@DocDateTo,0,0,0,0,0,0,@ProductID,@GoodsID,@RepOptions,@RepInfo

	---- ===== Test Select
    --Select ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, SentQuantity, FormulaQuantity, Kind, 
    --       BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, ProdQuantity, GoodsAmount, ProductName, GoodsName, UnitName, 
    --       ProductUnitName 
    --From #tbl_Prd_ProduceVariance_Total
    --Where 1 = 1
    --  And Case When @GoodsID <> '' Then GoodsID Else '' End = Case When @GoodsID <> '' Then @GoodsID Else '' End
    --  --Group By DocDate

	-- ==========================================================================
	select ProductID, Sum(ProdQuantity) ProdQuantity--, GoodsAmount
	into #tbl_Prd_ProduceVariance_Prods
	from
	(
		select FiscalYear, SerialNo, ProductID, Sum(ProdQuantity) ProdQuantity
		from #tbl_Prd_ProduceVariance_Total	T1
		group by FiscalYear, SerialNo, ProductID, GoodsID
	) T
	group by T.ProductID--, T.GoodsAmount

    -- ======================================================== Product And Goods Filter
	if @ProductID <> '' And @ProductID is not null
		SET @StrWhere = @StrWhere + ' AND ProductID = ''' + LTrim(Rtrim(@ProductID)) + ''''

	if @ProductID_Fr <> '' And @ProductID_Fr is not null
		SET @StrWhere = @StrWhere + ' AND SubString(ProductID, 1, ' + LTrim(RTrim(Str(Len(@ProductID_Fr)))) + ') >= ''' + LTrim(Rtrim(@ProductID_Fr)) + ''''

	if @ProductID_To <> '' And @ProductID_To is not null
		SET @StrWhere = @StrWhere + ' AND SubString(ProductID, 1, ' + LTrim(RTrim(Str(Len(@ProductID_To)))) + ') <= ''' + LTrim(Rtrim(@ProductID_To)) + ''''
		
	if @GoodsID <> '' And @GoodsID is not null
		SET @StrWhere = @StrWhere + ' AND GoodsID = ''' + LTrim(Rtrim(@GoodsID)) + ''''

	if @GoodsID_Fr <> '' And @GoodsID_Fr is not null
		SET @StrWhere = @StrWhere + ' AND SubString(GoodsID, 1, ' + LTrim(RTrim(Str(Len(@GoodsID_Fr)))) + ') >= ''' + LTrim(Rtrim(@GoodsID_Fr)) + ''''

	if @GoodsID_To <> '' And @GoodsID_To is not null
		SET @StrWhere = @StrWhere + ' AND SubString(GoodsID, 1, ' + LTrim(RTrim(Str(Len(@GoodsID_To)))) + ') <= ''' + LTrim(Rtrim(@GoodsID_To)) + ''''

	-- ==========================================================================
	--Select ProductID, ProductName, ProdQuantity, GoodsID, GoodsName, SentQuantity, FormulaQuantity,
    --       IsNull((
	--				Select Top 1 Cast(GoodsAmount As Decimal(29, 8))
	--				From inv.tblStorageDocsDtl 
	--				Where 1 = 1
	--				  And ProcessID  in(70, 82) 
	--				  And ProcessNo   = 1 
	--				  And FiscalYear  = T1.FiscalYear 
	--				  And SerialNo    = TT.SerialNo 
	--				  And DocDate     <= @DocDateTo
	--				  And GoodsID     = Result.GoodsID
	--				  And GoodsAmount Is Not Null
	--				  And GoodsAmount > 0
	--				Order By DocDate Desc
	--		     ), 0) GoodsAmount
	--From 
	--(
	--	select D.ProductID, D.ProductName, P.ProdQuantity, D.GoodsID, D.GoodsName,
	--		SUM(SentQuantity) SentQuantity,	SUM(FormulaQuantity) FormulaQuantity
	--	from #tbl_Prd_ProduceVariance_Total	D
	--		inner join #tbl_Prd_ProduceVariance_Prods P on P.ProductID=D.ProductID
	--	group by D.ProductID, D.ProductName, P.ProdQuantity, D.GoodsID, D.GoodsName
	--	having round(SUM(SentQuantity) - SUM(FormulaQuantity), @Round) <> 0
	--	order by D.ProductID, D.GoodsID
	--) Result
	--Where GoodsID = '110177'
	--Order By ProductID, GoodsID
	
	-- ========================================================================== My Result
	-- ====================================== Detailed
	IF @Detailed_Rpt = 1
	Begin
		SET @StrSelect = '
		-- =================================================================================
		Select 
		    ' +
		    --Case When @Grp_By_Date = 1 Then 'DocDate, '        Else                     ''  End + 'GoodsID, GoodsName, ' +
		    Case When @Grp_By_Serial = 1 Then 'BaseSerialNo SerialNo, '  Else                ''       End +
		    Case When @Grp_By_Prd    = 1 Then 'ProductID, ProductName, ' Else                ''       End +
		    Case When @Grp_By_Date   = 1 Then 'DocDate '                 Else                ''''' '  End + 'DocDate, GoodsID, GoodsName, ' +
		    Case When @Grp_By_Date   = 1 Then 'SentQuantity '            Else 'Sum(SentQuantity) '    End + 'SentQuantity, ' +
		    Case When @Grp_By_Date   = 1 Then 'FormulaQuantity '         Else 'Sum(FormulaQuantity) ' End + 'FormulaQuantity, ' +
			Case When @Rpt_By_Amnt   = 1 Then '
			IsNull((
					Select Top 1 Cast(GoodsAmount As Decimal(29, 8))
					From inv.tblStorageDocsDtl 
					Where 1 = 1
						And ProcessID  IN(70, 82) 
						And ProcessNo   = 1 
						--And FiscalYear  = T1.FiscalYear 
						--And SerialNo    = TT.SerialNo ' +
						Case When @DocDateTo <> '' Then ' 
						And DocDate    <= ''' + LTrim(RTrim(@DocDateTo)) + ''''
						Else '' End + '
						And GoodsID     = Result.GoodsID
						And GoodsAmount Is Not Null
						And GoodsAmount > 0
					Order By DocDate Desc
					), 0)'
		Else
			'0'
		End + ' GoodsAmount--, inv.funGetLastEndAmount(GoodsID, Null, DocDate) GoodsAmount_2
		From
		(
			Select D.BaseSerialNo, D.ProductID, GD.GoodsName ProductName, D.GoodsID, D.GoodsName, D.DocDate, 
			       Sum(SentQuantity)    SentQuantity, 
			       Sum(FormulaQuantity) FormulaQuantity
			From #tbl_Prd_ProduceVariance_Total	D
			Inner Join #tbl_Prd_ProduceVariance_Prods P ON P.ProductID = D.ProductID
			Inner Join inv.tblGoodsDtl               GD ON GD.GoodsID  = D.ProductID
			Group By D.BaseSerialNo, D.ProductID, GD.GoodsName, D.GoodsID, D.GoodsName, D.DocDate
			Having Round(Sum(SentQuantity) - Sum(FormulaQuantity), ' + LTrim(RTrim(Str(@Round))) + ') <> 0
			--Order By D.BaseSerialNo, D.ProductID, D.GoodsID
		) Result
		Where 1 = 1 ' + @StrWhere +
		Case When @Prd_Group <> '' And @Prd_Group Is Not Null Then '
          And ProductID IN(
							Select GoodsID
							From inv.tblGoodsGroupsGoodsListDtl
							Where GoodsGroupID IN(''' + LTrim(RTrim(@Prd_Group)) + ''')
                          )
        '
        Else '' End + 
        Case When @GoodsGroup <> '' And @GoodsGroup Is Not Null Then '
          And GoodsID   IN(
							Select GoodsID
							From inv.tblGoodsGroupsGoodsListDtl
							Where GoodsGroupID IN(''' + LTrim(RTrim(@GoodsGroup)) + ''')
                          )'
        Else '' End + '
		Group By ' +
		Case When @Grp_By_Prd    = 1 Then 'ProductID, ProductName, '  Else '' End + 'GoodsID, GoodsName ' +
		Case When @Grp_By_Serial = 1 Then ', BaseSerialNo '           Else '' End +
		Case When @Grp_By_Date   = 1 Then ', DocDate '                Else '' End +
		Case When @Grp_By_Date   = 1 Then ', SentQuantity '           Else '' End +
		Case When @Grp_By_Date   = 1 Then ', FormulaQuantity '        Else '' End + '
		Order By ' + 
        Case
		When @Grp_By_Serial = 1 And @Grp_By_Prd = 1 And @Grp_By_Date = 1 Then
		     Case When @Order_By_Date = 1 Then
			      'DocDate, BaseSerialNo, ProductID, GoodsID '
			 Else
			      'BaseSerialNo, ProductID, DocDate, GoodsID '
			 End

		When @Grp_By_Serial = 0 And @Grp_By_Prd = 1 And @Grp_By_Date = 1 Then
		     Case When @Order_By_Date = 1 Then
			      'DocDate, ProductID, GoodsID '
			 Else
			      'ProductID, DocDate, GoodsID '
			 End

		When @Grp_By_Serial = 1 And @Grp_By_Prd = 0 And @Grp_By_Date = 1 Then
		     Case When @Order_By_Date = 1 Then
			      'DocDate, BaseSerialNo, GoodsID '
			 Else
			      'BaseSerialNo, GoodsID, DocDate '
			 End

		When @Grp_By_Serial = 1 And @Grp_By_Prd = 1 And @Grp_By_Date = 0 Then
		     Case When @Order_By_Date = 1 Then
			      'BaseSerialNo, ProductID, GoodsID, DocDate '
			 Else
			      'BaseSerialNo, ProductID, GoodsID '
			 End

		When @Grp_By_Serial = 0 And @Grp_By_Prd = 1 And @Grp_By_Date = 0 Then
		     Case When @Order_By_Date = 1 Then
			      'ProductID, GoodsID, DocDate '
			 Else
			      'ProductID, GoodsID '
			 End
		
		When @Grp_By_Serial = 0 And @Grp_By_Prd = 0 And @Grp_By_Date = 1 Then
		     Case When @Order_By_Date = 1 Then
			      'DocDate, ProductID, GoodsID '
			 Else
			      'ProductID, GoodsID, DocDate '
			 End

        Else
		    'GoodsID'
		End
	End
	Else
	Begin
		-- ====================================== Sum
		--Select Case When @Rpt_By_Amnt = 1 Then Sum(Sum_Amount) Else Sum(Sum_Qty) End Sum_Result
		SET @StrSelect = '
		-- =================================================================================
		Select 
		   ' +
		   Case When @Grp_By_Date = 1 Then 'DocDate, ' Else '' End + '
		   Replace(Replace(Convert(Varchar, Convert(Money, Sum(Sum_Amount)), 1), ''.00'', ''''), ''.'', ''.'') Sum_Result_Amnt, 
		   Case When Sum(Sum_Amount) > 0 Then ''اضافه مصرف'' Else ''کسر مصرف'' End Status, 
		   Replace(Replace(Convert(Varchar, Convert(Money, Sum(Sum_Qty)), 1), ''.00'', ''''), ''.'', ''.'') Sum_Result_QTY, 
		   Case When Sum(Sum_Qty) > 0 Then ''اضافه مصرف'' Else ''کسر مصرف'' End Status
		From
		(
			Select 
			    DocDate,
			    (SentQuantity - FormulaQuantity) Sum_Qty,
			    (SentQuantity - FormulaQuantity) * GoodsAmount Sum_Amount
			From
			(
				Select ProductID, ProductName, GoodsID, GoodsName, DocDate, SentQuantity, FormulaQuantity,
					   IsNull((
								Select Top 1 Cast(GoodsAmount As Decimal(29, 8))
								From inv.tblStorageDocsDtl 
								Where 1 = 1
								  And ProcessID   IN(70, 82) 
								  And ProcessNo    = 1 
								  --And FiscalYear   = T1.FiscalYear 
								  --And SerialNo     = TT.SerialNo ' +
								  Case When @DocDateTo <> '' Then ' 
								  And DocDate     <= ''' + LTrim(RTrim(@DocDateTo)) + ''''
								  Else '' End + '
								  And GoodsID      = Result.GoodsID
								  And GoodsAmount Is Not Null
								  And GoodsAmount  > 0
								Order By DocDate Desc
							 ), 0) GoodsAmount--, inv.funGetLastEndAmount(GoodsID, Null, DocDate) GoodsAmount_2
				From 
				(
					Select D.ProductID, GD.GoodsName ProductName, D.GoodsID, D.GoodsName, D.DocDate, 
						   Sum(SentQuantity)    SentQuantity, 
						   Sum(FormulaQuantity) FormulaQuantity
					From #tbl_Prd_ProduceVariance_Total	D
					Inner Join #tbl_Prd_ProduceVariance_Prods P ON P.ProductID = D.ProductID
					Inner Join inv.tblGoodsDtl               GD ON GD.GoodsID  = D.ProductID
					Group By D.ProductID, GD.GoodsName, D.GoodsID, D.GoodsName, D.DocDate
					Having Round(Sum(SentQuantity) - Sum(FormulaQuantity), ' + LTrim(RTrim(Str(@Round))) + ') <> 0
					--Order By D.ProductID, D.GoodsID
				) Result
				Where 1 = 1 ' + @StrWhere +
				Case When @Prd_Group <> '' And @Prd_Group Is Not Null Then '
				  And ProductID IN(
									Select GoodsID
									From inv.tblGoodsGroupsGoodsListDtl
									Where GoodsGroupID IN(''' + LTrim(RTrim(@Prd_Group)) + ''')
								  )
				'
				Else '' End + 
				Case When @GoodsGroup <> '' And @GoodsGroup Is Not Null Then '
				  And GoodsID   IN(
									Select GoodsID
									From inv.tblGoodsGroupsGoodsListDtl
									Where GoodsGroupID IN(''' + LTrim(RTrim(@GoodsGroup)) + ''')
								  )'
				Else '' End + '
			) Result
		) Result_Sum ' + 
		Case When @Grp_By_Date = 1 Then '
		Group By DocDate ' Else '' End
	End

	-- ==================================== EXEC
	PRINT @StrSelect;
	EXEC  sp_executesql @StrSelect;

END
GO
