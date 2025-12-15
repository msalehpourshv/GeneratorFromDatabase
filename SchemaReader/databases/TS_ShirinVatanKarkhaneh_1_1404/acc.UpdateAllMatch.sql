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
-- Description	 :  بروز رسانی  جدول تطبیق و جدول میانی تطیق 
-- ==============================================
Create PROCEDURE acc.UpdateAllMatch
WITH ENCRYPTION
as
BEGIN -- ============================ S T A R T =====================================================

	declare @Sal_HasPayment bit
	
	SET @Sal_HasPayment = 'False'
	
	SELECT @Sal_HasPayment = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_HasPayment'

if (@Sal_HasPayment = 'True')
begin
		------تطبیق حسابهای دو طرفه مانند فروش و تخفیفات 
		------برگشت و تخفیفات
		select 
			a.SourceProcessID a1, a.SourceProcessNo a2, a.SourceFiscalYear a3, a.SourceSerialNo a4,a.SourceDocRowNo a41, a.BaseID a5
			, b.SourceProcessID b1,  b.SourceProcessNo b2, b.SourceFiscalYear b3,b.SourceSerialNo b4,b.SourceDocRowNo b41, b.BaseID b5
			, a.DocDate, a.AcntCode
			,1 EventNo				,Case when  a.Amount> b.Amount then b.Amount  else a.Amount end Amount , 'تطبیق اتوماتیک' RecDesc, 
			Case when  a.VisitorAcntCode='' then b.VisitorAcntCode  else a.VisitorAcntCode end VisitorAcntCode ,a.VisitorAcntCode VisitorAcntCode1,b.VisitorAcntCode VisitorAcntCode2
			,a.SerialNo SerialNo1,b.SerialNo SerialNo2
		INTO #tblVoucher2AccStateF
			from (select * from acc.tblVoucher2AccState where Debit=0)b
			inner join (select * from acc.tblVoucher2AccState where Credit=0)a
				on a.AcntCode=b.AcntCode
				and a.SourceProcessID=b.SourceProcessID
				and a.SourceProcessNo=b.SourceProcessNo	
				and a.SourceFiscalYear=b.SourceFiscalYear
				and a.SourceSerialNo=b.SourceSerialNo
				and a.SourceDocRowNo=b.SourceDocRowNo
				and a.BaseID=b.BaseID
				and a.SourceProcessID<>0 
				And a.BaseID=1 And b.BaseID=1 -- برای ااینکه فروش یکبار با تخفیفات تطبیق شود نه با فروش و مالیات که دوبار شود

		insert into  acc.tblAccState 
				(SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1
				, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2, BaseID2
				, DocDate, AcntCode, EventNo
				, Amount, RecDesc, VisitorAcntCode, VisitorAcntCode1, VisitorAcntCode2,SerialNo1,SerialNo2)  
		SELECT * from  #tblVoucher2AccStateF


		delete from acc.tblVoucher2AccState
			from acc.tblVoucher2AccState a
			inner join #tblVoucher2AccStateF b
			on a.AcntCode=b.AcntCode
			and a.SourceProcessID=b.a1
			and a.SourceProcessNo=b.a2
			and a.SourceFiscalYear=b.a3
			and a.SourceSerialNo=b.a4
			and a.SourceDocRowNo=b.a41
			and a.BaseID=b.a5
			and a.Amount=b.Amount

		delete from acc.tblVoucher2AccState
			from acc.tblVoucher2AccState a
			inner join #tblVoucher2AccStateF b
			on a.AcntCode=b.AcntCode
			and a.SourceProcessID=b.b1
			and a.SourceProcessNo=b.b2
			and a.SourceFiscalYear=b.b3
			and a.SourceSerialNo=b.b4
			and a.SourceDocRowNo=b.b41
			and a.BaseID=b.b5
			and a.Amount=b.Amount
			
		update acc.tblVoucher2AccState
			set Amount = a.Amount-b.Amount
			from acc.tblVoucher2AccState a
			inner join #tblVoucher2AccStateF b
			on a.AcntCode=b.AcntCode
			and a.SourceProcessID=b.a1
			and a.SourceProcessNo=b.a2
			and a.SourceFiscalYear=b.a3
			and a.SourceSerialNo=b.a4
			and a.SourceDocRowNo=b.a41
			and a.BaseID=b.a5
			and a.Amount>b.Amount
			
		update acc.tblVoucher2AccState
			set Amount = a.Amount-b.Amount
			from acc.tblVoucher2AccState a
			inner join #tblVoucher2AccStateF b
			on a.AcntCode=b.AcntCode
			and a.SourceProcessID=b.b1
			and a.SourceProcessNo=b.b2
			and a.SourceFiscalYear=b.b3
			and a.SourceSerialNo=b.b4
			and a.SourceDocRowNo=b.b41
			and a.BaseID=b.b5
			and a.Amount>b.Amount
			
			
			------تطبیق حسابهای تخفیفات پس از فروش
			
		select 
			a.SourceProcessID a1, a.SourceProcessNo a2, a.SourceFiscalYear a3, a.SourceSerialNo a4,a.SourceDocRowNo a41, a.BaseID a5
			, b.SourceProcessID b1,  b.SourceProcessNo b2, b.SourceFiscalYear b3,b.SourceSerialNo b4,b.SourceDocRowNo b41, b.BaseID b5
			, a.DocDate, a.AcntCode
			,1 EventNo				,Case when  a.Amount> b.Amount then b.Amount  else a.Amount end Amount , 'تطبیق اتوماتیک' RecDesc, 
			Case when  a.VisitorAcntCode='' then b.VisitorAcntCode  else a.VisitorAcntCode end VisitorAcntCode,a.VisitorAcntCode VisitorAcntCode1,b.VisitorAcntCode VisitorAcntCode2
			,a.SerialNo SerialNo1,b.SerialNo SerialNo2
		INTO #tblVoucher2AccStateFD	
		from (select * from acc.tblVoucher2AccState where Debit=0)b
		inner join (select * from acc.tblVoucher2AccState where Credit=0)a
			on a.AcntCode=b.AcntCode
			and b.SourceProcessID=95
			and a.SourceProcessID=90
			and a.SourceProcessNo=b.SourceProcessNo
			and a.SourceFiscalYear=b.SourceFiscalYear
			and a.SourceSerialNo=b.SourceSerialNo
			and a.SourceDocRowNo=b.SourceDocRowNo
			and a.SourceProcessID<>0 
			And a.BaseID=1 And b.BaseID=1 -- برای ااینکه فروش یکبار با تخفیفات تطبیق شود نه با فروش و مالیات که دوبار شود

		insert into  acc.tblAccState 
					(SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1
					, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2, SourceDocRowNo2,BaseID2
					, DocDate, AcntCode, EventNo
					, Amount, RecDesc, VisitorAcntCode, VisitorAcntCode1, VisitorAcntCode2,SerialNo1,SerialNo2)  
			
		SELECT * from #tblVoucher2AccStateFD	
			
		delete from acc.tblVoucher2AccState
			from acc.tblVoucher2AccState a
			inner join #tblVoucher2AccStateFD b
			on a.AcntCode=b.AcntCode
			and b.b1=95
			and a.SourceProcessID=90
			and a.SourceProcessNo=b.b2
			and a.SourceFiscalYear=b.b3
			and a.SourceSerialNo=b.b4
			and a.SourceDocRowNo=b.b41
			and a.BaseID=b.b5
			and a.Amount=b.Amount
			
		update acc.tblVoucher2AccState
			set Amount = a.Amount-b.Amount
			from acc.tblVoucher2AccState a
			inner join #tblVoucher2AccStateFD b
			on a.AcntCode=b.AcntCode
			and b.b1=95
			and a.SourceProcessID=90
			and a.SourceProcessNo=b.b2
			and a.SourceFiscalYear=b.b3
			and a.SourceSerialNo=b.b4
			and a.SourceDocRowNo=b.b41
			and a.BaseID=b.b5
			and a.Amount>b.Amount
					
			end
END
GO
