USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/03
-- Viewed By	 : 
-- Last Modified : 1393/04/31
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش لیست اموال
-- ==============================================
Create PROCEDURE [ast].[RptAst_AssetsList]

	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@LocateIDFr			VarChar(20) = Null, -- محل استقرار
	@LocateIDTo			VarChar(20) = Null, -- Not Used Now
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@AstGroupIDMask		VarChar(20) = Null,
	@AstGroupNameMask	NVarChar(50) = Null,
	@GoodsIDFr			VarChar(20) = Null,  
	@GoodsIDTo			VarChar(20) = Null,  
	@GoodsIDMask		VarChar(20) = Null,  
	@GoodsNameMask		NVarChar(50) = Null,  
	@RegisteredValueFr	Float = Null, -- ارزش دفتری
	@RegisteredValueTo	Float = Null,
	@FinalValueFr		Float = Null, -- قیمت تمام شده
	@FinalValueTo		Float = Null,
	@DeprecAmountFr		Float = Null, -- استهلاک انباشته جاری
	@DeprecAmountTo		Float = Null,
	@DeprecRateFr		TinyInt = Null, -- نرخ استهلاک
	@DeprecRateTo		TinyInt = Null,
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@DeprecMethod		TinyInt = Null, -- روش محاسبه استهلاک
	@AssetStatus		TinyInt = Null, -- وضعیت جاری
	@ExtraParams		NVarChar(2000) = Null,
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options

WITH ENCRYPTION
AS 
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhereD			NVarChar(max);
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی
DECLARE	@FromDate			Int; -- برای حالت کدهای انتخابی
DECLARE	@ToDate				Int; -- برای حالت کدهای انتخابی
DECLARE	@SelectedGoods		Int; 
DECLARE @CostInSale			VarChar(20) = Null;
DECLARE	@AssetSale			Int; 
DECLARE	@AssetDelete		Int; 
DECLARE	@ExitWithOutEnter	bit
DECLARE @DepreciationCostAcntCode		VarChar(20) = Null;
DECLARE	@MaxDate		char(10)

Begin 
	--============== S T A R T  C O D E =======================================
SET @SelectedGoods				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @CostInSale					= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @AssetDelete				= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
SET @AssetSale					= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @DepreciationCostAcntCode	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @ExitWithOutEnter			= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	
--	select @SelectedGoods,@CostInSale,@AssetDelete,@AssetSale
	SET NOCOUNT ON;
	
	---- Init ------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'

	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @FromDate	= pub.funSplitString(@RepInfo, '@', 4);
	SET @FromDate	= pub.funSplitString(@RepInfo, '@', 5);
	----------------------------------------------------
		SET @StrWhereD = ''
		If (@AstGroupIDMask Is Not Null)
			SET @StrWhereD = @StrWhereD + ' AND (b.DocDate >=  ''' + @AstGroupIDMask + ''')'
		If (@AstGroupNameMask Is Not Null)
			SET @StrWhereD = @StrWhereD + ' AND (b.DocDate <=  ''' + @AstGroupNameMask + ''')'
            
	SET @StrWhere = '  1=1  ' 
	
	if @AssetDelete=0
	SET @StrWhere =@StrWhere +  ' AND (Select COUNT(*) From ast.tblAssetsDtl a inner join (SELECT  max(DocDate )DocDate,AssetPlaque FROM  ast.tblAssetsDtl b where ProcessID in( 450,455,460,485,495) ' + @StrWhereD + ' group by   AssetPlaque ) b on a.AssetPlaque=b.AssetPlaque and a.DocDate=b.DocDate where ProcessID in( 485)   and a.AssetPlaque=D.AssetPlaque   )=0 ' 

	if @AssetSale=0
	SET @StrWhere =@StrWhere +  ' AND (Select COUNT(*) From ast.tblAssetsDtl a inner join (SELECT  max(DocDate )DocDate,AssetPlaque FROM  ast.tblAssetsDtl b where ProcessID in( 450,455,460,485,495) ' + @StrWhereD + ' group by   AssetPlaque ) b on a.AssetPlaque=b.AssetPlaque and a.DocDate=b.DocDate where ProcessID in( 495)   and a.AssetPlaque=D.AssetPlaque  )=0 ' 
	
	If (@AssetPlaqueFr Is Not Null) AND (@AssetPlaqueTo Is Not Null) AND (@AssetPlaqueFr = @AssetPlaqueTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque = ''' + @AssetPlaqueFr + ''')'
	Else
	Begin
		If (@AssetPlaqueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'
		If (@AssetPlaqueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'
	End

	If (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID LIKE ''' + @LocateIDFr + '%'')'
	Else
	Begin
		If (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		If (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID <= ''' + @LocateIDTo + ''')'
	End

	If (@AstGroupIDFr Is Not Null) AND (@AstGroupIDTo Is Not Null) AND (@AstGroupIDFr = @AstGroupIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.AstGroupID = ''' + @AstGroupIDFr + ''')'
	Else
	Begin
		If (@AstGroupIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID >= ''' + @AstGroupIDFr + ''')'
		If (@AstGroupIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID <= ''' + @AstGroupIDTo + ''')'
	End

	-- FromDate
	If (@AstGroupIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >=  ''' + @AstGroupIDMask + ''')'

	If (@CostInSale Is Not Null and @CostInSale<>0)
		SET @StrWhere = @StrWhere + ' AND (SubString (  D.CostInSale ,1,len (''' + @CostInSale + '''))=  ''' + @CostInSale + ''')'

	If (@DepreciationCostAcntCode Is Not Null and @DepreciationCostAcntCode<>'')
		SET @StrWhere = @StrWhere + ' AND DepreciationCostAcntCode like  ''' + @DepreciationCostAcntCode + '%'''

	-- ToDate
	If (@AstGroupNameMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <=  ''' + @AstGroupNameMask + ''')'
		
	-- (@GoodsIDFr & @GoodsIDTo
	--If (@GoodsIDFr Is Not Null) AND (@GoodsIDTo Is Not Null) AND (@GoodsIDFr = @GoodsIDTo)
		--SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsIDFr + ''')'
	--Else 
	--Begin
		--If (@GoodsIDFr Is Not Null)
			--SET @StrWhere = @StrWhere + ' AND (D.GoodsID >= ''' + @GoodsIDFr + ''')'
		--If (@GoodsIDTo Is Not Null)
			--SET @StrWhere = @StrWhere + ' AND (D.GoodsID <= ''' + @GoodsIDTo + ''')'
	--End
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		
	If (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'')'

	If (@GoodsNameMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND Replace(D.AssetTitle, '' '', '''') LIKE N''%' + RTrim(Replace(@GoodsNameMask, ' ', '')) + '%'''

	If (@RegisteredValueFr Is Not Null) AND (@RegisteredValueTo Is Not Null) AND (@RegisteredValueFr = @RegisteredValueTo)
		SET @StrWhere = @StrWhere + ' AND (D.RegisteredValue = ' + LTRim(Str(@RegisteredValueFr)) + ')'
	Else
	Begin
		If (@RegisteredValueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.RegisteredValue >= ' + LTRim(Str(@RegisteredValueFr)) + ')'
		If (@RegisteredValueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.RegisteredValue <= ' + LTRim(Str(@RegisteredValueTo)) + ')'
	End
	
	If (@FinalValueFr Is Not Null) AND (@FinalValueTo Is Not Null) AND (@FinalValueFr = @FinalValueTo)
		SET @StrWhere = @StrWhere + ' AND (D.CostAmount = ' + LTRim(Str(@FinalValueFr)) + ')'
	Else
	Begin
		If (@FinalValueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.CostAmount >= ' + LTRim(Str(@FinalValueFr)) + ')'
		If (@FinalValueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.CostAmount <= ' + LTRim(Str(@FinalValueTo)) + ')'
	End

	If (@DeprecAmountFr Is Not Null) AND (@DeprecAmountTo Is Not Null) AND (@DeprecAmountFr = @DeprecAmountTo)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationAmount = ' + LTRim(Str(@DeprecAmountFr)) + ')'
	Else
	Begin
		If (@DeprecAmountFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationAmount >= ' + LTRim(Str(@DeprecAmountFr)) + ')'
		If (@DeprecAmountTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationAmount <= ' + LTRim(Str(@DeprecAmountTo)) + ')'
	End

	If (@DeprecRateFr Is Not Null) AND (@DeprecRateTo Is Not Null) AND (@DeprecRateFr = @DeprecRateTo)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationRate = ' + LTRim(Str(@DeprecRateFr)) + ')'
	Else
	Begin
		If (@DeprecRateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationRate >= ' + LTRim(Str(@DeprecRateFr)) + ')'
		If (@DeprecRateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DepreciationRate <= ' + LTRim(Str(@DeprecRateTo)) + ')'
	End

	If (@AssetManagerID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID Like ''' + @AssetManagerID + '%'')'

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'

	If (@DeprecMethod Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationMethod = ' + LTRim(Str(@DeprecMethod)) + ')'

	If (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'
	If isnull(@ExitWithOutEnter,'False')='True'
		SET @StrWhere = @StrWhere + ' AND (D.LastProcessID <>500)  and ( select isnull(Sum(EnterKind),0) from ast.tblAssetsDtl a where a.AssetPlaque=D.AssetPlaque )>0 '



select @MaxDate=max(DocDate) from ast.tblAssetsDtl where ProcessID=520
set @MaxDate=isnull(@MaxDate,'')

	SET @StrSelect = ' 
	select *,	Case when ProcessID<>520 then 0 Else Case when DocDate='''+ @MaxDate +''' then PrevDepreciationAmount else 0 end end  LastDepreciation 
	from (
		SELECT	D.*,ast.funGetAssetManagerName (D.AssetManagerID, ' + @LangID	+ ')as AssetManagerName, L.LocateName, P.FirstName + '' '' + P.LastName AS ResponsibleName
			,isnull((Select top 1 DepreciationAmount FROM ast.tblAssetsDtl F  Where F.ProcessID = 450 and D.AssetPlaque = F.AssetPlaque order by F.DocDate desc),0) as FristDepreciationAmount 
			,isnull((Select  top 1  RegisteredValue FROM ast.tblAssetsDtl F  Where F.ProcessID = 450 and D.AssetPlaque = F.AssetPlaque order by F.DocDate desc),0) as FristRegisteredValue 
			, DepreciationCost	  as PrevDepreciationAmount,acc.funPartAcntName(DepreciationCostAcntCode,1) DepreciationCostAcntName
			,(SELECT     COUNT(*) AS AtomCout FROM         ast.tblAstGroupSpecs AS S 
				INNER JOIN ast.tblAssetsAtm AS A ON S.AstGroupSpecID = A.AstGroupSpecID
				WHERE     (A.ProcessID = D.ProcessID ) AND (A.ProcessNo = D.ProcessNo ) AND (A.FiscalYear = D.FiscalYear ) AND (A.SerialNo = D.SerialNo ) AND (A.DocRowNo = D.DocRowNo ) AND (S.AstGroupID = D.AstGroupID )) as AtomCout	
 		FROM	(select ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,Case when ProcessID in (450,455,460) Then PurchaseDate else DocDate end DocDate,AstGroupID,LocateID,GoodsID,AssetPlaque,AssetTitle,AssetManagerID,ResponsibleID
						,AssetAcntCode,ObverseAcntCode,PurchaseDate,PurchaseAmount,SetupAmount,OtherCosts,UseDate,DepreciationAcntCode,OldValue,TopRegisteredValue,CostAmount,DocRowNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
						,BaseDocRowNo,DepreciationMethod,DepreciationRate,DepreciationAmount,RegisteredValue,RenovationTypeID,ChangeAmount,ReturnDate,AssetState,EventNo,CostAcntCode,SourceSerialNo,SourceProcessNo,SetupAmountAcntCode,OtherCostsAcntCode
						,DepreciationValue,CostInSale,DescDtl,DepreciationCost,DepreciationCostAcntCode ,(select  top 1  ProcessID from ast.tblAssetsDtl M where D.AssetPlaque=M.AssetPlaque order by AssetPlaque, DocDate Desc )LastProcessID
						From ast.tblAssetsDtl D)AS D 
			RIGHT OUTER JOIN
				(SELECT    b.AssetPlaque, b.DocDate, max(b.EventNo) EventNo 
					FROM   (select Case when ProcessID in (450,455,460) Then PurchaseDate else DocDate end DocDate ,AssetPlaque,EventNo from  ast.tblAssetsDtl )b 
						inner join 
							(select    DISTINCT AssetPlaque,  MAX(Case when ProcessID in (450,455,460) Then PurchaseDate else DocDate end ) AS DocDate 
								From  ast.tblAssetsDtl b 
									WHERE 1=1 ' + @StrWhereD + '  GROUP BY AssetPlaque) a 
							on a.AssetPlaque=b.AssetPlaque and a.DocDate=b.DocDate
					WHERE 1=1 ' + @StrWhereD + ' 
					GROUP BY   b.AssetPlaque, b.DocDate) AS A 
				ON D.AssetPlaque = A.AssetPlaque AND D.DocDate = A.DocDate  AND D.EventNo = A.EventNo 
			LEFT OUTER JOIN ast.tblLocatesDtl AS L ON L.LocateID = D.LocateID AND L.LanguageID = ' + @LangID	+ ' 
			LEFT OUTER JOIN prs.tblPersonnelsDtl AS P ON P.PersonnelID = D.ResponsibleID AND P.LanguageID = ' + @LangID	

	SET @StrSelect = @StrSelect + '
	WHERE ' + @StrWhere + ' ) a
	ORDER BY AssetPlaque'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
