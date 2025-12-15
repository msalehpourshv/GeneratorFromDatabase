USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1394/02/20
-- Viewed By	 : 
-- Last Modified : 1394/02/27
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش برگه های سفارش تولید بهمراه سفارش کار
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_ProduceOrder_Tasks]
	@FiscalYearFr	int = null,
	@SerialNoFr		int = null,
	@FiscalYearTo	int = null,
	@SerialNoTo		int = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@SelectedProds	int = null,
	@SelectedPrdrs	int = null,
	@FormulaList	varchar(500) = null,
	@SortFields		nvarChar(100) = null,
	@ExtraParams	nvarchar(500) = '',
	@RepOptions		varChar(10) = '111111',  -- bit array options
	@RepInfo		nvarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrFrom		NVarChar(max);
DECLARE @StrWhere		NVarChar(max);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE	@Confirmed0		bit;
DECLARE	@Confirmed1		bit;

DECLARE	@Reserved0		bit;
DECLARE	@Reserved1		bit;

DECLARE	@Finished0		bit;
DECLARE	@Finished1		bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	if (@RepInfo	Is Null)	set @RepInfo = '1@1@1';
	IF (@SelectedProds Is Null)	set @SelectedProds = 0;
	IF (@SelectedPrdrs Is Null)	set @SelectedPrdrs = 0;
	if (@FiscalYearFr Is Null)	set @SerialNoFr = Null;
	if (@FiscalYearTo Is Null)	set @SerialNoTo = Null;
	if (@SerialNoFr	Is Null)	set @FiscalYearFr = Null;
	if (@SerialNoTo	Is Null)	set @FiscalYearTo = Null;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @Confirmed0 = Substring(@RepOptions, 1, 1);
	set @Confirmed1 = Substring(@RepOptions, 2, 1);
	set @Finished0	= Substring(@RepOptions, 3, 1);
	set @Finished1	= Substring(@RepOptions, 4, 1);
	set @Reserved0	= Substring(@RepOptions, 5, 1);
	set @Reserved1	= Substring(@RepOptions, 6, 1);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = '(H.ProcessID = 600)'

	If (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	If (@Confirmed0 <> 1)
		set @StrWhere = @StrWhere + ' AND (H.IsConfirmed <> 0)'
	If (@Confirmed1 <> 1)
		set @StrWhere = @StrWhere + ' AND (H.IsConfirmed <> 1)'

	If (@Reserved0 <> 1)
		set @StrWhere = @StrWhere + ' AND (H.ReserveGoods <> 0)'
	If (@Reserved1 <> 1)
		set @StrWhere = @StrWhere + ' AND (H.ReserveGoods <> 1)'

	If (@Finished0 <> 1)
		set @StrWhere = @StrWhere + ' AND (H.IsFinished <> 0)'
	If (@Finished1 <> 1)
		set @StrWhere = @StrWhere + ' AND (H.IsFinished <> 1)'
		
	If (@SelectedPrdrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrdrs, 'T.ProducerAcntCode')
	If (@FormulaList is not null)
		SET @StrWhere = @StrWhere + ' AND D.FormulaNo in (' + @FormulaList + ')'
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
	SET @StrFrom = '
	pln.tblProduceOrderHdr H
	    inner join pln.tblProduceOrderDtl D on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo and D.DocRowNo=1 -- dont change this line its correct for single row orders only
		left  join pln.tblItemRelations	R on R.BaseProcessID=H.ProcessID and R.BaseProcessNo=H.ProcessNo and R.BaseFiscalYear=H.FiscalYear and R.BaseSerialNo=H.SerialNo
		left  join pln.tblTaskOrderHdr T on T.ProcessID=R.ProcessID and T.ProcessNo=R.ProcessNo and T.FiscalYear=R.FiscalYear and T.SerialNo=R.SerialNo
		left  join pln.tblProduceStepHdr SH	on SH.ProductID=T.ProductID and SH.SerialNo=T.ProduceStepSerialNo
		left  join pln.tblProduceStepDtl SD on SD.ProductID=T.ProductID and SD.SerialNo=T.ProduceStepSerialNo and SD.DocRowNo=1
		left  join prs.tblPersonnelsDtl PR on PR.PersonnelID = H.PlanningManagerID '

	IF (@SelectedProds > 0)
	SET @StrFrom = @StrFrom + '
		inner join
		(
			select distinct ProcessID, ProcessNo, FiscalYear, SerialNo
			from  pln.tblProduceOrderDtl D2
			where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D2.ProductID') + '
		) T1 on T1.ProcessID = H.ProcessID and T1.ProcessNo = H.ProcessNo and T1.FiscalYear = H.FiscalYear and T1.SerialNo = H.SerialNo '
		
	SET @StrSelect = '
	SELECT	H.*, D.ProductID, [pub].[funGetGoodsName](D.ProductID,1) ProductName, D.ProductCount,
			PR.FirstName + '' '' + PR.LastName as PlanningManagerName,
			T.OrderCount, SH.ProduceMethodName, SD.ProduceStepName, 
			T.FiscalYear TaskFiscalYear, T.SerialNo TaskSerialNo,
			T.ProductID as GoodsID, [pub].[funGetGoodsName](T.ProductID,1) GoodsName, H.BaseSerialNo as POBaseSerialNo,
			T.ProducerAcntCode, [acc].[funPartAcntName](T.ProducerAcntCode, 2) ProducerAcntName,
			D.S36, D.S37, D.S38, D.S39, D.S40, D.S41, D.S42, D.S43, D.S44, D.S45, D.S46, D.S47, D.S48
	FROM  ' + @StrFrom + '
	WHERE ' + @StrWhere
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
