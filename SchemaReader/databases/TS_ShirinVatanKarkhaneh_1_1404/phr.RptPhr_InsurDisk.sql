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
create PROCEDURE [phr].[RptPhr_InsurDisk]
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@InsuranceID		varchar(20) = null,
	@InsuranceTypeID	varchar(20) = null,
	@RepOptions			VarChar(10) = '111011111',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1',
	@DateFilterType		TINYINT = 1,
	@Month				char(2)
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@IsConfirmY	Bit; 
DECLARE	@IsConfirmN	Bit; 
DECLARE	@OrderBy	Bit; 
DECLARE	@OrderByFields	varchar(100); 

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @IsConfirmY	= Substring(@RepOptions, 1, 1)
	SET @IsConfirmN	= Substring(@RepOptions, 2, 1)
	SET @OrderBy	= Substring(@RepOptions, 3, 1)
	

	-- Where Clause -----------------------------------------
	Select @StrWhere = '(D.InsurancePrice >0) and(D.InsurancePercent>0) and (D.InsurancePortion>0) 
				AND (D.DrugKind IN (1,2)) AND (H.ReciptionTypeID=1) AND (H.Payed=1) AND (H.DisketNo=0)
				 AND (H.Deleted=0) AND H.InsurancePortionSum >0 AND H.ConfirmType IN (0,1,2,5) '

	IF @DateFilterType=1
	BEGIN
		IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
	END
	
	IF (@DateFilterType =2 or  @DateFilterType =3)
	BEGIN
		IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.PrescriptionDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (H.PrescriptionDate <= ''' + @DocDateTo + ''')'
	END
		
	If (@InsuranceID is not null)
		SET @StrWhere = @StrWhere + ' AND (H.InsuranceID = ''' + @InsuranceID + ''')'
	If (@InsuranceTypeID is not null)
		SET @StrWhere = @StrWhere + ' AND (H.InsuranceTypeID = ''' + @InsuranceTypeID + ''')'

	if (@IsConfirmY = 0)
		Set @StrWhere = @StrWhere + ' AND (H.IsConfirm <> 1)'
	if (@IsConfirmN = 0)
		Set @StrWhere = @StrWhere + ' AND (H.IsConfirm <> 0)'

	
	If (@Month is not null)
		SET @StrWhere = @StrWhere + ' AND (H.Month = ''' + @Month + ''')'
	
	-- Select Clause -------------------------------------------
 IF @DateFilterType=1
 begin
	
	if @OrderBy ='1'
		set @OrderByFields=',cast(H.InsuranceOrder as float)'
		 
	if @OrderBy ='0'
		set @OrderByFields=''

	SET @StrSelect = '
	SELECT D.*, H.IllInsuranceNo, H.PrescriptionDate, H.PageNo, H.DoctorNo, 
			H.ExpDate as InsuranceExpDate, isnull(I.PrescripionTypeCode,'''')as PrescripionTypeCode,
			 H.DocDate, G.NationalCode,G.GenericID,
			isnull(P.Prefix, '''') Prefix, isnull(P.Postfix, '''') Postfix,
			isnull(CH.ProficiencyCode, '''') ProficiencyCode, isnull(CH.ApplyDate, '''') ApplyDate,
			isnull(CH.ProficiencyBeforeAmount, 0) ProficiencyBeforeAmount,
			isnull(CH.ProficiencyCurrentAmount, 0) ProficiencyCurrentAmount,H.InsuranceOrder
	FROM phr.tblReciptionHdr H
			inner join phr.tblReciptionDtl D on D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
			inner join phr.tblContractInsuranceHdr C on C.InsuranceID=H.InsuranceID and C.InsuranceTypeID=H.InsuranceTypeID
			inner join inv.tblGoods G on G.GoodsID=D.GoodsID
			left  join phr.tblInsurancePrePostfixDtl P on P.InsuranceID=H.InsuranceID and P.ProficiencyTypeID=H.ProficiencyTypeID
			left  join phr.tblContractInsuranceHdr CH on CH.InsuranceID=H.InsuranceID and CH.InsuranceTypeID=H.InsuranceTypeID
			LEFT JOIN phr.tblInsurance I ON I.InsuranceID=H.InsuranceID
	WHERE   ' + @StrWhere + '
	ORDER BY H.DocDate'+ @OrderByFields +', H.SerialNo'
 end
	
IF (@DateFilterType =2 or  @DateFilterType =3)
 begin
 
 if @OrderBy ='1'
		set @OrderByFields=',cast(H.InsuranceOrder as float)'
		 
	if @OrderBy ='0'
		set @OrderByFields=''
 
	SET @StrSelect = '
	SELECT D.*, H.IllInsuranceNo, H.PrescriptionDate, H.PageNo, H.DoctorNo, 
			H.ExpDate as InsuranceExpDate, isnull(I.PrescripionTypeCode,'''')as PrescripionTypeCode,
			 H.DocDate, G.NationalCode,G.GenericID,
			isnull(P.Prefix, '''') Prefix, isnull(P.Postfix, '''') Postfix,
			isnull(CH.ProficiencyCode, '''') ProficiencyCode, isnull(CH.ApplyDate, '''') ApplyDate,
			isnull(CH.ProficiencyBeforeAmount, 0) ProficiencyBeforeAmount,
			isnull(CH.ProficiencyCurrentAmount, 0) ProficiencyCurrentAmount,H.InsuranceOrder
	FROM phr.tblReciptionHdr H
			inner join phr.tblReciptionDtl D on D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
			inner join phr.tblContractInsuranceHdr C on C.InsuranceID=H.InsuranceID and C.InsuranceTypeID=H.InsuranceTypeID
			inner join inv.tblGoods G on G.GoodsID=D.GoodsID
			left  join phr.tblInsurancePrePostfixDtl P on P.InsuranceID=H.InsuranceID and P.ProficiencyTypeID=H.ProficiencyTypeID
			left  join phr.tblContractInsuranceHdr CH on CH.InsuranceID=H.InsuranceID and CH.InsuranceTypeID=H.InsuranceTypeID
			LEFT JOIN phr.tblInsurance I ON I.InsuranceID=H.InsuranceID
	WHERE   ' + @StrWhere + '
	ORDER BY H.PrescriptionDate'+ @OrderByFields +', H.SerialNo'
 end
 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
