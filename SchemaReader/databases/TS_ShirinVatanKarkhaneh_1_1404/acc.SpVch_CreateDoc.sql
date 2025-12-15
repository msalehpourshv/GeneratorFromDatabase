USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 91/02/11
-- Description   : 
-- =============================================
-- [acc].[SpVch_CreateDoc] 2,'1385/01/25','1385/01/15',110,1,85,1,2,0
-- [acc].[SpVch_CreateDoc] 0,'1386/11/08','1386/11/08',1,1,86,19,'trs.tblPayHdr','VchNo','','',2,2,12486,1
Create PROCEDURE [acc].[SpVch_CreateDoc]
	@intVchNo				 Int,				-- شماره سند
	@intDocStep				 TinyInt,			-- مرحله سند
    @strVchDate				 Char(10),			-- تاریخ سند
    @strOldVchDate			 Char(10),			-- تاریخ سند	
	@intSourceProcessID		 Int,			-- 
	@intSourceProcessNo		 Int,			--
	@intSourceFiscalYear	 Int,			--
	@intSourceSerialNo		 Int,				--	
	@strHdrTblName			 VarChar(100),		-- نام جدول هدر جدول اصلی
	@strVchNoFieldName		 VarChar(50),		-- ''
	@VoucherCreateMetod		 TinyInt,			-- سند تکی 1
	@DocFormType			 TinyInt = 2,		-- اگر فقط سریال 1 در غیر اینصورت 2
	@SelectedUserVchNoType	 TinyInt	= 1,		-- نوع انتخابی سند توسط کاربر
	@intOldVchNo			 Int	=0,			    -- شماره سند قدیمی
	@StrSourceCodeFieldName  VARCHAR(500)='',				--	
	@StrSourceCodeFieldValue VARCHAR(500)='',				--	
	@UserID					 Int=0,
	@Vch_Kind				 INT = -1,
	@Tax_Type				 Tinyint=0	,
	@SessionNo				 Int=0
	WITH ENCRYPTION
AS
	Declare @bolNewVoucher	Bit
	Declare @intMaxRowNo	Int
	Declare @intMaxDocRowNo Int
	Declare @MainSerialNo AS INT
	Declare @MaxRowNo AS INT
	Declare @BaseDistributionSerialNo AS INT
	Declare @AllFormLockVoucherNo AS INT
	DECLARE @VoucherGroupCodeID VARCHAR(20)
BEGIN
	SET NOCOUNT ON;

--====================================================================================================================
-- با تغییر تاریخ سند اگر سند قبلی خالی باشد همان شماره سند و درغیر اینصورت صفر برای ایجاد سند جدید استفاده میشود
--====================================================================================================================

	DECLARE @LanguageID	TINYINT
	DECLARE @AccVoucherCreateInReservedList BIT
	Declare @Pub_SendDoc2OtherSoftWare as bit
	
	if @SessionNo =0
		SET @SessionNo	= pub.funGetCurrentSessionNo();

	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @AccVoucherCreateInReservedList = 'False'
	SEt @BaseDistributionSerialNo = 0
	SET @AllFormLockVoucherNo = 0

	SELECT @AllFormLockVoucherNo = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'AllFormLockVoucherNo'

	SELECT @AccVoucherCreateInReservedList = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'AccVoucherCreateInReservedList'
 	 
	SELECT @Pub_SendDoc2OtherSoftWare = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'Pub_SendDoc2OtherSoftWare' 
	set @Pub_SendDoc2OtherSoftWare=isnull(@Pub_SendDoc2OtherSoftWare, 'False')

	IF @intVchNo = 1 AND  @intSourceProcessID<>50 and @intSourceProcessID<>10 and @intSourceProcessID<> 25
	BEGIN
		Raiserror (N'سند شماره 1 برای افتتاحیه رزرو شده و سنددیگری نمی تواند باشد',16,1)
		return -1
	END	

	IF @intSourceProcessID = 50 and SUBSTRING(@strVchDate,6,4)='01/01'
		SET @Vch_Kind = 2

  	DECLARE @OldTax_Type tinyint=0
	
	SELECT	@OldTax_Type=Tax_Type
	FROM	acc.tblVoucherHdr 
	WHERE	SerialNo = @intVchNo

 -----------------------------------------------------------------
	IF @intSourceProcessID = 90 and @intSourceProcessNo = 10
	BEGIN
		IF (SELECT  COUNT(*) FROM pub.tblSettings WHERE SettingKey = 'Sal_RegNoteVchForDst' AND SettingValue = 'True') =1
		BEGIN
			SELECT @BaseDistributionSerialNo = BaseDistributionSerialNo
			FROM inv.tblStorageDocsHdr
			WHERE ProcessID = @intSourceProcessID AND 
				  ProcessNo = @intSourceProcessNo AND 
			      FiscalYear= @intSourceFiscalYear AND 
				  SerialNo  = @intSourceSerialNo 
		END
	END
	-----------------------------------------------------------------
	DELETE FROM acc.tblVoucherDtl
	WHERE SourceDocType = 0 AND
		  SourceProcessID = @intSourceProcessID AND 
		  SourceProcessNo = @intSourceProcessNo AND 
		  SourceFiscalYear= @intSourceFiscalYear AND 
		  SourceSerialNo  = @intSourceSerialNo AND 
		  SourceCodeFieldValue = @StrSourceCodeFieldValue
-----  حذف از جدول میانی تطبیق
	DELETE FROM acc.tblVoucher2AccState
		WHERE SourceProcessID = @intSourceProcessID   
			AND SourceProcessNo = @intSourceProcessNo   
			AND SourceFiscalYear= @intSourceFiscalYear  
			AND SourceSerialNo  = @intSourceSerialNo 

	IF @VoucherCreateMetod = 6 AND @intVchNo <> 0
	BEGIN
			SELECT TOP 1 @UserID=UserID 
			FROM	acc.tblVoucherSerials 
			WHERE	DocDate=@strVchDate AND 
					VchNo = @intVchNo AND
					Tax_Type = @Tax_Type
			ORDER BY VchNo DESC
	END
	-----------------------------------------------------------------
	IF (@strOldVchDate <> @strVchDate OR @OldTax_Type<>@Tax_Type) AND @intVchNo <> 0 AND @SelectedUserVchNoType = 1
		BEGIN
			----- باقيمانده تعداد سطرهاي سند را نشان مي دهد
			Declare @IntRemainedRowCount INT

			SELECT @IntRemainedRowCount=COUNT(*)
			FROM acc.tblVoucherDtl
			WHERE SerialNo=@intVchNo 
			
			----- اگر سطرهاي ديگري غير از سطرهاي اين برگه باشد
			IF @IntRemainedRowCount > 0
				
				SET @intVchNo = 0
				
			ELSE
			
				BEGIN

					DECLARE @intSimilarVchNo int
					SET @intSimilarVchNo = 0
					
					----- Get Valid Voucher Number
					IF @VoucherCreateMetod = 2 ---- اگر برای هر ورژن هر کار در هر روز یک سند باشد
						SELECT TOP 1 @intSimilarVchNo=VchNo 
						FROM	acc.tblVoucherSerials 
						WHERE	DocDate=@strVchDate AND 
								SourceProcessID=@intSourceProcessID AND 
								SourceProcessNo=@intSourceProcessNo AND 
								DocRegisterState IN (0,1) AND 
								Tax_Type=@Tax_Type
								
						ORDER BY VchNo DESC

					ELSE IF @VoucherCreateMetod = 3 ---- اگر برای هر کار در هر روز یک سند باشد
						SELECT TOP 1 @intSimilarVchNo=VchNo 
						FROM	acc.tblVoucherSerials 
						WHERE	DocDate=@strVchDate AND 
								SourceProcessID=@intSourceProcessID AND 
								DocRegisterState IN (0,1) AND 
								Tax_Type=@Tax_Type
						ORDER BY VchNo DESC

					ELSE IF @VoucherCreateMetod = 4 ---- اگر برای همه کارها در هر روز یک سند صادر شود
					BEGIN
						IF  @AccVoucherCreateInReservedList = 'True'
						begin
							SELECT TOP 1 @intSimilarVchNo=VchNo 
							FROM	acc.tblVoucherSerials 
							WHERE	DocDate=@strVchDate AND		
									DocRegisterState IN (0,1) AND 
									IsReserved = 'True' AND 
									Tax_Type=@Tax_Type
							ORDER BY VchNo DESC

							IF @intSimilarVchNo = 0
								Raiserror (N'برای این تاریخ سند رزرو شده ای وجود ندارد',16,1)

						end
						ELSE
							SELECT TOP 1 @intSimilarVchNo=VchNo 
							FROM	acc.tblVoucherSerials 
							WHERE	DocDate=@strVchDate AND		
									DocRegisterState IN (0,1) AND 
									Tax_Type=@Tax_Type
							ORDER BY VchNo DESC
						
					END
					ELSE IF @VoucherCreateMetod = 5 ---- اگر سندها بر اساس گروه بندی باشد
					BEGIN
					
						SELECT @VoucherGroupCodeID = VoucherGroupCodeID
						FROM acc.tblVoucherGroupDtl
						WHERE ProcessID = @intSourceProcessID AND 
							  ProcessNo = @intSourceProcessNo 	
					
						SELECT TOP 1 @intSimilarVchNo=VchNo 
						FROM	acc.tblVoucherSerials 
						WHERE	DocDate=@strVchDate AND 
								VoucherGroupCodeID=@VoucherGroupCodeID AND 
								DocRegisterState IN (0,1) AND 
								Tax_Type=@Tax_Type
						ORDER BY VchNo DESC					
					END
					ELSE IF @VoucherCreateMetod = 6 ---- اگر برای هر کاربر در روز یک سند باشد
					BEGIN
						SELECT TOP 1 @intSimilarVchNo=VchNo 
						FROM	acc.tblVoucherSerials 
						WHERE	DocDate=@strVchDate AND 
								UserID = @UserID AND
								DocRegisterState IN (0,1) AND 
								Tax_Type=@Tax_Type
						ORDER BY VchNo DESC
					END
					---- اگر در سند ديگري اسناد مشابه با آن باشد - با توجه به اينكه اين سند خالي است
					IF @intSimilarVchNo > 0
						BEGIN

							IF @BaseDistributionSerialNo > 0 
							BEGIN
								declare @BaseDistributionSerialNo_t1 int 
								SET @BaseDistributionSerialNo_t1 = -1
								SELECT @BaseDistributionSerialNo_t1 = BaseDistributionSerialNo FROM acc.tblVoucherHdr WHERE SerialNo = @intSimilarVchNo 

								IF @BaseDistributionSerialNo_t1 <> @BaseDistributionSerialNo
								BEGIN
									SET @intSimilarVchNo = 0
									SELECT @intSimilarVchNo = SerialNo from acc.tblVoucherHdr WHERE BaseDistributionSerialNo=@BaseDistributionSerialNo AND DocRegisterState IN (0,1)
								END

							END
						END

					---- اگر در سند ديگري اسناد مشابه با آن باشد - با توجه به اينكه اين سند خالي است
					IF @intSimilarVchNo > 0
						BEGIN
							DELETE FROM acc.tblVoucherHdr
							WHERE SerialNo=@intVchNo

							DELETE FROM acc.tblVoucherSerials 
							WHERE VchNo=@intVchNo AND IsReserved = 'False'

							SET @intVchNo = @intSimilarVchNo

						END

					ELSE
						
						BEGIN

							IF @VoucherCreateMetod = 2
								UPDATE acc.tblVoucherSerials 
								SET DocDate = @strVchDate
								   ,Tax_Type=@Tax_Type
								WHERE VchNo = @intVchNo AND 
									  DocDate = @strOldVchDate AND 
									  SourceProcessID = @intSourceProcessID AND 
									  SourceProcessNo = @intSourceProcessNo 
									  
							ELSE IF  @VoucherCreateMetod = 3
								UPDATE acc.tblVoucherSerials 
								SET DocDate = @strVchDate
								   ,Tax_Type=@Tax_Type
								WHERE VchNo = @intVchNo AND 
									  DocDate = @strOldVchDate AND 
									  SourceProcessID = @intSourceProcessID 
									  
							ELSE IF @VoucherCreateMetod = 4 AND @AccVoucherCreateInReservedList = 'False'
								UPDATE acc.tblVoucherSerials 
								SET DocDate = @strVchDate
								   ,Tax_Type=@Tax_Type
								WHERE VchNo = @intVchNo AND 
									  DocDate = @strOldVchDate

							ELSE IF @VoucherCreateMetod = 5 
								BEGIN
									SELECT @VoucherGroupCodeID = VoucherGroupCodeID
									FROM acc.tblVoucherGroupDtl
									WHERE ProcessID = @intSourceProcessID AND 
										  ProcessNo = @intSourceProcessNo 	
										  						
									UPDATE acc.tblVoucherSerials 
									SET DocDate = @strVchDate
								       ,Tax_Type=@Tax_Type
									WHERE VchNo = @intVchNo AND 
										  DocDate = @strOldVchDate AND 
										  VoucherGroupCodeID = @VoucherGroupCodeID
								END
							ELSE IF @VoucherCreateMetod = 6 ---- اگر برای هر کاربر در روز یک سند باشد
							BEGIN
								UPDATE acc.tblVoucherSerials 
								SET DocDate = @strVchDate
								   ,Tax_Type=@Tax_Type
								WHERE VchNo = @intVchNo AND 
									  DocDate = @strOldVchDate AND 
									  UserID = @UserID 
								
							END
						END
						
							  
				END	
				
		END

--====================================================================================================================
		IF @SelectedUserVchNoType = 1
			BEGIN

				IF @intVchNo>0 AND (SELECT COUNT(*) FROM acc.tblVoucherDtl
					WHERE SerialNo=@intVchNo  AND DocDate <> @strVchDate AND NOT 
						(
						SourceProcessID =@intSourceProcessID AND
						SourceProcessNo =@intSourceProcessNo AND		 
						SourceFiscalYear =@intSourceFiscalYear AND
						SourceSerialNo =@intSourceSerialNo 
						)
				   )>0
				   SET @intVchNo = 0
			
			--====================================================================================================================
				-- اگر شماره سند صفر باشد یعنی سند جدید است وباید یک شماره جدید بگیرد
				--====================================================================================================================
				IF @intVchNo = 0
					BEGIN
						
						SET @intVchNo = -1
						
						----- Get Valid Voucher Number
						IF @VoucherCreateMetod = 1 ---- اگر سند تکی باشد
							SET @bolNewVoucher=1

						ELSE IF @VoucherCreateMetod = 2 ---- اگر برای هر ورژن هر کار در هر روز یک سند باشد
							SELECT TOP 1 @intVchNo=VchNo 
							FROM	acc.tblVoucherSerials 
							WHERE	DocDate=@strVchDate AND 
									SourceProcessID=@intSourceProcessID AND 
									SourceProcessNo=@intSourceProcessNo AND 
									DocRegisterState IN (0,1) AND
								    Tax_Type=@Tax_Type
							ORDER BY VchNo DESC

						ELSE IF @VoucherCreateMetod = 3 ---- اگر برای هر کار در هر روز یک سند باشد
							SELECT TOP 1 @intVchNo=VchNo 
							FROM	acc.tblVoucherSerials 
							WHERE	DocDate=@strVchDate AND 
									SourceProcessID=@intSourceProcessID AND 
									DocRegisterState IN (0,1) AND
								    Tax_Type=@Tax_Type
							ORDER BY VchNo DESC

						ELSE IF @VoucherCreateMetod = 4 ---- اگر برای همه کارها در هر روز یک سند صادر شود
						BEGIN
							IF  @AccVoucherCreateInReservedList = 'True'
							begin
								declare @DocRegisterStateR int 
								SET @DocRegisterStateR = -1

								SELECT TOP 1 @intVchNo=VchNo ,@DocRegisterStateR=DocRegisterState
								FROM	acc.tblVoucherSerials 
								WHERE	DocDate=@strVchDate AND		
										--DocRegisterState IN (0,1) AND 
										IsReserved = 'True' AND
										Tax_Type=@Tax_Type
								ORDER BY VchNo DESC

									IF @intSimilarVchNo = -1
									BEGIN
										SET @intVchNo =-1
										 Raiserror (N'برای این تاریخ سند رزرو شده ای وجود ندارد',16,1)
									END
									ELSE IF @DocRegisterStateR>1	
									BEGIN
										SET @intVchNo =-1
										 Raiserror (N'برای این تاریخ سند رزرو شده قفل  شده است',16,1)
									END

							END

							ELSE
								SELECT TOP 1 @intVchNo=VchNo 
								FROM	acc.tblVoucherSerials 
								WHERE	DocDate=@strVchDate AND		
										DocRegisterState IN (0,1) AND
								        Tax_Type=@Tax_Type
								ORDER BY VchNo DESC
						END
						ELSE IF @VoucherCreateMetod = 5 ---- اگر بر اساس گروه سند صادر شود
						BEGIN
							SELECT @VoucherGroupCodeID = VoucherGroupCodeID
							FROM acc.tblVoucherGroupDtl
							WHERE ProcessID = @intSourceProcessID AND 
								  ProcessNo = @intSourceProcessNo 
								  
							SELECT TOP 1 @intVchNo=VchNo 
							FROM	acc.tblVoucherSerials 
							WHERE	DocDate=@strVchDate AND 
									VoucherGroupCodeID=@VoucherGroupCodeID AND 
									DocRegisterState IN (0,1) AND
								    Tax_Type=@Tax_Type
							ORDER BY VchNo DESC						
						END
						ELSE IF @VoucherCreateMetod = 6 ---- اگر برای هر کاربر در روز یک سند باشد
						BEGIN
							SELECT TOP 1 @intVchNo=VchNo 
							FROM	acc.tblVoucherSerials 
							WHERE	DocDate=@strVchDate AND 
									UserID=@UserID AND 
									DocRegisterState IN (0,1) AND
								    Tax_Type=@Tax_Type
							ORDER BY VchNo DESC
						END

						IF @BaseDistributionSerialNo > 0 AND @intVchNo<>-1
						BEGIN
							declare @BaseDistributionSerialNo_t int 
							SET @BaseDistributionSerialNo_t = -1
							SELECT @BaseDistributionSerialNo_t = BaseDistributionSerialNo FROM acc.tblVoucherHdr WHERE SerialNo = @intVchNo 

							IF @BaseDistributionSerialNo_t <> @BaseDistributionSerialNo
							BEGIN
								SET @intVchNo = -1
								SELECT @intVchNo = SerialNo from acc.tblVoucherHdr WHERE BaseDistributionSerialNo=@BaseDistributionSerialNo AND DocRegisterState IN (0,1)
							END

						END
							--SELECT TOP 1 @intVchNo=SerialNo
							--FROM	acc.tblVoucherHdr H
							--WHERE	DocDate=@strVchDate AND 
									--DocRegisterState IN (0,1) AND 
									--SerialNo In (SELECT TOP 1 SerialNo 
												 --FROM	acc.tblVoucherDtl D
												 --WHERE	D.SourceDocType = 0 AND -- جزء اسناد خاص نباشد
														--D.SourceProcessID <> 0 AND  -- سند اتوماتيك باشد
												        --D.SerialNo=H.SerialNo)
							--ORDER BY SerialNo DESC

						SET @intVchNo = ISNULL(@intVchNo,-1)

						IF @intVchNo = -1 
							SET @bolNewVoucher = 1

						----- بررسی وجود و شماره سند فوق در سند و قفل بودن آن
						IF @intVchNo > 0
							BEGIN
								
								DECLARE @DocRegisterState INT
								DECLARE @CurVchKind INT
								DECLARE @CurTax_Type INT
								DECLARE @bolExistInSerialButNotExistInVchr BIT
								
								SET @bolExistInSerialButNotExistInVchr=0
								
								SELECT @DocRegisterState=DocRegisterState ,@CurVchKind = VchKind
								FROM acc.tblVoucherHdr 
								WHERE SerialNo=@intVchNo

								IF @DocRegisterState IS NULL 
									SET @bolExistInSerialButNotExistInVchr=1

								ELSE IF @DocRegisterState > 1 --- سند قفل شده است پس بايد سند جديد بزند
									SET @bolNewVoucher=1
								
								IF @AllFormLockVoucherNo >0 and  @AllFormLockVoucherNo>=@intVchNo
									SET @bolNewVoucher=1

								IF 	@Vch_Kind > -1 AND ((@CurVchKind>0 and @CurVchKind <> @Vch_Kind) OR 
								                        @CurTax_Type<>@Tax_Type)
									SET @bolNewVoucher=1

								IF @intSourceProcessID = 92 and @CurVchKind = 2
									SET @bolNewVoucher=1
							END

						----- بدست آوردن شماره سند جدید
						IF @bolNewVoucher=1
						
							BEGIN 
							
								IF (@VoucherCreateMetod = 4 AND @AccVoucherCreateInReservedList = 'True')
									SELECT TOP 1 @intVchNo = VchNo 
									FROM acc.tblVoucherSerials
									WHERE DocDate = @strVchDate AND 
										  IsReserved = 'True' AND 
										  DocRegisterState IN (0,1)
								ELSE
									SELECT @intVchNo=ISNULL(MAX(SerialNo),0)+1
									FROM acc.tblVoucherHdr

								----- Reserved 
								IF @intVchNo=1
									SET @intVchNo=2
								
								IF @AllFormLockVoucherNo >0 and  @AllFormLockVoucherNo>=@intVchNo
									SET @intVchNo = @AllFormLockVoucherNo + 1

								IF @VoucherCreateMetod = 2 
									INSERT INTO acc.tblVoucherSerials 
											(DocDate,SourceProcessID,SourceProcessNo,VchNo,VoucherGroupCodeID,Tax_Type) 
									VALUES	(@strVchDate ,@intSourceProcessID ,@intSourceProcessNo,@intVchNo,'',@Tax_Type)
								
								ELSE IF @VoucherCreateMetod = 3
									INSERT INTO acc.tblVoucherSerials 
											(DocDate,SourceProcessID,SourceProcessNo,VchNo,VoucherGroupCodeID,Tax_Type) 
									VALUES	(@strVchDate ,@intSourceProcessID ,0,@intVchNo,'',@Tax_Type)
								
								ELSE IF @VoucherCreateMetod = 4 AND @AccVoucherCreateInReservedList = 'False'
									INSERT INTO acc.tblVoucherSerials 
											(DocDate,SourceProcessID,SourceProcessNo,VchNo,VoucherGroupCodeID,Tax_Type) 
									VALUES	(@strVchDate, 0, 0, @intVchNo,'',@Tax_Type)
									
								ELSE IF @VoucherCreateMetod = 5
								begin 
									SELECT @VoucherGroupCodeID = VoucherGroupCodeID
									FROM acc.tblVoucherGroupDtl
									WHERE ProcessID = @intSourceProcessID AND 
										  ProcessNo = @intSourceProcessNo 
										  
									INSERT INTO acc.tblVoucherSerials 
											(DocDate,SourceProcessID,SourceProcessNo,VchNo,VoucherGroupCodeID,Tax_Type) 
									VALUES	(@strVchDate, 0, 0, @intVchNo,@VoucherGroupCodeID,@Tax_Type)
								end
								ELSE IF @VoucherCreateMetod = 6
									INSERT INTO acc.tblVoucherSerials 
											(DocDate,SourceProcessID,SourceProcessNo,VchNo,VoucherGroupCodeID,UserID,Tax_Type) 
									VALUES	(@strVchDate ,0 ,0,@intVchNo,'',@UserID,@Tax_Type)
							END	

						----- استفاده از شماره سریال قدیمی با احتساب جدید بودن آن
						IF @bolExistInSerialButNotExistInVchr=1
							SET @bolNewVoucher=1

				END ---- @intVchNo = 0
				
			--====================================================================================================================
			-- گرفتن آخرین شماره سطر
			--====================================================================================================================

			SELECT	@intMaxRowNo=MAX(RowNo),@intMaxDocRowNo=MAX(DocRowNo)
			FROM	acc.tblVoucherDtl 
			WHERE	SerialNo = @intVchNo

			SET @intMaxRowNo    = ISNULL(@intMaxRowNo,0)
			SET @intMaxDocRowNo = ISNULL(@intMaxDocRowNo,0)

			--====================================================================================================================
			-- ایجاد هدر سند
			--====================================================================================================================

			IF @bolNewVoucher=1 OR (SELECT COUNT(*) FROM acc.tblVoucherHdr WHERE SerialNo=@intVchNo) = 0
			
				BEGIN	
					Declare @VchKind Nvarchar(500)
					SET @VchKind = -1
					
					IF @intSourceProcessID = 10 OR @intSourceProcessID = 20 OR @intSourceProcessID = 25 OR @intSourceProcessID = 50 OR @intSourceProcessID = 450
						SET @VchKind = 2 --افتتاحيه
					ELSE
						SELECT @VchKind = SettingValue 
						FROM pub.tblSettings 
						WHERE SettingKey = 'AtomaticVchKind'
					
					IF @VchKind =-1
						SET @VchKind = 1
					
					IF @Vch_Kind>-1  
						SET @VchKind = @Vch_Kind
					
					SELECT @MainSerialNo = ISNULL(MAX(OldSerialNo),0)+1
					FROM acc.tblVoucherHdr

					SELECT @MaxRowNo= ISNULL(MAX(RowNo),0)+1
					FROM acc.tblVoucherHdr
					WHERE DocDate=@strVchDate
											
					INSERT INTO acc.tblVoucherHdr
							(SerialNo  , DocDate    , DocRegisterState, DocDesc, DocDesc2,  RecID, SessionNo , VchKind,OldSerialNo,RowNo,BaseDistributionSerialNo,Tax_Type) 
					VALUES	(@intVchNo , @strVchDate, 1               , ''     , ''      ,  0    , @SessionNo, @VchKind,@MainSerialNo,@MaxRowNo,@BaseDistributionSerialNo,@Tax_Type)
					
				END
				
			ELSE
			
				BEGIN	
					IF @intSourceProcessID = 10 OR @intSourceProcessID = 20 OR @intSourceProcessID = 25 OR @intSourceProcessID = 50 OR @intSourceProcessID = 450
						UPDATE acc.tblVoucherHdr
						SET DocDate = @strVchDate,VchKind = 2
						WHERE SerialNo=@intVchNo
					ELSE
						UPDATE acc.tblVoucherHdr
						SET DocDate = @strVchDate
						WHERE SerialNo=@intVchNo

					IF @Vch_Kind > -1
						UPDATE acc.tblVoucherHdr
						SET VchKind = @Vch_Kind
						WHERE SerialNo=@intVchNo

						
				END

		END	
			
--====================================================================================================================
		ELSE IF @SelectedUserVchNoType = 2
		
			BEGIN
			
				SET @intMaxRowNo    = 0
				SET @intMaxDocRowNo = 0
				
				IF (@VoucherCreateMetod = 4 AND @AccVoucherCreateInReservedList = 'True')
					SELECT TOP 1 @intVchNo = VchNo 
					FROM acc.tblVoucherSerials
					WHERE DocDate = @strVchDate AND 
						  IsReserved = 'True' AND 
						  DocRegisterState IN (0,1)
				ELSE				
					SELECT @intVchNo=ISNULL(MAX(SerialNo),0)+1
					FROM acc.tblVoucherHdr

			
				----- Reserved 
				IF @intVchNo=1
					SET @intVchNo=2

				IF @AllFormLockVoucherNo >0 and  @AllFormLockVoucherNo>=@intVchNo
					SET @intVchNo = @AllFormLockVoucherNo + 1

				IF @VoucherCreateMetod = 2
					INSERT INTO acc.tblVoucherSerials 
							(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
					VALUES	(@strVchDate, @intSourceProcessID, @intSourceProcessNo, @intVchNo,'',@Tax_Type)
				
				ELSE IF @VoucherCreateMetod = 3
					INSERT INTO acc.tblVoucherSerials 
							(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
					VALUES	(@strVchDate, @intSourceProcessID, 0, @intVchNo,'',@Tax_Type)
				
				ELSE IF @VoucherCreateMetod = 4 AND @AccVoucherCreateInReservedList = 'False'
					INSERT INTO acc.tblVoucherSerials 
							(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
					VALUES	(@strVchDate, 0, 0, @intVchNo,'',@Tax_Type)
					
				ELSE IF @VoucherCreateMetod = 5 
					INSERT INTO acc.tblVoucherSerials 
							(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
					VALUES	(@strVchDate, 0, 0, @intVchNo,@VoucherGroupCodeID,@Tax_Type)

				ELSE IF @VoucherCreateMetod = 6 
					INSERT INTO acc.tblVoucherSerials 
							(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,UserID,Tax_Type) 
					VALUES	(@strVchDate, 0, 0, @intVchNo,'',@UserID,@Tax_Type)									
				
				Declare @VchKind2 Nvarchar(500)
				SET @VchKind = -1
				
				SELECT @VchKind2 = SettingValue 
				FROM pub.tblSettings 
				WHERE SettingKey = 'AtomaticVchKind'
				
				IF @VchKind2 =-1
					SET @VchKind2 = 1

				IF @Vch_Kind>-1  
					SET @VchKind2 = @Vch_Kind

				SELECT @MainSerialNo = ISNULL(MAX(OldSerialNo),0)+1
				FROM acc.tblVoucherHdr

				SELECT @MaxRowNo= ISNULL(MAX(RowNo),0)+1
				FROM acc.tblVoucherHdr
				WHERE DocDate=@strVchDate
									
				INSERT INTO acc.tblVoucherHdr
						(SerialNo  , DocDate    , DocRegisterState, DocDesc, DocDesc2, RecID, SessionNo , VchKind,OldSerialNo,RowNo,BaseDistributionSerialNo,Tax_Type) 
				VALUES	(@intVchNo , @strVchDate, 1               , ''     , ''      , 0    , @SessionNo, @VchKind2,@MainSerialNo,@MaxRowNo,@BaseDistributionSerialNo,@Tax_Type)
				
			END
			
--====================================================================================================================
		ELSE IF @SelectedUserVchNoType = 3
			BEGIN
			
			IF (SELECT COUNT(*) 
			    FROM  acc.tblVoucherSerials 
			    WHERE VchNo = @intVchNo AND DocDate = @strOldVchDate AND IsReserved='False') = 1
			BEGIN
				IF (SELECT COUNT(*) FROM acc.tblVoucherDtl
					WHERE SerialNo=@intVchNo  AND NOT 
						(
						SourceProcessID =@intSourceProcessID AND
						SourceProcessNo =@intSourceProcessNo AND		 
						SourceFiscalYear =@intSourceFiscalYear AND
						SourceSerialNo =@intSourceSerialNo 
						)
				   )=0
				BEGIN
					UPDATE acc.tblVoucherSerials 
					SET DocDate = @strVchDate
					   ,Tax_Type =@Tax_Type
					WHERE VchNo = @intVchNo AND 
						  DocDate = @strOldVchDate 

					UPDATE acc.tblVoucherHdr 
					SET DocDate = @strVchDate
					   ,Tax_Type =@Tax_Type
					WHERE SerialNo = @intVchNo 

					UPDATE acc.tblVoucherDtl 
					SET DocDate = @strVchDate
					WHERE SerialNo = @intVchNo 
					
					SET @OldTax_Type=@Tax_Type
				END
			END
									  	

				DECLARE @DocRegisterState3 INT
				DECLARE @CurVchKind3 INT
				DECLARE @DocDate3 Varchar(10)
				
				SELECT @DocRegisterState3=DocRegisterState ,@DocDate3=DocDate ,@CurVchKind3=VchKind
				FROM acc.tblVoucherHdr 
				WHERE SerialNo=@intVchNo

				IF @DocRegisterState3 IS NULL 
				
					BEGIN
					
						IF @VoucherCreateMetod = 2
							INSERT INTO acc.tblVoucherSerials 
									(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
							VALUES	(@strVchDate, @intSourceProcessID, @intSourceProcessNo, @intVchNo,'',@Tax_Type)
				
						ELSE IF @VoucherCreateMetod = 3
							INSERT INTO acc.tblVoucherSerials 
									(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
							VALUES	(@strVchDate, @intSourceProcessID, 0, @intVchNo,'',@Tax_Type)
				
						ELSE IF @VoucherCreateMetod = 4 AND @AccVoucherCreateInReservedList = 'False'
							INSERT INTO acc.tblVoucherSerials 
									(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
							VALUES	(@strVchDate, 0, 0, @intVchNo,'',@Tax_Type)
					
						ELSE IF @VoucherCreateMetod = 5 
							INSERT INTO acc.tblVoucherSerials 
									(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,Tax_Type) 
							VALUES	(@strVchDate, 0, 0, @intVchNo,@VoucherGroupCodeID,@Tax_Type)

						ELSE IF @VoucherCreateMetod = 6 
							INSERT INTO acc.tblVoucherSerials 
									(DocDate, SourceProcessID, SourceProcessNo, VchNo,VoucherGroupCodeID,UserID,Tax_Type) 
							VALUES	(@strVchDate, 0, 0, @intVchNo,'',@UserID,@Tax_Type)							

						Declare @VchKind3 Nvarchar(500)
						SET @VchKind3 = -1
						
						SELECT @VchKind3 = SettingValue 
						FROM pub.tblSettings 
						WHERE SettingKey = 'AtomaticVchKind'

						IF @Vch_Kind>-1  
							SET @VchKind3 = @Vch_Kind

						SELECT @MainSerialNo = ISNULL(MAX(OldSerialNo),0)+1
						FROM acc.tblVoucherHdr

						SELECT @MaxRowNo= ISNULL(MAX(RowNo),0)+1
						FROM acc.tblVoucherHdr
						WHERE DocDate=@strVchDate
						
						INSERT INTO acc.tblVoucherHdr
								(SerialNo  , DocDate    , DocRegisterState, DocDesc, DocDesc2, RecID, SessionNo , VchKind,OldSerialNo,RowNo,BaseDistributionSerialNo,Tax_Type) 
						VALUES	(@intVchNo , @strVchDate, 1               , ''     , ''      , 0    , @SessionNo, @VchKind3,@MainSerialNo,@MaxRowNo,@BaseDistributionSerialNo,@Tax_Type)

					END

				ELSE IF @DocRegisterState3 > 1
					BEGIN
						-- Rollback
						Raiserror (N'این شماره سند قفل شده است',16,1)
						return -1
					END

				IF NOT (@DocRegisterState3 IS NULL)
					BEGIN
						IF @DocDate3 <> @strVchDate
							BEGIN
								-- Rollback
								Raiserror (N'456:تاریخ این شماره سند با تاریخ سند انتخابی یکی نیست',16,1)
								return -1
							END

						IF @OldTax_Type<>@Tax_Type
							BEGIN
								-- Rollback
								Raiserror (N'نوع مالیاتی این شماره سند با سند انتخابی یکی نیست',16,1)
								return -1
							END
							
						DECLARE @Acc_VchKindInRow BIT
						SET @Acc_VchKindInRow = 'False'
						SELECT @Acc_VchKindInRow = SettingValue
						FROM pub.tblSettings 
						WHERE SettingKey = 'Acc_VchKindInRow'

						if @Acc_VchKindInRow='False'
						begin
						
							IF @Vch_Kind>-1 and  @Vch_Kind<>@CurVchKind3
								BEGIN
									-- Rollback
									Raiserror (N'نوع سند با سند انتخابی برابر نیست',16,1)
									return -1
								END

							UPDATE acc.tblVoucherHdr
							SET DocDate = @strVchDate
							WHERE SerialNo=@intVchNo

							IF @Vch_Kind > -1
								UPDATE acc.tblVoucherHdr
								SET VchKind = @Vch_Kind
								WHERE SerialNo=@intVchNo
							END		
					END		
							
				--====================================================================================================================
				-- گرفتن آخرین شماره سطر
				--====================================================================================================================

				SELECT	@intMaxRowNo=MAX(RowNo),@intMaxDocRowNo=MAX(DocRowNo)
				FROM	acc.tblVoucherDtl 
				WHERE	SerialNo = @intVchNo

				SET @intMaxRowNo    = ISNULL(@intMaxRowNo,0)
				SET @intMaxDocRowNo = ISNULL(@intMaxDocRowNo,0)
				
			END --IF @SelectedUserVchNoType = 3

			UPDATE acc.tblVoucherHdr
			SET Tax_Type = @Tax_Type
			WHERE SerialNo=@intVchNo
--====================================================================================================================
-- ایجاد سطرهای جدید سند
--====================================================================================================================
	IF @Vch_Kind = -1
		SET @Vch_Kind = 1

	IF @intSourceProcessID = 1 -----برگ دريافت
	BEGIN
		IF @StrSourceCodeFieldName = ''
			EXEC [acc].[SpVchReceipt] 
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind
				
		ELSE
			EXEC [acc].[SpVchReceipt_BRN] 
			@intVchNo, @intDocStep, @strVchDate,
			@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
			@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID		
	END
	IF @intSourceProcessID = 2 -----برگ پرداخت
	BEGIN
		IF @StrSourceCodeFieldName = ''
			EXEC [acc].[SpVchPayment] 
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind
		ELSE
			EXEC [acc].[SpVchPayment_BRN] 
			@intVchNo, @intDocStep, @strVchDate,
			@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
			@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID	
					
	END	
	IF @intSourceProcessID = 3 -----برگ دريافت متفرقه
		EXEC [acc].[SpVchReceipt2] 
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind

	IF @intSourceProcessID = 4 -----برگ پرداخت متفرقه
		EXEC [acc].[SpVchPayment2]	
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind
	
	IF @intSourceProcessID = 10 ----- دريافت اول دوره چک 
		EXEC [acc].[SpVchReceivePrim]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	
	IF @intSourceProcessID = 12 -----اعلام وصول اسناد دريافتي
		EXEC[acc].[SpVchReceivableReceipt] 
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 13 -----اعلام برگشت اسناد دريافتي
		EXEC [acc].[SpVchReceivableReturn]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 17 -----استرداد چک اشخاص به صندوق
		EXEC [acc].[SpVchReceivablePaidPersonReturnCash]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 18 -----برگشت چک اشخاص به صاحب چک
		EXEC [acc].[SpVchReceivablePaidPersonReturnOwner]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 21 -----واگذاری چک اشخاص به بانک
		EXEC [acc].[SpVchReceivablePaidBank]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 22 -----وصول چکهای واگذار شده به بانکها
		EXEC [acc].[SpVchReceivablePaidBankReceipt]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 23 ----- استرداد چكهاي واگذار شده به بانك به صندوق
		EXEC [acc].[SpVchReceivablePaidBankReturnCash]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 24 -----استرداد چكهاي واگذار شده به بانك به صاحب چك
		EXEC [acc].[SpVchReceivablePaidBankReturnOwner]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 25 ----- دريافت اول دوره چک 
		EXEC [acc].[SpVchPaymentPrim]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 31 -----چکهای امانی دیگران نزد ما
		EXEC [acc].[SpVchReceivableTrust]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 32 ----- استرداد چکهای امانی دیگران نزد ما
		EXEC [acc].[SpVchReceivableTrustReturn]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 33 -----چکهای امانی ما نزد دیگران
		EXEC [acc].[SpVchPayableTrust]	
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 34 -----استرداد چکهای امانی ما نزد دیگران
		EXEC [acc].[SpVchPayableTrustReturn]	
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 27 -----وصول اسناد پرداختني
		EXEC [acc].[SpVchPayableReceipt]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 28 -----برگشت اسناد پرداختني
		EXEC [acc].[SpVchPayableReturn]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 5 -----تنخواه گردان
		EXEC [acc].[SpVchPettyCash]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 6 -----هزینه بانکی
		EXEC [acc].[SpVchBankCost]	
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 7 -----دریافت وام
		EXEC [acc].[SpVchLoanReceipts]	
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 8 -----پرداخت قسط وام
		EXEC [acc].[SpVchLoanPayments]	
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID


	IF @intSourceProcessID = 40 -----انتقال وجه بین صندوقها یا تنخواه گردانها
		EXEC [acc].[SpVchAmountTransfer]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 47 -----پرداخت وام
		IF @StrSourceCodeFieldName = ''
			EXEC [acc].[SpVchLoanToOtherPayments]	
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
		ELSE
			EXEC [acc].[SpVchLoanToOtherPayments_BRN]	
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 48 -----دریافت قسط وام
		IF @StrSourceCodeFieldName = ''
			EXEC [acc].[SpVchLoanToOtherReceipts]	
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
		ELSE
			EXEC [acc].[SpVchLoanToOtherReceipts_BRN]	
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID


	IF @intSourceProcessID = 49 ----- خدمات 
		EXEC [acc].[SpVchServices]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 50 ----- موجودي اول دوره
		IF @StrSourceCodeFieldName <> ''
			EXEC [acc].[SpVchStorePrimary_BRN]
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
		ELSE
			EXEC [acc].[SpVchStorePrimary]
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 51 ----- اصلاح قیمت اقلام انبار
		EXEC [acc].[SpVchInventoryModification]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 160 ----- سفارش خرید
		EXEC [acc].[SpVchBuyOrder]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind

	IF @intSourceProcessID = 55 ----- خرید
		EXEC [acc].[SpVchBuy]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind

	IF @intSourceProcessID = 56 ----- خرید باسکول
		EXEC [acc].[SpVchBuyBascule]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
					
	IF @intSourceProcessID = 57 ----- خرید
		EXEC [acc].[SpVchBuy_Sum]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 60 ----- برگشت از خرید
		EXEC [acc].[SpVchBuyRet]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind

	IF @intSourceProcessID = 77 ----- هزینه تولید
		EXEC [acc].[SpVchProductCosts]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	
	IF @intSourceProcessID = 610  ----- قبض تبدیلی ریالی 
		EXEC [acc].[SpVchPln_TaskOrder]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 72   ----- قبض تبدیلی  
		EXEC [acc].[SpVchPrd_ReceiveFromPln]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
								
	IF @intSourceProcessID = 80 ----- قبض تبدیلی ریالی 
		EXEC [acc].[SpVchPrd_Receive]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 90 or @intSourceProcessID = 95 -----فروش يا تخفيفات پس از فروش 
	BEGIN
		IF @StrSourceCodeFieldName <> ''
		BEGIN
			EXEC[acc].[SpVchSale_BRN]
			@intVchNo, @intDocStep, @strVchDate,
			@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
			@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
		END
		ELSE
		BEGIN
			IF (select COUNT(*)  from pub.tblSettings where SettingKey='Sal_SaleWithService' AND (SettingValue='True' OR SettingValue='1') ) = 0
				EXEC [acc].[SpVchSale]
						@intVchNo, @intDocStep, @strVchDate,
						@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
						@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind
			ELSE
				EXEC [acc].[SpVchSaleWithService]
						@intVchNo, @intDocStep, @strVchDate,
						@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
						@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
		END	
	END				
	IF @intSourceProcessID = 91 ----- فروش باسکول
		EXEC [acc].[SpVchSaleBascule]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
				
	IF @intSourceProcessID = 92 ----- فروش رستوران
		EXEC [acc].[SpVchSale_Restaurant]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldValue,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	
	IF @intSourceProcessID = 94 ----- برگشت رستوران
		EXEC [acc].[SpVchSale_Restaurant_Ret]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldValue,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 93 ----- فروش داروخانه
		EXEC [acc].[SpVchSaleExit]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
								
	IF @intSourceProcessID = 100 -----برگشت از فروش
		IF @StrSourceCodeFieldName <> ''
			EXEC [acc].[SpVchSaleRet_BRN]
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldName,@StrSourceCodeFieldValue,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
		ELSE
		
			EXEC [acc].[SpVchSaleRet]
					@intVchNo, @intDocStep, @strVchDate,
					@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
					@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind
	
	IF @intSourceProcessID = 111 ---- برگه مصرف  قطعات سرویس کاران
		EXEC [acc].[SpVchUseService]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,@Vch_Kind

	IF @intSourceProcessID = 120 -----انتقال بین انبارها
		EXEC [acc].[SpVchTransferAtom]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 130 --ارسال كالاهاي اماني ما نزد دیگران
		EXEC [acc].[SpVchOurTrust_Send]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
				
	IF @intSourceProcessID = 135 --دريافت كالاهاي اماني ما نزد دیگران
		EXEC [acc].[SpVchOurTrust_Receive]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
				
	IF @intSourceProcessID = 131 --ارسال كالاهاي اماني دیگران نزد ما 
		EXEC [acc].[SpVchOtherTrust_Send]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
				
	IF @intSourceProcessID = 136 --دريافت كالاهاي اماني دیگران نزد ما 
		EXEC [acc].[SpVchOtherTrust_Receive]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
				
	IF @intSourceProcessID = 180 ----- سفارش فروش 
		EXEC [acc].[SpVchSaleOrder]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	IF @intSourceProcessID = 185 -----انصراف سفارش فروش 
		EXEC [acc].[SpVchSaleOrderCancle]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	IF @intSourceProcessID = 182 ----- قرار داد فروش رستوران وتالار
	EXEC [acc].[SpVchRestaurantContract]
			@intVchNo, @intDocStep, @strVchDate,
			@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldValue,
			@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	
	IF @intSourceProcessID = 183 ----- اصلاحیه قرارداد فروش رستوران وتالار
	EXEC [acc].[SpVchRestaurantContract_Edit]
			@intVchNo, @intDocStep, @strVchDate,
			@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldValue,
			@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	IF @intSourceProcessID = 190 or  @intSourceProcessID = 191  -----قراردا حق الحفاظ
		EXEC [acc].[SpVchKeepingContract]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID	
	IF @intSourceProcessID = 193 ----- رسید و خروج کالا
		EXEC [acc].[SpVchGoodsExit]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldValue,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
						
	IF @intSourceProcessID = 211 --درآمد پخش 
		EXEC [acc].[SpVchAfterSaleInCome]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 212 --تخفيفات پخش
		EXEC [acc].[SpVchAfterSaleDiscount]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 240 ----- پيش فاکتور 
		EXEC [acc].[SpVchPreSale]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,1
		IF @intSourceProcessID = 255 ----- برگشت از تحویل دارایی
		EXEC [acc].[SpVchAssetDelivery_Ret]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID,1
							
	IF @intSourceProcessID = 300 -----پرداخت حقوق پرسنل
		EXEC [acc].[SpVchSalaryPays]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 310 -----پرداخت مساعده پرسنل
		EXEC [acc].[SpVchAdvance]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 321 -----پرداخت عيدي پرسنل
		EXEC [acc].[SpVchCelebrationPays]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 326 -----پرداخت پايانکار پرسنل
		EXEC [acc].[SpVchHistoryCalcDaysPays]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 420 ----- تسعير ارز
		EXEC [acc].[SpVchAccExchange]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 450 -----استقرار اول دوره دارایی
		EXEC [acc].[SpVchAssetPrimary]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 455 -----خرید دارایی از طریق انبار
		EXEC [acc].[SpVchAssetWithStore]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 456 -----برگشت دارایی ثابت به انبار
		EXEC [acc].[SpVchAssetReturnToStore]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 460 -----خرید دارایی مستقیم
		EXEC [acc].[SpVchAssetWithoutStore]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
												
	IF @intSourceProcessID = 470 -----تعمیرات اساسی دارایی
		EXEC [acc].[SpVchAssetRenovation]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 471 -----افزایش/کاهش قیمت اموال
		EXEC [acc].[SpVchAssetPriceChanging]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	IF @intSourceProcessID = 472 -----تجدید ارزیابی
		EXEC [acc].[SpVchAssetReNew]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 485 -----حذف یا اسقاط
		EXEC [acc].[SpVchAssetDelete]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 495 -----حذف یا اسقاط
		EXEC [acc].[SpVchAssetSale]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 500 ----- خروج موقت اموال
		EXEC [acc].[SpVchAssetTempExit]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	IF @intSourceProcessID = 505 ----- بازگشت از خروج موقت
		EXEC [acc].[SpVchAssetTempEnter]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 765 -----هزینه تعمیر و نگهداری
		EXEC [acc].[SpVchTaskExecutionCost]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 800 -----بارنامه
		EXEC [acc].[SpVchRoadBills]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 821 -----حمل و نقل
		EXEC [acc].[SpVchDispatch]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID

	IF @intSourceProcessID = 822 -----هزینه حمل و نقل
		EXEC [acc].[SpVchDispatchCost]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID


	IF @intSourceProcessID = 905 -----بارنامه
		EXEC [acc].[SpVchContractsBill]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID
	
	IF @intSourceProcessID = 906 ----- صورت وضعيت
		EXEC [acc].[SpVch_SyncSaleBuy]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,@StrSourceCodeFieldValue,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID				

	IF @intSourceProcessID = 933 ----- سند بیمه
		EXEC [acc].[SpVchInsuranceService]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID				

	IF @intSourceProcessID = 951 ----- خرید سهام
		EXEC [acc].[SpVchBuyStocks]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID	

	IF @intSourceProcessID = 952 ----- فروش سهام
		EXEC [acc].[SpVchSaleStocks]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID	

	IF @intSourceProcessID = 980 ----- هزینه یابی بر اساس فعالیت(تسهیم هزینه های سربار غیر مستقیم بر مراکز هزینه)
		EXEC [acc].[SpVchPortionABC]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID	

	IF @intSourceProcessID = 1128 ----- اعلامیه بدهکار و بستانکار
		EXEC [acc].[SpVchDebitCredit]
				@intVchNo, @intDocStep, @strVchDate,
				@intSourceProcessID, @intSourceProcessNo, @intSourceFiscalYear, @intSourceSerialNo,
				@intMaxRowNo, @intMaxDocRowNo, @SessionNo, @LanguageID	
								
	---------------------------------------------------------------------------------------	
		IF @intSourceProcessID = 183
		SET @intSourceProcessID = 182	
	---------------------------------------------------------------------------------------	
		
	 IF ((SELECT TOP 1 SerialNo 
	     FROM acc.tblVoucherDtl
         WHERE SerialNo=@intOldVchNo ) IS NULL)

			BEGIN
				DELETE FROM acc.tblVoucherHdr 
				WHERE SerialNo=@intOldVchNo
				
				DELETE FROM acc.tblVoucherSerials 
				WHERE VchNo=@intOldVchNo  AND IsReserved = 'False'
			
			END
			
	---------------------------------------------------------------------------------------	
	DELETE FROM acc.tblVoucherDtl
	WHERE SerialNo=@intVchNo AND 
		  SourceProcessID=@intSourceProcessID AND 
		  SourceProcessNo=@intSourceProcessNo AND 
		  SourceFiscalYear=@intSourceFiscalYear AND 
		  SourceSerialNo =@intSourceSerialNo AND 
		  SourceCodeFieldValue = @StrSourceCodeFieldValue AND
		  Debit = 0 AND Credit = 0
		 
	
	 IF ((SELECT TOP 1 SerialNo 
	     FROM acc.tblVoucherDtl
         WHERE SerialNo=@intVchNo ) IS NULL)

			BEGIN
				DELETE FROM acc.tblVoucherHdr 
				WHERE SerialNo=@intVchNo
				
				DELETE FROM acc.tblVoucherSerials 
				WHERE VchNo=@intVchNo  AND IsReserved = 'False'
				
				SET @intVchNo = 0
			END
			
	---------------------------------------------------------------------------------------	
	IF @intVchNo <> 0 AND 
	   ((SELECT TOP 1 SerialNo 
	     FROM acc.tblVoucherDtl
         WHERE SerialNo=@intVchNo AND 
          SourceProcessID=@intSourceProcessID AND 
		  SourceProcessNo=@intSourceProcessNo AND 
		  SourceFiscalYear=@intSourceFiscalYear AND 
		  SourceSerialNo =@intSourceSerialNo) IS NULL)

			BEGIN
				SET @intVchNo = 0
			END
			
		
	IF @intVchNo <> 0
		BEGIN
		
		--====================================================================================================================
		-- مرتب کردن شماره های سند
		--====================================================================================================================
			UPDATE acc.tblVoucherDtl 
			SET DocRowNo=ROW_N
			FROM acc.tblVoucherDtl, 
				(SELECT RowNo,ROW_NUMBER() OVER(ORDER BY DocRowNo) As ROW_N
				 FROM	acc.tblVoucherDtl
				 WHERE	SerialNo=@intVchNo) t 
			WHERE acc.tblVoucherDtl.SerialNo=@intVchNo AND acc.tblVoucherDtl.RowNo=t.RowNo
		END
--====================================================================================================================
-- بروز رسانی شماره سند در جدول هدر
--====================================================================================================================
	DECLARE @StrSelect NVarChar(4000)
	DECLARE @StrCode NVarChar(4000)
	SET @StrCode=''
	
	IF @intSourceProcessID = 95
		SET @intSourceProcessID = 90 
		
	IF @StrSourceCodeFieldName  <> ''
		SET @StrCode = pub.funSplitString(@StrSourceCodeFieldName, '@', 1) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 1) + '''' 
	
	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 2)<>''
		SET @StrCode = @StrCode + ' AND ' + pub.funSplitString(@StrSourceCodeFieldName, '@', 2) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 2) + '''' 
	
	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 3)<>''
		SET @StrCode = @StrCode + ' AND ' + pub.funSplitString(@StrSourceCodeFieldName, '@', 3) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 3) + '''' 

	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 4)<>''
		SET @StrCode = @StrCode + ' AND ' + pub.funSplitString(@StrSourceCodeFieldName, '@', 4) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 4) + '''' 

	IF @StrCode<>'' AND pub.funSplitString(@StrSourceCodeFieldName, '@', 5)<>''
		SET @StrCode = @StrCode + ' AND ' + pub.funSplitString(@StrSourceCodeFieldName, '@', 5) + ' = ''' + pub.funSplitString(@StrSourceCodeFieldValue, '@', 5) + '''' 
	
	IF @DocFormType > 0 AND @DocFormType < 15 AND @StrCode <> ''
		SET @StrCode = ' AND ' + @StrCode 

	IF @DocFormType = 1
	
		SET @StrSelect =
		N'UPDATE ' + @strHdrTblName + 
		' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
		' WHERE SerialNo  =' + STR(@intSourceSerialNo) + @StrCode
		
	ELSE IF @DocFormType = 2
	
		SET @StrSelect =
			N'UPDATE ' + @strHdrTblName + 
			' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
			' WHERE ProcessID =' + STR(@intSourceProcessID)  + 
			  ' AND ProcessNo =' + STR(@intSourceProcessNo)  +
			  ' AND FiscalYear=' + STR(@intSourceFiscalYear) +
			  ' AND SerialNo  =' + STR(@intSourceSerialNo) + @StrCode

	ELSE IF @DocFormType = 5

		SET @StrSelect =
			N'UPDATE ' + @strHdrTblName + 
			' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
			' WHERE ProcessID =' + STR(@intSourceProcessID)  + 
			  ' AND SerialNo  =' + STR(@intSourceSerialNo) + @StrCode

	ELSE IF @DocFormType = 8
	
		SET @StrSelect =
			N'UPDATE ' + @strHdrTblName + 
			' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
			' WHERE ProcessID =' + STR(@intSourceProcessID)  + 
			  ' AND ProcessNo =' + STR(@intSourceProcessNo)  +
			  ' AND FiscalYear=' + STR(@intSourceFiscalYear) +
			  ' AND SerialNo  =' + STR(@intSourceSerialNo) +
			  ' AND DocDate  =' + STR(@strVchDate) + @StrCode

	ELSE IF @DocFormType = 9
	
		SET @StrSelect =
			N'UPDATE ' + @strHdrTblName + 
			' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
			' WHERE PeriodWorkID =''' + str(@StrSourceCodeFieldValue)  +
			  ''' AND RowNo=' + STR(@StrSourceCodeFieldName) +
			  ' AND SerialNo  =' + STR(@intSourceSerialNo) +
			  ' AND DocDate  =''' + @strVchDate + ''''
			  
	ELSE IF @DocFormType = 10
	
		SET @StrSelect =
			N'UPDATE ' + @strHdrTblName + 
			' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
			' WHERE ProcessID =' + STR(@intSourceProcessID)  + 
			  ' AND ProcessNo =' + STR(@intSourceProcessNo)  +
			  ' AND FiscalYear=' + STR(@intSourceFiscalYear) +
			  ' AND VchNo = 0 AND DocDate  =''' + @strVchDate + ''' ' + @StrCode
				
			  			  			  
	ELSE IF @StrCode <> ''  
		SET @StrSelect =
			N'UPDATE ' + @strHdrTblName + 
			' SET '	+ @strVchNoFieldName + '=' + STR(@intVchNo) +
			' WHERE ' + @StrCode
			  	  
	ELSE
		BEGIN
			Raiserror (N'Form type is not valid',16,1)
			Return
		END
	IF @strHdrTblName<>''
		EXECUTE sp_executesql @StrSelect

	declare @Sal_HasPayment bit
	
	SET @Sal_HasPayment = 'False'
	
	SELECT @Sal_HasPayment = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'Sal_HasPayment'
	
	IF @intSourceProcessID <>1 and @intSourceProcessID <>55 and @intSourceProcessID <>60 and @intSourceProcessID <>70 and @intSourceProcessID <>80  and @intSourceProcessID <>72 and @intSourceProcessID <>82  and @intSourceProcessID <>73 and @intSourceProcessID <>100 and (select COUNT(*) from acc.tblAccState)>0 and @Sal_HasPayment = 'True'
	BEGIN
		DECLARE @AcntCode varchar(20) 
		-------------------
		IF ( @intSourceProcessID >=50 AND  @intSourceProcessID < 140) or @intSourceProcessID=240
		BEGIN 
			SELECT @AcntCode = AcntCode from inv.tblStorageDocsHdr 
			WHERE ProcessID = @intSourceProcessID 
			AND   ProcessNo = @intSourceProcessNo
			AND   FiscalYear = @intSourceFiscalYear
			AND   SerialNo = @intSourceSerialNo

					-- حذف اسناد بدون منبع
					-- اصلاح اسناد تطبیق اتوماتیک
					exec acc.SpAcc_AccState  @AcntCode,4,@intSourceProcessID ,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo
					--exec acc.SpAcc_AccState  @AcntCode,5,@intSourceProcessID ,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo
		END 

	END	 

	IF @intSourceProcessID in (450,455,460,469,470,471,472,480,485,486,490,495,500,505,520)  and @Pub_SendDoc2OtherSoftWare='True'
	BEGIN			
			insert into pub.tblSendDoc2OtherSoftWare
			Select @intVchNo ,@intSourceProcessID ,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo , 1, Getdate()
	END
--====================================================================================================================
-- شماره سند
--====================================================================================================================
	SELECT @intVchNo AS VchNo

END
GO
