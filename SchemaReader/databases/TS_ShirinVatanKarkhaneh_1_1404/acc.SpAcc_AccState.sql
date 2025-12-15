USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1394/08/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : وضعیت حساب مشتری و خوانده حسابها
-- ==============================================
Create procedure acc.SpAcc_AccState
@AcntCode			varchar(20) =Null,
@type Int=1,
@SourceProcessID int=0 ,
@SourceProcessNo int =0,
@SourceFiscalYear int =0,
@SourceSerialNo int=0,
@ForTransfer BIT='False'

WITH ENCRYPTION
as
begin
-- 1) مانده بدهکاران
-- 2) ماده بستانکاران
-- 3) تطبیق یافته ها
-- 4) حذف تطبیق های اتوماتیک و ثبت مجدد
-- 5) حذف اطلاعاتی که مبدا آنها حذف شده اند
--6) انتقال اطلاعات از اسناد به جدول میانی تطبیق
---8)حالت 1 و 2 بصورت ترکیبی 

declare @DocDate	char(10) 
declare @Debit	decimal(28,9)
declare @Credit	decimal(28,9)
declare @Amount	decimal(28,9)
declare @BaseID	int
declare @VisitorAcntCode	varchar(20)


if (@type=1)
begin

	if @ForTransfer ='False'
		select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode, Debit, Credit, DocDate, 
							  Amount, VisitorAcntCode, ID1
		,pub.GetCodeName(a.AcntCode, 1)as AcntName
		,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
		from acc.tblVoucher2AccState  a
		where a.Debit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
		AND (@SourceProcessID = 0  
			OR ( @SourceProcessID <> 0
			AND  a.SourceProcessID  =@SourceProcessID  
			AND  a.SourceProcessNo  =@SourceProcessNo  
			AND  a.SourceFiscalYear  =@SourceFiscalYear  
			AND  a.SourceSerialNo  =@SourceSerialNo  
		))
	ELSE
		select AcntCode,SUM(Amount) Amount, VisitorAcntCode from (
		select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID, AcntCode, Debit, Credit, DocDate, 
							  Amount, VisitorAcntCode, ID1
		,pub.GetCodeName(a.AcntCode, 1)as AcntName
		,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
		from acc.tblVoucher2AccState  a
		where a.Debit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
		AND (@SourceProcessID = 0  
			OR ( @SourceProcessID <> 0
			AND  a.SourceProcessID  =@SourceProcessID  
			AND  a.SourceProcessNo  =@SourceProcessNo  
			AND  a.SourceFiscalYear  =@SourceFiscalYear  
			AND  a.SourceSerialNo  =@SourceSerialNo  
		)) ) a
		group by AcntCode, VisitorAcntCode
end
----------------------------------------------------------------------------------------------------------------------------
if (@type=2)
begin

	if @ForTransfer ='False'
		select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocRowNo,BaseID, AcntCode, Debit, Credit, DocDate, 
							  Amount, VisitorAcntCode, ID1
		,pub.GetCodeName(a.AcntCode, 1)as AcntName
		,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
		from acc.tblVoucher2AccState  a
		where a.Credit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
		AND (@SourceProcessID = 0  
			OR ( @SourceProcessID <> 0
			AND  a.SourceProcessID  =@SourceProcessID  
			AND  a.SourceProcessNo  =@SourceProcessNo  
			AND  a.SourceFiscalYear  =@SourceFiscalYear  
			AND  a.SourceSerialNo  =@SourceSerialNo  
		))
	ELSE
		select AcntCode,SUM(Amount) Amount, VisitorAcntCode from (
		select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode, Debit, Credit, DocDate, 
							  Amount, VisitorAcntCode, ID1
		,pub.GetCodeName(a.AcntCode, 1)as AcntName
		,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
		from acc.tblVoucher2AccState  a
		where a.Credit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
		AND (@SourceProcessID = 0  
			OR ( @SourceProcessID <> 0
			AND  a.SourceProcessID  =@SourceProcessID  
			AND  a.SourceProcessNo  =@SourceProcessNo  
			AND  a.SourceFiscalYear  =@SourceFiscalYear  
			AND  a.SourceSerialNo  =@SourceSerialNo  
		))) a
		group by AcntCode, VisitorAcntCode
	
end



if (@type=8 OR @type=18)
begin

select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode, Debit, Credit, DocDate, 
                      Amount, VisitorAcntCode, ID1,1 as Types
,pub.GetCodeName(a.AcntCode, 1)as AcntName
,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
from acc.tblVoucher2AccState  a
where a.Debit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
AND (@SourceProcessID = 0  
	OR ( @SourceProcessID <> 0
	AND  a.SourceProcessID  =@SourceProcessID  
	AND  a.SourceProcessNo  =@SourceProcessNo  
	AND  a.SourceFiscalYear  =@SourceFiscalYear  
	AND  a.SourceSerialNo  =@SourceSerialNo  
))
Union all
select  ID, SerialNo, DocRowNo, RecDesc, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo,SourceDocRowNo, BaseID, AcntCode, Debit, Credit, DocDate, 
                      Amount, VisitorAcntCode, ID1,2 as Types
,pub.GetCodeName(a.AcntCode, 1)as AcntName
,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
from acc.tblVoucher2AccState  a
where a.Credit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
AND (@SourceProcessID = 0  
	OR ( @SourceProcessID <> 0
	AND  a.SourceProcessID  =@SourceProcessID  
	AND  a.SourceProcessNo  =@SourceProcessNo  
	AND  a.SourceFiscalYear  =@SourceFiscalYear  
	AND  a.SourceSerialNo  =@SourceSerialNo  
))
end


----------------------------------------------------------------------------------------------------------------------------
if (@type=3)
begin


select * 
,pub.GetCodeName(D.AcntCode, 1)as AcntName
,pub.GetCodeName(D.VisitorAcntCode,  1)as VisitorName
from (

SELECT     A.DocDate,  A.AcntCode,EventNo, A.Amount,  A.RecDesc, A.VisitorAcntCode
,isnull((Select  top 1 RecDesc  from  acc.tblVoucherDtl AS V1 where  A.SourceProcessID1 = V1.SourceProcessID AND A.SourceProcessNo1 = V1.SourceProcessNo AND A.SourceFiscalYear1 = V1.SourceFiscalYear AND A.SourceSerialNo1 = V1.SourceSerialNo AND A.SourceDocRowNo1 = V1.SourceDocRowNo AND A.BaseID1 = V1.BaseID AND A.AcntCode = V1.AcntCode and V1.Debit>0), '') V1RecDesc
,isnull((Select  top 1 SerialNo  from  acc.tblVoucherDtl AS V1 where  A.SourceProcessID1 = V1.SourceProcessID AND A.SourceProcessNo1 = V1.SourceProcessNo AND A.SourceFiscalYear1 = V1.SourceFiscalYear AND A.SourceSerialNo1 = V1.SourceSerialNo AND A.SourceDocRowNo1 = V1.SourceDocRowNo AND A.BaseID1 = V1.BaseID AND A.AcntCode = V1.AcntCode and V1.Debit>0), 0) V1SerialNo
,isnull((Select  top 1 DocRowNo  from  acc.tblVoucherDtl AS V1 where  A.SourceProcessID1 = V1.SourceProcessID AND A.SourceProcessNo1 = V1.SourceProcessNo AND A.SourceFiscalYear1 = V1.SourceFiscalYear AND A.SourceSerialNo1 = V1.SourceSerialNo AND A.SourceDocRowNo1 = V1.SourceDocRowNo AND A.BaseID1 = V1.BaseID AND A.AcntCode = V1.AcntCode and V1.Debit>0), '') V1DocRowNo
,isnull((Select  top 1 RecDesc  from  acc.tblVoucherDtl AS V1 where  A.SourceProcessID2 = V1.SourceProcessID AND A.SourceProcessNo2 = V1.SourceProcessNo AND A.SourceFiscalYear2 = V1.SourceFiscalYear AND A.SourceSerialNo2 = V1.SourceSerialNo AND A.SourceDocRowNo2 = V1.SourceDocRowNo AND A.BaseID2 = V1.BaseID AND A.AcntCode = V1.AcntCode and V1.Debit=0), '') V2RecDesc
,isnull((Select  top 1 SerialNo  from  acc.tblVoucherDtl AS V1 where  A.SourceProcessID2 = V1.SourceProcessID AND A.SourceProcessNo2 = V1.SourceProcessNo AND A.SourceFiscalYear2 = V1.SourceFiscalYear AND A.SourceSerialNo2 = V1.SourceSerialNo AND A.SourceDocRowNo2 = V1.SourceDocRowNo AND A.BaseID2 = V1.BaseID AND A.AcntCode = V1.AcntCode and V1.Debit=0), 0) V2SerialNo
,isnull((Select  top 1 DocRowNo  from  acc.tblVoucherDtl AS V1 where  A.SourceProcessID2 = V1.SourceProcessID AND A.SourceProcessNo2 = V1.SourceProcessNo AND A.SourceFiscalYear2 = V1.SourceFiscalYear AND A.SourceSerialNo2 = V1.SourceSerialNo AND A.SourceDocRowNo2 = V1.SourceDocRowNo AND A.BaseID2 = V1.BaseID AND A.AcntCode = V1.AcntCode and V1.Debit=0), '') V2DocRowNo

, SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1, SourceProcessID2, SourceProcessNo2, 
                     SourceFiscalYear2, SourceSerialNo2,SourceDocRowNo2, BaseID2,ID
FROM         acc.tblAccState A
WHERE      (@AcntCode='' or (@AcntCode <> '' and  A.AcntCode = @AcntCode))

)D
order by ID 
end



---اسناد اتواتیک با  دو طرف یکسان-------------------------------------------------------------------------------------------------------------------------
if (@type=4 and @AcntCode<>'')
begin
declare @SourceDocRowNo as int=0
Delete  from  acc.tblAccState 
where ( AcntCode = @AcntCode) AND  
SourceProcessID1=SourceProcessID2 and SourceProcessNo1=SourceProcessNo2
				and SourceFiscalYear1=SourceFiscalYear2 and SourceSerialNo1=SourceSerialNo2 and SourceDocRowNo1=SourceDocRowNo2
				AND (SourceSerialNo1 <> 0)  AND (SourceSerialNo2 <> 0)  
		and (@SourceSerialNo=0 or ( SourceProcessID1=@SourceProcessID and SourceProcessNo1=@SourceProcessNo and SourceFiscalYear1=@SourceFiscalYear and SourceSerialNo1=@SourceSerialNo  ))
		
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempTable]') AND type in (N'U'))
DROP TABLE [dbo].[TempTable]
		
				SELECT  Distinct   V1.SourceProcessID, V1.SourceProcessNo, V1.SourceFiscalYear, V1.SourceSerialNo,V1.SourceDocRowNo, V1.DocDate
				, V1.Debit, V2.Credit, isnull(d.VisitorAcntCode,'') as VisitorAcntCode,V1.BaseID
			     into #TempTable
				FROM         
				(SELECT    *   FROM          acc.tblVoucherDtl
					WHERE     VchKind<>0 and  ( AcntCode = @AcntCode) AND (Credit = 0) AND (SourceSerialNo <> 0) 
					  and (@SourceSerialNo=0 or ( SourceProcessID=@SourceProcessID and SourceProcessNo=@SourceProcessNo and SourceFiscalYear=@SourceFiscalYear and SourceSerialNo=@SourceSerialNo ))
					   and BaseID =1  
				) AS V1 
				INNER JOIN
				(SELECT   *   FROM          acc.tblVoucherDtl AS tblVoucherDtl_1
							WHERE    VchKind<>0 and  ( AcntCode = @AcntCode) AND (Debit = 0) AND (SourceSerialNo <> 0) 
						and (@SourceSerialNo=0 or ( SourceProcessID=@SourceProcessID and SourceProcessNo=@SourceProcessNo and SourceFiscalYear=@SourceFiscalYear and SourceSerialNo=@SourceSerialNo ))
				) AS V2 
				ON V1.SourceProcessID = V2.SourceProcessID AND 
					  V1.SourceProcessNo = V2.SourceProcessNo AND V1.SourceFiscalYear = V2.SourceFiscalYear AND V1.SourceSerialNo = V2.SourceSerialNo AND V1.SourceDocRowNo = V2.SourceDocRowNo
					   LEFT OUTER JOIN
                      inv.tblStorageDocsDtl AS d ON V2.SourceProcessID = d.ProcessID AND V2.SourceProcessNo = d.ProcessNo AND V2.SourceFiscalYear = d.FiscalYear AND 
                      V2.SourceSerialNo = d.SerialNo AND V2.AcntCode = d.AcntCode                      
										
										
			DECLARE curTables CURSOR FOR 
			
			select Distinct * from #TempTable
				OPEN curTables;
			
			
			FETCH NEXT FROM curTables INTO @SourceProcessID, @SourceProcessNo, @SourceFiscalYear, @SourceSerialNo,@SourceDocRowNo,  @DocDate, @Debit, @Credit,@VisitorAcntCode,@BaseID
			WHILE @@FETCH_STATUS = 0 
				BEGIN	
				if (@Debit< @Credit)
				set @Amount=@Debit
				else
				set @Amount=@Credit
				
				Select @Debit=isnull(Count(*),0) from  acc.tblAccState 
				where SourceProcessID1=@SourceProcessID and SourceProcessNo1=@SourceProcessNo 
				and SourceFiscalYear1=@SourceFiscalYear and SourceSerialNo1=@SourceSerialNo and SourceDocRowNo1=@SourceDocRowNo and BaseID1=@BaseID
				and SourceProcessID2=@SourceProcessID and SourceProcessNo2=@SourceProcessNo 
				and SourceFiscalYear2=@SourceFiscalYear and SourceSerialNo2=@SourceSerialNo and SourceDocRowNo1=@SourceDocRowNo and BaseID2=@BaseID
			
				if (@Debit=0)
				begin
				
				insert into  acc.tblAccState 
				(SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1, BaseID1
				, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2, BaseID2
				, DocDate, AcntCode, EventNo
				, Amount, RecDesc, VisitorAcntCode, VisitorAcntCode1, VisitorAcntCode2)  
                     Select @SourceProcessID, @SourceProcessNo, @SourceFiscalYear, @SourceSerialNo,@SourceDocRowNo,@BaseID
							,@SourceProcessID, @SourceProcessNo, @SourceFiscalYear, @SourceSerialNo,@SourceDocRowNo,@BaseID
							,@DocDate,@AcntCode,(select isnull(Max(EventNo),0)+1 as a from  acc.tblAccState where AcntCode=@AcntCode )
							,@Amount,'-' ,@VisitorAcntCode,@VisitorAcntCode,@VisitorAcntCode
			                 
				end 
				
				FETCH NEXT FROM curTables INTO @SourceProcessID, @SourceProcessNo, @SourceFiscalYear, @SourceSerialNo,@SourceDocRowNo,  @DocDate, @Debit, @Credit,@VisitorAcntCode,@BaseID
				end 
			Close curTables;
			Deallocate curTables;
		            
		            
		          update   acc.tblAccState 
		          set  VisitorAcntCode   = isnull(d.VisitorAcntCode ,'')  from acc.tblAccState V2 LEFT OUTER JOIN
                      inv.tblStorageDocsHdr AS d ON V2.SourceProcessID1 = d.ProcessID AND V2.SourceProcessNo1 = d.ProcessNo AND V2.SourceFiscalYear1 = d.FiscalYear AND 
                      V2.SourceSerialNo1 = d.SerialNo AND V2.AcntCode = d.AcntCode
                      where  SourceProcessID1 =SourceProcessID2 AND SourceProcessNo1=SourceProcessNo2 and SourceFiscalYear1 =SourceFiscalYear2
                      and  SourceSerialNo1= SourceSerialNo2 and  V2.VisitorAcntCode   =''
           
------- اجرای مجددبرای اصلاح اطلاعات جدول میانی
--exec acc.SpAcc_AccState  @AcntCode,44           
                      
end
-----------------------------------------------------------------------------------------------------------------------------------
if (@type=7)
begin


BEGIN TRY
Drop Table   #T1
Drop Table   #T2
			
		END TRY
		BEGIN CATCH
		END CATCH


select * into  #T1  from (
select * 
,pub.GetCodeName(a.AcntCode, 1)as AcntName
,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
from acc.tblVoucher2AccState  a
where a.Debit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
AND (@SourceProcessID = 0  
	OR ( @SourceProcessID <> 0
	AND  a.SourceProcessID  =@SourceProcessID  
	AND  a.SourceProcessNo  =@SourceProcessNo  
	AND  a.SourceFiscalYear  =@SourceFiscalYear  
	AND  a.SourceSerialNo  =@SourceSerialNo  
))

)a 
select * into  #T2  from (
select * 
,pub.GetCodeName(a.AcntCode, 1)as AcntName
,pub.GetCodeName(a.VisitorAcntCode,  1)as VisitorName
from acc.tblVoucher2AccState  a
where a.Credit>0 and  (@AcntCode='' or (@AcntCode <> '' and  a.AcntCode = @AcntCode))
AND (@SourceProcessID = 0  
	OR ( @SourceProcessID <> 0
	AND  a.SourceProcessID  =@SourceProcessID  
	AND  a.SourceProcessNo  =@SourceProcessNo  
	AND  a.SourceFiscalYear  =@SourceFiscalYear  
	AND  a.SourceSerialNo  =@SourceSerialNo  
))
) a

SELECT DISTINCT a.AcntCode,pub.GetCodeName(a.AcntCode, 1)as AcntName
FROM         #T1 AS a INNER JOIN
                      #T2 AS b ON a.AcntCode = b.AcntCode
 where a.AcntCode in (SELECT  Distinct  AcntCode FROM         acc.tblAccState )                     

end

end

GO
