USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Creation Date : 1396/03/03
-- Viewed By	 : 
-- Last Modified : 1396/03/03
-- Last Modifier : TakroSystem\Hamid
-- Description	 : 
-- ==============================================
--EXEC  [prd].[RptPrd_ProductCostsPrint] 77,Null,69,Null,69,Null,Null,'','',N'1@1164@160062@0@1'
Create PROCEDURE [prd].[RptPrd_ProductCostsPrint]
	@ProcessID			Int			  = 77,
	@FiscalYearFr		Int			  = Null,
	@SerialNoFr			Int			  = Null,
	@FiscalYearTo		Int			  = Null,
	@SerialNoTo			Int			  = Null,
	@DocDateFr			Char(10)	  = Null,
	@DocDateTo			Char(10)	  = Null,
	@ExtraParams		NVarChar(200) = Null,
	@RepOptions			VarChar(20)   = '11111111111',
	@RepInfo			NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@ProcessNo		Int; 
Begin --============== S T A R T  C O D E ===================================================

	set NOCOUNT ON;

	-- Init -------------------------------------------------
	if (@RepInfo Is Null)			set @RepInfo = '1@1@1';
	if (@RepOptions Is Null)		set @RepOptions = '0';

	--set @SDExist	= Substring(@RepOptions, 1, 1);

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @ProcessNo	= pub.funSplitString(@RepInfo, '@', 6);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = '1 = 1'
	if (@ProcessID is not null)
		set @StrWhere = @StrWhere + ' and (H.ProcessID = ' + LTrim(Str(@ProcessID)) + ')'
	if (@ProcessNo is not null)
		set @StrWhere = @StrWhere + ' and (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	if (@FiscalYearFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear >= ' + LTrim(Str(@FiscalYearFr)) + ')' 
	if (@FiscalYearTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear <= ' + LTrim(Str(@FiscalYearTo)) + ')' 
   	if (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')' 
	if (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 

	if (@DocDateFr Is Not Null) AND (@DocDateTo Is Not Null) AND (@DocDateFr = @DocDateTo)
		set @StrWhere = @StrWhere + ' AND (H.DocDate = ''' + @DocDateFr + ''')'
	else
	begin
		if (@DocDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'

		if (@DocDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
	end

	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	set @StrSelect = ' 
	SELECT H.*, D.Quantity, D.Amount, D.AcntCode AcntCodeDtl, 
		   pub.GetCodeName(D.AcntCode, ' + LTRIM(RTRIM(@LangID)) + ') AS AcntNameDtl,
		   pub.GetCodeName(H.AcntCode, ' + LTRIM(RTRIM(@LangID)) + ') AS AcntName,
		   pub.GetCodeName(H.AcntCode, ' + LTRIM(RTRIM(@LangID)) + ') AS GoodsInProductionAcntName,
		   IsNull(pub.GetGoodsName(H.ProductID, ' + LTRIM(RTRIM(@LangID)) + '),'''') As ProductName
	FROM prd.tblProductCostsHdr H
	INNER JOIN prd.tblProductCostsDtl D 
	ON H.ProcessID = D.ProcessID And  H.ProcessNo = D.ProcessNo And  H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
	WHERE ' + @StrWhere
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
