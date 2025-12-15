USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/04/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : نمایش درختی مانده سفارش کار
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_TaskOrderRemainTree]
	@TProcSetFr		VarChar(20) = Null,
	@TProcSetTo		VarChar(20) = Null,
	@PProcSetFr		VarChar(20) = Null,
	@PProcSetTo		VarChar(20) = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(4000)
declare @StrFrom	nvarchar(4000)

declare	@TProcessID		Int;
declare	@TProcessNo		Int;
declare	@TFiscalYearFr	Int;
declare	@TSerialNoFr	Int;
declare	@TFiscalYearTo	Int;
declare	@TSerialNoTo	Int;

declare	@PProcessID		Int;
declare	@PProcessNo		Int;
declare	@PFiscalYearFr	Int;
declare	@PSerialNoFr	Int;
declare	@PFiscalYearTo	Int;
declare	@PSerialNoTo	Int;

declare	@LangID		char(1);
declare	@SessionNo	Int; 
declare	@ReportID	Int; 

declare	@FirstStep	varchar(20); 
declare	@LastStep	varchar(20); 

begin
	SET NOCOUNT ON;

	-- init --------------------------------------------------------------------
	if (@RepInfo	Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions	Is Null)	set @RepOptions = '1';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	if (@TProcSetFr Is Not Null)
	begin
		set @TProcessID		= pub.funSplitString(@TProcSetFr, '@', 1);
		set @TProcessNo		= pub.funSplitString(@TProcSetFr, '@', 2);
		set @TFiscalYearFr	= pub.funSplitString(@TProcSetFr, '@', 3);
		set @TSerialNoFr	= pub.funSplitString(@TProcSetFr, '@', 4);
	end

	if (@TProcSetTo Is Not Null)
	begin
		set @TProcessID		= pub.funSplitString(@TProcSetTo, '@', 1);
		set @TProcessNo		= pub.funSplitString(@TProcSetTo, '@', 2);
		set @TFiscalYearTo	= pub.funSplitString(@TProcSetTo, '@', 3);
		set @TSerialNoTo	= pub.funSplitString(@TProcSetTo, '@', 4);
	end

	if (@PProcSetFr Is Not Null)
	begin
		set @PProcessID		= pub.funSplitString(@PProcSetFr, '@', 1);
		set @PProcessNo		= pub.funSplitString(@PProcSetFr, '@', 2);
		set @PFiscalYearFr	= pub.funSplitString(@PProcSetFr, '@', 3);
		set @PSerialNoFr	= pub.funSplitString(@PProcSetFr, '@', 4);
	end

	if (@PProcSetTo Is Not Null)
	begin
		set @PProcessID		= pub.funSplitString(@PProcSetTo, '@', 1);
		set @PProcessNo		= pub.funSplitString(@PProcSetTo, '@', 2);
		set @PFiscalYearTo	= pub.funSplitString(@PProcSetTo, '@', 3);
		set @PSerialNoTo	= pub.funSplitString(@PProcSetTo, '@', 4);
	end

	If (@TFiscalYearFr Is Null)		SET @TSerialNoFr = Null;
	If (@TFiscalYearTo Is Null)		SET @TSerialNoTo = Null;
	If (@TSerialNoFr	Is Null)	SET @TFiscalYearFr = Null;
	If (@TSerialNoTo	Is Null)	SET @TFiscalYearTo = Null;

	If (@PFiscalYearFr Is Null)		SET @PSerialNoFr = Null;
	If (@PFiscalYearTo Is Null)		SET @PSerialNoTo = Null;
	If (@PSerialNoFr	Is Null)	SET @PFiscalYearFr = Null;
	If (@PSerialNoTo	Is Null)	SET @PFiscalYearTo = Null;
	----------------------------------------------------------------------------
	-- where -------------------------------------------------------------------
	select @FirstStep = IsNull(Min(ProduceStepID), 0)
	from pln.tblProduceOrderSteps
	where (ProduceStepID <> '')

	select @LastStep = IsNull(ProduceStepID, 0)
	from pln.tblProduceOrderSteps
	where (ProduceStepID <> '') and (IsFinalStep = 1)

	SET @StrWhere = '(H.ProcessID = 610)'

	if (@TProcSetFr Is Not Null)
		set @StrWhere = @StrWhere + ' and (D.FiscalYear > ' + LTrim(Str(@TFiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@TFiscalYearFr)) + ' and D.SerialNo >= ' + LTrim(Str(@TSerialNoFr)) + '))' 
	if (@TProcSetTo Is Not Null)
		set @StrWhere = @StrWhere + ' and (D.FiscalYear < ' + LTrim(Str(@TFiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@TFiscalYearTo)) + ' and D.SerialNo <= ' + LTrim(Str(@TSerialNoTo)) + '))' 
	if (@TProcSetFr Is Not Null) Or (@TProcSetTo Is Not Null)
		if (@TProcessNo > 0)
			set @StrWhere = @StrWhere + ' and (D.ProcessNo = ' + LTrim(Str(@TProcessNo)) + ')' 

	if (@PProcSetFr Is Not Null)
		set @StrWhere = @StrWhere + ' and (R.BaseFiscalYear > ' + LTrim(Str(@PFiscalYearFr)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@PFiscalYearFr)) + ' and R.BaseSerialNo >= ' + LTrim(Str(@PSerialNoFr)) + '))' 
	if (@PProcSetTo Is Not Null)
		set @StrWhere = @StrWhere + ' and (R.BaseFiscalYear < ' + LTrim(Str(@PFiscalYearTo)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@PFiscalYearTo)) + ' and R.BaseSerialNo <= ' + LTrim(Str(@PSerialNoTo)) + '))' 
	if (@PProcSetFr Is Not Null) Or (@PProcSetTo Is Not Null)
		if (@PProcessNo > 0)
			set @StrWhere = @StrWhere + ' and (R.BaseProcessNo = ' + LTrim(Str(@PProcessNo)) + ')' 

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID')
	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'P.ProductID')
	
	if (@DocDateFr Is Not Null) 
		set @StrWhere = @StrWhere + ' and (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null) 
		set @StrWhere = @StrWhere + ' and (H.DocDate <= ''' + @DocDateTo + ''')'
	----------------------------------------------------------------------------
	-- select ------------------------------------------------------------------
	set @StrSelect = '
	select BaseProductID, ProductID, ProduceStepID, OrderCount, G.GoodsName as ProductName,
			IsNull(Sum(AcceptableCount),0) AcceptCount, IsNull(Sum(UnacceptableCount),0) FailedCount
	from 
	(
		select	P.ProductID as BaseProductID, H.ProductID, H.OrderCount, D.ProduceStepID, D.AcceptableCount, D.UnacceptableCount
		from	pln.tblTaskOrderHdr H
					inner join pln.tblTaskOrderDtl    D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo 
					inner join pln.tblItemRelations   R ON R.ProcessID = H.ProcessID and R.ProcessNo = H.ProcessNo and R.FiscalYear = H.FiscalYear and R.SerialNo = H.SerialNo and R.BaseProcessID = 600
					inner join pln.tblProduceOrderDtl P ON P.ProcessID = R.BaseProcessID and P.ProcessNo = R.BaseProcessNo and P.FiscalYear = R.BaseFiscalYear and P.SerialNo = R.BaseSerialNo and P.DocRowNo = R.BaseDocRowNo
		where ' + @StrWhere + '
	) T
		inner join inv.tblGoodsDtl G on G.GoodsID = T.ProductID and G.LanguageID = ' + @LangID + '
	group by BaseProductID, ProductID, ProduceStepID, OrderCount, G.GoodsName
	order by BaseProductID, ProductID, ProduceStepID, OrderCount '

    print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------
End
GO
