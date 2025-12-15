USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/03/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : آمار فروش - توزیع - وصول2
-- ==============================================
Create PROCEDURE [sal].[RptSaleOrder_Stats2]
	@ProcessNo		Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@SortFields		VarChar(100) = Null,
	@RepOptions		VarChar(100) = '2011',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrSelect2	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrHaving	NVarChar(max);
DECLARE @StrWhereP	NVarChar(max);

DECLARE @Remain1	bit;
DECLARE @Remain2	bit;
DECLARE @DecRet		bit;
DECLARE @DocStep	int;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE @Eqal		NVarChar(2000);
DECLARE @SalIvcRemain1	Bit;
DECLARE @SalIvcRemain2	Bit;
DECLARE @SalIvcRemain3	Bit;
DECLARE @SalIvcRemain4	Bit;
DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @Part1End	TinyInt;
DECLARE @SerialNoFrom	Int;
DECLARE @SerialNoTo		Int;
DECLARE @FiscalYearFrom	Int;
DECLARE @FiscalYearTo	Int;
 		 
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '2011';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	SET @DocStep	= Substring(@RepOptions, 1, 1);
	SET @DecRet		= Substring(@RepOptions, 2, 1);
	SET @Remain1	= Substring(@RepOptions, 3, 1);
	SET @Remain2	= Substring(@RepOptions, 4, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @FiscalYearFrom	= pub.funSplitString(@RepInfo, '@', 6);
	set @SerialNoFrom	= pub.funSplitString(@RepInfo, '@', 7);
	set @FiscalYearTo	= pub.funSplitString(@RepInfo, '@', 8);
	set @SerialNoTo		= pub.funSplitString(@RepInfo, '@', 9);
	---------------------------------------------------------
	-- Where Clause -----------------------------------------
	SET @StrWhere = '(D.ProcessID=180)'
	SET @StrWhereP = '(PD.ProcessID=1) and (PD.PayTypeID in (1,6,16,26))'

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If @FiscalYearFrom Is Not Null and @FiscalYearFrom>0
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear>=' + LTrim(Str(@FiscalYearFrom)) + ')'
	If @FiscalYearTo Is Not Null and @FiscalYearTo>0
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear<=' + LTrim(Str(@FiscalYearTo)) + ')'
	If @SerialNoFrom Is Not Null and @SerialNoFrom>0
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo>=' + LTrim(Str(@SerialNoFrom)) + ')'
	If @SerialNoTo Is Not Null and @SerialNoTo>0
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo<=' + LTrim(Str(@SerialNoTo)) + ')'

	IF (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		Set @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep=' + LTrim(Str(@DocStep)) + ')'
	---------------------------------------------------------
	set @StrHaving = '(1=1)'
	
	if (@Remain1 = 1)
		set @StrHaving = @StrHaving + ' and Sum(GoodsQuantity*GoodsPrice)>SalPrice'
	if (@Remain2 = 1)
		set @StrHaving = @StrHaving + ' and SalPrice>TrsPrice'

	-- ----------------------------------------
	declare @CountPartRemain tinyint
	SET @CountPartRemain=0;
	SET		@Part1Start = 1;
	
	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)


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
		
	set @SalIvcRemain1 =  'True'
	set @SalIvcRemain2 =  'True'
	set @SalIvcRemain3 =  'True'
	set @SalIvcRemain4 =  'True'

	SELECT @SalIvcRemain1 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain1'
	SELECT @SalIvcRemain2 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain2'
	SELECT @SalIvcRemain3 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain3'
	SELECT @SalIvcRemain4 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain4'
	
		SET @Eqal = '1=1'

		IF (@SalIvcRemain1 = 1)
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@SalIvcRemain2 = 1) AND @CountPartRemain = 1
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@SalIvcRemain3 = 1) AND @CountPartRemain = 2
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@SalIvcRemain4 = 1) AND @CountPartRemain = 3
			SET @CountPartRemain = @CountPartRemain + 1
	
	
		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
			BEGIN
					SET @Eqal = @Eqal + ' AND VM.AcntCode=M.AcntCode'
			END
			ELSE
			BEGIN
				IF (@SalIvcRemain1 = 1)
					SET @Eqal = @Eqal + ' AND Substring(VM.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
				IF (@SalIvcRemain2 = 1)
					SET @Eqal = @Eqal + ' AND Substring(VM.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
				IF (@SalIvcRemain3 = 1)
					SET @Eqal = @Eqal + ' AND Substring(VM.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
				IF (@SalIvcRemain4 = 1)
					SET @Eqal = @Eqal + ' AND Substring(VM.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
			END
			
			
	-- SELECT Clause ----------------------------------------
	select  FiscalYear	,SerialNo,ProcessNo	,DocDate,	GoodsID AcntCode, DescDtl	AcntName, GoodsQuantity	SorPrice	, GoodsQuantity SalPrice	, GoodsQuantity TrsPrice	, GoodsQuantity GoodsQuantity	, GoodsQuantity CancelQuantity		, GoodsQuantity SoldQuantity	, GoodsQuantity Remain	, GoodsQuantity DebitRemain , FiscalYear DBFiscalYear	, GoodsQuantity CancelPrice
	Into #tblRst 
	from inv.tblStorageDocsDtl 
	where 1=0

	SET @StrSelect = ' Insert into #tblRst
	select M.FiscalYear, M.SerialNo, M.ProcessNo, M.DocDate,	M.AcntCode,[pub].GetCodeName(M.AcntCode, ' + @LangID + ') As AcntName,
		Sum((GoodsQuantity*GoodsPrice)-DiscountDtl)+TaxOverWorthCost+TollOverWorthCost-Discount-Discount2 SorPrice,
		SalPrice, TrsPrice,Sum(GoodsQuantity )GoodsQuantity ,Sum(CancelQuantity)CancelQuantity,Sum(SoldQuantity)SoldQuantity
		,case when  Sum(SoldQuantity )  =0 then 0 else  Sum(GoodsQuantity)- Sum(SoldQuantity) end Remain
		,IsNull((
				SELECT	Sum(Debit-Credit) Debit 
						 FROM	acc.tblVoucherDtl VM 
						 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = VM.SerialNo
						 INNER join acc.tblAcnt b ON b.PartNumber = 1 
						 AND SUBSTRING(VM.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode)=' + LTrim(RTrim(STR(@Part1End))) + '
						 WHERE  (VM.VchKind <> 3) and (VM.VchKind <> 4) and b.AcntType NOT IN (91, 92) AND VM.VchKind <> 0 AND VH.DocRegisterState > 0
						   AND (' + @Eqal + ')
						 --AND VM.DocDate <= M.DocDate 							   		    
			),0) DebitRemain,cast(  ltrim(str(RIGHT(DB_NAME(),4)) ) as int),
		isnull((
			SELECT TOP 1 TPrice+TaxOverWorthCost+TollOverWorthCost-Discount-Discount2 
			FROM
			(SELECT S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo,sum((S.GoodsQuantity*S.GoodsPrice)-DiscountDtl) TPrice
			FROM	sal.tblSaleOrderDtl S
			WHERE S.ProcessID=185	AND S.BaseProcessID = M.ProcessID AND S.BaseProcessNo = M.ProcessNo AND S.BaseFiscalYear = M.FiscalYear AND S.BaseSerialNo = M.SerialNo 
			group by S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo
			) S
			INNER JOIN sal.tblSaleOrderHdr SH 
			ON SH.ProcessID = S.ProcessID AND SH.ProcessNo = S.ProcessNo AND SH.FiscalYear = S.FiscalYear AND SH.SerialNo = S.SerialNo
					
			),0) AS CancelPrice
	from
	(
		select	D.ProcessID,D.ProcessNo,D.FiscalYear, D.SerialNo, D.DocDate, D.GoodsQuantity, D.GoodsPrice,D.DiscountDtl,D.AcntCode,
				isnull((
					SELECT SUM(TPrice+TaxOverWorthCost+TollOverWorthCost-Discount-Discount2) FROM
					(SELECT S.ProcessID,S.ProcessNo,S.FiscalYear,S.SerialNo,sum((S.GoodsQuantity*S.GoodsPrice)-DiscountDtl) TPrice
					 FROM inv.tblStorageDocsDtl S
					 WHERE (S.ProcessID=90) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo)
					 group by ProcessID,ProcessNo,FiscalYear,SerialNo
					) S
					INNER JOIN inv.tblStorageDocsHdr SH 
					ON SH.ProcessID = S.ProcessID AND SH.ProcessNo = S.ProcessNo AND SH.FiscalYear = S.FiscalYear AND SH.SerialNo = S.SerialNo

				),0) SalPrice,
				isnull((
					select Sum(PD.Amount)	
					from trs.tblPayHdr PH
							inner join trs.tblPayDtl PD on PH.ProcessID=PD.ProcessID and PH.ProcessNo=PD.ProcessNo and PH.FiscalYear=PD.FiscalYear and PH.SerialNo=PD.SerialNo
							inner join (select distinct ProcessID, ProcessNo, FiscalYear, SerialNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo from inv.tblStorageDocsDtl) S on S.ProcessID=PH.BaseProcessID and S.ProcessNo=PH.BaseProcessNo and S.FiscalYear=PH.BaseFiscalYear and S.SerialNo=PH.BaseSerialNo
					where ' + @StrWhereP + ' and (S.ProcessID=90) and (S.BaseProcessID=D.ProcessID) and (S.BaseProcessNo=D.ProcessNo) and (S.BaseFiscalYear=D.FiscalYear) and (S.BaseSerialNo=D.SerialNo)
				),0) TrsPrice
				,(SELECT	IsNull(Sum(GoodsQuantity), 0)
					FROM	sal.tblSaleOrderDtl
					WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
				) AS CancelQuantity'

	SET @StrSelect2=',(SElECT IsNull(Sum(SOLD.GoodsQuantity - SOLD.SoldRet), 0)
					FROM
					(SELECT	GoodsQuantity, cast(0 as float) AS SoldRet
						FROM	inv.tblStorageDocsDtl SD
						WHERE	SD.ProcessID = 90 AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND 
								SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo AND 
								SD.BaseDocRowNo = D.DocRowNo AND SD.GoodsID = D.GoodsID
					) AS SOLD
				) AS SoldQuantity
		from	sal.tblSaleOrderDtl D
		where (SELECT COUNT(*) from #tblRst R WHERE R.ProcessNo=D.ProcessNo AND R.FiscalYear=D.FiscalYear AND R.SerialNo=D.SerialNo ) =0 AND ' + @StrWhere + '
	) M 
	INNER JOIN sal.tblSaleOrderHdr H
	ON H.ProcessID = M.ProcessID AND H.ProcessNo = M.ProcessNo AND H.FiscalYear = M.FiscalYear AND H.SerialNo = M.SerialNo
	group by M.ProcessID,M.ProcessNo,M.FiscalYear, M.SerialNo, M.DocDate, M.SalPrice, M.TrsPrice,M.AcntCode,
			 H.TaxOverWorthCost,H.TollOverWorthCost,H.Discount,H.Discount2	
	having ' + @StrHaving

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Print @StrSelect2;
	SET @StrSelect=@StrSelect+@StrSelect2;

	Exec sp_executesql @StrSelect;
		------------------------------------------------------------	
	if @FiscalYearTo=0 or @FiscalYearFrom=0
		Select @FiscalYearTo=min(FiscalYear) from  #tblRst
		
	if @FiscalYearTo<@FiscalYearFrom
		set @FiscalYearTo=@FiscalYearFrom

	if @FiscalYearTo<>RIGHT(DB_NAME(),4)  and @FiscalYearTo<>0
	begin
		DECLARE @FiscalYear	Int;
		set @FiscalYear	 = cast(  ltrim(str(RIGHT(DB_NAME(),4)) ) as int)
		  
		while @FiscalYearTo<@FiscalYear
		begin
			Declare @OldDbName1 Varchar(50)	 
			set @OldDbName1=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(@FiscalYearTo))
			if (select Count(*) from sys.databases where name =@OldDbName1)>0
			begin
				declare @db Sysname =@OldDbName1
				declare  @exec Nvarchar(max)=quotename(@db)+N'.sys.sp_executesql'
				declare @sql Nvarchar(max)=' select * from acc.tblAcnt;'
				exec @exec @StrSelect 
			end	
			set @FiscalYearTo+=1			
		end
		
	end

	select FiscalYear	,SerialNo,ProcessNo,	DocDate	,AcntCode,	AcntName
		, (Select top 1  SorPrice from  #tblRst  a where a.FiscalYear=D.FiscalYear	and a.SerialNo=D.SerialNo	order by DBFiscalYear ) SorPrice
		,	Sum(SalPrice)	 SalPrice
		,Sum(TrsPrice) TrsPrice,Sum(	GoodsQuantity	) GoodsQuantity,Sum(CancelQuantity	) CancelQuantity,Sum(CancelPrice	) CancelPrice,Sum(SoldQuantity	) SoldQuantity,Sum(Remain	) Remain 
		, (Select top 1  DebitRemain from  #tblRst  a where a.FiscalYear=D.FiscalYear	and a.SerialNo=D.SerialNo	order by DBFiscalYear Desc)DebitRemain		
	from #tblRst D
	group by FiscalYear	,SerialNo,ProcessNo,	DocDate	,AcntCode,	AcntName
End
GO
