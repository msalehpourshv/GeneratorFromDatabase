USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/02/29
-- Viewed By	 : 
-- Last Modified : 1390/05/03
-- Last Modifier : TakroSystem\Zia
-- Description	 : سن تسویه فروش
-- ==============================================
Create PROCEDURE [sal].[RptSale_SettleAge]
	@ProcessNo		Int = 1,
	@FiscalFr		Int = Null,
	@SerialFr		Int = Null,
	@FiscalTo		Int = Null,
	@SerialTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@PriceFr		float(20)=-1,
	@PriceTo		float(20)=-1,
	@SelectedGoods	Int = Null,
	@SelectedStore	Int = Null,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@SelectedVist1	Int = 0, 
	@SelectedVist2	Int = 0, 
	@SelectedVist3	Int = 0, 
	@SelectedVist4	Int = 0, 
	@CustKind		VarChar(20)=null,
	@SaleTypeID		VarChar(20)=Null, -- کد نوع فروش
	@SortFields		VarChar(90)=Null,
	@RepOptions		VarChar(20)='01000', 
	@RepInfo		VarChar(90)='1@1@1'
WITH ENCRYPTION
AS 
DECLARE @Eqal		NVarChar(2000);
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);


DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @Remain1	Bit;
DECLARE @Remain2	Bit;
DECLARE @Remain3	Bit;
DECLARE @Remain4	Bit;

DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @DocStep	Int;  -- مرحله
DECLARE @ExtraParams VarChar(90)
DECLARE @FromAge	Int;  
DECLARE @ToAge		Int;  
DECLARE @RemainAge		Bit;
DECLARE @NoRemainAge	Bit;  


Set @ExtraParams =@CustKind

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;

	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0
	IF (@SelectedStore Is Null)	SET @SelectedStore = 0
	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0
	IF (@SelectedVist1 Is Null)	SET @SelectedVist1 = 0
	IF (@SelectedVist2 Is Null)	SET @SelectedVist2 = 0
	IF (@SelectedVist3 Is Null)	SET @SelectedVist3 = 0
	IF (@SelectedVist4 Is Null)	SET @SelectedVist4 = 0

	IF (@FiscalFr Is Null)	SET @SerialFr = Null;
	IF (@FiscalTo Is Null)	SET @SerialTo = Null;
	IF (@SerialFr Is Null)	SET @FiscalFr = Null;
	IF (@SerialTo Is Null)	SET @FiscalTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @CustKind		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @FromAge		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @ToAge		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @RemainAge		= pub.funSplitString(@ExtraParams, '@', 4);
	SET @NoRemainAge		= pub.funSplitString(@ExtraParams, '@', 5);
	
 
	SET @DocStep = Substring(@RepOptions, 1, 1);
	SET @Remain1 = Substring(@RepOptions, 2, 1);
	SET @Remain2 = Substring(@RepOptions, 3, 1);
	SET @Remain3 = Substring(@RepOptions, 4, 1);
	SET @Remain4 = Substring(@RepOptions, 5, 1);

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
	
		declare @CountPartRemain tinyint
		SET @CountPartRemain=0;
	
		SET @Eqal = '1=1'

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
					SET @Eqal = @Eqal + ' AND M.AcntCode=H.AcntCode'
			END
			ELSE
			BEGIN
				IF (@Remain1 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
				IF (@Remain2 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
				IF (@Remain3 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
				IF (@Remain4 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
			END	
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = '(H.ProcessID=90)'

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ProcessNo=' + LTrim(Str(@ProcessNo))
		
	if (@CustKind <> '') and (@CustKind <> '0')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'

	If (@SaleTypeID Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'

	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (H.DocStep>=' + LTrim(Str(@DocStep)) + ')'

	If (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialFr)) + '))' 
	If (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialTo)) + '))' 

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate<=''' + @DocDateTo + ''')'

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 

	If (@SelectedVist1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVist2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVist3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVist4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist4, 'H.VisitorAcntCode') + ')'

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
		
		
	if @FromAge<>0
			set @StrWhere = @StrWhere + ' and  H.SettleAge >= ' + (Str(@FromAge)) + ''
	
	if @ToAge<>0
			set @StrWhere = @StrWhere + ' and  H.SettleAge <= ' + (Str(@ToAge)) + ''
	
		
	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------

	SET @StrSelect = '
	SELECT	H.*, S.StoreName,
			pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') AS VisitorAcntName,
			pub.GetCodeName(H.AcntCode, ' + @LangID + ') AS AcntName
			, F.VisitPathID1, F.VisitPathID2, F.VisitPathID3, F.VisitPathID4,	F.Tel, F.Address1 + '' '' + F.Address2 AcntAddress, F.Mobile,
			(  SELECT	IsNull(Sum(Debit-Credit),0) Debit 
				FROM	acc.tblVoucherDtl M INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
				WHERE   (VH.DocRegisterState>0) AND (' + @Eqal + ') 
						AND (M.DocDate<=H.VchDate AND Not (M.DocDate=H.VchDate AND M.SourceProcessID=H.ProcessID AND M.SourceProcessNo=H.ProcessNo AND M.SourceFiscalYear=H.FiscalYear AND M.SourceSerialNo>=H.SerialNo))
			) DebitRemain
			,(   SELECT IsNull(SUM(D.GoodsPrice * D.GoodsQuantity), 0)
				FROM inv.tblStorageDocsDtl D
				WHERE D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
			) PriceSum
			,isnull((   select Amount from 	inv.tblStorageDocsHdr  D
				WHERE D.BaseProcessID=H.ProcessID AND D.BaseProcessNo=H.ProcessNo AND D.BaseFiscalYear=H.FiscalYear AND D.BaseSerialNo=H.SerialNo
			) ,0) PriceSumRemain
				,(SELECT isnull( sum(Amount),0)Amount			FROM	trs.tblPayDtl D
				inner join trs.tblPayHdr P on P.ProcessID=D.ProcessID and P.ProcessNo=D.ProcessNo and P.FiscalYear=D.FiscalYear and P.SerialNo=D.SerialNo
				WHERE	D.ProcessID in (1,10) 			and P.BaseProcessID = H.ProcessID			and P.BaseProcessNo = H.ProcessNo
			and P.BaseFiscalYear = H.FiscalYear			and P.BaseSerialNo = H.SerialNo ) Pays
	FROM	(Select * , sal.funSettleAverage(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate) SettleAge		 from inv.vwStorageDocsHdr  ) H 
				INNER JOIN	inv.tblStoresDtl S ON S.StoreID=H.StoreID				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F
	WHERE ' + @StrWhere

		set @StrWhere = '(1=1)'
		if (@PriceFr <> -1)
			set @StrWhere = @StrWhere + ' and (PriceSum + SidePriceSum >= ' + LTrim(Str(@PriceFr)) + ')'
		if (@PriceTo <> -1)
			set @StrWhere = @StrWhere + ' and (PriceSum + SidePriceSum <= ' + LTrim(Str(@PriceTo)) + ')'
		if @RemainAge=0
			set @StrWhere = @StrWhere + ' and PriceSum + SidePriceSum - PriceSumRemain - Pays <=0'
		if @NoRemainAge=0
			set @StrWhere = @StrWhere + ' and  PriceSum + SidePriceSum - PriceSumRemain - Pays >0'
		set @StrSelect = 
		'select T.*,PriceSum + SidePriceSum - PriceSumRemain - Pays AmountPay  from (' + @StrSelect + ') T where ' + @StrWhere 
	
	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
