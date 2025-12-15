USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/06/27
-- Viewed By	 : 
-- Last Modified : 1390/04/18
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [sal].[RptSale_PreSale_Docs_StoreDocs] 
	@ProcessID			Int = 240,  -- default is pre sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@SelectedStore		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(200) = Null,
	@RepOptions			VarChar(20) = '0', -- bit array options
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
DECLARE	@SDExist		bit; -- سند انبار داشته باشد
DECLARE @OnlyConfirmedDoc bit ; -- فقط فاکتورهایی که تایید شده اند
DECLARE @NotConfirmedDoc  bit ; -- فقط فاکتورهایی که تایید نشده اند
DECLARE @RemoveState2	  bit ; -- عدم‌نمایش فاکتورهای ابطالی
Begin --============== S T A R T  C O D E ===================================================

	set NOCOUNT ON;

	-- Init -------------------------------------------------
	SET @OnlyConfirmedDoc = '0'
	SET @NotConfirmedDoc = '0'
	if (@RepInfo Is Null)			set @RepInfo = '1@1@1';
	if (@RepOptions Is Null)		set @RepOptions = '0';
	if (@ProcessNo Is Null)			set @ProcessNo = 1;

	if (@SelectedStore Is Null)		set @SelectedStore = 0;
	if (@SelectedAcnt1 Is Null)		set @SelectedAcnt1 = 0;
	if (@SelectedAcnt2 Is Null)		set @SelectedAcnt2 = 0;
	if (@SelectedAcnt3 Is Null)		set @SelectedAcnt3 = 0;
	if (@SelectedAcnt4 Is Null)		set @SelectedAcnt4 = 0;
	if (@SelectedVisitor1 Is Null)	set @SelectedVisitor1 = 0;
	if (@SelectedVisitor2 Is Null)	set @SelectedVisitor2 = 0;
	if (@SelectedVisitor3 Is Null)	set @SelectedVisitor3 = 0;
	if (@SelectedVisitor4 Is Null)	set @SelectedVisitor4 = 0;

	if (@FiscalYearFr Is Null)	set @SerialNoFr = Null;
	if (@FiscalYearTo Is Null)	set @SerialNoTo = Null;
	if (@SerialNoFr	Is Null)	set @FiscalYearFr = Null;
	if (@SerialNoTo	Is Null)	set @FiscalYearTo = Null;

	set @SDExist			= Substring(@RepOptions, 1, 1);
	set @OnlyConfirmedDoc	= Substring(@RepOptions, 2, 1);
	set @NotConfirmedDoc	= Substring(@RepOptions, 3, 1);
	set @RemoveState2		= Substring(@RepOptions, 4, 1);

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	if (@SDExist = 1)
		set @StrWhere = '(SH.BaseSerialNo is not null)'
	else
		set @StrWhere = '(SH.BaseSerialNo is null)'

	IF @OnlyConfirmedDoc = '1'
		set @StrWhere = @StrWhere + ' AND H.ConfirmState=1 AND H.DocStep>1'

	IF @NotConfirmedDoc = '1'
		set @StrWhere = @StrWhere + ' AND (H.ConfirmState<>1 OR H.DocStep=1)'

	if (@ProcessID is not null)
		set @StrWhere = @StrWhere + ' AND (H.ProcessID = ' + LTrim(Str(@ProcessID)) + ')'

	if (@ProcessNo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	if (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	if (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	if (@DocDateFr Is Not Null) AND (@DocDateTo Is Not Null) AND (@DocDateFr = @DocDateTo)
		set @StrWhere = @StrWhere + ' AND (H.DocDate = ''' + @DocDateFr + ''')'
	else
	begin
		if (@DocDateFr Is Not Null)
			set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'

		if (@DocDateTo Is Not Null)
			set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
	end

	if (@SaleTypeID Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'

	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 

	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	if (@SelectedVisitor1 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	if (@SelectedVisitor2 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	if (@SelectedVisitor3 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	if (@SelectedVisitor4 > 0)
		set @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	if @RemoveState2 = 'True'
		set @StrWhere = @StrWhere + ' AND (H.ConfirmState <> 2)'
	else
		set @StrWhere = @StrWhere + ''
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
	---------------------------------------------------------
declare @Result1 as varchar(max)
SET @Result1= ''
exec [pub].[funGetColumnsWithoutXColumns] @SchemaName='inv',@tableName='tblPreSaleHdr',
				@ColumnsName='DocHdr'',''DocFtr',
				@CompressTableName='H',@Result=@Result1 output

	-- SELECT Clause ----------------------------------------
	set @StrSelect = ' 
	SELECT	distinct '+ @Result1 +', S.StoreName, SH.BaseFiscalYear, SH.BaseSerialNo,
			(select sum(GoodsQuantity*GoodsAmount) from inv.tblPreSaleDtl D where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo) SumAmount 
			,SH.ProcessID BaseProcessID
	FROM	inv.tblPreSaleHdr H 
	LEFT  JOIN 
	(
		select distinct ProcessID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl where BaseProcessID = 240
		union all
		(select distinct  a.ProcessID,a.BaseProcessID,a.BaseProcessNo,a.BaseFiscalYear,a.BaseSerialNo 
		 FROM sal.tblSaleOrderDtl a
		 inner join inv.tblStorageDocsDtl b
		 on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo
		 where a.BaseProcessID = 240
		)
	) SH ON SH.BaseProcessID = H.ProcessID AND SH.BaseProcessNo = H.ProcessNo AND SH.BaseFiscalYear = H.FiscalYear AND SH.BaseSerialNo = H.SerialNo 
	INNER JOIN inv.tblStoresDtl S ON H.StoreID = S.StoreID AND S.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	if (@SortFields Is Not Null)
		set @StrSelect = @StrSelect + '
	 ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
