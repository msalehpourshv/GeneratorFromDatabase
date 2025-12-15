USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/06/01
-- Viewed By	 : 
-- Last Modified : 1393/05/16
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_GoodsPayments]
	@ProcessNo				int = 1,
	@FiscalFr				int = Null,
	@SerialFr				int = Null,
	@FiscalTo				int = Null,
	@SerialTo				int = Null,
	@DocDate1Fr				char(10) = null,
	@DocDate1To				char(10) = null,
	@DocDate2Fr				char(10) = null,
	@DocDate2To				char(10) = null,
	@DocDate3Fr				char(10) = null,
	@DocDate3To				char(10) = null,
	@SelectedAcnt1			int = 0,
	@SelectedAcnt2			int = 0,
	@SelectedAcnt3			int = 0,
	@SelectedAcnt4			int = 0,
	@SelectedVist1			int = 0,
	@SelectedVist2			int = 0,
	@SelectedVist3			int = 0,
	@SelectedVist4			int = 0,
	@SelectedGoods			int = 0,
	@SaleTypeID				varchar(20) = Null,
	@SortFields				varchar(50) = Null,
	@DistributionFiscalFr	int = Null,
	@DistributionSerialFr	int = Null,
	@DistributionFiscalTo	int = Null,
	@DistributionSerialTo	int = Null,
	@RepOptions				varchar(20) = '22',  -- bit array options
	@RepInfo				varchar(100) = '1@1@1',
	@ExtraParams			NVarChar(200) = ''

WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhere1	NVarChar(max)
DECLARE @StrWhere2	NVarChar(max)
DECLARE @StrWhere3	NVarChar(max)
DECLARE @StrWhereG	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@StrParts	nvarChar(500);

DECLARE	@DocStep				Int;
DECLARE	@GoodsPart				Int;
DECLARE @counter				int;
DECLARE @PartLen				int;

Begin

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions	= '21';
	IF (@SortFields	Is Null)	SET @SortFields = 'GoodsID';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVist1	Is Null)	SET @SelectedVist1 = 0;
	IF (@SelectedVist2	Is Null)	SET @SelectedVist2 = 0;
	IF (@SelectedVist3	Is Null)	SET @SelectedVist3 = 0;
	IF (@SelectedVist4	Is Null)	SET @SelectedVist4 = 0;

	If (@FiscalFr Is Null)	SET @SerialFr = Null;
	If (@FiscalTo Is Null)	SET @SerialTo = Null;
	If (@SerialFr Is Null)	SET @FiscalFr = Null;
	If (@SerialTo Is Null)	SET @FiscalTo = Null;
	
	If (@DistributionFiscalFr Is Null)	SET @DistributionSerialFr = Null;
	If (@DistributionFiscalTo Is Null)	SET @DistributionSerialTo = Null;
	If (@DistributionSerialFr Is Null)	SET @DistributionFiscalFr = Null;
	If (@DistributionSerialTo Is Null)	SET @DistributionFiscalTo = Null;	

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @DocStep	= Substring(@RepOptions, 1, 1);
	SET @GoodsPart	= Substring(@RepOptions, 2, 1);
	
	set @StrParts = '0';
	set @counter = 1;

	while (@counter <= @GoodsPart)
	begin
	  set @StrParts = @StrParts + '+Layer' + ltrim(STR(@counter));
	  set @counter = @counter + 1;
	end
	
	set @StrSelect = ' select @PartLen=' + @StrParts + ' from pub.tblCodeLayer where (TableName=''inv.tblGoods'')'
	exec sp_executesql @StrSelect, N'@PartLen int output', @PartLen output;
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhereG = '(1=1)'
	SET @StrWhere1 = '(1=1)'
	SET @StrWhere2 = '(1=1)'
	SET @StrWhere3 = '(1=1)'
	SET @StrWhere = '(H.ProcessID=90) and (H.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (H.DocStep>=' + LTrim(Str(@DocStep)) + ')'
	If (@SaleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SaleTypeID=''' + @SaleTypeID + ''')'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialFr)) + '))' 
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialTo)) + '))' 
		
	IF (@DistributionSerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H1.BaseDistributionFiscalYear>' + LTrim(Str(@DistributionFiscalFr)) + ' OR (H1.BaseDistributionFiscalYear=' + LTrim(Str(@DistributionFiscalFr)) + ' AND H1.BaseDistributionSerialNo>=' + LTrim(Str(@DistributionSerialFr)) + '))' 
	IF (@DistributionSerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H1.BaseDistributionFiscalYear<' + LTrim(Str(@DistributionFiscalTo)) + ' OR (H1.BaseDistributionFiscalYear=' + LTrim(Str(@DistributionFiscalTo)) + ' AND H1.BaseDistributionSerialNo<=' + LTrim(Str(@DistributionSerialTo)) + '))' 		

	IF (@DocDate1Fr is not null)
		SET @StrWhere1 = @StrWhere1 + ' AND (DocDate>=''' + @DocDate1Fr + ''')'
	IF (@DocDate1To is not null)
		SET @StrWhere1 = @StrWhere1 + ' AND (DocDate<=''' + @DocDate1To + ''')'

	IF (@DocDate2Fr is not null)
		SET @StrWhere2 = @StrWhere2 + ' AND (DocDate>=''' + @DocDate2Fr + ''')'
	IF (@DocDate2To is not null)
		SET @StrWhere2 = @StrWhere2 + ' AND (DocDate<=''' + @DocDate2To + ''')'

	IF (@DocDate3Fr is not null)
		SET @StrWhere3 = @StrWhere3 + ' AND (DocDate>=''' + @DocDate3Fr + ''')'
	IF (@DocDate3To is not null)
		SET @StrWhere3 = @StrWhere3 + ' AND (DocDate<=''' + @DocDate3To + ''')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	IF (@SelectedVist1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist1, 'H.VisitorAcntCode')
	IF (@SelectedVist2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist2, 'H.VisitorAcntCode')
	IF (@SelectedVist3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist3, 'H.VisitorAcntCode')
	IF (@SelectedVist4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist4, 'H.VisitorAcntCode')

	IF (@SelectedGoods > 0)
		SET @StrWhereG = @StrWhereG + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	select  H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.RowNo, H.GoodsID, (H.GoodsQuantity*H.GoodsPrice)-H.DiscountDtl as RowPrice
	into	#tbl_Sale_GoodsPayments_D
	from	inv.tblStorageDocsDtl H
	Inner JOin inv.tblStorageDocsHdr H1 ON H1.ProcessID = H.ProcessID And H1.ProcessNo = H.ProcessNo And 
										   H1.FiscalYear = H.FiscalYear And H1.SerialNo = H.SerialNo	
	where	' + @StrWhere + ' 
	
	select *
	into	#tbl_Sale_GoodsPayments_H
	from
	(
		select  H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate,
				(
					select sum(GoodsPrice*GoodsQuantity)
					from inv.tblStorageDocsDtl D 
					where D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
				) + SidePriceSum as SumPrice
		from	inv.vwStorageDocsHdr H
		Inner JOin inv.tblStorageDocsHdr H1 ON H1.ProcessID = H.ProcessID And H1.ProcessNo = H.ProcessNo And 
											   H1.FiscalYear = H.FiscalYear And H1.SerialNo = H.SerialNo			
		where	' + @StrWhere + '
	) X where SumPrice <> 0
	
	select	D.GoodsID, H.DocDate,
			D.RowPrice / H.SumPrice *
			isnull((
				select  sum(PD.Amount)
				from trs.tblPayDtl PD
					inner join trs.tblPayHdr PH on PD.ProcessID=PH.ProcessID AND PD.ProcessNo=PH.ProcessNo AND PD.FiscalYear=PH.FiscalYear AND PD.SerialNo=PH.SerialNo
				where (PD.ProcessID=1 and PD.PayTypeID in (1,10)) and PH.BaseProcessID=D.ProcessID AND PH.BaseProcessNo=D.ProcessNo AND PH.BaseFiscalYear=D.FiscalYear AND PH.BaseSerialNo=D.SerialNo
			),0) CashReceipt,
			D.RowPrice / H.SumPrice *
			isnull((
				select  sum(Amount)
				from trs.tblPayDtl PD
					inner join trs.tblPayHdr PH on PD.ProcessID=PH.ProcessID AND PD.ProcessNo=PH.ProcessNo AND PD.FiscalYear=PH.FiscalYear AND PD.SerialNo=PH.SerialNo
				where (PD.ProcessID=1 and PD.PayTypeID in (6,16,26)) and PH.BaseProcessID=D.ProcessID AND PH.BaseProcessNo=D.ProcessNo AND PH.BaseFiscalYear=D.FiscalYear AND PH.BaseSerialNo=D.SerialNo
			),0) CheqReceipt
	into #tbl_Sale_GoodsPayments_R
	from #tbl_Sale_GoodsPayments_D D
	       inner join #tbl_Sale_GoodsPayments_H H on D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
	
	select	GoodsID, 
			CashReceipt CashReceipt1, 0 CashReceipt2, 0 CashReceipt3,
			CheqReceipt CheqReceipt1, 0 CheqReceipt2, 0 CheqReceipt3
	into #tbl_Sale_GoodsPayments_X
	from #tbl_Sale_GoodsPayments_R
	where ' + @StrWhere1 + '
	union all
	select	GoodsID, 
			0 CashReceipt1, CashReceipt CashReceipt2, 0 CashReceipt3,
			0 CheqReceipt1, CheqReceipt CheqReceipt2, 0 CheqReceipt3
	from #tbl_Sale_GoodsPayments_R
	where ' + @StrWhere2 + '
	union all
	select	GoodsID, 
			0 CashReceipt1, 0 CashReceipt2, CashReceipt CashReceipt3,
			0 CheqReceipt1, 0 CheqReceipt2, CheqReceipt CheqReceipt3
	from #tbl_Sale_GoodsPayments_R
	where ' + @StrWhere3 + '
	
	select T.GoodsGroupID, T.GoodsGroupName, T.BarCode,
			sum(CashReceipt1) CashReceipt1,
			sum(CashReceipt2) CashReceipt2,
			sum(CashReceipt3) CashReceipt3,
			sum(CheqReceipt1) CheqReceipt1,
			sum(CheqReceipt2) CheqReceipt2,
			sum(CheqReceipt3) CheqReceipt3
	from 
	(
		select D.*, substring(D.GoodsID,1,' + str(@PartLen) + ') GoodsGroupID, 
			   [pub].[funGetGoodsName](SubString(D.GoodsID,1,' + str(@PartLen) + '),' + LTrim(RTrim(@LangID)) + ') GoodsGroupName,
			   IsNull([inv].[FunGetGoodsBarCode] (SubString(D.GoodsID,1,' + str(@PartLen) + ')), '''') BarCode
		from #tbl_Sale_GoodsPayments_X D
		--left join inv.tblGoodsDtl G on G.GoodsID = SubString(D.GoodsID,1,' + str(@PartLen) + ')
		left join inv.tblGoodsDtl G ON G.GoodsID = SubString(SubString(D.GoodsID,1,' + str(@PartLen) + '),' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		where ' + @StrWhereG + '
	) T
	group by T.GoodsGroupID, T.GoodsGroupName, T.BarCode
	order by T.GoodsGroupID'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
