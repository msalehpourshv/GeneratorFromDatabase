USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/04/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش لیست برگه های سفارش تولید
-- ==============================================
Create PROCEDURE pln.RptProducesPrdSerialsReg
	@ProcessID		Int = 600,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@ExtraParams	NVarChar(200) = Null,
	@RepInfo		NVarChar(100) = Null

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrDocDesc		NVarChar(600);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

declare @IsConfirmed	bit;
declare @IsNotConfirmed	bit;
declare @IsFinished		bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @StrWhere =' 1=1 '
	IF (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ' '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ' '
		
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
		SELECT  H.*,D.RowNo,D.DocRowNo,D.ProductSerialID,D.PSerialNo,'+  str(@FiscalYear)+' FiscalYear
		,pub.GetStoreName(H.StoreID1,'+str(@LangID)+') StoreName1,pub.GetStoreName(H.StoreID2,'+str(@LangID)+') StoreName2
		,acc.funPartAcntName(AcntCode,'+str(@LangID)+') AcntName,pub.GetGoodsName(ProductID,'+str(@LangID)+') ProductName
		,(SELECT FormulaName FROM prd.tblFormulasHdr F where F.ProductID=H.ProductID and F.SerialNo=H.FormulaNo) FormulaName
		FROM  pln.tblProducesPrdSerialsRegHdr H
		inner join pln.tblProducesPrdSerialsRegDtl D ON H.SerialNo=D.SerialNo
	WHERE ' + @StrWhere

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
