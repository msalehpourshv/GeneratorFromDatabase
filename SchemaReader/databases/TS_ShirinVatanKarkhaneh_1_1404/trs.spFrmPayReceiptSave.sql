USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/06/22
-- Description:	
-- =============================================
Create PROCEDURE [trs].[spFrmPayReceiptSave] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @DocDate		Char(10),
 @LanguageID	TinyInt=1,
 @VoucherSerialNo Int,
 @StartTargetLayer tinyint,
 @LenTargetLayer tinyint,
 @PartNumber TinyInt,
 @DateFrom   char(10)
 
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;
Declare @strMsgText	 NVarChar(2044)
Declare @LocationID		VarChar(20)
Declare @BankTypeID		VarChar(20)
Declare @rr		        NVarChar(500)
Declare @PayTypeID	 Int
Declare @EventNo	 Int
Declare @RowNo       Int
Declare @DebitCode VarChar(20)
Declare @CreditCode VarChar(20)
Declare @BankState   Tinyint
Declare @AcntCode1 Varchar(20)
Declare @AcntCode2 Varchar(20)
Declare @AcntCode3 Varchar(20)
Declare @AcntCode5 Varchar(20)
Declare @DebitRoof Bigint
Declare @ChequeNo  Varchar(20)
Declare @BankCode  Varchar(20)
declare @Amount    BigInt
declare @ReceiptPreventWhenNegativeRemain BIT
declare @VolumeFiscalYear INT
declare @VolumeRowNo INT
DECLARE @MaxVolumeRowNo int

SELECT @MaxVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
FROM trs.tblPayDtl 
WHERE PayTypeID IN (6,26) AND
	  VolumeFiscalYear = @FiscalYear
 if @MaxVolumeRowNo=0
	SELECT   @MaxVolumeRowNo= SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'StartVolumeRowNo')

SET @ReceiptPreventWhenNegativeRemain = 'False'
SELECT @ReceiptPreventWhenNegativeRemain= SettingValue 
FROM pub.tblSettings 
WHERE(SettingKey = N'ReceiptPreventWhenNegativeRemain')

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
		    PayTypeID IN (6,26)    ) t 
WHERE ProcessID =@ProcessID  AND
	  ProcessNo =@ProcessNo  AND
	  FiscalYear=@FiscalYear AND
	  SerialNo  =@SerialNo   AND
	  PayTypeID IN (6,26)    AND
      VolumeRowNo = 0	     AND
	  trs.tblPayDtl.RowNo=t.RowNo


Declare	Cursor_Rec CURSOR For 
    SELECT RD.LocationID,RD.BankTypeID,PayTypeID,EventNo,RowNo,DebitCode,BankState,AcntCode1,AcntCode2,AcntCode3,AcntCode5,DebitRoof,ChequeNo,BankCode,Amount,CreditCode,VolumeFiscalYear,VolumeRowNo
    FROM trs.tblPayDtl RD,trs.tblOurBanks OB
    WHERE  RD.DebitCode=OB.BankCode AND
		   RD.ProcessID=@ProcessID AND
           RD.ProcessNo=@ProcessNo AND
           RD.FiscalYear=@FiscalYear AND
           RD.SerialNo=@SerialNo 

Open  Cursor_Rec; 

Fetch NEXT From Cursor_Rec Into @LocationID, @BankTypeID,@PayTypeID,@EventNo,@RowNo,@DebitCode,@BankState,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@DebitRoof,@ChequeNo,@BankCode,@Amount,@CreditCode,@VolumeFiscalYear,@VolumeRowNo

While (@@Fetch_Status = 0)
BEGIN

	IF @LocationID IS NULL
		SET @LocationID = ''

	IF @BankTypeID IS NULL
		SET @BankTypeID = ''

	IF @EventNo IS NULL
		SET @EventNo = 0

	IF @BankTypeID <> '' AND ( 
		 SELECT count(*)
		 FROM trs.tblBankTypes
		 WHERE BankTypeID=@BankTypeID )=0
	begin
		Close Cursor_Rec;
		Deallocate Cursor_Rec;
		--بانكي به کد  %s وجود ندارد
		SET @strMsgText=TS.pub.funGetMessages(12064,@LanguageID)
		Raiserror (@strMsgText,16,1,@BankTypeID)
		Return
	END

	IF @LocationID  <> '' AND ( 
		 SELECT count(*)
		 FROM pub.tblLocations
		 WHERE LocationID=@LocationID )=0
	begin
		Close Cursor_Rec;
		Deallocate Cursor_Rec;
		--شهری به کد  %s وجود ندارد
		SET @strMsgText=TS.pub.funGetMessages(12065,@LanguageID)
		Raiserror (@strMsgText,16,1,@LocationID)
		Return
	END

	IF @BankState=2 
		BEGIN
			IF (SELECT ISNULL(SUM(Debit-Credit),0) 
				FROM acc.tblVoucherDtl
				WHERE ((@AcntCode1 <> '' AND AcntCode LIKE @AcntCode1+'%') OR 
					   (@AcntCode2 <> '' AND AcntCode LIKE @AcntCode2+'%') OR 
					   (@AcntCode3 <> '' AND AcntCode LIKE @AcntCode3+'%') OR 
					   (@AcntCode5 <> '' AND AcntCode LIKE @AcntCode5+'%')) AND DocDate<=@DocDate 
					   AND NOT (SourceProcessID =@ProcessID AND SourceProcessNo=@ProcessNo AND 
					            SourceFiscalYear=@FiscalYear AND SourceSerialNo=@SerialNo)
					  ) > @DebitRoof
			BEGIN
				SET @strMsgText=TS.pub.funGetMessages(12077,@LanguageID)
				Raiserror (@strMsgText,16,1,@DebitCode)
				Return
			END
		END		

	IF ( @PayTypeID = 6 OR @PayTypeID = 26 ) AND @LenTargetLayer > 0 AND @PartNumber > 0 AND @ReceiptPreventWhenNegativeRemain ='True'
		BEGIN
			DECLARE @MaxReceivableRemain as BIGINT
			DECLARE @ReceivableRemain as BIGINT
			DECLARE @TempSumVal BIGINT
			SET @MaxReceivableRemain = 0 						
			SELECT @MaxReceivableRemain = MaxReceivableRemain
			from acc.tblAcnt
			WHERE PartNumber = @PartNumber	AND AcntCode = SUBSTRING(@CreditCode,@StartTargetLayer,@LenTargetLayer)

			IF @MaxReceivableRemain > 0	
				BEGIN

					DECLARE @StrTemp		NVarChar(4000)
					DECLARE @StrSelect		NVarChar(4000)
					DECLARE @StrPrevDB		NVarChar(100)
					DECLARE @StrDB			NVarChar(100)
					DECLARE @ParmDefinition NVarChar(200)

					SET @ParmDefinition = N'@iSumVal BigInt OUTPUT';
					SET @ReceivableRemain = 0
					SET @TempSumVal = 0	

					--Set NOCOUNT ON;
	--DECLARE @iSumVal AS	BigInt
					--SET		@iSumVal = 0.0
					-- اسناد دریافتنی موجود در صندوق و موجود در بانک
					SET @StrSelect = '
					SELECT	@iSumVal = IsNull(Sum(PD.Amount), 0)
					FROM	[trs].tblPayDtl AS PD
							INNER JOIN 
							(
								SELECT A.*,Credit FROM 
								(SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
								FROM	[trs].tblPayDtl AS PD2
								WHERE	PD2.PayTypeID IN (6, 26) --AND PD2.ProcessNo = ' + LTrim(Str(@ProcessNo)) + '
								GROUP BY VolumeFiscalYear, VolumeRowNo) A
								,
								(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode  Credit
								 FROM	trs.tblPayDtl
								 WHERE	ProcessID IN (1,10) AND 
										PayTypeID IN (6,26) AND 
										CreditCode = ''' + @CreditCode + '''
								) B
								WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
							) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
									 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
					WHERE	PD.PayTypeID IN (6, 26) AND 
							PD.ProcessID IN (1, 10, 17, 20, 21, 23, 40) AND 
							--PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND
							VOL.Credit = ''' + @CreditCode + ''''

					Exec sp_executesql @StrSelect,@ParmDefinition, @iSumVal = @ReceivableRemain OUTPUT;

					SET @TempSumVal = @ReceivableRemain
					-- اسناد دریافتنی واگذار شده به اشخاص
					SET @StrSelect = '
					SELECT	@iSumVal = ISNull(Sum(PD.Amount), 0)
					FROM	[@DBNAME].[trs].[tblPayDtl] AS PD
							INNER JOIN 
							(
								SELECT A.*,Credit FROM 
								(SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
								FROM	[@DBNAME].[trs].[tblPayDtl] AS PD2
								WHERE	PD2.PayTypeID IN (6, 26) --AND PD2.ProcessNo = ' + LTrim(Str(@ProcessNo)) + '
								GROUP BY VolumeFiscalYear, VolumeRowNo) A
								,
								(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode  Credit
								 FROM	[@DBNAME].trs.tblPayDtl
								 WHERE	ProcessID IN (1,10) AND 
										PayTypeID IN (6,26) AND 
										CreditCode = ''' + @CreditCode + '''
								) B
								WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
							) VOL ON 
								PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
								PD.VolumeRowNo = VOL.VolumeRowNo AND 
								PD.EventNo = VOL.EventNo
					WHERE	PD.PayTypeID IN (6, 26) AND
							PD.ProcessID = 2 AND
							--PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND
							PD.ChequeDate > ''' + @DateFrom + ''' AND
							VOL.Credit = ''' + @CreditCode + ''''
					SET @StrTemp = @StrSelect
					SET @StrSelect = Replace(@StrSelect, '@DBNAME', db_name())
					SET @ReceivableRemain = 0
					Exec sp_executesql @StrSelect,@ParmDefinition, @iSumVal = @ReceivableRemain OUTPUT;
					SET @TempSumVal = @TempSumVal + @ReceivableRemain

					------- 1 Year Before ----------------------------------
					SET @StrDB = db_name()

					Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT
					
					If (@StrPrevDB = '')
						GOTO RUN

					SET @StrSelect = @StrTemp
					
					SET @StrSelect =  Replace(@StrSelect, '@DBNAME', @StrPrevDB)
					SET @ReceivableRemain = 0
					Exec sp_executesql @StrSelect,@ParmDefinition, @iSumVal = @ReceivableRemain OUTPUT;
					SET @TempSumVal = @TempSumVal + @ReceivableRemain
				
					----------- 2 Years Before ----------------------------------
					SET @StrDB = @StrPrevDB

					Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

					If (@StrPrevDB = '') 
						GOTO RUN

					SET @StrSelect = @StrTemp
					SET @StrSelect =  Replace(@StrSelect, '@DBNAME', @StrPrevDB)
					SET @ReceivableRemain = 0
					Exec sp_executesql @StrSelect,@ParmDefinition, @iSumVal = @ReceivableRemain OUTPUT;
					SET @TempSumVal = @TempSumVal + @ReceivableRemain
					--------------------------------------------------------
				RUN:

					If @MaxReceivableRemain < @TempSumVal  
						BEGIN
							Close Cursor_Rec;
							Deallocate Cursor_Rec;
							declare @IntRemain as int
							SET @IntRemain =@TempSumVal  - @MaxReceivableRemain 
							--از سقف اعتباری(مانده اسناد دریافتنی) به کد مشتری %s مبلغ %d بیشتر است
							SET @strMsgText=TS.pub.funGetMessages(12082,@LanguageID)
							Raiserror (@strMsgText,16,1,@CreditCode,@IntRemain)
							Return
						END
						

				END
		END
	IF ( @PayTypeID = 6 OR @PayTypeID = 26 )
	BEGIN
		IF (SELECT COUNT(*) 
		    FROM trs.tblPayDtl
			WHERE VolumeFiscalYear= @VolumeFiscalYear and 
			      VolumeRowNo = @VolumeRowNo AND 
				  PayTypeID = @PayTypeID  AND 
				  EventNo>@EventNo and 
				  DocDate<@DocDate
			)>0
			BEGIN
				Close Cursor_Rec;
				Deallocate Cursor_Rec; 
				SET @strMsgText='ذخیره با مشکل مواجه شد.شماره ریدف دفتر ' + LTRIM(RTRIM(@VolumeRowNo)) + ' تاریخ گردش های بعدی کوچکتر از تاریخ این برگه است' 
				Raiserror (@strMsgText,16,1,@DebitCode)
				Return
			END
	END

	Fetch NEXT From Cursor_Rec Into @LocationID, @BankTypeID,@PayTypeID,@EventNo,@RowNo,@DebitCode,@BankState,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@DebitRoof,@ChequeNo,@BankCode,@Amount,@CreditCode,@VolumeFiscalYear,@VolumeRowNo

End

Close Cursor_Rec;
Deallocate Cursor_Rec; 

-------------------------------------------------------------------------------

--if (select COUNT(*) from trs.tblPayDtl
--	where FiscalYear=@FiscalYear and ProcessNo =@ProcessNo and  ProcessID = @ProcessID and ChequeNo in 
--	(
--	select ChequeNo  from trs.tblPayDtl
--	where FiscalYear=@FiscalYear and ProcessNo =@ProcessNo and ProcessID = @ProcessID and PayTypeID in (6,26,16)
--	group by  ChequeNo,DocDate,BankTypeID,AccountNo,ChequeDate
--	having count(*)>1
--	))>0
--BEGIN
--		Raiserror (N'خطای 150004 : مشکل شبکه لطفا برگه را ببندید',16,1)
--		Return
--END
-------------------------------------------------------------------------------
if (select count(*) from 
(SELECT count(*) Qty, ISNULL(VolumeFiscalYear,0) VolumeFiscalYear, ISNULL(VolumeRowNo,0) VolumeRowNo
FROM trs.tblPayDtl 
WHERE ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo 
      and VolumeRowNo<>0
group by  ISNULL(VolumeFiscalYear,0) , ISNULL(VolumeRowNo,0) 
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
SELECT DocRowNo, ISNULL(VolumeFiscalYear,0) VolumeFiscalYear, ISNULL(VolumeRowNo,0) VolumeRowNo
FROM trs.tblPayDtl 
WHERE ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo 
ORDER BY DocRowNo

END
GO
