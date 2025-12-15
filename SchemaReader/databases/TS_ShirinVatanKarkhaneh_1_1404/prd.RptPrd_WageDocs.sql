USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza NP
-- Create date   : 1394/03/25
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_WageDocs]
	@ProductAcntCode	varchar(20) = null, 
	@ProductID			varchar(20) = null,  
	@BatchNo			varchar (20)=null,
	@SerialNoFr			int=null,
	@SerialNoTo			int=null,
	@FromDate			char(10)=null,
	@ToDate				char(10)=null,
	@RepOptions		varchar(10) = '101',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION

AS
DECLARE @strSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@UserID		int; 

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);

set @StrWhere	=' 1=1 ';

If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND d.SerialNo >=' + LTrim(Str(@SerialNoFr))  
If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND d.SerialNo <=' + LTrim(Str(@SerialNoTo)) 

IF (@FromDate Is Not Null)  
	SET @StrWhere = @StrWhere + ' AND h.DateFrom >='''+ @FromDate +''' AND h.DateTo <='''+ @ToDate +''''

IF (@ToDate Is Not Null)  
	SET @StrWhere = @StrWhere + ' AND  h.DateFrom <='''+ @ToDate +''' AND h.DateTo >=''' + @ToDate + ''''

 IF (@ProductAcntCode Is Not Null)  
	SET @StrWhere = @StrWhere + ' AND  d.ProducerAcntCode ='''+ @ProductAcntCode +''''

 
 IF (@ProductID Is Not Null)  
	SET @StrWhere = @StrWhere + ' AND  d.GoodsID ='''+ @ProductID +''''

  IF (@BatchNo Is Not Null)  
	SET @StrWhere = @StrWhere + ' AND  h.BatchNo ='''+ @BatchNo +''''
	
 
SET @strSelect='select h.ProcessID,h.SerialNo,h.ProducerAcntCode,h.ContractID,d.GoodsID,d.GoodsQuantity,d.WageAmount,
(
	select  isnull(sum(EnterKind*GoodsQuantity),0) from prd.tblProducersWageHdr hh
	inner join prd.tblProducersWageDtl dd  on hh.ProducerAcntCode=dd.ProducerAcntCode
	and hh.SerialNo=dd.SerialNo and hh.ProcessID=dd.ProcessID
	where hh.ProcessID=89 and hh.ProducerAcntCode=h.ProducerAcntCode 
	and hh.BaseSerialNo=h.SerialNo
	) as Decr_incre,

	(
	select  isnull(sum(EnterKind*WageAmount),0) FROM prd.tblProducersWageHdr hh
	inner join prd.tblProducersWageDtl dd  ON hh.ProducerAcntCode=dd.ProducerAcntCode
	and hh.SerialNo=dd.SerialNo and hh.ProcessID=dd.ProcessID
	where hh.ProcessID=89 and hh.ProducerAcntCode=h.ProducerAcntCode 
	and hh.BaseSerialNo=h.SerialNo
	) as Decr_incre_Amount,

	(
	select isnull(sum(GoodsQuantity),0) FROM inv.tblStorageDocsHdr sh
	inner join  inv.tblStorageDocsDtl sd ON sh.ProcessID=sd.ProcessID
	and sh.ProcessNo=sd.ProcessNo and sh.FiscalYear=sd.FiscalYear and sh.SerialNo=sd.SerialNo
	where sh.ProcessID=80 and sh.SourceSerialNo=h.SerialNo and sh.SourceProcessID=h.ProcessID AND sh.AcntCode=h.ProducerAcntCode 
	and sd.GoodsID=d.GoodsID
	)sumSend,
	(
	select isnull(sum(GoodsQuantity),0) FROM inv.tblStorageDocsHdr sh
	inner join  inv.tblStorageDocsDtl sd ON sh.ProcessID=sd.ProcessID
	and sh.ProcessNo=sd.ProcessNo and sh.FiscalYear=sd.FiscalYear and sh.SerialNo=sd.SerialNo
	where sh.ProcessID=85 and sh.SourceSerialNo=h.SerialNo and sh.SourceProcessID=h.ProcessID AND sh.AcntCode=h.ProducerAcntCode 
	and sd.GoodsID=d.GoodsID
	)sumSendRet,
	 pub.GetCodeName(h.ProducerAcntCode,'+ltrim(str(@LangID))+') Acntname,
	 [pub].[funGetGoodsName](d.GoodsID,'+ ltrim(str(@LangID))+') GoodsName

FROM prd.tblProducersWageHdr h
inner join prd.tblProducersWageDtl d
on h.ProducerAcntCode=d.ProducerAcntCode
and h.SerialNo=d.SerialNo and h.ProcessID=d.ProcessID
WHERE  ' + @StrWhere

print @strSelect;
Exec sp_executesql @strSelect;
	 
	---------------------------------------------------------------------------
End
GO
