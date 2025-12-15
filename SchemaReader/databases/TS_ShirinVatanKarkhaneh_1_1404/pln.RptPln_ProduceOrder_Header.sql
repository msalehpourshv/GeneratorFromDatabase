USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1390/06/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش سربرگ برگه های سفارش تولید
-- ==============================================
Create PROCEDURE [pln].[RptPln_ProduceOrder_Header]
	@ProcessID			int = 600,  -- default is sale
	@ProcessNo			int = null,
	@FiscalYearFr		int = null,
	@SerialNoFr			int = null,
	@FiscalYearTo		int = null,
	@SerialNoTo			int = null,
	@DocDateFr			char(10) = null,
	@DocDateTo			char(10) = null,
	@CnfDateFr			char(10) = null,
	@CnfDateTo			char(10) = null,
	@SelectedProds		int = null,
	@SelectedGoods		int = null,
	@PlanningMgrID		int = null,
	@ProduceStepList	varchar(20) = null,
	@TitleMask			nvarchar(50) = null,  
	@DocDescMask		nvarChar(100) = null, 
	@SortFields			nvarChar(100) = null,
	@RepOptions			varChar(10) = '111111',  -- bit array options
	@RepInfo			nvarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);

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
	if (@ProcessID	Is Null)	set @ProcessID = 600;
	if (@ProcessNo	Is Null)	set @ProcessNo = 0;

	IF (@SelectedGoods Is Null)	set @SelectedGoods = 0;
	IF (@SelectedProds Is Null)	set @SelectedProds = 0;
	IF (@ProduceStepList = '')	set @ProduceStepList = null;

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
	SET @StrWhere = '(H.ProcessID = ' + LTrim(Str(@ProcessID)) + ')'

	If (@ProcessNo > 0)
		set @StrWhere = @StrWhere + ' AND (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	if (@ProduceStepList is not null)
		set @StrWhere = @StrWhere + ' AND (H.ProduceStepID in (' + @ProduceStepList + '))'

	if (@PlanningMgrID is not null)
		set @StrWhere = @StrWhere + ' AND (H.PlanningManagerID = ''' + @PlanningMgrID + ''')'

	If (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	If (@CnfDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.ConfirmDate >= ''' + @CnfDateFr + ''')'
	If (@CnfDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.ConfirmDate <= ''' + @CnfDateTo + ''')'

	If (@DocDescMask Is Not Null)
		set @StrWhere = @StrWhere + ' AND (Replace(H.DocDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DocDescMask, ' ', '')) + '%'')'

	If (@TitleMask Is Not Null)
		set @StrWhere = @StrWhere + ' AND (Replace(H.Title, '' '', '''') LIKE N''%' + RTrim(Replace(@TitleMask, ' ', '')) + '%'')'

	if (@Confirmed0 <> 1 And @Confirmed1 = 1)
		set @StrWhere = @StrWhere + ' AND (H.IsConfirmed <> 0)'
	if (@Confirmed1 <> 1 And @Confirmed0 = 1)
		set @StrWhere = @StrWhere + ' AND (H.IsConfirmed <> 1)'
		
	--if (@Confirmed1 <> 1 And @Confirmed0 <> 1)
	--	set @StrWhere = @StrWhere + ' AND (H.IsConfirmed <> 1 And H.IsConfirmed <> 0)'		

	if (@Reserved0 <> 1 And @Reserved1 = 1)
		set @StrWhere = @StrWhere + ' AND (H.ReserveGoods <> 0)'
	if (@Reserved1 <> 1 And @Reserved0 = 1)
		set @StrWhere = @StrWhere + ' AND (H.ReserveGoods <> 1)'
		
	--if (@Reserved1 <> 1 And @Reserved0 <> 1)
	--	set @StrWhere = @StrWhere + ' AND (H.ReserveGoods <> 1 And H.ReserveGoods <> 0)'		

	if (@Finished0 <> 1 And @Finished1 = 1)
		set @StrWhere = @StrWhere + ' AND (H.IsFinished <> 0)'
	if (@Finished1 <> 1 And @Finished0 = 1)
		set @StrWhere = @StrWhere + ' AND (H.IsFinished <> 1)'
		
	--if (@Finished1 <> 1 And @Finished0 <> 1)
	--	set @StrWhere = @StrWhere + ' AND (H.IsFinished <> 1 And H.IsFinished <> 0)'		
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
	Set @StrFrom = 'pln.tblProduceOrderHdr H
		left join prs.tblPersonnelsDtl PR on PR.PersonnelID = H.PlanningManagerID
		left join pln.tblProduceOrderStepsDtl PS on PS.ProduceStepID = H.ProduceStepID
		left join pln.tblItemRelations I on I.ProcessID=H.ProcessID and I.ProcessNo=H.ProcessNo and I.FiscalYear=H.FiscalYear and I.SerialNo=H.SerialNo '

	if (@SelectedProds > 0)
	Set @StrFrom = @StrFrom + '
		INNER JOIN 
		(
			select distinct ProcessID, ProcessNo, FiscalYear, SerialNo
			from  pln.tblProduceOrderDtl D2
			where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D2.ProductID') + '
		) T1 on T1.ProcessID = H.ProcessID and T1.ProcessNo = H.ProcessNo and T1.FiscalYear = H.FiscalYear and T1.SerialNo = H.SerialNo '

--	if (@SelectedGoods > 0)
--	Set @StrFrom = @StrFrom + '
--		inner join #tbl_RptPln_ProduceOrderHeader_G T2 on T2.ProcessID = H.ProcessID and T2.ProcessNo = H.ProcessNo and T2.FiscalYear = H.FiscalYear and T2.SerialNo = H.SerialNo'
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
--	if (@SelectedGoods > 0)
--	begin
--		insert into #tbl_RptPln_ProduceOrderHeader_G
--		exec [prd].[RptPrd_ProductGoods_All_Stock] 0, 0, @UserID, null, @SortFields, '10100', @RepInfoX
--	end

	SET @StrSelect = '
	SELECT	 H.ProcessID	,H.ProcessNo	,H.FiscalYear	,H.SerialNo	,H.DocDate	,H.DocStep	,H.ProduceStepID	,H.DocDesc	,H.PlanningManagerID	
	,H.ConfirmDate	,H.ConfirmerAcntCode	,H.RecID	,H.SessionNo	,isnull(I.BaseProcessID,0)	BaseProcessID,isnull(I.BaseProcessNo,0)	BaseProcessNo
	,isnull(I.BaseFiscalYear,0)	BaseFiscalYear,isnull(I.BaseSerialNo,0)	BaseSerialNo,H.IsConfirmed	,H.Title	,H.ReserveGoods	,H.IsFinished	,H.BaseDocType	,H.SgnSN1	,H.SgnSN2	,H.SgnSN3	,H.SgnSN4	,H.SgnSN5	
	,H.StepDefault	,H.FormulaDefault	,H.ProductOnly	,PR.FirstName + '' '' + PR.LastName as PlanningManagerName, PS.ProduceStepName,
		    (Select Sum(ProductCount) From pln.tblProduceOrderDtl D Where H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And 
			                       		   H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo) As ProductCount
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
