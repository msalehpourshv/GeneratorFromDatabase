USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE TRIGGER [acc].[trgVoucherDtlInsert]
   ON acc.tblVoucherDtl 
   WITH ENCRYPTION
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @AcntCode NVarchar(20)

	--- zia ----------------------------
	DECLARE @FinalSerialNo	int

	set @FinalSerialNo = -1
	
	select @FinalSerialNo = SerialNo
	from acc.tblVoucherDtl
	where VchKind = 3
	
	if (@FinalSerialNo > 0) and ((Select top 1 SerialNo From Inserted) <> @FinalSerialNo)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR (N'سند اختتامیه ثبت شده است.', 16, 1);
	END
	--- /zia ----------------------------

	SELECT TOP 1 @AcntCode=inserted.AcntCode 
	FROM inserted
	WHERE ltrim(rtrim(inserted.AcntCode)) = ''

	IF @AcntCode is not null 
		BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR (N'کد خالی طرف حساب است !',10,1,@AcntCode); 
		END

	---------------------
	SELECT TOP 1 @AcntCode=rtrim(ltrim(inserted.AcntCode))
	FROM inserted
	WHERE pub.GetCodeName(inserted.AcntCode,1) is null 

	IF @AcntCode is not null 
		BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR ( N'%s کد مورد نظر پيدا نشد ',10,1, @AcntCode ); 
		END

	---------------------
	Declare 
    @SerialNo	Int,
	@DocRowNo	Int,
	@DocDate	VarChar(10),
	@AcntState	Tinyint,
	@LenAcnt1	Tinyint,
	@SumCreditDebit	Bigint, 
	@Credit		Bigint,
	@Debit		Bigint,
	@StrErr1	NVARCHAR(4000),--,
	@CurrencyAmount	FLOAT,
	@CurrencyTypeID	VarChar(20),
	@IsCurrency BIT
	
	SET @SumCreditDebit = 0

	SELECT @LenAcnt1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE PartNumber=1 AND TableName='acc.tblAcnt'

	Declare curVoucherInsertDocs Cursor  For 
	Select SerialNo, DocRowNo, I.AcntCode, DocDate, AcntState, Debit, Credit, CurrencyAmount, IsCurrency,I.CurrencyTypeID
	From Inserted I,acc.tblAcnt a 
	WHERE PartNumber = 1 AND a.AcntCode = LEFT(I.AcntCode,@LenAcnt1) AND AcntState > 1

	Open curVoucherInsertDocs
	
	FETCH NEXT FROM curVoucherInsertDocs INTO	
		@SerialNo, @DocRowNo, @AcntCode, @DocDate, @AcntState, @Debit, @Credit, @CurrencyAmount, @IsCurrency,@CurrencyTypeID

	WHILE @@FETCH_STATUS = 0
		BEGIN

		--IF @IsCurrency = 'True' AND @CurrencyAmount=0 
			--BEGIN
			--ROlLBACK
			--SET @StrErr1 = pub.funReverseForCrystal('#$ حساب کد ' + @AcntCode + ' ارزي است و بايد مبلغ ارزي پر شود #$')
			--RAISERROR (@StrErr1, 16, 1)				
			--END
		
		--IF @IsCurrency = 'False'  AND @CurrencyAmount<>0 
			--BEGIN
			--ROlLBACK
			--SET @StrErr1 = pub.funReverseForCrystal('#$ حساب کد ' + @AcntCode + ' ارزي نيست و نبايد مبلغ ارزي پر شود #$')
			--RAISERROR (@StrErr1, 16, 1)				
			--END
			
		IF @AcntState=2 AND	@Debit=0 AND @Credit<>0
			BEGIN
			ROlLBACK
			SET @StrErr1 = pub.funReverseForCrystal('#$ حساب کد ' + @AcntCode + ' فقط ميتواند بدهكار شود #$')
			RAISERROR (@StrErr1, 16, 1)
			END
		
		ELSE IF @AcntState=3 AND @Credit=0 AND @Debit<>0
			BEGIN
			ROlLBACK
			SET @StrErr1 = pub.funReverseForCrystal('#$ حساب کد ' + @AcntCode + ' فقط ميتواند بستانكار شود #$')
			RAISERROR (@StrErr1, 16, 1)
			END

		ELSE IF @AcntState=4 OR @AcntState=5
			BEGIN

			IF @IsCurrency ='True'
			BEGIN
			
				SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
				FROM acc.tblVoucherDtl
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND CurrencyTypeID = @CurrencyTypeID AND
					  ((DocDate<@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo<@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo<@DocRowNo) )

				Declare curNewAcntCode Cursor For 
				SELECT	SerialNo, DocRowNo,AcntCode, DocDate, case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
				FROM acc.tblVoucherDtl 
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND CurrencyTypeID = @CurrencyTypeID AND
					  ((DocDate>@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo>@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo>=@DocRowNo) )
				ORDER BY DocDate,SerialNo,DocRowNo
			END
			ELSE
			BEGIN
			BEGIN
				SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
				FROM acc.tblVoucherDtl
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND 
					  ((DocDate<@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo<@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo<@DocRowNo) )

				Declare curNewAcntCode Cursor For 
				SELECT	SerialNo, DocRowNo,AcntCode, DocDate, Debit, Credit
				FROM acc.tblVoucherDtl 
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND 
					  ((DocDate>@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo>@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo>=@DocRowNo) )
				ORDER BY DocDate,SerialNo,DocRowNo
			END
			END

			Open curNewAcntCode

			FETCH NEXT FROM curNewAcntCode INTO	
				@SerialNo, @DocRowNo, @AcntCode, @DocDate, @Debit, @Credit

			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @SumCreditDebit = @SumCreditDebit + @Debit - @Credit

					IF @AcntState = 4
						BEGIN
							IF @SumCreditDebit < 0
							BEGIN
								ROlLBACK
								SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @AcntCode + 'بايد بدهكار شود . در تاریخ ' + @DocDate + ' سند شماره ' + LTRIM(STR(ABS(@SerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$')
								RAISERROR (@StrErr1, 16, 1)
							END
						END
						
					ELSE IF @AcntState = 5
						BEGIN
							IF @SumCreditDebit > 0
							BEGIN
								ROlLBACK
								SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @AcntCode + 'بايد بستانكار شود . در تاریخ ' + @DocDate + ' سند شماره ' + LTRIM(STR(ABS(@SerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$')
								RAISERROR (@StrErr1, 16, 1)
							END			
						END			
			
					FETCH NEXT FROM curNewAcntCode INTO	
						@SerialNo, @DocRowNo, @AcntCode, @DocDate, @Debit, @Credit
				END
				
			Close curNewAcntCode
			Deallocate curNewAcntCode
			
			END
			
		----- Fetch next record
		FETCH NEXT FROM curVoucherInsertDocs INTO	
			@SerialNo, @DocRowNo, @AcntCode, @DocDate, @AcntState, @Debit, @Credit, @CurrencyAmount, @IsCurrency,@CurrencyTypeID
				
		END

	Close curVoucherInsertDocs
	Deallocate curVoucherInsertDocs

	--SELECT @LenAcnt1=Layer1
	--FROM pub.tblCodeLayer 
	--WHERE PartNumber=1 AND TableName='acc.tblAcnt'

	--Select TOP 1 @SerialNo = SerialNo
	--From Inserted I
	
	--DECLARE @Balance FLOAT
	--set @Balance =0
	--SELECT @Balance =SUM(Debit-Credit) 
	--FROM acc.tblVoucherDtl a
	--inner join (
	--	SELECT AcntCode FROM acc.tblAcnt 
	--	WHERE len(AcntCode)=@LenAcnt1 and PartNumber=1 and AcntType IN(91,92)
	--	) b
	--ON b.AcntCode=SUBSTRING(a.AcntCode,1,LEN(b.AcntCode))
	--WHERE SerialNo=@SerialNo


	--IF @Balance <>0
	--BEGIN
	--	ROlLBACK
	--	SET @StrErr1 = pub.funReverseForCrystal('#$ حساب های انتظامی بالانس نیست ' )
	--	RAISERROR (@StrErr1, 16, 1)
	--END
END
GO
