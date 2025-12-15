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
Create procedure acc.SpAcc_AccState2
@CounterRun Int=1
WITH ENCRYPTION
as
begin


DECLARE @AcntCode			varchar(20) 
DECLARE @Counter			int=0
DECLARE  @Amount   Decimal(28,9) 
DECLARE  @VisitorAcntCode  	varchar(20) 
DECLARE  @DocDate Varchar(10)
	
DECLARE  @SS1   Integer
DECLARE  @SSD1   Integer
DECLARE  @SPID1   Integer
DECLARE  @SPNo1   Integer
DECLARE  @SF1   Integer
DECLARE  @SID1   Integer
DECLARE  @VisitorAcntCode1  	varchar(20) 
DECLARE  @Amount1   Decimal(28,9) 
DECLARE  @ID1   Integer      

DECLARE  @SS2   Integer
DECLARE  @SSD2   Integer
DECLARE  @SPID2   Integer
DECLARE  @SPNo2   Integer
DECLARE  @SF2   Integer
DECLARE  @SID2   Integer
DECLARE  @VisitorAcntCode2  	varchar(20) 
DECLARE  @Amount2   Decimal(28,9)
DECLARE  @ID2   Integer

Set @AcntCode=''

select   Distinct CreditCode, ROW_NUMBER() OVER (ORDER BY CreditCode)  AS 'RowNumber'
 into ##MyTable from   trs.tblPayHdr 
where BaseProcessID<>0 And CreditCode<>''
Group by CreditCode

select @AcntCode=CreditCode from ##MyTable
where RowNumber=@CounterRun

select @AcntCode

Drop table  ##MyTable

select   Count( Distinct CreditCode) from   trs.tblPayHdr 
where BaseProcessID<>0 And CreditCode<>'' and CreditCode>=@AcntCode

DECLARE mycur CURSOR FOR 
select   Distinct  CreditCode from   trs.tblPayHdr 
where BaseProcessID<>0 And len (CreditCode)>1 and CreditCode>=@AcntCode
order by CreditCode 
 --and CreditCode='111301 10101057004'
--'111301 10130003012'
   
OPEN mycur;

FETCH NEXT FROM mycur INTO @AcntCode

WHILE @@FETCH_STATUS = 0 
BEGIN
set @Counter+=1
Select @Counter,@AcntCode

--exec acc.SpAcc_AccState  '',5
exec acc.SpAcc_AccState @AcntCode,4
--exec acc.SpAcc_AccState  @AcntCode,6


BEGIN TRY
	Drop Table   #T1
	Drop Table   #T2
END TRY
BEGIN CATCH
END CATCH
		
		
CREATE TABLE  #T1
	(
		ID		integer,
		SerialNo		integer,
		DocRowNo		integer,
		RecDesc		VarChar(max) COLLATE ARABIC_CS_AS,
		SourceProcessID		integer,
		SourceProcessNo		integer,
		SourceFiscalYear		integer,
		SourceSerialNo		integer,
		SourceDocRowNo		integer,
		BaseID		integer,
		AcntCode			varchar(20) ,
		Debit Integer,
		Credit integer,
		DocDate Varchar(10),
		Amount integer,
		VisitorAcntCode			varchar(20) ,
		ID1 integer,
		AcntName		VarChar(max) COLLATE ARABIC_CS_AS,
		VisitorName		VarChar(max) COLLATE ARABIC_CS_AS,
	);
		
		Select * into #T2 from #T1 where 1=0
	
	INSERT INTO #T1
	exec acc.SpAcc_AccState  @AcntCode,1
	INSERT INTO #T2
	exec acc.SpAcc_AccState  @AcntCode,2
	
	
	--Select * from   #T1
	--Select * from   #T2

---------------------------------------------------------------------------
if ((Select Count(*) from #T1)>0)
	begin
DECLARE mycurt1 CURSOR FOR 
select   SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,BaseID,VisitorAcntCode,Amount,ID from #T1
OPEN mycurt1;

FETCH NEXT FROM mycurt1 INTO   @SPID1,@SPNo1,@SF1,@SS1,@SSD1,@SID1,@VisitorAcntCode1,@Amount1,@ID1

WHILE @@FETCH_STATUS = 0 
BEGIN
Set @SPID2=0

--select @SPID1,@SPNo1,@SF1,@SS1,@SID1,@VisitorAcntCode1,@Amount1,@ID1

select @SPID2= ProcessID,@SPNo2=ProcessNo,@SF2=FiscalYear,@SS2=SerialNo,@SSD2=0, @DocDate=DocDate from trs.tblPayHdr
--select * from trs.tblPayHdr
where BaseProcessID=@SPID1 and BaseProcessNo=@SPNo1 and BaseFiscalYear=@SF1 and BaseSerialNo=@SS1 and CreditCode=@AcntCode
if (@SPID2<>0)
begin
--select * from trs.tblPayHdr
--where BaseProcessID=@SPID1 and BaseProcessNo=@SPNo1 and BaseFiscalYear=@SF1 and BaseSerialNo=@SS1 and CreditCode=@AcntCode

select  @SPID2=  SourceProcessID,@SPNo2=SourceProcessNo,@SF2=SourceFiscalYear,@SS2=SourceSerialNo,@SSD2=SourceDocRowNo,@SSD2=SourceDocRowNo,@SID2=BaseID,@VisitorAcntCode2=VisitorAcntCode,@Amount2=Amount,@ID2=ID from #T2
where @SPID2=  SourceProcessID and @SPNo2=SourceProcessNo and @SF2=SourceFiscalYear and @SS2=SourceSerialNo and @SSD2=SourceDocRowNo

if (@Amount1   >@Amount2   )
set @Amount=@Amount2
else
set @Amount=@Amount1


if  (@VisitorAcntCode1<>'')
set @VisitorAcntCode=@VisitorAcntCode1  	
if  (@VisitorAcntCode2<>'')
set @VisitorAcntCode=@VisitorAcntCode2  	



insert into  acc.tblAccState(SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1,SourceDocRowNo1,BaseID1
							, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2,SourceDocRowNo2,BaseID2, ID1,ID2 ,
                    DocDate, AcntCode, EventNo, Amount, RecDesc, VisitorAcntCode, VisitorAcntCode1, VisitorAcntCode2)
                     Select @SPID1  , @SPNo1 , @SF1 , @SS1,@SSD1  ,@SID1  ,
		                    @SPID2  ,@SPNo2 , @SF2  ,@SS2,@SSD2 , @SID2  , @ID1  , @ID2  ,
                   @DocDate ,@AcntCode,(select isnull(Max(EventNo),0)+1 as a from  acc.tblAccState where AcntCode=@AcntCode ) ,@Amount, ' - ', @VisitorAcntCode, @VisitorAcntCode1, @VisitorAcntCode2 

 Update  acc.tblVoucher2AccState  set Amount=Amount- @Amount where ID=@ID1
 Update  acc.tblVoucher2AccState  set Amount=Amount- @Amount where ID=@ID2
                

--select  * from #T2 where @SPID2=  SourceProcessID and @SPNo2=SourceProcessNo and @SF2=SourceFiscalYear and @SS2=SourceSerialNo




end 


FETCH NEXT FROM mycurt1 INTO  @SPID1,@SPNo1,@SF1,@SS1,@SSD1,@SID1,@VisitorAcntCode1,@Amount1,@ID1
end 
Close mycurt1;
Deallocate mycurt1;

end
---------------------------------------------------------------------------




--insert into  acc.tblAccState(SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1, BaseID1, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2,  BaseID2, ID1,ID2 ,DocDate, AcntCode, EventNo, Amount, RecDesc, VisitorAcntCode)   Select 24 , 1 , 94 , 1 , 5415 ,  1 , 1 , 94 , 16 , 306 , 715808 , 715821 ,  '1395/03/22' , '111301 10130003012',(select isnull(Max(EventNo),0)+1 as a from  acc.tblAccState where AcntCode='111301 10130003012' ) ,1400000, '-', ''

--Select * from   #T1
--Select * from   #T2

FETCH NEXT FROM mycur INTO @AcntCode
end 
Close mycur;
Deallocate mycur;



end 
GO
