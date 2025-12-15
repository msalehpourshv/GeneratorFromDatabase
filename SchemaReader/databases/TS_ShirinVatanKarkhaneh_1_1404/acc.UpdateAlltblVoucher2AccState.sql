USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/08/05
-- Viewed By	 : 
-- Last Modified : 1395/10/15
-- Last Modifier :
-- ----------------------------------------------
-- Description	 :  بروز رسانی کل جدول میانی تطیق 
-- ==============================================
Create PROCEDURE acc.UpdateAlltblVoucher2AccState
WITH ENCRYPTION
as

BEGIN -- ============================ S T A R T =====================================================
  
update acc.tblVoucherDtl 	
set BaseID=ID 	
where SourceProcessID=0 and 
	(BaseID =0 or BaseID =1) and 
	(SELECT	Count(*) 
	 FROM acc.tblVoucherDtl 		
	 WHERE VchKind = 3) < 1

------------------------------------------------------------------------------------------------------------

---  حذف اطلاعات جدول میانی کلی و یا بصور ت انتخابی
delete from acc.tblVoucher2AccState     	

BEGIN TRY
			DROP TABLE #tbl11
			DROP TABLE #tbl12
			DROP TABLE #tbl13
			DROP TABLE #tbl14			
		END TRY
		BEGIN CATCH
		END CATCH
----------------------------------------------------------------------------
-- حذف اطلاعات جدول میانی به شرطی تطبیق در سند نباشد 
	SELECT AcntCode, SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1,SerialNo1 
		into #tbl11
	FROM acc.tblAccState
		except 
	select AcntCode, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID ,SerialNo
	from acc.tblVoucherDtl
	where VchKind>0 and Credit=0

	if (select Count(*) from  #tbl11)>0
	delete from acc.tblAccState
		from  acc.tblAccState a 
		inner join #tbl11 b 
		ON a.AcntCode = b.AcntCode 
			AND a.SourceProcessID1 = b.SourceProcessID1 
			AND a.SourceProcessNo1 = b.SourceProcessNo1 		
			AND a.SourceFiscalYear1 = b.SourceFiscalYear1 
			AND a.SourceSerialNo1 = b.SourceSerialNo1		
			AND a.SourceDocRowNo1 = b.SourceDocRowNo1		
			AND a.BaseID1 = b.BaseID1
			AND a.SerialNo1 = b.SerialNo1

----------------------------------------------------------------------------			
	SELECT  AcntCode, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2, SourceSerialNo2,SourceDocRowNo2, BaseID2,SerialNo2  
		into #tbl12
	FROM acc.tblAccState
		except 
	select AcntCode, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID ,SerialNo
	from acc.tblVoucherDtl
	where VchKind>0 and Debit=0			

	if (select Count(*) from  #tbl12)>0
	delete from acc.tblAccState 
		from  acc.tblAccState a 

		inner join #tbl12 b 

		ON a.AcntCode = b.AcntCode 		
			AND a.SourceProcessID2 = b.SourceProcessID2 
			AND a.SourceProcessNo2 = b.SourceProcessNo2 		
			AND a.SourceFiscalYear2 = b.SourceFiscalYear2 
			AND a.SourceSerialNo2 = b.SourceSerialNo2		
			AND a.SourceDocRowNo2 = b.SourceDocRowNo2		
			AND a.SerialNo2 = b.SerialNo2 

------------------------------------------------------------------------------------------------------------
-- حذف اطلاعات جدول میانی به شرطی مجموع مبلغ تطبیق بزرگتر از سند باشد 
	Select b.*
	into #tbl13
	from 
		(	select SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,AcntCode,SerialNo,sum(Debit)  Amount
			from acc.tblVoucherDtl
			where Credit=0
			Group by SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,AcntCode,SerialNo
		) a 
		inner join
		(	select Sum(Amount)Amount,AcntCode,SerialNo1,SourceProcessID1,SourceProcessNo1,SourceFiscalYear1,SourceSerialNo1,SourceDocRowNo1
			FROM acc.tblAccState
			Group by AcntCode,SerialNo1,SourceProcessID1,SourceProcessNo1,SourceFiscalYear1,SourceSerialNo1,SourceDocRowNo1
		) b on a.SourceProcessID=b.SourceProcessID1
				and a.SourceProcessNo=b.SourceProcessNo1
				and a.SourceFiscalYear=b.SourceFiscalYear1
				and a.SourceSerialNo=b.SourceSerialNo1
				and a.SourceDocRowNo=b.SourceDocRowNo1	
				and a.AcntCode=b.AcntCode 
				and a.SerialNo=b.SerialNo1
		where a.Amount <isnull(b.Amount,0)

	if (select Count(*) from  #tbl13)>0
	delete from acc.tblAccState  
	from acc.tblAccState  b
		inner join 	#tbl13 a 
		on  a.SourceProcessID1=b.SourceProcessID1
		and a.SourceProcessNo1=b.SourceProcessNo1
		and a.SourceFiscalYear1=b.SourceFiscalYear1
		and a.SourceSerialNo1=b.SourceSerialNo1
		and a.SourceDocRowNo1=b.SourceDocRowNo1 
		and a.AcntCode=b.AcntCode 
		and a.SerialNo1=b.SerialNo1
		
------------------------------------------------------------------------------------------------------------	
	Select b.*	into #tbl14
		from  
			(	select SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,AcntCode,SerialNo
					,sum(Credit)  Amount 
				from acc.tblVoucherDtl
				where Debit=0
				Group by SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,AcntCode,SerialNo
			) a
		inner join
			(	select  Sum(Amount)Amount  ,AcntCode,SerialNo2,SourceProcessID2,SourceProcessNo2,SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2
				FROM acc.tblAccState
				Group by PPFSD2,AcntCode,SerialNo2,SourceProcessID2,SourceProcessNo2,SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2
			) b on a.SourceProcessID=b.SourceProcessID2
				and a.SourceProcessNo=b.SourceProcessNo2
				and a.SourceFiscalYear=b.SourceFiscalYear2
				and a.SourceSerialNo=b.SourceSerialNo2
				and a.SourceDocRowNo=b.SourceDocRowNo2	
			and a.AcntCode=b.AcntCode and a.SerialNo=b.SerialNo2	 		
			where a.Amount <isnull(b.Amount,0) 

	if (select Count(*) from  #tbl14)>0
	delete from acc.tblAccState  
		from acc.tblAccState  b
		inner join 	#tbl14 a 
		on  a.SourceProcessID2=b.SourceProcessID2
		and a.SourceProcessNo2=b.SourceProcessNo2
		and a.SourceFiscalYear2=b.SourceFiscalYear2
		and a.SourceSerialNo2=b.SourceSerialNo2
		and a.SourceDocRowNo2=b.SourceDocRowNo2 
		and a.AcntCode=b.AcntCode 
		and a.SerialNo2=b.SerialNo2
		
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- بروز کردن اطلاعات جدول میانی   debit
 Insert into acc.tblVoucher2AccState     	
		(SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, 
	 		AcntCode, Debit, Credit, DocDate, ID1, Amount,VisitorAcntCode) 		
		select a.SerialNo, a.DocRowNo, a.RecDesc, a.SourceProcessID, a.SourceProcessNo, a.SourceFiscalYear, a.SourceSerialNo,a.SourceDocRowNo, a.BaseID, 
		 	a.AcntCode, a.Debit, a.Credit, a.DocDate, a.ID, a.Debit - ISNULL(b1.Amount,0)  Amount ,VisitorAcntCode
		from  
			(select SerialNo,DocRowNo,RecDesc,SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo,BaseID, AcntCode,  Debit ,Credit ,DocDate,ID ,VisitorAcntCode
				from  acc.tblVoucherDtl v
				where VchKind>0  and VchKind<>3 and Credit=0 
			)a
		left join 
			(select  SUM(Amount) Amount,AcntCode,SerialNo1,SourceProcessID1,SourceProcessNo1,SourceFiscalYear1,SourceSerialNo1,SourceDocRowNo1,BaseID1
					from acc.tblAccState 
					group by AcntCode ,SerialNo1,SourceProcessID1,SourceProcessNo1,SourceFiscalYear1,SourceSerialNo1,SourceDocRowNo1,BaseID1
			)b1	on a.SourceProcessID=b1.SourceProcessID1
					and a.SourceProcessNo=b1.SourceProcessNo1
					and a.SourceFiscalYear=b1.SourceFiscalYear1
					and a.SourceSerialNo=b1.SourceSerialNo1
					and a.SourceDocRowNo=b1.SourceDocRowNo1	
					and a.BaseID=b1.BaseID1	
					and a.AcntCode=b1.AcntCode 
					and a.SerialNo=b1.SerialNo1
		where a.Debit > ISNULL(b1.Amount,0)

---- بروز کردن اطلاعات جدول میانی   Credit
 Insert into acc.tblVoucher2AccState     	
		(SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, 
	 		AcntCode, Debit, Credit, DocDate, ID1, Amount,VisitorAcntCode)
		select a.SerialNo, a.DocRowNo, a.RecDesc, a.SourceProcessID, a.SourceProcessNo, a.SourceFiscalYear, a.SourceSerialNo,a.SourceDocRowNo
			, a.BaseID, a.AcntCode, a.Debit, a.Credit, a.DocDate, a.ID, a.Credit - ISNULL(b2.Amount,0)  Amount,VisitorAcntCode 
		from 
			(select SerialNo,DocRowNo,RecDesc,SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode,  Debit ,Credit ,DocDate,ID , VisitorAcntCode
			from acc.tblVoucherDtl v
			where VchKind>0  and  VchKind<>3 and Debit=0 
			)a
		left join 
			(select  SUM(Amount) Amount,AcntCode,SerialNo2 ,SourceProcessID2,SourceProcessNo2,SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2,BaseID2
				from acc.tblAccState 
				group by AcntCode,SerialNo2,SourceProcessID2,SourceProcessNo2,SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2,BaseID2
			)b2	on a.SourceProcessID=b2.SourceProcessID2
				and a.SourceProcessNo=b2.SourceProcessNo2
				and a.SourceFiscalYear=b2.SourceFiscalYear2
				and a.SourceSerialNo=b2.SourceSerialNo2
				and a.SourceDocRowNo=b2.SourceDocRowNo2	
				and a.BaseID=b2.BaseID2
				and a.AcntCode=b2.AcntCode and a.SerialNo=b2.SerialNo2
	where a.Credit > ISNULL(b2.Amount,0)

--------------------------------------------------------------------------------------------------------------
delete from acc.tblVoucher2AccState     	
where Amount<=0 


 exec  acc.UpdateAllMatch 
END
GO
