USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : zia
-- Create date   : 1389/03/17
-- Viewed By	 : 
-- Last Modified : zia
-- Last Modifier : 1391/03/21
-- Description	 : صورت وضعیت پخش      
-- =============================================
--EXEC [sal].[RptSale_DistributeState] 96, 2, '0@1@0@0@null@null@0@0'
Create PROCEDURE [sal].[RptSale_DistributeState]
	@FiscalYear		int = null,
	@SerialNo		int = null,
	@ExtraParams	NVarChar(500) = '0@1@0@0@null@null@0@0'
	
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(MAX);
DECLARE @StrSelect2	NVarChar(4000);
DECLARE @StrSelect3	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrSort	NVarChar(1000);

DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @FiscalTo	Int;
DECLARE @SerialTo	Int;

DECLARE @DocDateFr	char(10);
DECLARE @DocDateTo	char(10);

DECLARE @Remain1	Bit;
DECLARE @Remain2	Bit;
DECLARE @Remain3	Bit;
DECLARE @Remain4	Bit;

DECLARE @Eqal		nvarchar(500);

DECLARE @SortByAcntCode	Bit;
declare @Dst_HasBranch	bit;
declare @CountPartRemain tinyint
declare @NoInSettlement tinyint
Begin
	
	Set @SortByAcntCode = 0;
	
	set @FiscalTo = 0;
	set @SerialTo = 0;
	SET @CountPartRemain=0;

	if (@FiscalYear is null) or (@SerialNo is null)
	begin
		set @FiscalYear = 0;
		set @SerialNo = 0;
	end

	SET @Remain1		= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @Remain2		= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Remain3		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Remain4		= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	
	SET @DocDateFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @DocDateTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @FiscalTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @SerialTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @SortByAcntCode	= LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @Dst_HasBranch	= LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @NoInSettlement	= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	
	if (@FiscalTo = 0) set  @FiscalTo = @FiscalYear
	if (@SerialTo = 0) set  @SerialTo = @SerialNo

	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	SET @Eqal = '(1=1)'
	
	IF @SortByAcntCode = 1
		Set @StrSort = 'H.AcntCode, DD.DocRowNo'
	ELSE
		Set @StrSort = 'DD.DocRowNo'
	IF (@Remain1 = 1)
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain2 = 1) AND @CountPartRemain = 1
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain3 = 1) AND @CountPartRemain = 2
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain4 = 1) AND @CountPartRemain = 3
		SET @CountPartRemain = @CountPartRemain + 1

		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
		BEGIN
				SET @Eqal = @Eqal + ' AND VD.AcntCode=H.AcntCode'
		END
		ELSE
		BEGIN
		
			IF (@Remain1 = 1)
				SET @Eqal = @Eqal + ' AND Substring(VD.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
			IF (@Remain2 = 1)
				SET @Eqal = @Eqal + ' AND Substring(VD.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
			IF (@Remain3 = 1)
				SET @Eqal = @Eqal + ' AND Substring(VD.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
			IF (@Remain4 = 1)
				SET @Eqal = @Eqal + ' AND Substring(VD.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
		
		END
	
	set @StrWhere = '(1=1)'

	IF (@DocDateFr <> 'null')
		SET @StrWhere = @StrWhere + ' AND (DH.DocDate>=''' + @DocDateFr + ''')'
	IF (@DocDateTo <> 'null')
		SET @StrWhere = @StrWhere + ' AND (DH.DocDate<=''' + @DocDateTo + ''')'

	If (@FiscalYear	> 0)
		SET @StrWhere = @StrWhere + ' AND (H.BaseDistributionFiscalYear>' + LTrim(Str(@FiscalYear)) + ' OR (H.BaseDistributionFiscalYear=' + LTrim(Str(@FiscalYear)) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	If (@FiscalTo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.BaseDistributionFiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (H.BaseDistributionFiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(Str(@SerialTo)) + ')) '

	IF @Dst_HasBranch = 1
	Begin		
		SET @StrWhere = @StrWhere + ' And IsNull(DH.BranchManagerConfirmed, 0) = 1'
	End
	
	-- ===================================
	SET @StrSelect = N'
	SELECT	H.AcntCode, pub.GetCodeName(H.AcntCode, 1) AcntName, DH.DocDesc, 
			pub.funFarsiDate(GETDATE()) PrintDate,
			H.FiscalYear, H.SerialNo, H.DriverID, H.DistributerID1, H.DistributerID2,
			DV.FirstName + '' '' + DV.LastName As DriverName, D.VehicleNo, DH.DocDate as DistDate, DH.DistributDate,
			PR1.PersonnelName DistributerName1,IsNull(PR1.Mobile ,'''') as DistributerMobile1, DH.SerialNo As DistSerialNo,
			PR2.PersonnelName DistributerName2,IsNull(PR2.Mobile ,'''') as DistributerMobile2, H.TotalLineDiscount, H.Discount, H.Discount2+H.Discount3 Discount2 ,
			(Select Sum(GoodsPrice * GoodsQuantity) From inv.tblStorageDocsDtl 
			 Where ProcessID = H.ProcessID and ProcessNo = H.ProcessNo and FiscalYear = H.FiscalYear and SerialNo = H.SerialNo) + SidePriceSum FinalPrice,
			(Select Sum(SubUnitPrice * SubUnitQuantity) From inv.tblStorageDocsDtl 
			 Where ProcessID = H.ProcessID and ProcessNo = H.ProcessNo and FiscalYear = H.FiscalYear and SerialNo = H.SerialNo) + SidePriceSum FinalPrice2,
			 H.TaxOverWorthCost, H.TollOverWorthCost,
			(
				Select	IsNull(Sum(Debit-Credit),0) Debit 
				From	acc.tblVoucherDtl VD 
				Inner Join acc.tblVoucherHdr VH ON VH.SerialNo=VD.SerialNo
				Where   (VH.DocRegisterState > 0) AND (' + @Eqal + ') AND 
						(
							(VD.DocDate<=H.VchDate) AND Not
							(
								(VD.DocDate=H.VchDate) AND 
								(VD.SourceProcessID=90) AND 
								(VD.SourceProcessNo=H.ProcessNo) AND 
								(VD.SourceFiscalYear=H.FiscalYear) AND 
								(VD.SourceSerialNo>=H.SerialNo)
							)
						)
			) DebitRemain, 
			(
				Select --IsNull(Sum((GoodsPrice * GoodsQuantity) + (SH.TaxOverWorthCost + SH.TollOverWorthCost) - (SH.TotalLineDiscount + SH.Discount + SH.Discount2+ SH.Discount3)),0)
					 IsNull(Sum(SH.Price + (SH.TaxOverWorthCost + SH.TollOverWorthCost) - (SH.TotalLineDiscount + SH.Discount + SH.Discount2+ SH.Discount3)),0)
				From inv.tblStorageDocsHdr SH
				--Inner Join inv.tblStorageDocsDtl SD ON SD.ProcessID = SH.ProcessID And SD.ProcessNo = SH.ProcessNo And 
				--									   SD.FiscalYear = SH.FiscalYear And SD.SerialNo = SH.SerialNo
				Inner Join sal.tblDistributionsDtl DD 
				ON DD.BaseSaleRetProcessID = SH.ProcessID And DD.BaseSaleRetProcessNo = SH.ProcessNo And 
				   DD.BaseSaleRetFiscalYear = SH.FiscalYear And DD.BaseSaleRetSerialNo = SH.SerialNo And
				   DD.BaseSaleProcessID = H.ProcessID And DD.BaseSaleProcessNo = H.ProcessNo And 
				   DD.BaseSaleFiscalYear = H.FiscalYear And DD.BaseSaleSerialNo = H.SerialNo
				Where SH.ProcessID = 100 And SH.ProcessNo = 10
			) SaleRetPrice,
			(
			 Select IsNull(Sum(Amount),0)
			 From trs.tblPayHdr PH
			 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
										    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
										    PD.PayTypeID Not In (6, 26)
			 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
				   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo --And PH.DocDate <= H.DocDate
			) CashReceiptAmount,
			(Select IsNull(Sum(Amount),0)
			 From trs.tblPayHdr PH
			 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
										    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
										    PD.PayTypeID In (6, 26)
			 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
				   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo --And PH.DocDate <= H.DocDate
			) ChequeReceiptAmount,
			ST.SaleTypeName, F.VisitPathID1, F.VisitPathID2, F.VisitPathID3, F.VisitPathID4, F.Address1 Address, 
			F.Tel, F.Mobile, F.Fax, F.OtherTels, F.SaleCash, 
			F.CustomerFirstName, F.CustomerLastName, F.CustomerFirstName +'' ''+ F.CustomerLastName CustomerFullName '
	SET @StrSelect2 = N'	FROM  inv.vwStorageDocsHdr H'	
	if @NoInSettlement=1
		SET @StrSelect2 += N'  
			inner join  (
						select ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblStorageDocsHdr  where ProcessID=90 
							except
						select BaseSaleProcessID,BaseSaleProcessNo,BaseSaleFiscalYear,BaseSaleSerialNo from trs.tblSettlementDtl ) SH
				on SH.ProcessID = H.ProcessID and SH.ProcessNo = H.ProcessNo and SH.FiscalYear = H.FiscalYear and SH.SerialNo = H.SerialNo  '
	SET @StrSelect2 += N' LEFT  JOIN pub.tblDriversDtl DV on H.DriverID = DV.DriverID and LanguageID = 1
	LEFT  JOIN pub.tblDrivers D on H.DriverID = D.DriverID 
	LEFT  JOIN prs.vwPersonnels PR1 on H.DistributerID1 = PR1.PersonnelID 
	LEFT  JOIN prs.vwPersonnels PR2 on H.DistributerID2 = PR2.PersonnelID 
	LEFT  JOIN sal.tblDistributionsHdr DH on DH.ProcessID = H.BaseDistributionProcessID and DH.SerialNo = H.BaseDistributionSerialNo
	LEFT  JOIN sal.tblDistributionsDtl DD on DD.BaseSaleProcessID = H.ProcessID and DD.BaseSaleProcessNo = H.ProcessNo and DD.BaseSaleFiscalYear = H.FiscalYear and DD.BaseSaleSerialNo = H.SerialNo
	LEFT  JOIN sal.tblSaleTypesDtl ST on ST.SaleTypeID = H.SaleTypeID
	OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F
	WHERE (H.ProcessID = 90) and ' + @StrWhere + ' 
	ORDER BY ' + @StrSort

	-- ===========================				
	PRINT @StrSelect;
	PRINT @StrSelect2;
	SET @StrSelect = @StrSelect + @StrSelect2;
	EXEC sp_executesql @StrSelect;
	-- ===========================				
END
GO
