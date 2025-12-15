USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================

CREATE TRIGGER [acc].[trgVoucherDtlDelete]
   ON acc.tblVoucherDtl 
   WITH ENCRYPTION     
   AFTER DELETE
AS 

BEGIN
		---------------------
	Declare 
	
	@AcntCode	NVarchar(20),
    @SerialNo	Int,
	@DocRowNo	Int,
	@DocDate	VarChar(10) ,
	@AcntState	Tinyint,
	@LenAcnt1	Tinyint,
	@SumCreditDebit	Bigint, 
	@Credit		Bigint,
	@Debit		Bigint,
	@StrErr1	NVARCHAR(4000),
	@CurrencyAmount	FLOAT,
	@CurrencyTypeID	VarChar(20),
	@IsCurrency BIT

	--- zia ----------------------------
	declare @FinalSerialNo	int

	set @FinalSerialNo = -1
	
	select @FinalSerialNo = SerialNo
	from acc.tblVoucherDtl
	where VchKind = 3
	
	if (@FinalSerialNo > 0) and ((Select top 1 SerialNo From Deleted where Debit<>0 or Credit<>0) <> @FinalSerialNo)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR (N'سند اختتامیه ثبت شده است!', 16, 1);
	END
	--- /zia ----------------------------

	SET @SumCreditDebit = 0

	SELECT @LenAcnt1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE PartNumber=1 AND TableName='acc.tblAcnt'

	Declare curVoucherDeletedDocs Cursor For 
	Select	SerialNo, DocRowNo, D.AcntCode, DocDate, AcntState, CurrencyAmount, IsCurrency,CurrencyTypeID
	From Deleted D,acc.tblAcnt a 
	WHERE PartNumber = 1 AND a.AcntCode = LEFT(D.AcntCode,@LenAcnt1) AND AcntState IN (4,5)

	Open curVoucherDeletedDocs
	
	FETCH NEXT FROM curVoucherDeletedDocs INTO	
		@SerialNo, @DocRowNo, @AcntCode, @DocDate, @AcntState, @CurrencyAmount, @IsCurrency,@CurrencyTypeID

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SumCreditDebit = 0
			IF @IsCurrency ='True'
			BEGIN
				SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
				FROM acc.tblVoucherDtl
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND CurrencyTypeID = @CurrencyTypeID AND
					  ((DocDate<@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo<@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo<@DocRowNo) )

				Declare curNewAcntCode Cursor  For 
				SELECT	SerialNo, DocRowNo, AcntCode, DocDate, case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
				FROM acc.tblVoucherDtl 
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND CurrencyTypeID = @CurrencyTypeID AND
					  ((DocDate>@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo>@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo>=@DocRowNo) )
				ORDER BY DocDate,SerialNo,DocRowNo
			END
			ELSE
			BEGIN
				SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
				FROM acc.tblVoucherDtl
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND 
					  ((DocDate<@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo<@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo<@DocRowNo) )

				Declare curNewAcntCode Cursor  For 
				SELECT	SerialNo, DocRowNo, AcntCode, DocDate, Debit, Credit
				FROM acc.tblVoucherDtl 
				WHERE LEFT(AcntCode,LEN(@AcntCode)) = @AcntCode AND 
					  ((DocDate>@DocDate) OR 
					   (DocDate=@DocDate AND SerialNo>@SerialNo) OR
					   (DocDate=@DocDate AND SerialNo=@SerialNo AND DocRowNo>=@DocRowNo) )
				ORDER BY DocDate,SerialNo,DocRowNo
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
								Close curNewAcntCode
								Deallocate curNewAcntCode
								Close curVoucherDeletedDocs
								Deallocate curVoucherDeletedDocs								
								SET @StrErr1 =  pub.funReverseForCrystal('#$مانده حساب کد ' + @AcntCode + 'بايد بدهكار شود . در تاریخ ' + @DocDate + ' سند شماره ' + LTRIM(STR(ABS(@SerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$' )
								raiserror (@StrErr1, 16, 1)
							END
						END
						
					ELSE IF @AcntState = 5
						BEGIN
							IF @SumCreditDebit > 0
							BEGIN
								ROlLBACK
								Close curNewAcntCode
								Deallocate curNewAcntCode
								Close curVoucherDeletedDocs
								Deallocate curVoucherDeletedDocs
								SET @StrErr1 =  pub.funReverseForCrystal('#$مانده حساب کد ' + @AcntCode + 'بايد بستانكار شود . در تاریخ ' + @DocDate + ' سند شماره ' + LTRIM(STR(ABS(@SerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$' )
								raiserror (@StrErr1, 16, 1)
							END			
						END			
			
					FETCH NEXT FROM curNewAcntCode INTO	
						@SerialNo, @DocRowNo, @AcntCode, @DocDate,@Debit,@Credit
				END
				
			Close curNewAcntCode
			Deallocate curNewAcntCode
			
			----- Fetch next record
			FETCH NEXT FROM curVoucherDeletedDocs INTO	
				@SerialNo, @DocRowNo, @AcntCode, @DocDate, @AcntState, @CurrencyAmount, @IsCurrency,@CurrencyTypeID
				
		END

	Close curVoucherDeletedDocs
	Deallocate curVoucherDeletedDocs

END
GO
