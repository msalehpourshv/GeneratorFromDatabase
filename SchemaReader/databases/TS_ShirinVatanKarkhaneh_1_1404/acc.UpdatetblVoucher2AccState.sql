USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/07/09
-- Viewed By	 : 
-- Last Modified : 1395/10/15
-- Last Modifier :
-- ----------------------------------------------
-- Description	 :  بروز رسانی جدول میانی تطیق 
-- ==============================================
Create PROCEDURE acc.UpdatetblVoucher2AccState
@ExtraParams nvarchar(1000)
WITH ENCRYPTION
as

BEGIN -- ============================ S T A R T =====================================================

declare @AcntCode	varchar(20)

SET @AcntCode		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 

-- ProcessID	4
-- ProcessNo	2
-- FiscalYear	4
-- SerialNo		8
-- DocRowNo		5
-- BaseID		5

exec  acc.UpdatePPFSDB 

update acc.tblVoucherDtl 	
set BaseID=ID 	
where AcntCode=@AcntCode and
	SourceProcessID=0 and 
	(BaseID =0 or BaseID =1) and 
	(SELECT	Count(*) 
	 FROM acc.tblVoucherDtl 		
	 WHERE VchKind = 3) < 1

------------------------------------------------------------------------------------------------------------
----  @Type=0 برای  حالت با مرجع
----  @Type=1 بازسازی جدول میانی
---  حذف اطلاعات جدول میانی کلی و یا بصور ت انتخابی
delete from acc.tblVoucher2AccState     	
where AcntCode=@AcntCode
--	and (PPFSD1=@PPFSD1 or PPFSD1=@PPFSD2 or @Type=1)	

-----  حذف اطلاعاتی که سند آنها موجود نیست
delete from acc.tblAccState 
	from  acc.tblAccState a 
	inner join (SELECT AcntCode, SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1, SourceDocRowNo1,BaseID1,SerialNo1
				FROM acc.tblAccState
				Where AcntCode=@AcntCode
				except 
				select AcntCode, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID ,SerialNo
				from acc.tblVoucherDtl
				where AcntCode=@AcntCode and VchKind>0 and Credit=0) b 

	ON a.AcntCode = b.AcntCode 
		AND a.SourceProcessID1 = b.SourceProcessID1 
		AND a.SourceProcessNo1 = b.SourceProcessNo1 		
		AND a.SourceFiscalYear1 = b.SourceFiscalYear1 
		AND a.SourceSerialNo1 = b.SourceSerialNo1		
		AND a.SourceDocRowNo1 = b.SourceDocRowNo1		
		AND a.BaseID1 = b.BaseID1
		AND a.SerialNo1 = b.SerialNo1

delete from acc.tblAccState 
	from  acc.tblAccState a 

	inner join (SELECT  AcntCode, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2, SourceSerialNo2,SourceDocRowNo2, BaseID2,SerialNo2
				FROM acc.tblAccState
				Where AcntCode=@AcntCode
				except 
				select AcntCode, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID ,SerialNo
				from acc.tblVoucherDtl
				where AcntCode=@AcntCode and VchKind>0 and Debit=0) b 

	ON a.AcntCode = b.AcntCode 		
		AND a.SourceProcessID2 = b.SourceProcessID2 
		AND a.SourceProcessNo2 = b.SourceProcessNo2 		
		AND a.SourceFiscalYear2 = b.SourceFiscalYear2 
		AND a.SourceSerialNo2 = b.SourceSerialNo2		
		AND a.SourceDocRowNo2 = b.SourceDocRowNo2		
		AND a.SerialNo2 = b.SerialNo2 

------------------------------------------------------------------------------------------------------------
-- حذف اطلاعات جدول میانی به شرطی مجموع مبلغ تطبیق و میانی بزرگتر از سند باشد 

delete from acc.tblAccState  
	from acc.tblAccState  ab
	inner join 
	  (
			select right('00000'+LTRIM (rtrim( cast(SourceProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(SourceProcessNo as char(20)))) , 2) 
			 +right('00000'+LTRIM (rtrim( cast(SourceFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(SourceSerialNo as char(20)))) , 8) 
			 +right('00000'+LTRIM (rtrim( cast(SourceDocRowNo as char(20)))) , 5) PPFSD1 ,AcntCode,SerialNo,sum(Debit)  Amount
			from acc.tblVoucherDtl
			where AcntCode=@AcntCode and Credit=0
			Group by SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,AcntCode,SerialNo
		) a 
		on    a.PPFSD1=ab.PPFSD1 and a.AcntCode=ab.AcntCode and a.SerialNo=ab.SerialNo1
		inner join
		(
			select PPFSD1,Sum(Amount)Amount,AcntCode,SerialNo1
			FROM acc.tblAccState
			where AcntCode=@AcntCode
			Group by PPFSD1,AcntCode,SerialNo1
		) b on a.PPFSD1=b.PPFSD1 and a.AcntCode=b.AcntCode and a.SerialNo=b.SerialNo1		
	where a.AcntCode=@AcntCode and a.Amount <isnull(b.Amount,0)
	

delete from acc.tblAccState  
	from acc.tblAccState  ab
	inner join (
			select right('00000'+LTRIM (rtrim( cast(SourceProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(SourceProcessNo as char(20)))) , 2) 
			 +right('00000'+LTRIM (rtrim( cast(SourceFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(SourceSerialNo as char(20)))) , 8) 
			 +right('00000'+LTRIM (rtrim( cast(SourceDocRowNo as char(20)))) , 5) PPFSD2,AcntCode,SerialNo
				,sum(Credit)  Amount 
			from acc.tblVoucherDtl
			where AcntCode=@AcntCode and Debit=0
			Group by SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,AcntCode,SerialNo
		) a
		on    a.PPFSD2=ab.PPFSD2 and a.AcntCode=ab.AcntCode and a.SerialNo=ab.SerialNo2
		inner join
		(
			select  PPFSD2 ,Sum(Amount)Amount  ,AcntCode,SerialNo2
			FROM acc.tblAccState
			where  AcntCode=@AcntCode
			Group by PPFSD2,AcntCode,SerialNo2
		) b on a.PPFSD2=b.PPFSD2 and a.AcntCode=b.AcntCode and a.SerialNo=b.SerialNo2	 		
		where a.AcntCode=@AcntCode and a.Amount <isnull(b.Amount,0) 
 
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- بروز کردن اطلاعات جدول میانی   debit
 Insert into acc.tblVoucher2AccState     	
		(SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID, 
	 	AcntCode, Debit, Credit, DocDate, ID1, Amount,VisitorAcntCode)

 select a.SerialNo, a.DocRowNo, a.RecDesc, a.SourceProcessID, a.SourceProcessNo, a.SourceFiscalYear, a.SourceSerialNo,a.SourceDocRowNo, a.BaseID, 
	 	a.AcntCode, a.Debit, a.Credit, a.DocDate, a.ID, a.Debit - ISNULL(b1.Amount,0)  Amount ,VisitorAcntCode

 from  (select SerialNo,DocRowNo,RecDesc,SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,BaseID, AcntCode,  Debit ,Credit ,DocDate,ID , 
 right('00000'+LTRIM (rtrim( cast(SourceProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(SourceProcessNo as char(20)))) , 2) 
			 +right('00000'+LTRIM (rtrim( cast(SourceFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(SourceSerialNo as char(20)))) , 8) 
			 +right('00000'+LTRIM (rtrim( cast(SourceDocRowNo as char(20)))) , 5)   PPFSD1,
			 right('00000'+LTRIM (rtrim( cast(SourceProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(SourceProcessNo as char(20)))) , 2) 
			 +right('00000'+LTRIM (rtrim( cast(SourceFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(SourceSerialNo as char(20)))) , 8) 
			 +right('00000'+LTRIM (rtrim( cast(SourceDocRowNo as char(20)))) , 5)+right('00000'+LTRIM (rtrim( cast(BaseID as char(20)))) , 5) PPFSDB1,VisitorAcntCode
		from  acc.tblVoucherDtl v
		where AcntCode = @AcntCode and VchKind>0  and VchKind<>3 and Credit=0 
		)a
left join (
		select  PPFSD1,PPFSDB1,SUM(Amount) Amount,AcntCode,SerialNo1
		from acc.tblAccState 
		where AcntCode = @AcntCode 
		group by PPFSD1,PPFSDB1,AcntCode ,SerialNo1
	)b1	on a.PPFSDB1=b1.PPFSDB1 and a.AcntCode=b1.AcntCode and a.SerialNo=b1.SerialNo1
	where a.AcntCode = @AcntCode and a.Debit > ISNULL(b1.Amount,0)

---- بروز کردن اطلاعات جدول میانی   Credit
 Insert into acc.tblVoucher2AccState     	
		(SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, 
	 	 AcntCode, Debit, Credit, DocDate, ID1, Amount,VisitorAcntCode)
	select a.SerialNo, a.DocRowNo, a.RecDesc, a.SourceProcessID, a.SourceProcessNo, a.SourceFiscalYear, a.SourceSerialNo,a.SourceDocRowNo
	    , a.BaseID, a.AcntCode, a.Debit, a.Credit, a.DocDate, a.ID, a.Credit - ISNULL(b2.Amount,0)  Amount,VisitorAcntCode 
	from 
	 (select SerialNo,DocRowNo,RecDesc,SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID, AcntCode,  Debit ,Credit ,DocDate,ID ,
	 right('00000'+LTRIM (rtrim( cast(SourceProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(SourceProcessNo as char(20)))) , 2) 
			 +right('00000'+LTRIM (rtrim( cast(SourceFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(SourceSerialNo as char(20)))) , 8) 
			 +right('00000'+LTRIM (rtrim( cast(SourceDocRowNo as char(20)))) , 5)   PPFSD2,
			 right('00000'+LTRIM (rtrim( cast(SourceProcessID as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast(SourceProcessNo as char(20)))) , 2) 
			 +right('00000'+LTRIM (rtrim( cast(SourceFiscalYear as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast(SourceSerialNo as char(20)))) , 8) 
			 +right('00000'+LTRIM (rtrim( cast(SourceDocRowNo as char(20)))) , 5)+right('00000'+LTRIM (rtrim( cast(BaseID as char(20)))) , 5) PPFSDB2,VisitorAcntCode
	 from acc.tblVoucherDtl v
      where AcntCode = @AcntCode  and VchKind>0  and  VchKind<>3 and Debit=0 
	  )a
	left join 
	(	select  PPFSD2,PPFSDB2, SUM(Amount) Amount,AcntCode,SerialNo2 
		from acc.tblAccState 
		where (AcntCode = @AcntCode) 
		group by  PPFSD2,PPFSDB2,AcntCode,SerialNo2
	)b2	on a.PPFSDB2=b2.PPFSDB2  and a.AcntCode=b2.AcntCode and a.SerialNo=b2.SerialNo2
	---- ID به خاطر اینکه اگر در دریافت دوسطر با مبالغ یکسان باشد لز هر دو کسر نشود لینک شده است
	where a.AcntCode=@AcntCode and a.Credit > ISNULL(b2.Amount,0)

--------------------------------------------------------------------------------------------------------------
delete from acc.tblVoucher2AccState     	
where AcntCode=@AcntCode and Amount<=0 
 
 exec  acc.UpdateAllMatch
 exec  acc.UpdatePPFSDB 
 
END
GO
