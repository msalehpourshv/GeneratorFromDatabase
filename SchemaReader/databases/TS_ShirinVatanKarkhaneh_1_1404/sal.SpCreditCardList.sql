USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1401/10/07
-- Viewed By	 : 
-- Last Modified : 

-- Description	 : 
-- ==============================================
Create PROCEDURE sal.SpCreditCardList
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	

WITH ENCRYPTION
AS
declare	@RetPID int
declare	@DateFr char(10)
declare	@DateTo char(10)
declare @MaxSmallDealAmount as bigint
--declare @TaxOverWorthBeforOverLoadInBuy as bit
Declare @ChequeNo	int, -- 55 or 90
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

 	SET @ChequeNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @DateFr		        = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @DateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);

	--select @ProcessID,@FSFR,@SRFR,@FSTO,@SRTO,@DateFr,@DateTo

	  select  @StrWhere=' 1=1 '
	
		if @ChequeNo<>0
			set @StrWhere =@StrWhere+ ' AND D.ChequeNo=' +str(@ChequeNo)
		if @DateFr<>''
			set @StrWhere = @StrWhere+' AND D.DocDate	>=''' + @DateFr +''''
		if @DateTo<>''
			set @StrWhere = @StrWhere+' AND D.DocDate	<=''' + @DateTo +''''

 
		set @StrSelect = '	

				Select ChequeNo, H.FiscalYear, H.SerialNo, H.BaseFiscalYear, H.BaseSerialNo, H.DocDate
				From   trs.tblPayHdr H
				inner join  trs.tblPayDtl D
				on H.ProcessID=D.ProcessID and  H.ProcessNo=D.ProcessNo and  H.FiscalYear=D.FiscalYear and  H.SerialNo=D.SerialNo 
				where PayTypeID=37 and '+ @StrWhere +'	'
	
		print @StrSelect
	Exec sp_executesql @StrSelect;

END----end
GO
