USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1397/01/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : انتقال حسابهای تطبیق نشده به سال جدید
-- ==============================================
Create procedure acc.SpAcc_AccStateTrans2NewYear
WITH ENCRYPTION
as
begin

	Declare @DbNameOld 	NVarChar(100);
	Declare @DbName 	NVarChar(100);
	Declare @StrSelect	NVarChar(max);
	Declare @StrParams	NVarChar(max);
	Declare @intCount	int;


	select @DbName=DB_name()
	

	
	exec pub.SpGetPrevDBName @DbName,@DbNameOld output
		--Select @DbName,@DbNameOld

	set @StrSelect= ' select @intCount2=Count(*)  from     '+@DbNameOld+'.acc.tblAccState;  '
	
	SET @StrParams = N'  @intCount2 int OUTPUT';

	Exec sp_executesql  @StrSelect, @StrParams, @intCount OUTPUT;

	if  @intCount<=0 
		return ;



	 SELECT     0 ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode, Debit, Credit, DocDate, 
						  Amount, VisitorAcntCode, ID1, RecDesc AcntName,RecDesc VisitorName
						  into #tblV2A
	FROM         acc.tblVoucher2AccState where 1=0



set @StrSelect= ' insert  into #tblV2A  exec '+@DbNameOld+'.acc.SpAcc_AccState '''',1'
 
 print @StrSelect
	Exec sp_executesql  @StrSelect;
	
set @StrSelect= 'insert  into #tblV2A exec '+@DbNameOld+'.acc.SpAcc_AccState '''',2'
 
 print @StrSelect
	Exec sp_executesql  @StrSelect;
	
	    
Update  #tblV2A
Set Amount=-1*Amount
where Debit=0

--Drop table  #tblV2A2

update  acc.tblVoucherDtl 	set BaseID=ID 	where SourceProcessID=0 and (BaseID =0 or BaseID =1)  and (SELECT	 Count(*) 		FROM	acc.tblVoucherDtl 		WHERE	VchKind = 3)<1


select Amount,AcntCode, VisitorAcntCode  into #tblV2A2 from #tblV2A where 1=0
insert into #tblV2A2
select SUM(Amount) Amount,AcntCode, VisitorAcntCode   from #tblV2A
Group by AcntCode, VisitorAcntCode


delete from  #tblV2A2 where Amount=0

--Select * from  #tblV2A2 where AcntCode='111301 0300101111036'
--Select * from  acc.tblVoucherDtl where AcntCode='111301 0300101111036'
--Select * from  acc.tblVoucherDtl where AcntCode='111301 0300101071023'
--Select * from  acc.tblVoucherDtl where AcntCode='111301 0300101216001'


Delete from acc.tblVoucher2AccState
--- برای ورود اطلاعات براساس سند افتتاحیه
insert into acc.tblVoucher2AccState
(SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,
 BaseID, AcntCode, Debit, Credit, DocDate, Amount,  ID1, ActiveHalf,VisitorAcntCode)
 
Select SerialNo,DocRowNo,RecDesc,SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,
BaseID,a.AcntCode,Debit, Credit, DocDate,Amount,ID,1 ,b.VisitorAcntCode from acc.tblVoucherDtl a 
inner join #tblV2A2  b 
on a.AcntCode=b.AcntCode and b.Amount>0 and Debit>0
 where a.VchKind=2 

insert into acc.tblVoucher2AccState
(SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,
 BaseID, AcntCode, Debit, Credit, DocDate, Amount,  ID1, ActiveHalf,VisitorAcntCode)
 
Select SerialNo,DocRowNo,RecDesc,SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,
BaseID,a.AcntCode,Debit, Credit, DocDate,Amount*-1,ID,1 ,b.VisitorAcntCode from acc.tblVoucherDtl a 
inner join #tblV2A2  b 
on a.AcntCode=b.AcntCode and b.Amount<0 and Debit=0
 where a.VchKind=2

 update  acc.tblVoucher2AccState
 set Amount=Debit+ Credit
 where Amount>Debit+ Credit
 -----برای ایجاد کپی از جدول میانی برای ویزیتور ها--------------------------------------------------------------------
Begin
		BEGIN TRY
			DROP TABLE  acc.tblVoucher2AccStateVoucher1			 
		END TRY
		BEGIN CATCH
		END CATCH
End
	
select * into  acc.tblVoucher2AccStateVoucher1		 from acc.tblVoucher2AccState where SerialNo=1
and (Select count(*) from acc.tblVoucherDtl where VchKind=2)>0
----  در ثبت سند افتتاحیه همه چیز خالی است
--and AcntCode   in  
--(
--select distinct AcntCode from inv.tblStorageDocsHdr
--union
--select distinct AcntCode from acc.tblServicesHdr
---- علت برگشتیها به خاطر برگشت چک مشتری تسویه شده سال قبل در این سال
--union
--select distinct CreditCode from trs.tblPayDtl where ProcessID in (13,17,18,23,24)
--union
--select distinct DebitCode from trs.tblPayDtl where ProcessID in (13,17,18,23,24)
--) 
--  بروز رسانی ویزیتور سند افتتا حیه
Update acc.tblVoucherDtl
	set VisitorAcntCode=b.VisitorAcntCode
from acc.tblVoucherDtl a
inner join acc.tblVoucher2AccStateVoucher1	b
	on a.AcntCode=b.AcntCode and a.Debit=b.Debit and a.Credit=b.Credit and a.RowNo =b.DocRowNo and a.SerialNo=b.SerialNo
where a.VisitorAcntCode='' and b.VisitorAcntCode<>''
and a.VchKind=2

end

GO
