USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/06/21
-- Description:	Control Receipt 
-- =============================================

Create PROCEDURE [trs].[spFrmPayPaymentSave] 
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo      int,
 @MainSerialNo  int,
 @DocDate		Char(10),
 @LanguageID    TinyInt=1 ,
 @VoucherSerialNo Int,
 @VolumeRowNos  NVARCHAR(4000)
 
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;
Declare @strMsgText	 NVarChar(2044)
Declare @sql	 NVarChar(2044)
Declare @AcntCode	 VarChar(20)
Declare @LocationID	 VarChar(20)
Declare @BankTypeID	 VarChar(20)
Declare @rr		     NVarChar(500)
Declare @SumAcntCode float
Declare @PayTypeID	 TinyInt
Declare @EventNo	 Int
Declare @VolumeFiscalYear INT
Declare @VolumeRowNo Int
Declare @RowNo       Int
Declare @CreditCode VarChar(20)
Declare @MaxDocDate			Char(10)
Declare @BankState       Tinyint
Declare @AcntCode1 Varchar(20)
Declare @AcntCode2 Varchar(20)
Declare @AcntCode3 Varchar(20)
Declare @AcntCode5 Varchar(20)
Declare @CreditRoof Bigint
Declare @ChequeNo Varchar(20)
Declare @BankCode Varchar(20)
Declare @Amount   BigInt
Declare @MaxEvn		int
Declare @MaxDebitCode  Varchar(20)
---------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT RD.LocationID,RD.BankTypeID,PayTypeID,EventNo,VolumeFiscalYear,VolumeRowNo,RowNo,CreditCode,BankState,AcntCode1,AcntCode2,AcntCode3,AcntCode5,CreditRoof,ChequeNo,BankCode,Amount
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.CreditCode=OB.BankCode AND
          RD.ProcessID=@ProcessID AND
		  RD.ProcessNo=@ProcessNo AND
		  RD.FiscalYear=@FiscalYear AND
		  RD.SerialNo=@SerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @LocationID, @BankTypeID,@PayTypeID,@EventNo,@VolumeFiscalYear,@VolumeRowNo,
					@RowNo,@CreditCode,@BankState,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@CreditRoof,@ChequeNo,@BankCode,@Amount

	While (@@Fetch_Status = 0)
		BEGIN

			SET @MaxEvn = 0
			SET @MaxDebitCode = ''
			
			IF @LocationID IS NULL
				SET @LocationID = ''

			IF @BankTypeID IS NULL
				SET @BankTypeID = ''

			IF @EventNo IS NULL
				SET @EventNo = 0

			IF @VolumeFiscalYear IS NULL
				SET @VolumeFiscalYear = 0

			IF @VolumeRowNo IS NULL
				SET @VolumeRowNo = 0

			-------------------------------------------
			IF (@PayTypeID=6 OR @PayTypeID=26 )
			BEGIN
				IF  @EventNo>0
				BEGIN
					SELECT TOP 1 @MaxDocDate = DocDate
						FROM trs.tblPayDtl 
						WHERE PayTypeID IN (6,26) AND
							  VolumeFiscalYear=@VolumeFiscalYear AND
							  VolumeRowNo=@VolumeRowNo AND
							  EventNo = @EventNo - 1		
						ORDER BY EventNo DESC
					
						IF @MaxDocDate > @DocDate
							BEGIN
								Close Cursor_PayDtl;
								Deallocate Cursor_PayDtl;
								--تاریخ جاری از تاریخ آخرین حالت چک کوچکتر است
								SET @strMsgText=TS.pub.funGetMessages(12080,@LanguageID)
								Raiserror (@strMsgText,16,1) 
								Return
							END
				END
				else IF  @EventNo=0
				BEGIN

					SELECT TOP 1 @MaxEvn = EventNo + 1 , @MaxDocDate = DocDate , @MaxDebitCode = DebitCode
					FROM trs.tblPayDtl 
					WHERE PayTypeID IN (6,26) AND
						  VolumeFiscalYear=@VolumeFiscalYear AND
						  VolumeRowNo=@VolumeRowNo 			
					ORDER BY EventNo DESC
					  
	--				SELECT @MaxEvn =ISNULL(MAX(EventNo),0)+1
	--				FROM trs.tblPayDtl 
	--				WHERE PayTypeID IN (6,26) AND
	--					  VolumeFiscalYear=@VolumeFiscalYear AND
	--					  VolumeRowNo=@VolumeRowNo 
	--
	--				SELECT @MaxDocDate = DocDate
	--				FROM trs.tblPayDtl 
	--				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
	--					  VolumeRowNo=@VolumeRowNo AND 
	--					  EventNo = @MaxEvn

					IF @MaxDebitCode <> @CreditCode
			    		BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl;
							--چک به شماره دفتر %d در صندوق %s وجود ندارد
							SET @strMsgText=TS.pub.funGetMessages(12081,@LanguageID)
							Raiserror (@strMsgText,16,1,@VolumeRowNo,@CreditCode) 
							Return
						END
					
					IF @MaxDocDate > @DocDate
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl;
							--تاریخ جاری از تاریخ آخرین حالت چک کوچکتر است
							SET @strMsgText=TS.pub.funGetMessages(12080,@LanguageID)
							Raiserror (@strMsgText,16,1) 
							Return
						END
				
					UPDATE trs.tblPayDtl
					SET EventNo=@MaxEvn
					WHERE ProcessID=@ProcessID AND
						  ProcessNo=@ProcessNo AND
						  FiscalYear=@FiscalYear AND
						  SerialNo=@SerialNo AND
						  RowNo=@RowNo
					  
					SET @EventNo=@MaxEvn
				
				END
				
				DECLARE @TempDocRowNo as varchar(10) ='0'
				select @TempDocRowNo = DocRowNo  
				from trs.tblPayDtl a
				where ProcessID=@ProcessID AND
					  ProcessNo=@ProcessNo AND
					  FiscalYear=@FiscalYear AND
					  SerialNo=@SerialNo AND
					  RowNo=@RowNo AND
				      PayTypeID in (6,26) AND
				   ( a.VolumeRowNo=0 OR (select  Top 1 COUNT(*)
					from trs.tblPayDtl b
					where PayTypeID in (6,26) and ProcessID in (1,10) and 
					a.VolumeFiscalYear=b.VolumeFiscalYear and a.VolumeRowNo=b.VolumeRowNo and a.DocDate>=b.DocDate and 
					a.EventNo>b.EventNo and ( a.ChequeNo<>b.ChequeNo OR a.ChequeDate<>b.ChequeDate OR a.Amount<>b.Amount))>0)

					IF @TempDocRowNo <>'0'
			    		BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl;
							SET @strMsgText='مشکل در ذخیره:اطلاعات چک وارد شده (ردیف دفتری/مبلغ/شماره چک/تاریخ) در ردیف ' + @TempDocRowNo + ' با اطلاعات وارد شده در برگه دریافت  متفاوت است' 
							Raiserror (@strMsgText,16,1,@VolumeRowNo,@CreditCode) 
							Return
						END
			END

			-------------------------------------------
			IF @BankTypeID <> '' AND 
			  (SELECT COUNT(*)
			   FROM trs.tblBankTypes
			   WHERE BankTypeID=@BankTypeID) = 0
			BEGIN
				Close Cursor_PayDtl;
				Deallocate Cursor_PayDtl; 
				--بانكي به کد  %s وجود ندارد
				SET @strMsgText=TS.pub.funGetMessages(12017,@LanguageID)
				Raiserror (@strMsgText,16,1,@BankTypeID)
				Return
			END

			-------------------------------------------
			IF @LocationID <> '' AND 
			  (SELECT COUNT(*)
			   FROM pub.tblLocations
			   WHERE LocationID=@LocationID) = 0
			BEGIN
				Close Cursor_PayDtl;
				Deallocate Cursor_PayDtl; 
				--شهری به کد  %s وجود ندارد
				SET @strMsgText=TS.pub.funGetMessages(12018,@LanguageID)
				Raiserror (@strMsgText,16,1,@LocationID)
				Return
			END


			-------------------------------------------
			IF @BankState=2 
				BEGIN
					IF (SELECT ISNULL(SUM(Credit-Debit),0)
						FROM acc.tblVoucherDtl
						WHERE ((@AcntCode1 <> '' AND AcntCode LIKE @AcntCode1+'%') OR 
							   (@AcntCode2 <> '' AND AcntCode LIKE @AcntCode2+'%') OR 
							   (@AcntCode3 <> '' AND AcntCode LIKE @AcntCode3+'%') OR 
							   (@AcntCode5 <> '' AND AcntCode LIKE @AcntCode5+'%')) AND DocDate<=@DocDate 
						) > @CreditRoof
				
					BEGIN
						Close Cursor_PayDtl;
						Deallocate Cursor_PayDtl; 
						SET @strMsgText=TS.pub.funGetMessages(12016,@LanguageID)
						Raiserror (@strMsgText,16,1,@CreditCode)
						Return
					END
				END
	
			-------------------------------------------
			IF @PayTypeID=7 OR @PayTypeID=8  OR @PayTypeID=28
				BEGIN
					-------------------------------------------
					IF(SELECT COUNT(*) 
					   FROM trs.tblBankVoidChequesDtl
					   WHERE BankCode=@BankCode AND
		    				 ChequeNo=@ChequeNo)>0 
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
							--چک به شماره %s قبلا باطل شده است
							SET @strMsgText=TS.pub.funGetMessages(12020,@LanguageID)
							Raiserror (@strMsgText,16,1,@ChequeNo)
							Return
						END
					
					-------------------------------------------
--					IF(SELECT TOP 1 ProcessID
--					   FROM trs.tblPayDtl
--					   WHERE PayTypeID IN (7,8,28) AND
--		    				 VolumeFiscalYear=@VolumeFiscalYear AND
--		    				 VolumeRowNo=@VolumeRowNo AND 
--						NOT( ProcessID=@ProcessID AND
--							 ProcessNo=@ProcessNo AND
--							 FiscalYear=@FiscalYear AND
--							 SerialNo=@SerialNo AND 
--							 RowNo=@RowNo AND
--							 EventNo=@EventNo)
--						Order By EventNo Desc)<>28 
--						BEGIN
--							--چک به شماره %s قبلا پرداخت شده است
--							SET @strMsgText=TS.pub.funGetMessages(12021,@LanguageID)
--							Raiserror (@strMsgText,16,1,@ChequeNo) 
--							Return
--						END
				END

			-------------------------------------------
			IF @PayTypeID=6 OR @PayTypeID=26
				BEGIN
					DECLARE @TempProcessID Tinyint
					Declare @ParmDefinition NVarChar(200)

					SET @sql = 'SELECT TOP 1 @TempProcessID1 = ProcessID 
								FROM trs.tblPayDtl
								WHERE PayTypeID IN (6,26) AND
	    			 				  VolumeFiscalYear=' + LTRIM(RTRIM(STR(@VolumeFiscalYear))) + ' AND
	    							  VolumeRowNo=' + LTRIM(RTRIM(STR(@VolumeRowNo))) + ' AND 
								 not (ProcessID=' + LTRIM(RTRIM(STR(@ProcessID)))  + 'AND
									  ProcessNo=' + LTRIM(RTRIM(STR(@ProcessNo)))  + 'AND
									  FiscalYear=' + LTRIM(RTRIM(STR(@FiscalYear)))  + 'AND
									  SerialNo=' + LTRIM(RTRIM(STR(@SerialNo)))  + 'AND 
									  RowNo=' + LTRIM(RTRIM(STR(@RowNo)))  + 'AND
									  EventNo=' + LTRIM(RTRIM(STR(@EventNo))) + ')'

					IF @VolumeRowNos <>'' 
						SET @sql = @sql + ' AND VolumeRowNo NOT IN (' + @VolumeRowNos + ')'
																   
					SET @sql = @sql + ' Order By EventNo Desc'
					
					SET @ParmDefinition = N'@TempProcessID1 Tinyint OUTPUT';

					Exec sp_executesql @sql ,@ParmDefinition , @TempProcessID1 = @TempProcessID OUTPUT;
					
					 IF not (@TempProcessID=1 or @TempProcessID=10 or @TempProcessID=17 or @TempProcessID=23 or @TempProcessID=40)
						BEGIN
							Close Cursor_PayDtl;
							Deallocate Cursor_PayDtl; 
							--چک به شماره %s قابل پرداخت نیست
							SET @strMsgText=TS.pub.funGetMessages(12022,@LanguageID)
							Raiserror (@strMsgText,16,1,@ChequeNo) 
							Return
						END 

				END
			-------------------------------------------
			Fetch NEXT From Cursor_PayDtl Into @LocationID, @BankTypeID,@PayTypeID,@EventNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@CreditCode,@BankState,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@CreditRoof,@ChequeNo,@BankCode,@Amount

		End

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

-------------------------------------------------------------------------------

DECLARE @MaxVolumeRowNo int

SELECT @MaxVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
FROM trs.tblPayDtl 
WHERE PayTypeID IN (7,8,28) AND
	  VolumeFiscalYear = @FiscalYear

UPDATE  trs.tblPayDtl
SET  VolumeRowNo=@MaxVolumeRowNo+ROW_N
FROM trs.tblPayDtl, 
	(SELECT RowNo,ROW_NUMBER() OVER(ORDER BY DocRowNo) As ROW_N
	 FROM	trs.tblPayDtl
	 WHERE	ProcessID = @ProcessID  AND
		    ProcessNo = @ProcessNo  AND
		    FiscalYear= @FiscalYear AND
		    SerialNo  = @SerialNo   AND
		    VolumeRowNo = 0	        AND
		    PayTypeID IN (7,8,28)    ) t 
WHERE ProcessID =@ProcessID  AND
	  ProcessNo =@ProcessNo  AND
	  FiscalYear=@FiscalYear AND
	  SerialNo  =@SerialNo   AND
	  PayTypeID IN (7,8,28)  AND
      VolumeRowNo = 0	     AND
	  trs.tblPayDtl.RowNo=t.RowNo

update trs.tblPayDtl
set ChequeBookID=b.ChequeBookID,ChequeBookFiscalYear=b.FiscalYear
from trs.tblPayDtl p
inner join trs.tblBankChequesDtl b
on p.CreditCode = b.BankCode
where ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      p.FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo AND
      ProcessID in (2,25,40) AND PayTypeID in (7,8,18,28) AND 
      ChequeNo>=b.FromChequeNo AND ChequeNo<=b.ToChequeNo AND 
     (p.ChequeBookFiscalYear <> b.FiscalYear OR p.ChequeBookID<>b.ChequeBookID)
-------------------------------------------------------------------------------
if (select count(*) from 
(SELECT count(*) Qty, ISNULL(VolumeFiscalYear,0) VolumeFiscalYear, ISNULL(VolumeRowNo,0) VolumeRowNo
,case when PayTypeID=6 then PayTypeID else 8 end PayTypeID
FROM trs.tblPayDtl 
WHERE ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo 
      and VolumeRowNo<>0
group by  ISNULL(VolumeFiscalYear,0) , ISNULL(VolumeRowNo,0) ,PayTypeID
Having count(*)>1) C) >0
begin

SELECT top 1  @MaxVolumeRowNo= ISNULL(VolumeRowNo,0) 
FROM trs.tblPayDtl 
WHERE ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo 
      and VolumeRowNo<>0
      
group by  ISNULL(VolumeFiscalYear,0) , ISNULL(VolumeRowNo,0) 
Having count(*)>1
			SET @strMsgText=' مشکل صدور شماره ردیف دفتر تکراری ' + str(@MaxVolumeRowNo)
			Raiserror (@strMsgText,16,1) 
			Return
end
-------------------------------------------------------------------------------
SELECT Distinct DocRowNo, ISNULL(VolumeFiscalYear,0) VolumeFiscalYear, ISNULL(VolumeRowNo,0) VolumeRowNo
FROM trs.tblPayDtl 
WHERE ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo 
ORDER BY DocRowNo
                               
END
GO
