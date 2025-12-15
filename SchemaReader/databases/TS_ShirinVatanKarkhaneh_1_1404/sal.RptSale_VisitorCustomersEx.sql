USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/05
-- Viewed By	 : 
-- Last Modified : 1390/05/30
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_VisitorCustomersEx]
	@VistAcnt1	Int = 0,
	@VistAcnt2	Int = 0,
	@VistAcnt3	Int = 0,
	@VistAcnt4	Int = 0,
	@CustAcnt1	Int = 0,
	@CustAcnt2	Int = 0,
	@CustAcnt3	Int = 0,
	@CustAcnt4	Int = 0,
	@ProbAcnt1	Int = 0,
	@ProbAcnt2	Int = 0,
	@ProbAcnt3	Int = 0,
	@ProbAcnt4	Int = 0,
	@CheqAcnt1	Int = 0,
	@CheqAcnt2	Int = 0,
	@CheqAcnt3	Int = 0,
	@CheqAcnt4	Int = 0,
	@DocDateFr	char(10) = null,
	@DocDateTo	char(10) = null,
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(100) = '',
	@RepOptions		VarChar(10) = '1000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrWhere1	NVarChar(4000)
DECLARE @StrWhere2	NVarChar(4000)
DECLARE @StrWhere3	NVarChar(4000)
DECLARE @StrWhere4	NVarChar(4000)
DECLARE @StrWhere5	NVarChar(4000)
DECLARE @StrFrom	NVarChar(4000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

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
DECLARE @SumAmount1	float;
DECLARE @SumAmount2	float;
DECLARE @SumAmount3	float;
DECLARE @Eqal		NVarChar(2000);

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1000';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '1,2,3,4';
	IF (@ExtraParams	= '')		SET @ExtraParams= '1,2,3,4';
	IF (@SortFields		Is Null)	SET @SortFields = 'VisitorAcntCode';
	IF (@SortFields		= '')		SET @SortFields = 'VisitorAcntCode';

	IF (@VistAcnt1	Is Null)	SET @VistAcnt1 = 0;
	IF (@VistAcnt2	Is Null)	SET @VistAcnt2 = 0;
	IF (@VistAcnt3	Is Null)	SET @VistAcnt3 = 0;
	IF (@VistAcnt4	Is Null)	SET @VistAcnt4 = 0;
	IF (@CustAcnt1	Is Null)	SET @CustAcnt1 = 0;
	IF (@CustAcnt2	Is Null)	SET @CustAcnt2 = 0;
	IF (@CustAcnt3	Is Null)	SET @CustAcnt3 = 0;
	IF (@CustAcnt4	Is Null)	SET @CustAcnt4 = 0;
	IF (@ProbAcnt1	Is Null)	SET @ProbAcnt1 = 0;
	IF (@ProbAcnt2	Is Null)	SET @ProbAcnt2 = 0;
	IF (@ProbAcnt3	Is Null)	SET @ProbAcnt3 = 0;
	IF (@ProbAcnt4	Is Null)	SET @ProbAcnt4 = 0;
	IF (@CheqAcnt1	Is Null)	SET @CheqAcnt1 = 0;
	IF (@CheqAcnt2	Is Null)	SET @CheqAcnt2 = 0;
	IF (@CheqAcnt3	Is Null)	SET @CheqAcnt3 = 0;
	IF (@CheqAcnt4	Is Null)	SET @CheqAcnt4 = 0;

	SET @Remain1 = Substring(@RepOptions, 1, 1);
	SET @Remain2 = Substring(@RepOptions, 2, 1);
	SET @Remain3 = Substring(@RepOptions, 3, 1);
	SET @Remain4 = Substring(@RepOptions, 4, 1);

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

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @Eqal = '(1=1)'

	IF (@Remain1 = 1)
		SET @Eqal = @Eqal + ' AND Substring(D.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(V.CustomerAcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
	IF (@Remain2 = 1)
		SET @Eqal = @Eqal + ' AND Substring(D.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(V.CustomerAcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
	IF (@Remain3 = 1)
		SET @Eqal = @Eqal + ' AND Substring(D.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(V.CustomerAcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
	IF (@Remain4 = 1)
		SET @Eqal = @Eqal + ' AND Substring(D.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(V.CustomerAcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere1 = '(1=1)'
	SET @StrWhere2 = '(1=1)'
	SET @StrWhere5 = '(1=1)'

	IF (@VistAcnt1 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt1, 'V.VisitorAcntCode')
	IF (@VistAcnt2 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt2, 'V.VisitorAcntCode')
	IF (@VistAcnt3 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt3, 'V.VisitorAcntCode')
	IF (@VistAcnt4 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt4, 'V.VisitorAcntCode')

	IF (@DocDateFr is not null)
		SET @StrWhere5 = @StrWhere5 + ' AND (DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhere5 = @StrWhere5 + ' AND (DocDate <= ''' + @DocDateTo + ''')'

	IF (@CustAcnt1 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt1, 'V.CustomerAcntCode')
	IF (@CustAcnt2 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt2, 'V.CustomerAcntCode')
	IF (@CustAcnt3 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt3, 'V.CustomerAcntCode')
	IF (@CustAcnt4 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt4, 'V.CustomerAcntCode')

	IF (@CheqAcnt1 > 0) or (@CheqAcnt2 > 0) or (@CheqAcnt3 > 0) or (@CheqAcnt4 > 0)
	begin
		set @StrWhere3 = '(1=1)'
	
		IF (@CheqAcnt1 > 0)
			SET @StrWhere3 = @StrWhere3 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @CheqAcnt1, 'D.AcntCode')
		IF (@CheqAcnt2 > 0)
			SET @StrWhere3 = @StrWhere3 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @CheqAcnt2, 'D.AcntCode')
		IF (@CheqAcnt3 > 0)
			SET @StrWhere3 = @StrWhere3 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @CheqAcnt3, 'D.AcntCode')
		IF (@CheqAcnt4 > 0)
			SET @StrWhere3 = @StrWhere3 + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @CheqAcnt4, 'D.AcntCode')
	end
	Else
		set @StrWhere3 = '(1<>1)'

	IF (@ProbAcnt1 > 0) or (@ProbAcnt2 > 0) or (@ProbAcnt3 > 0) or (@ProbAcnt4 > 0)
	begin
		set @StrWhere4 = '(1=1)'

		IF (@ProbAcnt1 > 0)
			SET @StrWhere4 = @StrWhere4  + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @ProbAcnt1, 'V.CustomerAcntCode')
		IF (@ProbAcnt2 > 0)
			SET @StrWhere4 = @StrWhere4  + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @ProbAcnt2, 'V.CustomerAcntCode')
		IF (@ProbAcnt3 > 0)
			SET @StrWhere4 = @StrWhere4  + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @ProbAcnt3, 'V.CustomerAcntCode')
		IF (@ProbAcnt4 > 0)
			SET @StrWhere4 = @StrWhere4  + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @ProbAcnt4, 'V.CustomerAcntCode')
	end
	Else
		set @StrWhere4 = '(1<>1)'
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	create table #tbl_result
	(
		VisitorAcntCode varchar(20) collate arabic_cs_as,
		VisitorAcntName varchar(2000) collate arabic_cs_as,
		CustomerCount int,
		SumSale float,
		SumSaleRet float,
		SumRemainCustomer float,
		SumRemainCheques float,
		SumRemainProblems float,
		CountSale float,
		CountSaleRet float,
		DiscountSale1 float,
		DiscountSale2 float,
	);

	SET @StrSelect = '
	select	V.VisitorAcntCode, V.CustomerAcntCode, sum(D.Debit-D.Credit) Remain
	into	#tbl_CustRemain
	from	sal.tblVisitorsCustomersDtl V
				inner join acc.tblVoucherDtl D on ' + @Eqal + '
	where	' + @StrWhere1 + ' and ' + @StrWhere2 + '
	group by V.VisitorAcntCode, V.CustomerAcntCode 

	select	V.VisitorAcntCode, V.CustomerAcntCode, sum(D.Debit-D.Credit) Remain
	into	#tbl_Cheques
	from	sal.tblVisitorsCustomersDtl V
				inner join acc.tblVoucherDtl D on ' + @Eqal + '
	where	' + @StrWhere1 + ' and ' + @StrWhere2 + ' and ' + @StrWhere3 + '
	group by V.VisitorAcntCode, V.CustomerAcntCode 

	select	V.VisitorAcntCode, V.CustomerAcntCode, sum(D.Debit-D.Credit) Remain
	into	#tbl_Problems
	from	sal.tblVisitorsCustomersDtl V
				inner join acc.tblVoucherDtl D on ' + @Eqal + '
	where	' + @StrWhere1 + ' and ' + @StrWhere2 + ' and ' + @StrWhere4 + '
	group by V.VisitorAcntCode, V.CustomerAcntCode 

	---------------------------------------------------
	INSERT INTO #tbl_result
	SELECT  VisitorAcntCode,  
			pub.GetCodeName(VisitorAcntCode,1) VisitorAcntName, 
			count(*) CustomerCount,
			isnull((select sum(GoodsPrice*GoodsQuantity) from inv.tblStorageDocsDtl S where (ProcessID = 90 ) and (S.VisitorAcntCode = V.VisitorAcntCode) and ' + @StrWhere5 + '), 0) SumSale,
			isnull((select sum(GoodsPrice*GoodsQuantity) from inv.tblStorageDocsDtl S where (ProcessID = 100) and (S.VisitorAcntCode = V.VisitorAcntCode) and ' + @StrWhere5 + '), 0) SumSaleRet,
			isnull((
				select sum(Remain) 
				from #tbl_CustRemain C
				where (C.VisitorAcntCode = V.VisitorAcntCode) 
			), 0) SumRemainCustomer,
			isnull((
				select sum(Remain) 
				from #tbl_Cheques C
				where (C.VisitorAcntCode = V.VisitorAcntCode) 
			), 0) SumRemainCheques,
			isnull((
				select sum(Remain) 
				from #tbl_Problems C
				where (C.VisitorAcntCode = V.VisitorAcntCode) 
			), 0) SumRemainProblems,
			isnull((select count(*) from inv.tblStorageDocsHdr S where (ProcessID = 90)  and (S.VisitorAcntCode = V.VisitorAcntCode) and ' + @StrWhere5 + '), 0) CountSale,
			isnull((select count(*) from inv.tblStorageDocsHdr S where (ProcessID = 100) and (S.VisitorAcntCode = V.VisitorAcntCode) and ' + @StrWhere5 + '), 0) CountSaleRet,
			isnull((select sum(Discount)  from inv.tblStorageDocsHdr S where (ProcessID = 90) and (S.VisitorAcntCode = V.VisitorAcntCode) and ' + @StrWhere5 + '), 0) DiscountSale1,
			isnull((select sum(Discount2) +sum(Discount3)  from inv.tblStorageDocsHdr S where (ProcessID = 90) and (S.VisitorAcntCode = V.VisitorAcntCode) and ' + @StrWhere5 + '), 0) DiscountSale2
	FROM	sal.tblVisitorsCustomersDtl V
	WHERE ' + @StrWhere1 + ' and ' + @StrWhere2 + '
	GROUP By VisitorAcntCode
	ORDER BY ' + @SortFields 

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	select @SumAmount1 = sum(SumSale)
	from #tbl_result

	select @SumAmount2 = sum(SumSaleRet)
	from #tbl_result

	select @SumAmount3 = sum(SumRemainCustomer)
	from #tbl_result

	if (@SumAmount1 = 0)
		set @SumAmount1 = 1;
	if (@SumAmount2 = 0)
		set @SumAmount2 = 1;
	if (@SumAmount3 = 0)
		set @SumAmount3 = 1;
	
	select T.*, pub.GetCodeName(T.VisitorAcntCode, 1) VisitorAcntName,
		(T.SumSale / @SumAmount1 * 100) as SalePercent, 
		(T.SumSaleRet / @SumAmount2 * 100) as SaleRetPercent, 
		(T.SumRemainCustomer / @SumAmount3 * 100) as RemainPercent
	from #tbl_result T
		
	---------------------------------------------------------------------------
End
GO
