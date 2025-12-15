USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Takrosystem\Hamid
-- Create date   : 1396/05/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : Takrosystem\Hamid
-- Description	 : فاکتور الکترونیکی
-- =============================================
Create PROCEDURE [inv].[RptInv_BatchNoList]
	@BatchNoFr			NVarChar(20) = Null,
	@BatchNoTo			NVarChar(20) = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null, 
	@DocDateTo			Char(10) = Null,
	@SelectedOrders1	Int = 0, 
	@SelectedOrders2	Int = 0, 
	@SelectedOrders3	Int = 0, 
	@SelectedOrders4	Int = 0, 	
	@RepOptions			VarChar(20) = '0',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''

WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrSelect2	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

DECLARE	@NotReadBatchNo	Bit;
DECLARE	@PartNo	Int;
DECLARE	@PartStart	Int;
DECLARE	@PartLen	Int;

Begin

	set @PartNo= [acc].[FunGetAcntInfoForRemain](1)
	set @PartStart= [acc].[FunGetAcntInfoForRemain](2)
	set @PartLen= [acc].[FunGetAcntInfoForRemain](3)
	
	-- init ----------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '0'

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@SelectedOrders1 Is Null)	SET @SelectedOrders1 = 0;
	IF (@SelectedOrders2 Is Null)	SET @SelectedOrders2 = 0;
	IF (@SelectedOrders3 Is Null)	SET @SelectedOrders3 = 0;
	IF (@SelectedOrders4 Is Null)	SET @SelectedOrders4 = 0;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @NotReadBatchNo	  = Substring(@RepOptions, 1, 1)

	------------------------------------------------
	-- where ---------------------------------------
	SET @StrWhere = '1 = 1'
	SET @StrSelect2 = ''

	IF (@BatchNoFr <> '')
		Set @StrWhere = @StrWhere + ' AND (B.BatchNo >= ''' + Ltrim(@BatchNoFr) + ''')'
	IF (@BatchNoTo <> '')
		Set @StrWhere = @StrWhere + ' AND (B.BatchNo <= ''' + Ltrim(@BatchNoTo) + ''')'
		
	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (B.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(B.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND B.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (B.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(B.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND B.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (B.BatchDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (B.BatchDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedOrders1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'B.OrderAcntCode') 
	IF (@SelectedOrders2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'B.OrderAcntCode') 
	IF (@SelectedOrders3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'B.OrderAcntCode') 
	IF (@SelectedOrders4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'B.OrderAcntCode')
		
	--SET @NotReadBatchNo = 1
	IF @NotReadBatchNo = 1
		SET @StrSelect2	= '
		AND B.BatchNo not IN (SELECT BatchNo FROM inv.tblStorageDocsDtl Where BatchNo <> '''')'
	------------------------------------------------------------
	-- select --------------------------------------------------
	SET @StrSelect = '
		SELECT B.BatchNo, D.BatchName, B.BatchDate, B.EndProduction, B.BatchCount, B.OrderAcntCode, 
			AcntName  AS OrderAcntName, B.RelatedGoodsID, B.BaseFiscalYear, 
			   B.BaseSerialNo, D.BatchExtraField1, D.BatchExtraField2, D.BatchExtraField3, D.BatchExtraField4 
		FROM   inv.tblBatch B
		Inner Join inv.tblBatchDtl D ON B.BatchNo = D.BatchNo
		inner join acc.tblAcntDtl a  on a.AcntCode=SUBSTRING(B.OrderAcntCode,'+ STR(@PartStart)+ ','+ STR(@PartLen)+ ') and a.PartNumber='+ STR(@PartNo)+ ' and a.LanguageID=1
		WHERE  ' + @StrWhere + @StrSelect2
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
