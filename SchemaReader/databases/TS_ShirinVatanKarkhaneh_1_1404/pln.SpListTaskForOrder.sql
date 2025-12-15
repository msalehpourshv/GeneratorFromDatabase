USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 99/09/09
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE pln.SpListTaskForOrder
@CallType	Int,
@ExtraParams	NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE	@BaseFiscalYearFr	Int
DECLARE	@BaseSerialNoFr		Int
DECLARE	@BaseFiscalYearTo	Int 
DECLARE	@BaseSerialNoTo		Int
DECLARE	@FiscalYearFr		Int
DECLARE	@SerialNoFr			Int
DECLARE	@FiscalYearTo		Int 
DECLARE	@SerialNoTo			Int
DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrWhere 		NVarChar(Max);

SET @BaseFiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 1);
SET @BaseSerialNoFr		= pub.funSplitString(@ExtraParams, '@', 2);
SET @BaseFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 3);
SET @BaseSerialNoTo		= pub.funSplitString(@ExtraParams, '@', 4);
SET @FiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 5);
SET @SerialNoFr		= pub.funSplitString(@ExtraParams, '@', 6);
SET @FiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 7);
SET @SerialNoTo		= pub.funSplitString(@ExtraParams, '@', 8);


		BEGIN TRY			
			drop table #task 
			drop table #T2
		END TRY
		BEGIN CATCH
		END CATCH


 set @StrWhere=' where  1=1 '
	if @BaseFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and bb.BaseFiscalYear>= ' + str(@BaseFiscalYearFr)  +''
	if @BaseSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.BaseSerialNo>= ' + str(@BaseSerialNoFr)  +''
	if @BaseFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and bb.BaseFiscalYear<= ' + str(@BaseFiscalYearTo)  +''
	if @BaseSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.BaseSerialNo<= ' + str(@BaseSerialNoTo)  +''
			
	if @FiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and b.FiscalYear>= ' + str(@FiscalYearFr)  +''
	if @SerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and b.SerialNo>= ' + str(@SerialNoFr)  +''
	if @FiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and b.FiscalYear<= ' + str(@FiscalYearTo)  +''
	if @SerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and b.SerialNo<= ' + str(@SerialNoTo)  +''
	
	select BaseFiscalYear, BaseSerialNo, ProductID,a.* into #task  from pln.tblTaskOrderDtl a
	inner join pln.tblTaskOrderHdr bb
				on a.ProcessID=bb.ProcessID and a.ProcessNo=bb.ProcessNo and a.FiscalYear=bb.FiscalYear and a.SerialNo=bb.SerialNo
				where 0=1

---  لیست انجام هایی که حواله ندارند
set @StrSelect=' insert into  #task 
				select BaseFiscalYear, BaseSerialNo,ProductID,b.* 
				from (select ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
				from pln.tblTaskOrderDtl ta							 
			except
			select  BaseProcessID ,BaseProcessNo ,BaseFiscalYear ,BaseSerialNo ,BaseDocRowNo
				from inv.tblStorageDocsDtl 
				where BaseProcessID=610 and ProcessID in (72,82,83,73)  
				) a
				inner join pln.tblTaskOrderDtl b
				on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
				inner join pln.tblTaskOrderHdr bb
				on a.ProcessID=bb.ProcessID and a.ProcessNo=bb.ProcessNo and a.FiscalYear=bb.FiscalYear and a.SerialNo=bb.SerialNo
				' + @StrWhere

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	select distinct  BaseFiscalYear, BaseSerialNo, a.ProcessID ,a.ProcessNo  ,a.FiscalYear  ,a.SerialNo  
		from #task a
		inner join pln.tblTaskOrderDtl b
			on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
		where a.ProduceStepID =isnull((select top 1 ProduceStepID from pln.tblProduceStepDtl  p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo order by NeedStep desc ,ProduceStepID Desc ),0)
	or a.ProduceStepID in (select ProduceStepID from prd.tblFormulasDtl p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and ProduceStepID<>0)

end
GO
