USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/09/03
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
Create PROCEDURE [acc].[RptAcc_Contracts]
	@SerialNoFr		int = null,
	@SerialNoTo		int = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@ContractDateFr	char(10) = null,
	@ContractDateTo	char(10) = null,
	@StartDateFr	char(10) = null,
	@StartDateTo	char(10) = null,
	@ProjectName	nvarchar(50) = null,
	@ProjectNo		nvarchar(50) = null,
	@ContractTitle	nvarchar(50) = null,
	@ContractNo		nvarchar(50) = null,
	@Contractor		nvarchar(50) = null,
	@EngineerViewer	nvarchar(50) = null,
	@Adviser		nvarchar(50) = null,
	@Employer		nvarchar(50) = null,
	@PlanManager	nvarchar(50) = null,
	@ContractTypeID varchar(20) = null,
	@AmountFr		bigint = null,
	@AmountTo		bigint = null,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@SortFields		nvarchar(100) = Null,
	@RepOptions		varchar(10) = '0000', -- bit array options
	@RepInfo		varchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE	@LangID		Int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@CheckConfirm	bit; 
DECLARE	@Confirm1	bit; 
DECLARE	@Confirm2	bit; 
DECLARE	@Confirm3	bit; 

BEGIN -- ====================================================
	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '11111111';
	IF (@SortFields Is Null)	SET @SortFields = 'SerialNo';

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	SET @CheckConfirm	= Substring(@RepOptions, 1, 1)
	SET @Confirm1		= Substring(@RepOptions, 2, 1)
	SET @Confirm2		= Substring(@RepOptions, 3, 1)
	SET @Confirm3		= Substring(@RepOptions, 4, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	set @StrWhere = '(1=1)' 

	if (@CheckConfirm = 1)
	begin
		SET @StrWhere = @StrWhere + ' AND (Confirm1 = ' + CAST(@Confirm1 as varchar(1)) + ')'
		SET @StrWhere = @StrWhere + ' AND (Confirm2 = ' + CAST(@Confirm2 as varchar(1)) + ')'
		SET @StrWhere = @StrWhere + ' AND (Confirm3 = ' + CAST(@Confirm3 as varchar(1)) + ')'
	end
	
	print @SessionNo
	print @ReportID
	print @SelectedAcnt1
	
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'CustomerAcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'CustomerAcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'CustomerAcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'CustomerAcntCode')

	If (@SerialNoFr is not null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')' 
	If (@SerialNoTo is not null)
		SET @StrWhere = @StrWhere + ' AND (SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 

	If (@DocDateFr is not null)
		SET @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DocDateFr + ''')' 
	If (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDateTo + ''')' 

	If (@ContractDateFr is not null)
		SET @StrWhere = @StrWhere + ' AND (ContractDate >= ''' + @ContractDateFr + ''')' 
	If (@ContractDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (ContractDate <= ''' + @ContractDateTo + ''')' 
	
	If (@StartDateFr is not null)
		SET @StrWhere = @StrWhere + ' AND (StartDate >= ''' + @StartDateFr + ''')' 
	If (@StartDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (StartDate <= ''' + @StartDateTo + ''')' 

	If (@AmountFr is not null)
		SET @StrWhere = @StrWhere + ' AND (EstimateAmount >= ' + LTrim(Str(@AmountFr)) + ')' 
	If (@AmountTo is not null)
		SET @StrWhere = @StrWhere + ' AND (EstimateAmount <= ' + LTrim(Str(@AmountTo)) + ')' 

	If (@ContractTypeID is not null) and (@ContractTypeID <> '')
		SET @StrWhere = @StrWhere + ' AND (H.ContractTypeID = ''' + LTrim(@ContractTypeID) + ''')' 
		
	If (@ProjectName is not null)
		SET @StrWhere = @StrWhere + ' AND (ProjectName like N''%' + LTrim(@ProjectName) + '%'')' 
	If (@ProjectNo is not null)
		SET @StrWhere = @StrWhere + ' AND (ProjectNo like N''%' + LTrim(@ProjectNo) + '%'')' 
	If (@ContractTitle is not null)
		SET @StrWhere = @StrWhere + ' AND (ContractTitle like N''%' + LTrim(@ContractTitle) + '%'')' 
	If (@ContractNo is not null)
		SET @StrWhere = @StrWhere + ' AND (ContractNo like N''%' + LTrim(@ContractNo) + '%'')' 
	If (@Contractor is not null)
		SET @StrWhere = @StrWhere + ' AND (Contractor like N''%' + LTrim(@Contractor) + '%'')' 
	If (@EngineerViewer is not null)
		SET @StrWhere = @StrWhere + ' AND (EngineerViewer like N''%' + LTrim(@EngineerViewer) + '%'')' 
	If (@Adviser is not null)
		SET @StrWhere = @StrWhere + ' AND (Adviser like N''%' + LTrim(@Adviser) + '%'')' 
	If (@Employer is not null)
		SET @StrWhere = @StrWhere + ' AND (Employer like N''%' + LTrim(@Employer) + '%'')' 
	If (@PlanManager is not null)
		SET @StrWhere = @StrWhere + ' AND (PlanManager like N''%' + LTrim(@PlanManager) + '%'')' 
		
	SET @StrSelect = '
	SELECT	H.*, pub.GetCodeName(CustomerAcntCode, 1) CustomerAcntName, C.ContractTypeName , ((H.AdditionalPercent * H.PrimitiveCost) /100 )as AdditionalCost
	FROM	acc.tblContratctsHdr H
				left join cnt.tblContractTypeDtl C on C.ContractTypeID = H.ContractTypeID
	WHERE 	' + @StrWhere
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
END
GO
