USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/08/30
-- Viewed By	 : 
-- Last Modified : 1391/09/30
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
CREATE PROCEDURE [prd].[RptPrd_WagesDocs]
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SelectedGoods	int = 0,
	@WageAmountFr	int = -1,
	@WageAmountTo	int = -1,
	@SerialNoFr		int = null,
	@SerialNoTo		int = null,
	@DateFr			char(10) = null,
	@DateTo			char(10) = null,
	@ContractID		varchar(20) = null,
	@RepOptions		VarChar(20) = '',
	@RepInfo		varchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@ProcessID	int; 
Begin
	SET NOCOUNT ON;
	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ProcessID	= substring(@RepOptions, 1,2);

	SET @StrWhere = '(1=1)'
	
	If (@ProcessID is not null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID =' + LTrim(Str(@ProcessID)) + ')' 

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')' 
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 

	If (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DateFrom >= ''' + @DateFr + ''')' 
	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DateTo <= ''' + @DateTo + ''')' 

	If (@WageAmountFr > -1)
		SET @StrWhere = @StrWhere + ' AND (D.WageAmount >= ' + LTrim(Str(@WageAmountFr)) + ')' 
	If (@WageAmountTo > -1)
		SET @StrWhere = @StrWhere + ' AND (D.WageAmount <= ' + LTrim(Str(@WageAmountTo)) + ')' 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.ProducerAcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.ProducerAcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.ProducerAcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.ProducerAcntCode')

	set @StrSelect = '
	SELECT	H.*, D.RowNo, D.DocRowNo, D.GoodsID, D.GoodsQuantity, D.WageAmount,
			[pub].[funGetGoodsName](D.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, 
			[pub].[funGetGoodsUnitName] (D.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As UnitName, pub.GetUserName(H.SessionNo) AS UserName,
			pub.GetCodeName(H.ProducerAcntCode, 1) ProducerAcntName,D.EnterKind
	FROM	prd.tblProducersWageDtl D 
	INNER JOIN prd.tblProducersWageHdr H ON H.ProducerAcntCode = D.ProducerAcntCode AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
	WHERE 	' + @StrWhere + '
	ORDER BY H.ProducerAcntCode, H.SerialNo'
	
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
