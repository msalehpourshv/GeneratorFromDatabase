USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 95/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
--  [inv].[RptGoodsFlow] Null,Null,Null,Null,Null,Null,Null,Null,Null,'','','11111'
Create PROCEDURE [inv].[RptGoodsFlow]

	@Acnt1    VarChar(20) = Null, 
	@Acnt2    VarChar(20) = Null, 
	@Acnt3    VarChar(20) = Null, 
	@Acnt4    VarChar(20) = Null, 
	@StoreID		Int = 0, 
	@GoodsID		Int = 0, 
	@BatchNo		varchar(20) = '', 
	@DocDateFrom	Char(10) = '',
	@DocDateTo	Char(10) = '',
	@Extraparam	    VarChar(1000) = Null, 
	@RepOptions		NVarChar(10) = '11',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@QtyType		Int;
DECLARE	@ProcessNo		Int;
DECLARE	@FromBaseSerialNo		Int;
DECLARE	@ToBaseSerialNo		Int;
DECLARE	@ProcessID190		bit;
DECLARE	@ProcessID192		bit;
DECLARE	@ProcessID193		bit;

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhereAll		NVarChar(2000);
DECLARE @StrWhereQty		NVarChar(2000);
DECLARE @StrWhereStorage		NVarChar(2000);
DECLARE @StrHaving		NVarChar(1000);


DECLARE @ReciveAcnt1    VarChar(20) 
DECLARE @ReciveAcnt2    VarChar(20) 
DECLARE @ReciveAcnt3    VarChar(20) 
DECLARE @ReciveAcnt4    VarChar(20) 

BEGIN 
	--============================ S T A R T ===========================================

	-- init ------------------------------------------------
	SET NOCOUNT ON;

	If (@RepInfo Is Null)	SET @RepInfo = '1@1@1'
	If (@RepOptions Is Null) SET @RepOptions = '11'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @SortByName		= Substring(@RepOptions, 2, 1);

	SET @QtyType		= pub.funSplitString(@Extraparam, '@', 1);
	SET @ProcessNo		= pub.funSplitString(@Extraparam, '@', 2);
	SET @ReciveAcnt1		= pub.funSplitString(@Extraparam, '@', 3);
	SET @ReciveAcnt2		= pub.funSplitString(@Extraparam, '@', 4);
	SET @ReciveAcnt3		= pub.funSplitString(@Extraparam, '@', 5);
	SET @ReciveAcnt4		= pub.funSplitString(@Extraparam, '@', 6);
	SET @ProcessID190		= pub.funSplitString(@Extraparam, '@', 7);
	SET @ProcessID192		= pub.funSplitString(@Extraparam, '@', 8);
	SET @ProcessID193		= pub.funSplitString(@Extraparam, '@', 9);
	SET @FromBaseSerialNo		= pub.funSplitString(@Extraparam, '@', 10);
	SET @ToBaseSerialNo		= pub.funSplitString(@Extraparam, '@', 11);
	
	
	--------------------------------------------------------


	-------------------------------------------------------------------------------------
	-- where ----------------------------------------------------------------------------
	SET @StrWhereAll = ' '--' LanguageID = ' + @LangID + ' '
	SET @StrWhereStorage = '   '--' LanguageID = ' + @LangID + ' '


	IF (@Acnt1 > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt1, 'a.AcntCode')
	IF (@Acnt2 > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt2, 'a.AcntCode')
	IF (@Acnt3 > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt3, 'a.AcntCode')
	IF (@Acnt4 > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt4, 'a.AcntCode')
	IF (@GoodsID > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'a.GoodsID')
		
	IF (@ProcessNo> 0 AND @ProcessNo is not NULL)
			SET @StrWhereAll = @StrWhereAll + ' AND (ProcessNo = ' + str(@ProcessNo) + ')'
	
	
Set @StrWhereQty=''

	IF (@QtyType > 0 and @QtyType is not null)
	begin 

	IF (@QtyType = 1)
		SET @StrWhereQty = @StrWhereQty + ' AND b.QtyIn-b.QtyOut=0 '
	IF (@QtyType = 2)
		SET @StrWhereQty = @StrWhereQty + ' AND b.QtyIn-b.QtyOut>0 '
	IF (@QtyType = 3)
		SET @StrWhereQty = @StrWhereQty + ' AND b.QtyIn-b.QtyOut<0 '
	
	end
	
	
	IF (@ProcessID190= 1 or @ProcessID192= 1 or @ProcessID193= 1 )
	begin
	
	SET @StrWhereQty = @StrWhereQty + ' and ( 1=0 '
		IF (@ProcessID190=1) 
				SET @StrWhereQty = @StrWhereQty + ' or (ProcessID in(190,191))'
		IF (@ProcessID192=1) 
				SET @StrWhereQty = @StrWhereQty + ' or (ProcessID in(192))'
		IF (@ProcessID193=1) 
				SET @StrWhereQty = @StrWhereQty + ' or (ProcessID in(193))'
	SET @StrWhereQty = @StrWhereQty + ' ) '
		
	end 
	
		if @FromBaseSerialNo	<>0
			SET @StrWhereQty = @StrWhereQty + ' and SerialNo>= ' + str( @FromBaseSerialNo)
		if @ToBaseSerialNo	<>0
			SET @StrWhereQty = @StrWhereQty + ' and  SerialNo<= ' + Str(@ToBaseSerialNo)

If (@DocDateTo Is Not Null) 
			SET @StrWhereQty = @StrWhereQty + ' AND (DocDate <= ''' + @DocDateTo + ''')'
	if (@DocDateFrom Is Not Null)
			SET @StrWhereQty = @StrWhereQty + ' AND (DocDate >= ''' + @DocDateFrom + ''')'

	IF (@Acnt1 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt1, 'd.AcntCode')
	IF (@Acnt2 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt2, 'd.AcntCode')
	IF (@Acnt3 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt3, 'd.AcntCode')
	IF (@Acnt4 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt4, 'd.AcntCode')



	IF (@ReciveAcnt1 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ReciveAcnt1, 'd.ReciverAcntCode')
	IF (@ReciveAcnt2 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ReciveAcnt2, 'd.ReciverAcntCode')
	IF (@ReciveAcnt3 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ReciveAcnt3, 'd.ReciverAcntCode')
	IF (@ReciveAcnt4 > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ReciveAcnt4, 'd.ReciverAcntCode')


	IF (@BatchNo <> '' AND @BatchNo is not NULL )
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BatchNo, 'h.BatchNo')
	IF (@StoreID > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'h.StoreID')
	IF (@GoodsID > 0)
		SET @StrWhereStorage = @StrWhereStorage + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'd.GoodsID')
	If (@DocDateTo Is Not Null) 
			SET @StrWhereStorage = @StrWhereStorage + ' AND (d.DocDate <= ''' + @DocDateTo + ''')'
	if (@DocDateFrom Is Not Null)
			SET @StrWhereStorage = @StrWhereStorage + ' AND (d.DocDate >= ''' + @DocDateFrom + ''')'
	IF (@ProcessNo> 0 AND @ProcessNo is not NULL)
			SET @StrWhereStorage = @StrWhereStorage + ' AND (d.ProcessNo = ' + str(@ProcessNo) + ')'

BEGIN TRY
			DROP TABLE #tblGoodsFlow
		END TRY
		BEGIN CATCH
END CATCH

select AcntCode,GoodsID , ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID
, pub.funGetGoodsUnitName(GoodsID,'+ str(@LangID) +') as UnitName,GoodsQuantity
, 0 VQtyIn
, 0 QtyIn
 , 0 VQtyOut
, 0 QtyOut
,pub.funGetGoodsName(GoodsID,'+ str(@LangID) +')  AS GoodsName
 ,pub.GetCodeName(AcntCode, '+ str(@LangID) +') AS AcntName ,'''' as  ReciverAcntCode
 ,'''' AS ReciverAcntName
 into #tblGoodsFlow
  from sal.tblSaleOrderDtl where 1=0 
  			
	SET @StrSelect = '
 insert into #tblGoodsFlow
	select AcntCode,GoodsID , ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID
, pub.funGetGoodsUnitName(GoodsID,'+ str(@LangID) +') as UnitName,GoodsQuantity
, isnull(( Select sum(VirtualQuantity)  From inv.tblStorageDocsDtl d   inner join	inv.tblStorageDocsHdr h
on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
  where d.ProcessID=192    and h.BaseProcessID=a.ProcessID  and h.BaseProcessNo=a.ProcessNo
     and h.BaseFiscalYear=a.FiscalYear and h.BaseSerialNo=a.SerialNo
     and a.GoodsID = substring( d.GoodsID,1,LEN(a.GoodsID))   ),0) VQtyIn
, isnull(( Select sum(NetWeight)  From inv.tblStorageDocsDtl d   inner join	inv.tblStorageDocsHdr h
on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
  where d.ProcessID=192    and h.BaseProcessID=a.ProcessID  and h.BaseProcessNo=a.ProcessNo
     and h.BaseFiscalYear=a.FiscalYear and h.BaseSerialNo=a.SerialNo
     and a.GoodsID = substring( d.GoodsID,1,LEN(a.GoodsID))  ),0) QtyIn
 , isnull((Select sum(VirtualQuantity)  From inv.tblStorageDocsDtl d   inner join	inv.tblStorageDocsHdr h
on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
  where d.ProcessID=193    and h.BaseProcessID=a.ProcessID  and h.BaseProcessNo=a.ProcessNo
     and h.BaseFiscalYear=a.FiscalYear and h.BaseSerialNo=a.SerialNo
     and a.GoodsID = substring( d.GoodsID,1,LEN(a.GoodsID))   ),0) VQtyOut
, isnull((Select sum(NetWeight)  From inv.tblStorageDocsDtl d   inner join	inv.tblStorageDocsHdr h
on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
  where d.ProcessID=193    and h.BaseProcessID=a.ProcessID  and h.BaseProcessNo=a.ProcessNo
     and h.BaseFiscalYear=a.FiscalYear and h.BaseSerialNo=a.SerialNo
     and a.GoodsID = substring( d.GoodsID,1,LEN(a.GoodsID))   ),0) QtyOut
,pub.funGetGoodsName(GoodsID,'+ str(@LangID) +')  AS GoodsName
 ,pub.GetCodeName(AcntCode, '+ str(@LangID) +') AS AcntName ,'''' as  ReciverAcntCode
 ,'''' AS ReciverAcntName
  from sal.tblSaleOrderDtl a where ProcessID in(190,191) '+ @StrWhereAll +'
	'		
		Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	
		
	
	-------------------------------------------------------------------------------------
	-- select ---------------------------------------------------------------------------
	SET @StrSelect = '
insert into  #tblGoodsFlow
Select d.AcntCode ,d.GoodsID , d.ProcessID,d.ProcessNo,d.FiscalYear,0,'''' as DocDate,d.StoreID, pub.funGetGoodsUnitName(GoodsID,'+ str(@LangID) +') as UnitName,0,Sum(VirtualQuantity),SUM(NetWeight),0 ,0,pub.funGetGoodsName(GoodsID,'+ str(@LangID) +')  AS GoodsName,pub.GetCodeName(d.AcntCode, '+ str(@LangID) +') AS AcntName
,ReciverAcntCode ,pub.GetCodeName(ReciverAcntCode, '+ str(@LangID) +') AS ReciverAcntName
  From inv.tblStorageDocsDtl d inner join	inv.tblStorageDocsHdr h
on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
 And h.BaseSerialNo=0 where d.ProcessID=192 '+ @StrWhereStorage +'Group by  d.AcntCode ,d.GoodsID ,d.StoreID, d.ProcessID,d.ProcessNo,d.FiscalYear,ReciverAcntCode
	'
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	SET @StrSelect = '
insert into  #tblGoodsFlow

Select d.AcntCode ,d.GoodsID , d.ProcessID,d.ProcessNo,d.FiscalYear,0,'''' as DocDate,d.StoreID, pub.funGetGoodsUnitName(GoodsID,'+ str(@LangID) +') as UnitName,0,0,0,Sum(VirtualQuantity),SUM(NetWeight) ,pub.funGetGoodsName(GoodsID,'+ str(@LangID) +')  AS GoodsName ,pub.GetCodeName(d.AcntCode,'+ str(@LangID) +') AS AcntName 
,ReciverAcntCode ,pub.GetCodeName(ReciverAcntCode, '+ str(@LangID) +') AS ReciverAcntName
 From inv.tblStorageDocsDtl d inner join	inv.tblStorageDocsHdr h
on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
 And h.BaseSerialNo=0 where d.ProcessID=193 '+ @StrWhereStorage +'Group by  d.AcntCode ,d.GoodsID ,d.StoreID, d.ProcessID,d.ProcessNo,d.FiscalYear,ReciverAcntCode
'
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	
	-------------------------------------------------------------------------------------
	-- run ------------------------------------------------------------------------------
	SET @StrSelect = ' Select * from  #tblGoodsFlow Where 1=1 	'+@StrWhereQty
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	-------------------------------------------------------------------------------------
END
GO
