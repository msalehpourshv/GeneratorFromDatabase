USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSytem\Taha Esmaeili
-- Create date   : 1400/10/19

-- ==============================================
Create  PROCEDURE [trs].[RptChequeStatus]
	@InputChequeBookID	Int = 0,
	@InputBankCode	VarChar(20) = Null,
	@InputFiscalYear  int , 
	@InputRowNo     int
WITH ENCRYPTION
AS 

Begin 
	
DECLARE @StrSelect NVarChar(Max);

create table #cheques
(
ChequeNoNumber bigint,
Amount float,
VolumeRowNo int,
Descs nvarchar(4000),
AccountNo varchar(50),
AccOwnerName nvarchar(200),
SerialNo varchar(120),
SerialType varchar(30),
StatusOfCheque varchar(20),
ChequeDate char(10),
DocDate char(10),
ChequeNo varchar(20),
VoidChequeDate char(10),
BankName nvarchar(50)
)

 SET @StrSelect = '
declare @ChequeNoFrom bigint
declare @ChequeNoTo bigint
declare @TempChequeNo bigint
declare @ChequeNo bigint
declare @Amount float
declare @VolumeRowNo int
declare @Descs nvarchar(500)
declare @AccountNo varchar(50)
declare @AccOwnerName nvarchar(100)
declare @SerialNo  varchar(20)
declare @DocDate char(10)
declare @ProcessID int
declare @PayTypeID int
declare @ChequeDate char(10)
declare @RowNo int
declare @ChequebookID int
declare @BankCode varchar(20)
declare @Fiscalyear int
declare @BankName nvarchar(50)

Declare Cursor_RowNo CURSOR For 
	 SELECT RowNo,ChequeBookID,B.BankCode,FiscalYear,BD.BankName
	 FROM trs.tblBankChequesDtl B
	  inner join  trs.tblOurBanksDtl  BD on B.BankCode=BD.BankCode'
	 
	 if @InputChequeBookID<>0  and @InputBankCode<>0
     SET @StrSelect = @StrSelect + ' WHERE ChequeBookID=' + cast(@InputChequeBookID as varchar) +' and B.BankCode='''+@InputBankCode +''' and FiscalYear=' + cast(@InputFiscalYear as varchar) + ' and RowNo=' + cast(@InputRowNo as varchar)

	 if @InputChequeBookID=0  and @InputBankCode<>0  --To include all ChequeBooks of this bank
     SET @StrSelect = @StrSelect + ' WHERE B.BankCode='+@InputBankCode +''


	  SET @StrSelect = @StrSelect + ' Open  Cursor_RowNo; 
          Fetch NEXT From Cursor_RowNo Into @RowNo,@ChequebookID,@BankCode,@Fiscalyear,@BankName
		   While (@@Fetch_Status = 0)
		   begin
		   -------------------------------- start of inner query
		    set @ChequeNoFrom=(select FromChequeNo from trs.tblBankChequesDtl where ChequeBookID=@ChequebookID and BankCode=@BankCode and FiscalYear=@Fiscalyear and RowNo=@RowNo)
            set @ChequeNoTo=(select ToChequeNo from trs.tblBankChequesDtl where ChequeBookID=@ChequebookID and BankCode=@BankCode and FiscalYear=@Fiscalyear and RowNo=@RowNo)
            set @TempChequeNo= @ChequeNoFrom
            while (@TempChequeNo<=@ChequeNoTo)
             begin
               insert  into  #cheques (ChequeNoNumber,Amount,VolumeRowNo,Descs,AccountNo,AccOwnerName,SerialNo ,SerialType ,StatusOfCheque ,ChequeDate,DocDate,VoidChequeDate,BankName)
               values( @TempChequeNo,'''','''','''','''','''','''','''','''','''','''','''',@BankName)			
              set @TempChequeNo=@TempChequeNo+1              
         	end

      Fetch NEXT From Cursor_RowNo Into @RowNo,@ChequebookID,@BankCode,@Fiscalyear,@BankName
   end
   Close Cursor_RowNo
   Deallocate Cursor_RowNo    '
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
set @StrSelect=	 '   update  #cheques 
            set SerialNo=0,Descs='''' ,SerialType=''ابطال چک'',StatusOfCheque=''باطل شده'',VoidChequeDate=b.ChequeDate
			from #cheques a
			inner join trs.tblBankVoidChequesDtl b
			on b.ChequeNo=a.ChequeNoNumber   '
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
 
set @StrSelect=	 '      update  #cheques 
			SET SerialNo = b.SerialNo ,Descs=b.RowDesc,Amount=b.Amount,VolumeRowNo=b.VolumeRowNo,
			    SerialType = case 
			                 when PayTypeID=8 then ''اسناد پرداختنی تجاری'' 
			                 when PayTypeID=28 then ''اسناد پرداختنی غیر تجاری'' 
			                 when PayTypeID=7 then ''چک روز'' 
			                 when PayTypeID=18 then ''پرداختی امانی'' 
			                 END,
   			    StatusOfCheque = case 
			                 when ProcessID=27 OR (ProcessID=2 and PayTypeID=7) THEN ''وصول شده''
			                 when ProcessID=2 OR ProcessID=33  THEN ''صادر شده''
			                 when ProcessID=25 THEN ''صادر شده(اول دوره)''
			                 when ProcessID=28 OR ProcessID=34 THEN ''استرداد شده''
							 END,
				ChequeDate=b.ChequeDate,
				DocDate=b.DocDate
			from #cheques a
			inner join 
			 ( select * from (
			SELECT ROW_NUMBER()over(partition by ChequeNo,ChequeBookFiscalYear,ChequeBookID order by ChequeNo,ChequeBookFiscalYear,ChequeBookID,DocDate desc,EventNo desc) R,* 
			FROM trs.tblPayDtl
			where PayTypeID in (7,8,28,18) and ProcessID not in (41)
			) a
			where R=1) b
			on b.ChequeNo=a.ChequeNoNumber    '
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
 
set @StrSelect=	 ' 	update  #cheques 
			SET AccountNo=b.DebitCode,AccOwnerName=pub.GetCodeName(b.DebitCode, 1)			   
			from #cheques a
			inner join 
			 ( select * from (
			SELECT ROW_NUMBER()over(partition by ChequeNo,ChequeBookFiscalYear,ChequeBookID order by ChequeNo,ChequeBookFiscalYear,ChequeBookID,DocDate desc,EventNo asc) R,* 
			FROM trs.tblPayDtl
			where PayTypeID in (7,8,28,18) And (ProcessID =2 OR ProcessID=25 OR ProcessID=33)
			) a
			where R=1) b
			on b.ChequeNo=a.ChequeNoNumber    '
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
 
set @StrSelect=	 '   update  #cheques 
       set ChequeNo=cast(ChequeNoNumber as  varchar(20)) '
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

       select * from #cheques
end
GO
