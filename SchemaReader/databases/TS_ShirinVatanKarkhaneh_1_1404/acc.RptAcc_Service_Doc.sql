USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/07/14
-- Viewed By	 : 
-- Last Modified : 1388/06/14
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : �ǁ �ǘ��� �����
-- =============================================
Create PROCEDURE [acc].[RptAcc_Service_Doc]
	@ProcessNo		Int = 1,
	@SerialNoFr		Int = Null,
	@SerialNoTo		Int = Null,
	@ShowRemain		Bit = 0,
	@ExtraParams	NVarChar(200) = 'RepTitle',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 

DECLARE @FiscalYear		SmallInt;
DECLARE @IsSettle bit;
DECLARE @IsShowByCurrency bit;

DECLARE @fval Float;
DECLARE @sval Varchar(50);

BEGIN -- ============================ S T A R T =====================================================

	SET NOCOUNT ON;

	--- init -----------------------------------------------
	--IF (@SortFields Is Null)	SET @SortFields = 'SerialNo'
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	If (@SerialNoFr Is Null)	SET @SerialNoFr = 1;
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNoFr;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @IsShowByCurrency	= pub.funSplitString(@RepInfo, '@', 6);

	SET @FiscalYear = Cast(Right(db_name(), 4) AS SmallInt)

	select @IsSettle = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'InvHasSettlementKind'

	-- =========================
	set @sval = '0'
	set @fval = 0
	set @sval = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TaxOverWorthPercentInSale'), '0')
	if (@sval <> '')
		set @fval = @fval + CAST(@sval as float);
			
	set @sval = '0'
	set @sval = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TollOverWorthPercentInSale'), '0')
	if (@sval <> '')
		set @fval = @fval + CAST(@sval as float);

	DECLARE @Part1End			TinyInt;
	DECLARE @PartStart			TinyInt;
	DECLARE @PartEnd			TinyInt;
	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)


select @PartStart= [acc].[FunGetAcntInfoForRemain](2)
select  @PartEnd=[acc].[FunGetAcntInfoForRemain](3)
		
	--------------------------------------------------------
	--- select ----------------------------------------------
	if (@IsShowByCurrency = 1)
	Begin
	If (@ShowRemain = 1)
		SELECT	H.SerialNo,DocDate,AcntCode,DescHdr,ServiceDiscount, 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaxOverWorthAcntCode TaxOverWorthAcntCode , 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaxOverWorthCost TaxOverWorthCost,
				VchNo,H.RecID,H.SessionNo,DiscountAcntCode,OldSerialNo,VchDate,ExpertCode,H.ProcessID,H.ProcessNo,H.FiscalYear,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TollOverWorthAcntCode TollOverWorthAcntCode,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TollOverWorthCost TollOverWorthCost,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * CashAmount CashAmount,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * ChequeAmount ChequeAmount,
				DiscountPercent,VisitorAcntCode,VisitorPercent,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaskTax TaskTax,
				TaskTaxAcntCode,H.DocStep,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * Amount Amount,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * Price Price,
				BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseStep,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TotalLineDiscount TotalLineDiscount,
				TransferSerialNo,CurrencyTypeID,CurrencyRate,SortSerialNo,SortProcessNo, D.DocRowNo, D.ServiceID, D.DescDtl, D.ServiceQuantity, 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.ServiceAmount ServiceAmount,
				pub.GetCodeName(H.AcntCode, @LangID) AcntName, 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.DiscountDtl DiscountDtl, 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.DiscountDtl DiscountDtl2, 
				D.DiscountPercentDtl,acc.funGetServiceNameFull2(D.ServiceID, @LangID) ServiceName, Cast(0 AS VarChar(20)) AS DebitRemainStr,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * (
					SELECT	IsNull(Sum(Debit - Credit), 0) DebitRemain 
					FROM	acc.tblVoucherDtl VD INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = VD.SerialNo
					INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(VD.AcntCode, 1, @Part1End) = SUBSTRING(b.AcntCode, 1,@Part1End) AND LEN(b.AcntCode) = @Part1End
					WHERE   b.AcntType NOT IN (91, 92) AND VH.VchKind <> 0 AND  (VH.DocRegisterState > 0) AND 
					(substring(VD.AcntCode,@PartStart,@PartEnd )= substring(H.AcntCode,@PartStart,@PartEnd )) AND 
							(
								(VD.DocDate <= H.VchDate) AND Not
								(
									(VD.DocDate = H.VchDate) AND 
									(VD.SourceProcessID = 49) AND 
									(VD.SourceProcessNo = @ProcessNo) AND 
									(VD.SourceFiscalYear = @FiscalYear) AND 
									(VD.SourceSerialNo >= H.SerialNo)
								)
							)
				) As DebitRemain,
				F.EconomicalCode, F.CustomerFirstName + ' ' + F.CustomerLastName AS CustomerName, 
				F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity,F.OrganzationName, 
				F.ZipCode, IsNull(F.Tel, '') Tel, IsNull(F.Mobile, '') Mobile, LH.AreaCode, 
				pub.funGetLocationName(F.LocationID, 1) as LocationName,@IsSettle as HasSettlement,
				Cast(@fval as float) VATPercent,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaxOverWorthCostDtl TaxOverWorthCostDtl,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TollOverWorthCostDtl TollOverWorthCostDtl,
				pub.funGetCurrencyTypesName(H.CurrencyTypeID,@LangID) CurrencyTypeName
		FROM	acc.tblServicesHdr H 
					INNER JOIN	acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
					OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
					LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID AND LD.LanguageID = @LangID 
					LEFT  JOIN pub.tblLocations LH ON LH.LocationID = LD.LocationID 
		WHERE	(H.ProcessNo = @ProcessNo) AND (H.SerialNo >= @SerialNoFr) AND (H.SerialNo <= @SerialNoTo)
	Else
		SELECT	H.SerialNo,DocDate,AcntCode,DescHdr,ServiceDiscount,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaxOverWorthAcntCode TaxOverWorthAcntCode , 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaxOverWorthCost TaxOverWorthCost,
				VchNo,H.RecID,H.SessionNo,DiscountAcntCode,OldSerialNo,VchDate,ExpertCode,H.ProcessID,H.ProcessNo,H.FiscalYear,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TollOverWorthAcntCode TollOverWorthAcntCode,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TollOverWorthCost TollOverWorthCost,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * CashAmount CashAmount,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * ChequeAmount ChequeAmount,
				DiscountPercent,VisitorAcntCode,VisitorPercent,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaskTax TaskTax,
				TaskTaxAcntCode,H.DocStep,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * Amount Amount,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * Price Price,
				BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseStep,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TotalLineDiscount TotalLineDiscount,
				TransferSerialNo,CurrencyTypeID,CurrencyRate,SortSerialNo,SortProcessNo, D.DocRowNo, D.ServiceID, D.DescDtl, D.ServiceQuantity, 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.ServiceAmount ServiceAmount,
				pub.GetCodeName(H.AcntCode, @LangID) AcntName,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.DiscountDtl DiscountDtl, 
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.DiscountDtl DiscountDtl2, 
				D.DiscountPercentDtl, acc.funGetServiceNameFull2(D.ServiceID, @LangID) ServiceName, Cast(0 AS VarChar(20)) AS DebitRemainStr,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * 0 As DebitRemain,
				F.EconomicalCode, F.CustomerFirstName + ' ' + F.CustomerLastName AS CustomerName, 
				F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity,F.OrganzationName, 
				F.ZipCode, IsNull(F.Tel, '') Tel, IsNull(F.Mobile, '') Mobile, LH.AreaCode, 
				pub.funGetLocationName(F.LocationID, 1) as LocationName,
				@IsSettle as HasSettlement, Cast(@fval as float) VATPercent,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TaxOverWorthCostDtl TaxOverWorthCostDtl,
				CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TollOverWorthCostDtl TollOverWorthCostDtl,
				pub.funGetCurrencyTypesName(H.CurrencyTypeID,@LangID) CurrencyTypeName
		FROM	acc.tblServicesHdr H 
					INNER JOIN acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
					OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
					LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID AND LD.LanguageID = @LangID 
					LEFT  JOIN pub.tblLocations LH ON LH.LocationID = LD.LocationID 
		WHERE	(H.ProcessNo = @ProcessNo) AND (H.SerialNo >= @SerialNoFr) AND (H.SerialNo <= @SerialNoTo)
	End
	Else
	Begin
	If (@ShowRemain = 1)
		SELECT	H.SerialNo,DocDate,AcntCode,DescHdr,ServiceDiscount,TaxOverWorthAcntCode,TaxOverWorthCost,VchNo,H.RecID,H.SessionNo,DiscountAcntCode,OldSerialNo,VchDate,ExpertCode,H.ProcessID,H.ProcessNo,H.FiscalYear,TollOverWorthAcntCode,
				TollOverWorthCost,CashAmount,ChequeAmount,DiscountPercent,VisitorAcntCode,VisitorPercent,TaskTax,TaskTaxAcntCode,H.DocStep,Amount,Price,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseStep,TotalLineDiscount,
				TransferSerialNo,CurrencyTypeID,CurrencyRate,SortSerialNo,SortProcessNo, D.DocRowNo, D.ServiceID, D.DescDtl, D.ServiceQuantity, D.ServiceAmount,
				pub.GetCodeName(H.AcntCode, @LangID) AcntName, D.DiscountDtl, D.DiscountDtl DiscountDtl2, D.DiscountPercentDtl,
				acc.funGetServiceNameFull2(D.ServiceID, @LangID) ServiceName, Cast(0 AS VarChar(20)) AS DebitRemainStr,
				(


					SELECT	IsNull(Sum(Debit - Credit), 0) DebitRemain 
					FROM	acc.tblVoucherDtl VD INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = VD.SerialNo
					INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(VD.AcntCode, 1, @Part1End) = SUBSTRING(b.AcntCode, 1,@Part1End) AND LEN(b.AcntCode) = @Part1End
					WHERE   b.AcntType NOT IN (91, 92) AND VH.VchKind <> 0 AND  (VH.DocRegisterState > 0) AND 
					(substring(VD.AcntCode,@PartStart,@PartEnd )= substring(H.AcntCode,@PartStart,@PartEnd )) AND 
							(
								(VD.DocDate <= H.VchDate) AND Not
								(
									(VD.DocDate = H.VchDate) AND 
									(VD.SourceProcessID = 49) AND 
									(VD.SourceProcessNo = @ProcessNo) AND 
									(VD.SourceFiscalYear = @FiscalYear) AND 
									(VD.SourceSerialNo >= H.SerialNo)
								)
							)
				) As DebitRemain,
				F.EconomicalCode, F.CustomerFirstName + ' ' + F.CustomerLastName AS CustomerName, 
				F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity,F.OrganzationName, 
				F.ZipCode, IsNull(F.Tel, '') Tel, IsNull(F.Mobile, '') Mobile, LH.AreaCode, 
				pub.funGetLocationName(F.LocationID, 1) as LocationName,@IsSettle as HasSettlement,
				Cast(@fval as float) VATPercent,
				TaxOverWorthCostDtl,TollOverWorthCostDtl, pub.funGetCurrencyTypesName(H.CurrencyTypeID,@LangID) CurrencyTypeName
		FROM	acc.tblServicesHdr H 
					INNER JOIN	acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
					OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
					LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID AND LD.LanguageID = @LangID 
					LEFT  JOIN pub.tblLocations LH ON LH.LocationID = LD.LocationID 
		WHERE	(H.ProcessNo = @ProcessNo) AND (H.SerialNo >= @SerialNoFr) AND (H.SerialNo <= @SerialNoTo)
	Else
		SELECT	H.SerialNo,DocDate,AcntCode,DescHdr,ServiceDiscount,TaxOverWorthAcntCode,TaxOverWorthCost,VchNo,H.RecID,H.SessionNo,DiscountAcntCode,OldSerialNo,VchDate,ExpertCode,H.ProcessID,H.ProcessNo,H.FiscalYear,TollOverWorthAcntCode,
				TollOverWorthCost,CashAmount,ChequeAmount,DiscountPercent,VisitorAcntCode,VisitorPercent,TaskTax,TaskTaxAcntCode,H.DocStep,Amount,Price,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseStep,TotalLineDiscount,
				TransferSerialNo,CurrencyTypeID,CurrencyRate,SortSerialNo,SortProcessNo, D.DocRowNo, D.ServiceID, D.DescDtl, D.ServiceQuantity, D.ServiceAmount, 
				pub.GetCodeName(H.AcntCode, @LangID) AcntName, D.DiscountDtl, D.DiscountDtl DiscountDtl2, D.DiscountPercentDtl, 
				acc.funGetServiceNameFull2(D.ServiceID, @LangID) ServiceName, Cast(0 AS VarChar(20)) AS DebitRemainStr,
				0 As DebitRemain,
				F.EconomicalCode, F.CustomerFirstName + ' ' + F.CustomerLastName AS CustomerName, 
				F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber, F.NationalIdentity,F.OrganzationName, 
				F.ZipCode, IsNull(F.Tel, '') Tel, IsNull(F.Mobile, '') Mobile, LH.AreaCode, 
				pub.funGetLocationName(F.LocationID, 1) as LocationName,
				@IsSettle as HasSettlement, Cast(@fval as float) VATPercent,
				TaxOverWorthCostDtl,TollOverWorthCostDtl, pub.funGetCurrencyTypesName(H.CurrencyTypeID,@LangID) CurrencyTypeName
		FROM	acc.tblServicesHdr H 
					INNER JOIN acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
					OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
					LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID AND LD.LanguageID = @LangID 
					LEFT  JOIN pub.tblLocations LH ON LH.LocationID = LD.LocationID 
		WHERE	(H.ProcessNo = @ProcessNo) AND (H.SerialNo >= @SerialNoFr) AND (H.SerialNo <= @SerialNoTo)
	End
END
GO
