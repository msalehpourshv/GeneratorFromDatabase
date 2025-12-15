USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1396/07/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : وضعیت حساب مشتری و خوانده حسابها
-- ==============================================
Create procedure acc.SpMatchAccounts
	@AcntCode	varchar(20) =Null,
	@ProcessID int=0 ,
	@ProcessNo int =0,
	@FiscalYear int =0,
	@SerialNo int=0
WITH ENCRYPTION
As
Begin

	BEGIN TRY
			DROP TABLE #tblMatchAccounts1
			DROP TABLE #tblMatchAccounts2
			DROP TABLE #tblAccState1
			DROP TABLE #tblAccState2
		END TRY
		BEGIN CATCH
		END CATCH
	
CREATE TABLE #tblAccState1
	(
	ID					int,
	SerialNo			int,
	DocRowNo			int,
	RecDesc				nvarchar(max),
	SourceProcessID		int,
	SourceProcessNo		int,
	SourceFiscalYear	int,
	SourceSerialNo		int,
	BaseID				int,
	AcntCode			varchar(20) ,
	Debit				bigint,
	Credit				bigint,
	DocDate				char(10),
	Amount				bigint,
	VisitorAcntCode		varchar(20) ,
	ID1					int,
	AcntName			nvarchar(max),
	VisitorName			nvarchar(max)
	)
	
select *  into #tblAccState2 from #tblAccState1 

	CREATE TABLE #tblMatchAccounts1
	(
		ProcessID int ,
		ProcessNo int,
		FiscalYear int,
		SerialNo int
	)
	
	select *  into #tblMatchAccounts2 from #tblMatchAccounts1 
	-- فروش
	insert into #tblMatchAccounts1
	select 	@ProcessID ,@ProcessNo ,@FiscalYear ,@SerialNo 

	insert into #tblMatchAccounts2
	select 	@ProcessID ,@ProcessNo ,@FiscalYear ,@SerialNo 

-- تخفیفات پس از فروش 
	
   Insert into #tblMatchAccounts1
   Select b.ProcessID,0 ProcessNo, b.BaseFiscalYear,b.SerialNo	
                         From  sal.tblAfterSaleBillDtl b 
                          where b.BaseProcessID= @ProcessID 
                           and b.BaseProcessNo= @ProcessNo 
                         and b.BaseFiscalYear= @FiscalYear 
                         and b.BaseSerialNo=  @SerialNo
   --پرداخت ها
   insert into #tblMatchAccounts2
   select ProcessID,ProcessNo,FiscalYear,SerialNo from trs.tblPayHdr 
   where BaseProcessID= @ProcessID
      and BaseProcessNo= @ProcessNo
      and BaseFiscalYear= @FiscalYear
      and BaseSerialNo= @SerialNo
 --برگشت
 insert into #tblMatchAccounts2
 select ProcessID,ProcessNo,FiscalYear,SerialNo 
 from inv.tblStorageDocsHdr where ProcessID=100 
                         and  BaseProcessID=@ProcessID
                          and BaseProcessNo=@ProcessNo
                        and BaseFiscalYear=@FiscalYear
                        and BaseSerialNo=@SerialNo
               
	insert into #tblAccState1
	exec acc.SpAcc_AccState @AcntCode ,1
	
	insert into #tblAccState2
	exec acc.SpAcc_AccState @AcntCode ,2


--select * from #tblMatchAccounts1
--select * from #tblMatchAccounts2

--select * from #tblAccState1
--select * from #tblAccState2

select 1  TypeOut,a.*  from #tblAccState1 a inner join #tblMatchAccounts1 b
on a.SourceProcessID=b.ProcessID and a.SourceProcessNo=b.ProcessNo 
and a.SourceFiscalYear=b.FiscalYear and a.SourceSerialNo=b.SerialNo
union 

select 2  TypeOut,a.* from #tblAccState2 a inner join #tblMatchAccounts2 b
on a.SourceProcessID=b.ProcessID and a.SourceProcessNo=b.ProcessNo 
and a.SourceFiscalYear=b.FiscalYear and a.SourceSerialNo=b.SerialNo

--select a.* from #tblAccState2 a 
--select * from #tblAccState2

END
GO
