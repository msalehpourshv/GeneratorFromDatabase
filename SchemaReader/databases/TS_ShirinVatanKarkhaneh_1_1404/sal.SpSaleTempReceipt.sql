USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1401/08/18
-- Viewed By	 : 
-- Last Modified : 

-- Description	 : 
-- ==============================================
Create PROCEDURE sal.SpSaleTempReceipt
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	

WITH ENCRYPTION
AS
declare	@RetPID int
declare	@DateFr char(10)
declare	@DateTo char(10)
declare	@DescRetSaleID varchar(30)

declare @MaxSmallDealAmount as bigint
--declare @TaxOverWorthBeforOverLoadInBuy as bit
Declare @ProcessID	int, -- 55 or 90
		@FSFR	int, 
		@SRFR	int, 
		@FSTO	int,
		@SRTO	int, 
		@StrWhereH		NVarChar(Max),
		@StrWhereIN		NVarChar(Max),
		@LangID			Char(1),
		@SessionNo		Int, 
		@ReportID		Int,
		@UserID			Int,
		@UserIsAdmin	bit
Declare @StrSelect			NVarChar(max);		
Declare @StrWhere			NVarChar(max);		
Declare @PartNumber	int;
Declare @Start	int;
Declare @Len	int;

 Begin 

select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
select @Start=[acc].[FunGetAcntInfoForRemain](2)
select @Len=[acc].[FunGetAcntInfoForRemain](3)

 	SET @ProcessID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 	SET @FSFR			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
 	SET @SRFR			    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
 	SET @FSTO			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @SRTO			    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @DateFr		        = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @DateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @DescRetSaleID	    = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);

	--select @ProcessID,@FSFR,@SRFR,@FSTO,@SRTO,@DateFr,@DateTo

	  select  @StrWhere=' 1=1 '
	
		if @FSFR>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear>=' +str(@FSFR)
		if @SRFR>0
			set @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SRFR)
		if @FSTO>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear<=' +str(@FSTO)
		if @SRTO>0
			set @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SRTO)
		if @DateFr<>''
			set @StrWhere = @StrWhere+' AND D.DocDate	>=''' + @DateFr +''''
		if @DateTo<>''
			set @StrWhere = @StrWhere+' AND D.DocDate	<=''' + @DateTo +''''
		if @DescRetSaleID<>''
			set @StrWhere = @StrWhere+' AND S.DescRetSaleID	LIKE ''' + @DescRetSaleID +'%'''
 
		set @StrSelect = '
				select D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.DocRowNo,S.PSerialNo, isnull(DescRetSaleName, '''') DescRetSaleName,1 SubUnitQuantity,Confirmed, D.DocDate
					, H.AcntCode,pub.GetCodeName(H.AcntCode,1) AS AcntName	,P.RegDate				
					,isnull(SD.ProcessID,0)ProcessIDRet,isnull(SD.ProcessNo,0)ProcessNoRet,isnull(SD.FiscalYear,0)FiscalYearRet,isnull(SD.SerialNo,0)SerialNoRet
					,D.GoodsID,pub.funGetGoodsName(D.GoodsID,1) GoodsName,ISNULL(UnitValue/MainUnitValue,0) SubUnitValue
				from inv.tblStorageDocsSerials S
				inner join  pln.tblProductSerials P on P.ProductSerialID=S.ProductSerialID
				inner join  inv.tblInvTempReceiptDtl  D on D.ProcessID=S.ProcessID And D.ProcessNo=S.ProcessNo And D.FiscalYear=S.FiscalYear And D.SerialNo=S.SerialNo And D.DocRowNo=S.DocRowNo
				inner join  inv.tblInvTempReceiptHdr  H on H.ProcessID=S.ProcessID And H.ProcessNo=S.ProcessNo And H.FiscalYear=S.FiscalYear And H.SerialNo=S.SerialNo 
				inner join  inv.tblGoods G on D.GoodsID=G.GoodsID
				left Join	sal.tblDescRetSaleDtl R on S.DescRetSaleID=R.DescRetSaleID and R.LanguageID=1
				left Join	inv.tblStorageDocsDtl SD on   D.ProcessID=SD.SourceProcessID And D.ProcessNo=SD.SourceProcessNo And D.FiscalYear=SD.SourceFiscalYear And D.SerialNo=SD.SourceSerialNo  And D.DocRowNo=SD.SourceDocRowNo				
				left Join	inv.tblSubUnitsDtl  SU on SU.ShowInInvoice= 1  and SU.GoodsID=D.GoodsID
				where '+ @StrWhere +'	'
	
		print @StrSelect
	Exec sp_executesql @StrSelect;

END----end
GO
