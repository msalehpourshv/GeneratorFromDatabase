USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/06/31
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_InsurList]
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = '1393/09/01',
	@DocDateTo		Char(10) = '1393/09/30',
	@ExpDateFr		char(10) = null,
	@ExpDateTo		char(10) = null,
	@InsuranceID	varchar(20) = '02',
	@InsuranceTypeID	varchar(20) = '0201',
	@RepOptions		VarChar(10) = '111011111',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);
Declare @OrderDateFieldName	 VarChar(20);

DECLARE	@LangID		 Char(1);
DECLARE	@Month		 Char(2);
DECLARE	@SessionNo	 Int; 
DECLARE	@ReportID	 Int;

DECLARE	@IsConfirmY	Bit; 
DECLARE	@IsConfirmN	Bit; 

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @Month	= pub.funSplitString(@RepOptions, '@', 2);

	SET @IsConfirmY	= Substring(@RepOptions, 1, 1)
	SET @IsConfirmN	= Substring(@RepOptions, 2, 1)
	
	if @DocDateFr<>'' or @DocDateTo<>''
		begin 
			set @OrderDateFieldName='H.DocDate'
		end
	
	if @ExpDateFr<>'' or @ExpDateTo<>''
		begin 
			set @OrderDateFieldName='H.PrescriptionDate'
		end
		
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = '(SELECT COUNT(*) from phr.tblReciptionDtl
	where  phr.tblReciptionDtl.SerialNo=H.SerialNo and 
	phr.tblReciptionDtl.InsurancePercent>0 AND 
	phr.tblReciptionDtl.InsurancePortion>0)>0
	AND	 (H.ReciptionTypeID=1) AND (H.Payed=1) AND (H.Deleted=0) 
	AND H.InsurancePortionSum >0 AND H.ConfirmType IN (0,1,2,5) '

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
		
	IF (@ExpDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.PrescriptionDate >= ''' + @ExpDateFr + ''')'
	IF (@ExpDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.PrescriptionDate <= ''' + @ExpDateTo + ''')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If (@InsuranceID is not null)
		SET @StrWhere = @StrWhere + ' AND (H.InsuranceID = ''' + @InsuranceID + ''')'

	If (@InsuranceTypeID is not null)
		SET @StrWhere = @StrWhere + ' AND (H.InsuranceTypeID = ''' + @InsuranceTypeID + ''')'

	--if (@IsConfirmY = 0)
	--	Set @StrWhere = @StrWhere + ' AND (H.IsConfirm <> 1)'
	--if (@IsConfirmN = 0)
	--	Set @StrWhere = @StrWhere + ' AND (H.IsConfirm <> 0)'


	IF (@Month Is Not Null AND @Month <> '')
		SET @StrWhere = @StrWhere + ' AND (H.Month = ''' + @Month + ''')'


		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT H.*, I.InsuranceName, T.InsuranceTypeName,C.InsuranceTypeConditions,
		(
			select sum(D.TotalPrice)
			from phr.tblReciptionDtl D 
			where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
		and D.InsurancePercent>0 and D.InsurancePortion>0 and D.DrugKind in (1,2)
		
		) TotalPrice,
		(
			select sum(PriceDiff*Qty) 
			from phr.tblReciptionDtl D 
			where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
		and D.InsurancePercent>0 and D.InsurancePortion>0 and D.DrugKind in (1,2)
		
		) DifPrice
		
	FROM phr.tblReciptionHdr H
			inner join phr.tblInsuranceDtl I on I.InsuranceID=H.InsuranceID
			inner join phr.tblInsuranceTypeDtl T on T.InsuranceTypeID=H.InsuranceTypeID
			LEFT join phr.tblContractInsuranceHdr C on C.InsuranceID=H.InsuranceID AND C.InsuranceTypeID=H.InsuranceTypeID
	WHERE  ' + @StrWhere + '
	ORDER BY '+ @OrderDateFieldName +', H.SerialNo'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
