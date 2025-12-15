USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Name
-- Create date: 
-- Description:	
-- =============================================
CREATE TRIGGER [acc].[trgVoucherDtlUpdate]
   ON acc.tblVoucherDtl 
   WITH ENCRYPTION
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @NewAcntCode NVarchar(20)

	--- zia ----------------------------
	DECLARE @FinalSerialNo	int

	set @FinalSerialNo = -1
	
	select @FinalSerialNo = SerialNo
	from acc.tblVoucherDtl
	where VchKind = 3
	
	if (@FinalSerialNo > 0) and ((Select top 1 SerialNo From Inserted) <> @FinalSerialNo)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR (N'سند اختتامیه ثبت شده است!', 16, 1);
	END
	--- /zia ----------------------------

	SELECT TOP 1 @NewAcntCode=inserted.AcntCode 
	FROM inserted
	WHERE ltrim(rtrim(inserted.AcntCode)) = ''

	IF @NewAcntCode is not null 
		BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR (N'کد خالی طرف حساب است !',10,1,@NewAcntCode); 
		END

	---------------------
	SELECT TOP 1 @NewAcntCode=rtrim(ltrim(inserted.AcntCode))
	FROM inserted
	WHERE pub.GetCodeName(inserted.AcntCode,1) is null 

	IF @NewAcntCode is not null 
		BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR ( N'%s کد مورد نظر پيدا نشد ',10,1, @NewAcntCode ); 
		END

	---------------------
	Declare 
	@NewSerialNo	Int,
    @OldSerialNo	Int,
	@OldAcntCode	NVarchar(20),
	@NewDocRowNo	Int,
	@OldDocRowNo	Int,
	@NewDocDate		VarChar(10) ,
	@OldDocDate		VarChar(10) ,
	@NewAcntState	Tinyint,
	@OldAcntState	Tinyint,
	@NewCredit	Bigint,
	@OldCredit	Bigint,
	@NewDebit	Bigint,
	@OldDebit	Bigint,
	@SumCreditDebit	Bigint,
	@LenAcnt1	Tinyint,
	@Flg		Int,
	@StrErr1	NVARCHAR(4000),
	@NewCurrencyAmount	FLOAT,
	@NewCurrencyTypeID	VarChar(20),
	@NewIsCurrency BIT,
 	@OldCurrencyAmount	FLOAT,
	@OldCurrencyTypeID	VarChar(20),
	@OldIsCurrency BIT

	SET @Flg=0
	SET @SumCreditDebit = 0

	SELECT @LenAcnt1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE PartNumber=1 AND TableName='acc.tblAcnt'

	Declare curVoucherInsertDocs Cursor  For 
	SELECT SerialNo, DocRowNo,I.AcntCode, DocDate, AcntState, CurrencyAmount, IsCurrency,CurrencyTypeID
	From Inserted I,acc.tblAcnt a 
	--WHERE PartNumber = 1 AND a.AcntCode = LEFT(I.AcntCode,@LenAcnt1)
	WHERE PartNumber = 1 AND a.AcntCode = LEFT(I.AcntCode,@LenAcnt1) AND AcntState > 1

	Declare curVoucherDeleted Cursor  For 
	SELECT SerialNo, DocRowNo,D.AcntCode, DocDate, AcntState, CurrencyAmount, IsCurrency,CurrencyTypeID
	From Deleted D,acc.tblAcnt a 
	--WHERE PartNumber = 1 AND a.AcntCode = LEFT(D.AcntCode,@LenAcnt1)
	WHERE PartNumber = 1 AND a.AcntCode = LEFT(D.AcntCode,@LenAcnt1) AND AcntState IN (4,5)

	Open curVoucherInsertDocs
	Open curVoucherDeleted
	
	FETCH NEXT FROM curVoucherInsertDocs INTO	
		@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewAcntState, @NewCurrencyAmount, @NewIsCurrency,@NewCurrencyTypeID

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
		--IF @NewIsCurrency = 'True' AND @NewCurrencyAmount=0 
			--BEGIN
			--ROlLBACK
			--SET @StrErr1 = pub.funReverseForCrystal('#$ حساب کد ' + @NewAcntCode + ' ارزي است و بايد مبلغ ارزي پر شود #$')
			--RAISERROR (@StrErr1, 16, 1)				
			--END
		
		--IF @NewIsCurrency = 'False'  AND @NewCurrencyAmount<>0 
			--BEGIN
			--ROlLBACK
			--SET @StrErr1 = pub.funReverseForCrystal('#$ حساب کد ' + @NewAcntCode + ' ارزي نيست و نبايد مبلغ ارزي پر شود #$')
			--RAISERROR (@StrErr1, 16, 1)				
			--END
			
			----- داده هاي سطر قديمي 
			FETCH NEXT FROM curVoucherDeleted INTO	
				@OldSerialNo, @OldDocRowNo, @OldAcntCode, @OldDocDate, @OldAcntState, @OldCurrencyAmount, @OldIsCurrency,@OldCurrencyTypeID
		
				IF @OldAcntCode <> @NewAcntCode
					BEGIN
						IF @OldAcntState=4 OR @OldAcntState=5
							BEGIN
								IF @OldIsCurrency ='True'
								BEGIN
									SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
									FROM acc.tblVoucherDtl
									WHERE LEFT(AcntCode,LEN(@OldAcntCode)) = @OldAcntCode AND CurrencyTypeID = @OldCurrencyTypeID AND
										  ((DocDate<@OldDocDate) OR 
										   (DocDate=@OldDocDate AND SerialNo<@OldSerialNo) OR
										   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo<@OldDocRowNo) )

									Declare curOldAcntCode Cursor  For 
									SELECT SerialNo, DocRowNo,AcntCode, DocDate,case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
									FROM acc.tblVoucherDtl 
									WHERE LEFT(AcntCode,LEN(@OldAcntCode)) = @OldAcntCode AND CurrencyTypeID = @OldCurrencyTypeID AND
										  ((DocDate>@OldDocDate) OR 
										   (DocDate=@OldDocDate AND SerialNo>@OldSerialNo) OR
										   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo>=@OldDocRowNo) )
									ORDER BY DocDate,SerialNo,DocRowNo
								END
								ELSE
								BEGIN
									SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
									FROM acc.tblVoucherDtl
									WHERE LEFT(AcntCode,LEN(@OldAcntCode)) = @OldAcntCode AND 
										  ((DocDate<@OldDocDate) OR 
										   (DocDate=@OldDocDate AND SerialNo<@OldSerialNo) OR
										   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo<@OldDocRowNo) )

									Declare curOldAcntCode Cursor  For 
									SELECT SerialNo, DocRowNo,AcntCode, DocDate,Debit,Credit
									FROM acc.tblVoucherDtl 
									WHERE LEFT(AcntCode,LEN(@OldAcntCode)) = @OldAcntCode AND 
										  ((DocDate>@OldDocDate) OR 
										   (DocDate=@OldDocDate AND SerialNo>@OldSerialNo) OR
										   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo>=@OldDocRowNo) )
									ORDER BY DocDate,SerialNo,DocRowNo
								END
								Open curOldAcntCode
				
								FETCH NEXT FROM curOldAcntCode INTO	
									@OldSerialNo, @OldDocRowNo, @OldAcntCode, @OldDocDate,@OldDebit,@OldCredit

								WHILE @@FETCH_STATUS = 0
									BEGIN
										SET @SumCreditDebit = @SumCreditDebit + @OldDebit - @OldCredit

										IF @OldAcntState = 4
											BEGIN
												IF @SumCreditDebit < 0
												BEGIN
													ROlLBACK
													SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @OldAcntCode + 'بايد بدهكار شود . در تاریخ ' + @OldDocDate + ' سند شماره ' + LTRIM(STR(ABS(@OldSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$' )
													raiserror (@StrErr1, 16, 1)
												END
											END
											
										ELSE IF @OldAcntState = 5
											BEGIN
												IF @SumCreditDebit > 0
												BEGIN
													ROlLBACK
													SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @OldAcntCode + 'بايد بستانكار شود . در تاریخ ' + @OldDocDate + ' سند شماره ' + LTRIM(STR(ABS(@OldSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$' )
													raiserror (@StrErr1, 16, 1)
												END			
											END			
								
										FETCH NEXT FROM curOldAcntCode INTO	
											@OldSerialNo, @OldDocRowNo, @OldAcntCode, @OldDocDate,@OldDebit,@OldCredit
									
									END
							
								Close curOldAcntCode
								Deallocate curOldAcntCode
							
							END -- IF @OldAcntState=4 OR @OldAcntState=5
							
						-------------------------
						IF @NewAcntState=4 OR @NewAcntState=5
							BEGIN						
								IF @NewIsCurrency ='True'
								BEGIN
									SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
									FROM acc.tblVoucherDtl
									WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND
										  ((DocDate<@NewDocDate) OR 
										   (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
										   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<@NewDocRowNo) )

									Declare curNewAcntCode Cursor  For 
									SELECT SerialNo,DocRowNo,AcntCode,DocDate,case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
									FROM acc.tblVoucherDtl 
									WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND 
										  ((DocDate>@NewDocDate) OR 
										   (DocDate=@NewDocDate AND SerialNo>@NewSerialNo) OR
										   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo>=@NewDocRowNo) )
									ORDER BY DocDate,SerialNo,DocRowNo
								END	
								ELSE
								BEGIN
									SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
									FROM acc.tblVoucherDtl
									WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
										  ((DocDate<@NewDocDate) OR 
										   (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
										   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<@NewDocRowNo) )

									Declare curNewAcntCode Cursor  For 
									SELECT SerialNo,DocRowNo,AcntCode,DocDate,Debit,Credit
									FROM acc.tblVoucherDtl 
									WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
										  ((DocDate>@NewDocDate) OR 
										   (DocDate=@NewDocDate AND SerialNo>@NewSerialNo) OR
										   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo>=@NewDocRowNo) )
									ORDER BY DocDate,SerialNo,DocRowNo

								END
								
								Open curNewAcntCode
				
								FETCH NEXT FROM curNewAcntCode INTO	
									@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate,@NewDebit,@NewCredit

								WHILE @@FETCH_STATUS = 0
									BEGIN
										SET @SumCreditDebit = @SumCreditDebit + @NewDebit - @NewCredit

										IF @NewAcntState = 4
											BEGIN
												IF @SumCreditDebit < 0
												BEGIN
													ROlLBACK
													SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بدهكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$' )
													raiserror (@StrErr1, 16, 1)
												END
											END

										ELSE IF @NewAcntState = 5
											BEGIN
												IF @SumCreditDebit > 0
												BEGIN
													ROlLBACK
													SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بستانكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$' )
													raiserror (@StrErr1, 16, 1)
												END			
											END			
								
										FETCH NEXT FROM curNewAcntCode INTO	
											@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewDebit, @NewCredit
									END
									
								Close curNewAcntCode
								Deallocate curNewAcntCode
								
							END
					END --@OldAcntCode <> @NewAcntCode

				ELSE IF @NewDocDate>@OldDocDate
					SET @Flg = 1
					
				ELSE IF @NewDocDate<@OldDocDate
					SET @Flg = -1
					
				ELSE 
					BEGIN
						IF @NewSerialNo>@OldSerialNo
							SET @Flg = 1
							
						ELSE IF @NewSerialNo<@OldSerialNo
							SET @Flg = -1
							
						ELSE
							BEGIN
								IF @NewDocRowNo>@OldDocRowNo
									SET @Flg = 1
									
								ELSE IF @NewDocRowNo<@OldDocRowNo
									SET @Flg = -1
									
								ELSE
									SET @Flg = 0
							END
							
					END	
			 
			--------------------------------------------------
			IF 	@Flg = 1
				BEGIN
					IF @NewAcntState=4 OR @NewAcntState=5
						BEGIN
							IF @NewIsCurrency ='True'
							BEGIN
								SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
								FROM acc.tblVoucherDtl
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND  
									  ((DocDate<@OldDocDate) OR 
									   (DocDate=@OldDocDate AND SerialNo<@OldSerialNo) OR
									   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo<@OldDocRowNo) )
								   
								Declare curFlg1 Cursor  For 
								SELECT SerialNo,DocRowNo,AcntCode,DocDate,case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
								FROM acc.tblVoucherDtl 
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND  
									  ((DocDate>@OldDocDate) OR 
									   (DocDate=@OldDocDate AND SerialNo>@OldSerialNo) OR
									   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo>=@OldDocRowNo) ) AND
									  ((DocDate<@NewDocDate) OR 
									   (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
									   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<=@NewDocRowNo) )
								ORDER BY DocDate,SerialNo,DocRowNo
							END
							ELSE
							BEGIN
								SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
								FROM acc.tblVoucherDtl
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
									  ((DocDate<@OldDocDate) OR 
									   (DocDate=@OldDocDate AND SerialNo<@OldSerialNo) OR
									   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo<@OldDocRowNo) )
								   
								Declare curFlg1 Cursor  For 
								SELECT SerialNo,DocRowNo,AcntCode,DocDate,Debit,Credit
								FROM acc.tblVoucherDtl 
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
									  ((DocDate>@OldDocDate) OR 
									   (DocDate=@OldDocDate AND SerialNo>@OldSerialNo) OR
									   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo>=@OldDocRowNo) ) AND
									  ((DocDate<@NewDocDate) OR 
									   (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
									   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<=@NewDocRowNo) )
								ORDER BY DocDate,SerialNo,DocRowNo
							END
							Open curFlg1
			
							FETCH NEXT FROM curFlg1 INTO	
								@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewDebit, @NewCredit

							WHILE @@FETCH_STATUS = 0
								BEGIN
									SET @SumCreditDebit = @SumCreditDebit + @NewDebit - @NewCredit

									IF @NewAcntState = 4
										BEGIN
											IF @SumCreditDebit < 0
											BEGIN
												ROlLBACK
												SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بدهكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$' )
												raiserror (@StrErr1, 16, 1)
											END
										END
										
									ELSE IF @NewAcntState = 5
										BEGIN
											IF @SumCreditDebit > 0
											BEGIN
												ROlLBACK
												SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بستانكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$' )
												raiserror (@StrErr1, 16, 1)
											END			
										END			
							
									FETCH NEXT FROM curFlg1 INTO	
										@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate,@NewDebit,@NewCredit
								END
							Close curFlg1
							Deallocate curFlg1
						END --IF @NewAcntState=4 OR @NewAcntState=5
				END
				
			--------------------------------------------------
			ELSE IF @Flg = -1
				BEGIN
					IF @NewAcntState = 4 OR @NewAcntState = 5
						BEGIN				
							IF @NewIsCurrency ='True'
							BEGIN
								SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
								FROM acc.tblVoucherDtl
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND   
									((DocDate<@NewDocDate) OR 
									 (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
									 (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<@NewDocRowNo) )

								Declare curFlg2 Cursor  For 
								SELECT SerialNo, DocRowNo,AcntCode, DocDate,case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
								FROM acc.tblVoucherDtl 
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND   
									  ((DocDate>@NewDocDate) OR 
									   (DocDate=@NewDocDate AND SerialNo>@NewSerialNo) OR
									   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo>=@NewDocRowNo) ) AND
									  ((DocDate<@OldDocDate) OR 
									   (DocDate=@OldDocDate AND SerialNo<@OldSerialNo) OR
									   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo<=@OldDocRowNo) )
								ORDER BY DocDate,SerialNo,DocRowNo
							END
							ELSE
							BEGIN
								SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
								FROM acc.tblVoucherDtl
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
									((DocDate<@NewDocDate) OR 
									 (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
									 (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<@NewDocRowNo) )

								Declare curFlg2 Cursor  For 
								SELECT SerialNo, DocRowNo,AcntCode, DocDate,Debit,Credit
								FROM acc.tblVoucherDtl 
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
									  ((DocDate>@NewDocDate) OR 
									   (DocDate=@NewDocDate AND SerialNo>@NewSerialNo) OR
									   (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo>=@NewDocRowNo) ) AND
									  ((DocDate<@OldDocDate) OR 
									   (DocDate=@OldDocDate AND SerialNo<@OldSerialNo) OR
									   (DocDate=@OldDocDate AND SerialNo=@OldSerialNo AND DocRowNo<=@OldDocRowNo) )
								ORDER BY DocDate,SerialNo,DocRowNo
							END
							Open curFlg2
			
							FETCH NEXT FROM curFlg2 INTO	
								@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewDebit, @NewCredit

							WHILE @@FETCH_STATUS = 0
								BEGIN
									SET @SumCreditDebit = @SumCreditDebit + @NewDebit - @NewCredit

									IF @NewAcntState = 4
										BEGIN
											IF @SumCreditDebit < 0
											BEGIN
												ROlLBACK
												SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بدهكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$' )
												raiserror (@StrErr1, 16, 1)
											END
										END

									ELSE IF @NewAcntState = 5
										BEGIN
											IF @SumCreditDebit > 0
											BEGIN
												ROlLBACK
												SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بستانكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$' )
												raiserror (@StrErr1, 16, 1)
											END			
										END			
							
									FETCH NEXT FROM curFlg2 INTO	
										@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewDebit, @NewCredit
								END

							Close curFlg2
							Deallocate curFlg2

						END	--IF @NewAcntState=4 OR @NewAcntState=5
				END

			--------------------------------------------------
			ELSE IF @NewDebit<>@OldDebit OR @NewCredit<>@OldCredit
				BEGIN
					IF @NewAcntState=4 OR @NewAcntState=5
						BEGIN					
							IF @NewIsCurrency ='True'
							BEGIN
								SELECT @SumCreditDebit=ISNULL(SUM(case when Debit >0 then CurrencyAmount ELSE -1 * CurrencyAmount END ),0)
								FROM acc.tblVoucherDtl
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND  
									((DocDate<@NewDocDate) OR 
									 (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
									 (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<@NewDocRowNo) )

								Declare curCreditDebit Cursor  For 
								SELECT SerialNo, DocRowNo,AcntCode, DocDate,case when Debit >0 then CurrencyAmount ELSE 0 END Debit,case when Credit >0 then CurrencyAmount ELSE 0 END Credit
								FROM acc.tblVoucherDtl 
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND CurrencyTypeID = @NewCurrencyTypeID AND 
									((DocDate>@NewDocDate) OR 
									 (DocDate=@NewDocDate AND SerialNo>@NewSerialNo) OR
									 (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo>=@NewDocRowNo) )
								ORDER BY DocDate,SerialNo,DocRowNo
							END
							ELSE
							BEGIN
								SELECT @SumCreditDebit=ISNULL(SUM(Debit-Credit),0)
								FROM acc.tblVoucherDtl
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
									((DocDate<@NewDocDate) OR 
									 (DocDate=@NewDocDate AND SerialNo<@NewSerialNo) OR
									 (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo<@NewDocRowNo) )

								Declare curCreditDebit Cursor  For 
								SELECT SerialNo, DocRowNo,AcntCode, DocDate,Debit,Credit
								FROM acc.tblVoucherDtl 
								WHERE LEFT(AcntCode,LEN(@NewAcntCode)) = @NewAcntCode AND 
									((DocDate>@NewDocDate) OR 
									 (DocDate=@NewDocDate AND SerialNo>@NewSerialNo) OR
									 (DocDate=@NewDocDate AND SerialNo=@NewSerialNo AND DocRowNo>=@NewDocRowNo) )
								ORDER BY DocDate,SerialNo,DocRowNo
							END
							
							Open curCreditDebit
			
							FETCH NEXT FROM curCreditDebit INTO	
								@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewDebit, @NewCredit

							WHILE @@FETCH_STATUS = 0
								BEGIN
									SET @SumCreditDebit = @SumCreditDebit + @NewDebit - @NewCredit

									IF @NewAcntState = 4
										BEGIN
											IF @SumCreditDebit < 0
											BEGIN
												ROlLBACK
												SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بدهكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بستانكار می شود #$' )
												raiserror (@StrErr1, 16, 1)
											END
										END
										
									ELSE IF @NewAcntState = 5
										BEGIN
											IF @SumCreditDebit > 0
											BEGIN
												ROlLBACK
												SET @StrErr1 = pub.funReverseForCrystal('#$ مانده حساب کد ' + @NewAcntCode + 'بايد بستانكار شود . در تاریخ ' + @NewDocDate + ' سند شماره ' + LTRIM(STR(ABS(@NewSerialNo))) + 'به مبلغ ' + STR(ABS(@SumCreditDebit)) +  ' بدهکار می شود #$' )
												raiserror (@StrErr1, 16, 1)
											END			
										END			
							
									FETCH NEXT FROM curCreditDebit INTO	
										@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate,@NewDebit,@NewCredit
								END
								
							Close curCreditDebit
							Deallocate curCreditDebit
							
						END
						
					END --IF @NewAcntState=4 OR @NewAcntState=5

			----- Fetch next record
			FETCH NEXT FROM curVoucherInsertDocs INTO	
				@NewSerialNo, @NewDocRowNo, @NewAcntCode, @NewDocDate, @NewAcntState, @NewCurrencyAmount, @NewIsCurrency,@NewCurrencyTypeID
		END

	Close curVoucherInsertDocs
	Deallocate curVoucherInsertDocs

	Close curVoucherDeleted
	Deallocate curVoucherDeleted


	--SELECT @LenAcnt1=Layer1
	--FROM pub.tblCodeLayer 
	--WHERE PartNumber=1 AND TableName='acc.tblAcnt'

	--Select TOP 1 @NewSerialNo = SerialNo
	--From Inserted 

	--DECLARE @Balance FLOAT
	--set @Balance =0
	--SELECT @Balance =SUM(Debit-Credit) 
	--FROM acc.tblVoucherDtl a
	--inner join (
	--	SELECT AcntCode FROM acc.tblAcnt 
	--	WHERE len(AcntCode)=@LenAcnt1 and PartNumber=1 and AcntType IN(91,92)
	--	) b
	--ON b.AcntCode=SUBSTRING(a.AcntCode,1,LEN(b.AcntCode))
	--WHERE SerialNo=@NewSerialNo

	--IF @Balance <>0
	--BEGIN
	--	ROlLBACK
	--	SET @StrErr1 = pub.funReverseForCrystal('#$ حساب های انتظامی بالانس نیست ' )
	--	RAISERROR (@StrErr1, 16, 1)
	--END

END
GO
