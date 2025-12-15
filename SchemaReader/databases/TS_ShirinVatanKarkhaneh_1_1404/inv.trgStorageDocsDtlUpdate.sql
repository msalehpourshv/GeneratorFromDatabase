USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER  [inv].[trgStorageDocsDtlUpdate]
   ON  [inv].[tblStorageDocsDtl]
   WITH ENCRYPTION
   AFTER UPDATE
AS 

BEGIN
	--IF (SELECT top 1 CalculatingAmount FROM Inserted) = (SELECT top 1 CalculatingAmount FROM Deleted) 
		--BEGIN

			DECLARE 
			 @OldDate			Char(10)	,	@NewDate			Char(10)	,
			 @OldStoreID		VARCHAR(20) ,	@NewStoreID			VARCHAR(20)	,
			 @OldStoreID2		VARCHAR(20) ,	@NewStoreID2		VARCHAR(20)	,
			 @OldGoodsID		VARCHAR(20) ,	@NewGoodsID			VARCHAR(20)	,
			 @OldBatchNo		NVARCHAR(20),	@NewBatchNo			NVARCHAR(20),
			 @OldDocStep		Tinyint		,	@NewDocStep			Tinyint		,
			 @MinDate			Char(10)	,	@NewGoodsID2		VARCHAR(20)	,	@OldGoodsID2		VARCHAR(20)	,
			 @OldVolumeRowNo	FLOAT		,	@NewVolumeRowNo		FLOAT		,	@TmpVolumeRowNo	FLOAT			,	
			 @OldGoodsQuantity	Decimal(28,9),	@NewGoodsQuantity   Decimal(28,9),  @TmpVolumeRowNo2	FLOAT		,
			 @VisitorPercent	FLOAT	    ,   @VirtualQuantity	FLOAT		,		 
			 @ProcessID			Smallint    ,	@ProcessNo			Tinyint		,
			 @FiscalYear		Smallint	,	@SerialNo			Bigint		,   @MaxFiscalYear		Smallint,
			 @OldBaseProcessID	Smallint    ,	@OldBaseProcessNo	Tinyint		,
			 @OldBaseFiscalYear	Smallint	,	@OldBaseSerialNo	Bigint		,
			 @NewBaseProcessID	Smallint    ,	@NewBaseProcessNo	Tinyint		,
			 @NewBaseFiscalYear	Smallint	,	@NewBaseSerialNo	Bigint		,
			 @NewRowNo			Int			,	@OldRowNo			Int			,
			 @NewUserPriceID	Int			,	@OldUserPriceID		Int			,
			 @NewUserPriceID2	Int			,	@OldUserPriceID2	Int			,
			 @EnterKind			SmallInt	,	@OldEnterKind			SmallInt	,@DocDateErr			Char(10)	,
			 @UpdateState       Smallint	,	@StrErr				NVARCHAR(4000),
			 @AllowStoreNegativeBalance	Bit	,	@Balance			VARCHAR(20) , 
			 @SubUnitID			VarChar(20) ,	@NewBatchNo2		NVARCHAR(20),	
			 @OldSum			FLOAT       ,	@NewSum					FLOAT	,
			 @NewVolume			Bit			,	@ChangeLastUpdateInGoodsList	Bit
			
			BEGIN TRY
				
				SET @UpdateState = 0 
				SET @AllowStoreNegativeBalance = 0
				SET @NewVolume = 'False'
				SET @ChangeLastUpdateInGoodsList = 0
		
				SELECT @ChangeLastUpdateInGoodsList = SettingValue from pub.tblSettings where SettingKey = 'ChangeLastUpdateInGoodsList'

				DECLARE @MinStoreBalance float
				SELECT @MinStoreBalance = SettingValue from pub.tblSettings where SettingKey = 'MinStoreBalance'
				set @MinStoreBalance=isnull(@MinStoreBalance,-0.001)

				DECLARE @UnitPart TINYINT

				SET @UnitPart  = 1

				SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

				IF @UnitPart IS NULL or @UnitPart = 0
					SET @UnitPart = 1

				DECLARE @str_Goods  tinyint,
						@str_GoodsSum tinyint

				select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
				from pub.tblCodeLayer 
				where TableName='inv.tblGoods' AND PartNumber<@UnitPart

				select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
				from pub.tblCodeLayer 
				where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

				SELECT @AllowStoreNegativeBalance = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = N'AllowStoreNegativeBalance'
				
				SELECT @MaxFiscalYear = ISNULL(MAX(FiscalYear),0) from inv.tblStorageDocsHdr

				IF @AllowStoreNegativeBalance = 1
					BEGIN
						IF(SELECT Count(*) FROM sys.all_objects WHERE type = 'C' AND name = 'CK_tblStorageDocsDtl_2')> 0
							ALTER TABLE [inv].[tblStorageDocsDtl] DROP CONSTRAINT [CK_tblStorageDocsDtl_2]
					END

				DECLARE curStorageDocsInserted Cursor  For 
				SELECT	DocDate, StoreID, StoreID2, GoodsID, GoodsID2, VolumeRowNo, GoodsQuantity, EnterKind, 
						ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo,DocStep,SubUnitID, BatchNo, BatchNo2,UserPriceID,UserPriceID2
						,VisitorPercent,VirtualQuantity,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
				FROM	Inserted

				DECLARE curStorageDocsDeleted Cursor  For 
				SELECT	DocDate, StoreID, StoreID2, GoodsID,GoodsID2, VolumeRowNo, GoodsQuantity, RowNo,DocStep,BatchNo,UserPriceID,UserPriceID2,
						EnterKind,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
				FROM	Deleted

				OPEN curStorageDocsInserted
				OPEN curStorageDocsDeleted
				
				FETCH NEXT FROM curStorageDocsInserted INTO	
					 @NewDate, @NewStoreID, @NewStoreID2, @NewGoodsID, @NewGoodsID2, @NewVolumeRowNo, @NewGoodsQuantity, @EnterKind, 
					 @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @NewRowNo, @NewDocStep,@SubUnitID, @NewBatchNo, @NewBatchNo2,@NewUserPriceID,@NewUserPriceID2
					,@VisitorPercent,@VirtualQuantity,@NewBaseProcessID,@NewBaseProcessNo,@NewBaseFiscalYear,@NewBaseSerialNo
--------			,@VisitorPercent,VirtualQuantity    برای حالت kpn  سرخانه ها برای کارت به کارت

				WHILE @@FETCH_STATUS = 0
					BEGIN
						
						IF (SELECT COUNT(*)  +
							isnull((SELECT COUNT(*) FROM  inv.tblSubUnitsDtl 
									WHERE GoodsID='' AND UnitID in 
												 (SELECT UnitID FROM inv.tblGoods 
												  WHERE GoodsID = SUBSTRING(@NewGoodsID,@str_Goods+1,@str_GoodsSum)  AND PartNumber = @UnitPart )),0)
							FROM
							(SELECT UnitID UnitID  FROM inv.tblGoods
							WHERE GoodsID = SUBSTRING(@NewGoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber = @UnitPart 
							UNION
							SELECT SubUnitID UnitID FROM inv.tblSubUnitsDtl
							WHERE GoodsID = @NewGoodsID) G
							WHERE UnitID = @SubUnitID) =0
						BEGIN
							--ROlLBACK
							
							CLOSE curStorageDocsDeleted
							Deallocate curStorageDocsDeleted
							
							Close curStorageDocsInserted
							Deallocate curStorageDocsInserted
							
							SET @StrErr = N'#$ کالا تعریف نشده و یا واحد کالای ' + @NewGoodsID +  ' درست نيست #$'
							RAISERROR (@StrErr, 16, 1)
						END
						 
						IF (SELECT COUNT(*) FROM sal.tblSaleServiceDtl WHERE NegativeFlag='True' AND GoodsID = @NewGoodsID ) = 0  AND (@FiscalYear=@MaxFiscalYear OR @MaxFiscalYear=0) AND
						   (SELECT COUNT(*) FROM inv.tblGoods WHERE  GoodsID=SUBSTRING(@NewGoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart  AND  (IsService='True' OR (@ProcessID=90 and OurTrustInSale='True')) ) = 0
							BEGIN	
						----- داده هاي سطر قديمي 
								FETCH NEXT FROM curStorageDocsDeleted INTO	
									 @OldDate, @OldStoreID, @OldStoreID2, @OldGoodsID, @OldGoodsID2, @OldVolumeRowNo, @OldGoodsQuantity, @OldRowNo, @OldDocStep,@OldBatchNo,@OldUserPriceID,@OldUserPriceID2,
									 @OldEnterKind,@OldBaseProcessID,@OldBaseProcessNo,@OldBaseFiscalYear,@OldBaseSerialNo
									
								Update_BEGIN:
								
								SET @TmpVolumeRowNo = 0							  
								SET @TmpVolumeRowNo2 = 0							  
								--==================== When StoreID Or GoodsID Or Others are changed ============================================
								IF	@NewVolume = 'True' OR @OldStoreID <> @NewStoreID OR @OldGoodsID <> @NewGoodsID OR @OldBatchNo <> @NewBatchNo OR @OldUserPriceID<>@NewUserPriceID OR @UpdateState = 1
									-- حذف سطر قديمي و افزودن سطر جديد
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 1
										ELSE
										   SET @UpdateState = -1

									IF @ProcessID = 70
										BEGIN
											IF (Select  COUNT(VolumeRowNo)
												FROM  inv.tblStorageDocsDtl 	
												WHERE ProcessID IN (80) AND BaseProcessID  = @ProcessID  AND BaseProcessNo = @ProcessNo AND 
													  BaseFiscalYear = @FiscalYear AND BaseSerialNo  = @SerialNo  ) > 0
												BEGIN
													Select @TmpVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
													FROM  inv.tblStorageDocsDtl 	
													WHERE ProcessID IN (70) AND ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
														  FiscalYear = @FiscalYear AND SerialNo  = @SerialNo
										
													IF @TmpVolumeRowNo = 0	
														BEGIN
															Select  @TmpVolumeRowNo = ISNULL(MIN(VolumeRowNo),0)
															FROM  inv.tblStorageDocsDtl 	
															WHERE ProcessID IN (80) AND BaseProcessID  = @ProcessID  AND BaseProcessNo = @ProcessNo AND 
																  BaseFiscalYear = @FiscalYear AND BaseSerialNo  = @SerialNo
													
															SET @TmpVolumeRowNo = @TmpVolumeRowNo -1	  									    
														END	  
												END
										END
									IF @ProcessID = 75
										BEGIN
											IF (Select  COUNT(VolumeRowNo)
												FROM  inv.tblStorageDocsDtl 	
												WHERE ProcessID IN (80) AND BaseProcessID  = @NewBaseProcessID  AND BaseProcessNo = @NewBaseProcessNo AND 
													  BaseFiscalYear = @NewBaseFiscalYear AND BaseSerialNo  = @NewBaseSerialNo  ) > 0
												BEGIN

													Select @TmpVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
													FROM  inv.tblStorageDocsDtl 	
													WHERE ProcessID IN (70) AND ProcessID  = @NewBaseProcessID  AND ProcessNo = @NewBaseProcessNo AND 
														  FiscalYear = @NewBaseFiscalYear AND SerialNo  = @NewBaseSerialNo
										
													Select @TmpVolumeRowNo2 = ISNULL(MAX(VolumeRowNo),0)
													FROM  inv.tblStorageDocsDtl 	
													WHERE ProcessID IN (75) AND ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
														  FiscalYear = @FiscalYear AND SerialNo  = @SerialNo
													IF @TmpVolumeRowNo2>@TmpVolumeRowNo
														SET @TmpVolumeRowNo = @TmpVolumeRowNo2

													IF @TmpVolumeRowNo = 0	
														BEGIN
															Select  @TmpVolumeRowNo = ISNULL(MIN(VolumeRowNo),0)
															FROM  inv.tblStorageDocsDtl 	
															WHERE ProcessID IN (80) AND BaseProcessID  = @NewBaseProcessID  AND BaseProcessNo = @NewBaseProcessNo AND 
																  BaseFiscalYear = @NewBaseFiscalYear AND BaseSerialNo  = @NewBaseSerialNo
													
															SET @TmpVolumeRowNo = @TmpVolumeRowNo -1	  									    
														END	  
												END
									END
										
									IF @ProcessID = 78
										BEGIN
											IF (Select  COUNT(VolumeRowNo)
												FROM  inv.tblStorageDocsDtl 	
												WHERE ProcessID IN (88) AND ProcessNo = @ProcessNo AND 
													  FiscalYear = @FiscalYear AND SerialNo  = @NewBaseSerialNo  ) > 0
												BEGIN
													Select @TmpVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
													FROM  inv.tblStorageDocsDtl 	
													WHERE ProcessID IN (78)   AND ProcessNo = @ProcessNo AND 
														  FiscalYear = @FiscalYear AND SerialNo  = @SerialNo
										
													IF @TmpVolumeRowNo = 0	
														BEGIN
															Select  @TmpVolumeRowNo = ISNULL(MIN(VolumeRowNo),0)
															FROM  inv.tblStorageDocsDtl 	
															WHERE ProcessID IN (88) AND  ProcessNo = @ProcessNo AND 
																  FiscalYear = @FiscalYear AND SerialNo  = @NewBaseSerialNo
													
															SET @TmpVolumeRowNo = @TmpVolumeRowNo -1	  									    
														END	  
												END
									END
										IF @ProcessID = 50 OR @ProcessID = 55
										BEGIN
								
											Select @NewVolumeRowNo = ISNULL(MAX(VolumeRowNo),-1000000000)
											From inv.tblStorageDocsDtl
											Where DocDate = @NewDate AND ProcessID IN (50,55) AND VolumeRowNo < 0
	
											IF @NewVolumeRowNo = 0
												SET @NewVolumeRowNo = -1000000000
												
											Set @NewVolumeRowNo = ISNULL(@NewVolumeRowNo,0) + 1
										END


										ELSE IF (@ProcessID = 70 OR @ProcessID = 78) AND @TmpVolumeRowNo >0							
											Set @NewVolumeRowNo = ISNULL(@TmpVolumeRowNo,0) + 0.0001
										ELSE	
										BEGIN
											------ جديد VolumeRowNo 
											SELECT TOP(1) @NewVolumeRowNo = VolumeRowNo
											FROM	[inv].[tblStorageDocsDtl] 
											WHERE	DocDate = @NewDate	AND VolumeRowNo > 0
											Order By DocDate Desc, VolumeRowNo Desc

											SET @NewVolumeRowNo = ISNULL(@NewVolumeRowNo,0) + 1
										END

										----- بروز رساني سطر جاري
										Update	inv.tblStorageDocsDtl 
										SET		DocDate = @NewDate, StoreID = @NewStoreID, GoodsID = @NewGoodsID, VolumeRowNo = @NewVolumeRowNo,
												GoodsQuantity = @NewGoodsQuantity ,BatchNo=@NewBatchNo ,UserPriceID=@NewUserPriceID,
												LastUpdate = GETDATE()
										WHERE	ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
												FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND RowNo = @NewRowNo 
									END

								ELSE IF	@OldStoreID2 <> @NewStoreID2
									-- حذف سطر قديمي و افزودن سطر جديد
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 1
										ELSE
										   SET @UpdateState = -1
									END
								ELSE IF	@OldGoodsID2 <> @NewGoodsID2
									-- حذف سطر قديمي و افزودن سطر جديد
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 1
										ELSE
										   SET @UpdateState = -1
									END
								ELSE IF	@OldUserPriceID2 <> @NewUserPriceID2
									-- حذف سطر قديمي و افزودن سطر جديد
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 1
										ELSE
										   SET @UpdateState = -1
									END

								--==================== When Only Date Or GoodsQuantity are changed ============================================================
								ELSE IF (@NewDate > @OldDate) OR @UpdateState = 2
									-- حذف سطر قديمي و افزودن سطر جديد
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 2
										ELSE
											SET @UpdateState = -2

										------ جديد VolumeRowNo 
										IF @ProcessID = 50 OR @ProcessID = 55
										BEGIN
								
											Select @NewVolumeRowNo = ISNULL(MAX(VolumeRowNo),-1000000000)
											From inv.tblStorageDocsDtl
											Where DocDate = @NewDate AND ProcessID IN (50,55) AND VolumeRowNo < 0
	
											IF @NewVolumeRowNo = 0
												SET @NewVolumeRowNo = -1000000000
												
											Set @NewVolumeRowNo = ISNULL(@NewVolumeRowNo,0) + 1
										END
										ELSE
										BEGIN
											SELECT TOP(1) @NewVolumeRowNo = VolumeRowNo
											FROM	[inv].[tblStorageDocsDtl] 
											WHERE	DocDate = @NewDate  AND 	 VolumeRowNo > 0
											Order By DocDate Desc, VolumeRowNo Desc

											SET @NewVolumeRowNo = ISNULL(@NewVolumeRowNo,0) + 1
										END
									
										----- بروز رساني سطر جاري
										Update	inv.tblStorageDocsDtl 
										SET		DocDate = @NewDate, VolumeRowNo = @NewVolumeRowNo,
												LastUpdate = GETDATE()
										WHERE	ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
												FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND RowNo = @NewRowNo 
									END

								--==================== When Only Date Or GoodsQuantity are changed ============================================================
								ELSE IF (@NewDate < @OldDate) OR @UpdateState = 3
									-- افزودن سطر جديد و حذف سطر قديمي 
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 3
										ELSE
											SET @UpdateState = -3
										------ جديد VolumeRowNo 
										IF @ProcessID = 50 OR @ProcessID = 55
										BEGIN
								
											Select @NewVolumeRowNo = ISNULL(MAX(VolumeRowNo),-1000000000)
											From inv.tblStorageDocsDtl
											Where DocDate = @NewDate AND ProcessID IN (50,55) AND VolumeRowNo < 0
	
											IF @NewVolumeRowNo = 0
												SET @NewVolumeRowNo = -1000000000
												
										END
										ELSE
										BEGIN												
											------ جديد VolumeRowNo 
											SELECT TOP(1) @NewVolumeRowNo = VolumeRowNo
											FROM [inv].[tblStorageDocsDtl] 
											WHERE	DocDate = @NewDate  AND 	 VolumeRowNo > 0
											Order By DocDate Desc, VolumeRowNo Desc
										END

										SET @NewVolumeRowNo = ISNULL(@NewVolumeRowNo,0) + 1
																
										----- بروز رساني سطر جاري
										Update	inv.tblStorageDocsDtl 
										SET		DocDate = @NewDate, VolumeRowNo = @NewVolumeRowNo,
												LastUpdate = GETDATE()
										WHERE	ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
												FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND RowNo = @NewRowNo
									END

								--==================== When Only GoodsQuantity are changed ============================================================
								ELSE IF	(@OldGoodsQuantity <> @NewGoodsQuantity OR @OldEnterKind <> @EnterKind) OR @UpdateState = 4
									BEGIN
										IF @UpdateState = 0
											SET @UpdateState = 4
										ELSE
											SET @UpdateState = -4
																			 
									END
						
						IF @OldEnterKind <> @EnterKind
							BEGIN
								SELECT TOP(1) @NewVolumeRowNo = VolumeRowNo
								FROM [inv].[tblStorageDocsDtl] 
								WHERE	DocDate = @NewDate  AND 	 VolumeRowNo > 0
								Order By DocDate Desc, VolumeRowNo Desc
											
								Set @NewVolumeRowNo = ISNULL(@NewVolumeRowNo,0) + 1

											----- بروز رساني سطر جاري
								Update	inv.tblStorageDocsDtl 
								SET		VolumeRowNo = @NewVolumeRowNo,
										LastUpdate = GETDATE()
								WHERE	ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
										FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND RowNo = @NewRowNo
							END

							IF @NewVolumeRowNo = 0
							BEGIN
								IF @OldBaseProcessID  <> @NewBaseProcessID OR
								   @OldBaseProcessNo  <> @NewBaseProcessNo OR
								   @OldBaseFiscalYear <> @NewBaseFiscalYear OR
								   @OldBaseSerialNo   <> @NewBaseSerialNo 
								   BEGIN
								------ جديد VolumeRowNo 
										IF @ProcessID = 50 OR @ProcessID = 55
											BEGIN
												Select @OldVolumeRowNo = ISNULL(MAX(VolumeRowNo),-1000000000)
												From inv.tblStorageDocsDtl
												Where DocDate = @NewDate AND ProcessID IN (50,55) AND VolumeRowNo < 0

												IF @OldVolumeRowNo = 0
													SET @OldVolumeRowNo = -1000000000
											END
										ELSE
											SELECT TOP(1) @OldVolumeRowNo = VolumeRowNo
											FROM	[inv].[tblStorageDocsDtl] 
											WHERE	DocDate = @NewDate	AND VolumeRowNo > 0
											Order By DocDate Desc, VolumeRowNo Desc

										SET @OldVolumeRowNo = ISNULL(@OldVolumeRowNo,0) + 1
									END
								----- بروز رساني سطر جاري
									Update	inv.tblStorageDocsDtl 
									SET		VolumeRowNo = @OldVolumeRowNo,
											LastUpdate = GETDATE()
									WHERE	ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
											FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND RowNo = @NewRowNo
							END	
								--========================================================================================================================

								IF @NewDate < @OldDate 
									SET @MinDate =@NewDate
								ELSE
									SET @MinDate =@OldDate

							--	Calculate QtyRemain
							  IF (@OldGoodsQuantity <> @NewGoodsQuantity OR 
							      @EnterKind <> @OldEnterKind OR 
							      (@OldVolumeRowNo <> @NewVolumeRowNo and @OldVolumeRowNo<>0 and @NewVolumeRowNo<>0) OR 
							      @NewDate <> @OldDate OR 
								  @OldStoreID <> @NewStoreID OR 
								  @OldGoodsID <> @NewGoodsID OR 
								  @NewBatchNo<>@OldBatchNo OR 
								  @NewUserPriceID<>@OldUserPriceID OR 
								  @NewUserPriceID2<>@OldUserPriceID2 OR 
								  @OldStoreID2 <> @NewStoreID2 OR 
								  @OldGoodsID2 <> @NewGoodsID2 OR
								  @NewVolume = 'True') AND 
								  @AllowStoreNegativeBalance <> 'True'
								  --IF @AllowStoreNegativeBalance <> 'True'
								BEGIN
									SET @Balance = ''
									SET @DocDateErr = ''
									IF @ChangeLastUpdateInGoodsList = 1
									BEGIN
										update inv.tblGoods SET LastUpdate = GETDATE() WHERE GoodsID = @NewGoodsID
										update inv.tblGoods SET LastUpdate = GETDATE() WHERE GoodsID = @OldGoodsID
									END
									IF (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(@NewGoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart AND (IsService='True' OR (@ProcessID=90 and OurTrustInSale='True'))) > 0
										SET @NewGoodsID = ''
										
									IF (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(@OldGoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart AND (IsService='True' OR (@ProcessID=90 and OurTrustInSale='True'))) > 0
										SET @OldGoodsID = ''
								
									SELECT @OldSum= ISNULL(Sum(GoodsQuantity * EnterKind) ,0)
									FROM	inv.tblStorageDocsDtl DM 
									WHERE	(DM.StoreID = (@OldStoreID)) AND
											(DM.GoodsID = (@OldGoodsID)) AND 
											(DM.BatchNo = (@OldBatchNo)) AND 
											(DM.UserPriceID = (@OldUserPriceID)) AND
											(DM.DocDate < @MinDate) AND 
											(FiscalYear = @FiscalYear OR (FiscalYear <> @FiscalYear AND EnterKind=1))

									SELECT @NewSum= ISNULL(Sum(GoodsQuantity * EnterKind) ,0)
									FROM	inv.tblStorageDocsDtl DM 
									WHERE	(DM.StoreID = (@NewStoreID)) AND
											(DM.GoodsID = (@NewGoodsID)) AND 
											(DM.BatchNo = (@NewBatchNo)) AND 
											(DM.UserPriceID = (@NewUserPriceID))  AND
											(DM.DocDate < @MinDate) AND
											(FiscalYear = @FiscalYear OR (FiscalYear <> @FiscalYear AND EnterKind=1))
									SELECT TOP 1 @DocDateErr = T.DocDate ,@Balance = Convert(VARCHAR(20),T.Balance)
									FROM 
									(
										SELECT DM.DocDate, @OldSum + SUM(GoodsQuantity * EnterKind)over (partition by StoreID,GoodsID,BatchNo,UserPriceID order by StoreID,GoodsID,DocDate,VolumeRowNo) Balance 
										FROM	inv.tblStorageDocsDtl DM 
										WHERE	(DM.StoreID = (@OldStoreID)) AND
												(DM.GoodsID = (@OldGoodsID)) AND 
												(DM.BatchNo = (@OldBatchNo)) AND 
												(DM.UserPriceID = (@OldUserPriceID)) AND
												(DM.DocDate >= @MinDate) 
									) T 
									WHERE (T.Balance < @MinStoreBalance) 

									IF @Balance=''
										SELECT TOP 1 @DocDateErr = T.DocDate ,@Balance = Convert(VARCHAR(20),T.Balance)
										FROM 
										(
											SELECT DM.DocDate, @NewSum + SUM(GoodsQuantity * EnterKind)over (partition by StoreID,GoodsID,BatchNo,UserPriceID order by StoreID,GoodsID,DocDate,VolumeRowNo) Balance 
											FROM	inv.tblStorageDocsDtl DM 
											WHERE	(DM.StoreID = (@NewStoreID)) AND
													(DM.GoodsID = (@NewGoodsID)) AND 
													(DM.BatchNo = (@NewBatchNo)) AND 
													(DM.UserPriceID = (@NewUserPriceID))  AND
													(DM.DocDate >= @MinDate) 
										) T 
										WHERE (T.Balance < @MinStoreBalance) 

									IF @DocDateErr<>''
										BEGIN
											--ROlLBACK

											CLOSE curStorageDocsInserted
											Deallocate curStorageDocsInserted

											CLOSE curStorageDocsDeleted
											Deallocate curStorageDocsDeleted

											IF @UpdateState = 1 or @UpdateState = -1
												IF @OldGoodsID <> @NewGoodsID AND @OldStoreID <> @NewStoreID
													SET @StrErr = N'#$با تغییر کالای' + @OldGoodsID + ' به ' + @NewGoodsID + ' و انبار ' + @OldStoreID + ' به '  + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @OldStoreID <> @NewStoreID
													SET @StrErr = N'#$با تغییر کالای' + @OldGoodsID + ' به ' + @NewGoodsID + ' و انبار ' + @OldStoreID + ' به '  + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @OldStoreID2 <> @NewStoreID2
													SET @StrErr = N'#$با تغییر کالای' + @OldGoodsID + ' به ' + @NewGoodsID + ' و انبار ' + @OldStoreID2 + ' به '  + @NewStoreID2 + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @OldGoodsID <> @NewGoodsID
													SET @StrErr = N'#$با تغییر کالای' + @OldGoodsID + ' به ' + @NewGoodsID + ' در انبار ' + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @OldBatchNo <> @NewBatchNo
													SET @StrErr = N'#$با تغییر بچ' + @OldBatchNo + ' به ' + @NewBatchNo + ' در انبار ' + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @OldUserPriceID <> @NewUserPriceID
													SET @StrErr = N'#$با تغییر قیمت مصرف کننده' + RTRIM(LTRIM(STR(@OldUserPriceID))) + ' به کد' + RTRIM(LTRIM(STR(@NewUserPriceID))) + ' در انبار ' + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @OldUserPriceID2 <> @NewUserPriceID2
													SET @StrErr = N'#$با تغییر قیمت مصرف کننده' + RTRIM(LTRIM(STR(@OldUserPriceID2))) + ' به کد' + RTRIM(LTRIM(STR(@NewUserPriceID2))) + ' در انبار ' + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
												ELSE IF @NewVolume = 'True'
													SET @StrErr = N'#$با تغییر انبار مبدا گردش کالا در انبار مقصد منفی میشود .گردش های بعدی این کالا در انبار مقصدر را حذف و اقدام به ذخیره  این برگه  نمایید ' + '(در تاریخ'+ @DocDateErr + ')#$' 
												ELSE
													SET @StrErr = N'#$با تغییر انبار' + @OldStoreID + ' به ' + @NewStoreID + ' برای کالای ' + @OldGoodsID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
													
											ELSE IF @UpdateState = 2 OR @UpdateState = 3 or @UpdateState = -2 or @UpdateState = -3
													SET @StrErr = N'#$با تغییر تاریخ کالای ' + @OldGoodsID  + ' در انبار ' + @NewStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'

											ELSE IF @UpdateState = 4 or @UpdateState = -4
												BEGIN
													IF @OldBatchNo <> @NewBatchNo
														SET @StrErr = N'#$با تغییر مقدار و بچ کالای ' + @OldGoodsID  + ' در انبار ' + @NewStoreID + ' از ' + LTRIM(STR(@OldGoodsQuantity,20,5)) + ' به ' + LTRIM(STR(@NewGoodsQuantity,20,5)) + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'

													ELSe IF @OldUserPriceID <> @NewUserPriceID
														SET @StrErr = N'#$با تغییر مقدار و قیمت مصرف کننده کالای ' + @OldGoodsID  + ' در انبار ' + @NewStoreID + ' از ' + LTRIM(STR(@OldGoodsQuantity,20,5)) + ' به ' + LTRIM(STR(@NewGoodsQuantity,20,5)) + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'

													ELSe
														BEGIN
															IF @NewBatchNo<>''
																SET @StrErr = N'#$با تغییر مقدار کالای ' + @OldGoodsID  + ' بچ ' + @NewBatchNo +' در انبار ' + @NewStoreID + ' از ' + LTRIM(STR(@OldGoodsQuantity,20,5)) + ' به ' + LTRIM(STR(@NewGoodsQuantity,20,5)) + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
															ELSE IF @NewUserPriceID<>0
																SET @StrErr = N'#$با تغییر مقدار کالای ' + @OldGoodsID  + ' با این قیمت مصرف در انبار  ' + @NewStoreID + ' از ' + LTRIM(STR(@OldGoodsQuantity,20,5)) + ' به ' + LTRIM(STR(@NewGoodsQuantity,20,5)) + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
															ELSE 
																SET @StrErr = N'#$با تغییر مقدار کالای ' + @OldGoodsID  + ' در انبار ' + @NewStoreID + ' از ' + LTRIM(STR(@OldGoodsQuantity,20,5)) + ' به ' + LTRIM(STR(@NewGoodsQuantity,20,5)) + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
														END
												END
											ELSE 
													SET @StrErr = N'#$ کالای' + @OldGoodsID + ' به تاریخ ' + @DocDateErr + ' در انبار ' + @OldStoreID + ' مانده در کارت کالا به مقدار' + @Balance + ' منفي می شود ' + '(در تاریخ'+ @DocDateErr + ')#$'
											
											RAISERROR (@StrErr, 16, 1)
										END
									END

								--========================================================================================================================
								IF @ProcessID=120 
								BEGIN
									DECLARE @SettingValue NVARCHAR(10)
								IF @ProcessNo = 2
									SELECT @SettingValue=SettingValue 
									FROM pub.tblSettings 
									WHERE SettingKey='IsAutoTransfer2'
								ELSE
									SELECT @SettingValue=SettingValue 
									FROM pub.tblSettings 
									WHERE SettingKey='IsAutoTransfer'

									SET @OldVolumeRowNo = -1
									
									SELECT	@OldVolumeRowNo = VolumeRowNo
									FROM  [inv].[tblStorageDocsDtl] 
									WHERE ProcessID  = 125  AND 
										  ProcessNo  = @ProcessNo  AND
										  FiscalYear = @FiscalYear AND 
										  SerialNo   = @SerialNo   AND 
										  RowNo      = @OldRowNo
									
									IF (@OldVolumeRowNo <> -1)
									BEGIN
										DECLARE @Result1 VARCHAR(max);
										DECLARE @strSql NVARCHAR(max)
										
										IF UPPER(@SettingValue) = 'TRUE' OR @SettingValue = '1'
											BEGIN
												SET @Result1= ''
												
												EXEC [pub].[funCreateColumnsString] 
													@SchemaName='inv',
													@tableName='tblStorageDocsDtl',
													@ColumnsName='StoreID'',''StoreID2'',''ProcessID'',''EnterKind'',''QtyRemain'',''AmntRemain'',''VolumeRowNo',
													@CompressTableName='N',
													@Result=@Result1 output
											
												SELECT * INTO #tblStorageDocsDtlUpdate1 
												FROM Inserted
												WHERE ProcessID  = 120			AND 
													  ProcessNo  = @ProcessNo	AND 
													  FiscalYear = @FiscalYear	AND 
													  SerialNo   = @SerialNo	AND
													  RowNo		 = @NewRowNo

												SET @strSql = 
													N'UPDATE inv.tblStorageDocsDtl 
													SET StoreID=''' + @NewStoreID2 + ''',StoreID2=''' + @NewStoreID + ''',' + @Result1 + '
													FROM inv.tblStorageDocsDtl O INNER JOIN #tblStorageDocsDtlUpdate1 N
													ON  N.ProcessID  = 120 AND O.ProcessID  = 125 AND 
														N.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
														O.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
														N.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
														O.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
														N.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
														O.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
														N.RowNo      = ' + CAST(@NewRowNo   AS VARCHAR(10)) + ' AND										  
														O.RowNo      = ' + CAST(@OldRowNo   AS VARCHAR(10))
								
												EXEC sp_executesql @strSql

												IF (SELECT Count(*) FROM tempdb.sys.tables WHERE name LIKE '#tblStorageDocsDtlUpdate1%') > 0 
													DROP TABLE #tblStorageDocsDtlUpdate1
											
												IF @OldStoreID <> @NewStoreID
													SET @NewVolume = 'True'
												SET @ProcessID  = 125
												SET @OldStoreID = @OldStoreID2
												SET @NewStoreID = @NewStoreID2
												SET @NewUserPriceID = @NewUserPriceID2 
												SET @OldUserPriceID = @OldUserPriceID2 

												SET @EnterKind  = 1
												SET @OldEnterKind  = 1

												IF @UpdateState > 0
													GOTO Update_BEGIN 
											END
											
										ELSE -- IF @SettingValue = 'False'
										
											BEGIN
												IF @NewDocStep=2 AND @OldDocStep=3
													BEGIN
														SET @Result1= '' -- باید 125 ها حذف شوند لطفا توجه شود
													END
												ELSE IF @NewDocStep>=3 
													BEGIN
														SET @Result1= ''
														
														EXEC [pub].[funCreateColumnsString] 
															@SchemaName='inv',
															@tableName='tblStorageDocsDtl',
															@ColumnsName='StoreID'',''StoreID2'',''DocDate'',''GoodsQuantity'',''SubUnitQuantity'',''ProcessID'',''EnterKind'',''QtyRemain'',''AmntRemain'',''VolumeRowNo',
															@CompressTableName='N',
															@Result=@Result1 output
													
														declare @DocDate_H varchar(10)
														declare @DocDate3_H varchar(10)

														SELECT @DocDate_H=DocDate, @DocDate3_H=DocDate3
														FROM inv.tblStorageDocsHdr
														WHERE ProcessID  = 120			AND 
															  ProcessNo  = @ProcessNo	AND 
															  FiscalYear = @FiscalYear	AND 
															  SerialNo   = @SerialNo	

														IF @DocDate3_H>@DocDate_H
															SET @DocDate_H = @DocDate3_H

														SELECT * INTO #tblStorageDocsDtlUpdate125 
														FROM Inserted
														WHERE ProcessID  = 120			AND 
															  ProcessNo  = @ProcessNo	AND 
															  FiscalYear = @FiscalYear	AND 
															  SerialNo   = @SerialNo	AND
															  RowNo	     = @NewRowNo

														SET @strSql = 
															N'UPDATE inv.tblStorageDocsDtl 
															SET StoreID=''' + @NewStoreID2 + ''',StoreID2=''' + @NewStoreID + ''',DocDate=''' + @DocDate_H + ''',GoodsQuantity=N.GoodsQuantity + N.Wage,SubUnitQuantity=N.SubUnitQuantity+N.Wage ,' + @Result1 + '
															FROM inv.tblStorageDocsDtl O INNER JOIN #tblStorageDocsDtlUpdate125 N
															ON  N.ProcessID = 120 AND O.ProcessID  = 125 AND 
																N.ProcessNo = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
																O.ProcessNo = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
																N.FiscalYear= ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
																O.FiscalYear= ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
																N.SerialNo  = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
																O.SerialNo  = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
																N.RowNo = ' + CAST(@NewRowNo   AS VARCHAR(10)) + ' AND										  
																O.RowNo = ' + CAST(@OldRowNo   AS VARCHAR(10))
									
														EXEC sp_executesql @strSql

														IF (SELECT Count(*) FROM tempdb.sys.tables WHERE name LIKE '#tblStorageDocsDtlUpdate125%') > 0 
														   DROP TABLE #tblStorageDocsDtlUpdate125
														IF @OldStoreID <> @NewStoreID
															SET @NewVolume = 'True'																		
														SET @ProcessID  = 125
														SET @OldStoreID = @OldStoreID2
														SET @NewStoreID = @NewStoreID2
														SET @NewUserPriceID = @NewUserPriceID2 
														SET @OldUserPriceID = @OldUserPriceID2 

														SET @EnterKind  = 1
														SET @OldEnterKind  = 1

														IF @UpdateState > 0
															GOTO Update_BEGIN 
													END		
																
											END	-- IF @SettingValue 
											
										END -- IF (SELECT ProcessID)  Is Not Null
										
									END -- IF @ProcessID=120 
									
								--========================================================================================================================
								ELSE IF  @ProcessID=260
								
									BEGIN
									
										DECLARE @strSql2 NVARCHAR(max)
										DECLARE @Result2 VARCHAR(max);
										declare @UnitID AS varchar(20)
										SET @UnitID = ''
										SET @Result2= ''
										
										IF (select  UnitID from inv.tblGoods WHERE PartNumber = @UnitPart AND GoodsID = SUBSTRING(@NewGoodsID2,@str_Goods+1,@str_GoodsSum) ) <>  (select  UnitID from inv.tblGoods WHERE PartNumber = @UnitPart AND GoodsID = SUBSTRING(@NewGoodsID,@str_Goods+1,@str_GoodsSum) )
											select  @UnitID = UnitID from inv.tblGoods WHERE PartNumber = @UnitPart AND GoodsID = SUBSTRING(@NewGoodsID2,@str_Goods+1,@str_GoodsSum) 
										ELSE
											SET @UnitID=@SubUnitID

										EXEC [pub].[funCreateColumnsString] 
											@SchemaName='inv',
											@tableName='tblStorageDocsDtl',
											@ColumnsName='GoodsID'',''GoodsID2'',''StoreID'',''StoreID2'',''BatchNo'',''BatchNo2'',''UserPriceID'',''UserPriceID2'',''SubUnitID'',''ProcessID'',''EnterKind'',''QtyRemain'',''AmntRemain'',''VolumeRowNo'',''VisitorPercent'',''VirtualQuantity',
											@CompressTableName='N',
											@Result=@Result2 output
										
										 
										SELECT * INTO #tblStorageDocsDtlUpdate2 
										FROM Inserted
										WHERE ProcessID  = 260			AND 
											  ProcessNo  = @ProcessNo	AND 
											  FiscalYear = @FiscalYear	AND 
											  SerialNo   = @SerialNo	AND
											  RowNo		 = @NewRowNo
								
										SET @strSql2 = 
											N'UPDATE [inv].[tblStorageDocsDtl] 
											SET GoodsID=''' + @NewGoodsID2 + ''',GoodsID2=''' + @NewGoodsID + ''',StoreID=''' + @NewStoreID2 + ''',StoreID2=''' + @NewStoreID + ''',BatchNo=''' + @NewBatchNo2 + ''',BatchNo2=''' + @NewBatchNo + ''',SubUnitID=''' + @UnitID +  ''',
											UserPriceID='+  str(@NewUserPriceID2 ) + ' ,UserPriceID2='+  str(@NewUserPriceID ) + ' ,VisitorPercent='+  str(@VirtualQuantity ) + ',VirtualQuantity ='+  str(@VisitorPercent ) + ',' + @Result2 +'
											FROM [inv].[tblStorageDocsDtl] O 
											INNER JOIN #tblStorageDocsDtlUpdate2 N
											ON    N.ProcessID  = 260 AND 
												  O.ProcessID  = 265 AND 
												  N.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
												  O.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
												  N.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
												  O.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
												  N.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
												  O.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
												  N.RowNo      = ' + CAST(@NewRowNo   AS VARCHAR(10)) + ' AND										  
												  O.RowNo      = ' + CAST(@OldRowNo   AS VARCHAR(10))

										EXEC sp_executesql @strSql2

										IF (SELECT Count(*) FROM tempdb.sys.tables WHERE name LIKE '#tblStorageDocsDtlUpdate2%') > 0 
										   DROP TABLE #tblStorageDocsDtlUpdate2
										   
										IF @OldStoreID <> @NewStoreID
											SET @NewVolume = 'True'										SET @ProcessID  = 265
										SET @NewGoodsID = @NewGoodsID2
										SET @OldGoodsID = @OldGoodsID2
										SET @NewStoreID = @NewStoreID2
										SET @OldStoreID = @OldStoreID2
										SET @NewUserPriceID = @NewUserPriceID2 
										SET @OldUserPriceID = @OldUserPriceID2 
										SET @EnterKind  = 1
										SET @OldEnterKind  = 1
										
										IF @UpdateState > 0
											GOTO Update_BEGIN 
									END
						END	
						ELSE
						BEGIN
							IF (@ProcessID = 90 OR @ProcessID = 100) AND (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID = @NewGoodsID AND OurTrustInSale='True')>0
							BEGIN
								----- بروز رساني سطر جاري
								Update  inv.tblStorageDocsDtl
								Set EnterKind = 0 
								Where ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
									  FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND 
									  RowNo = @NewRowNo and GoodsID = @NewGoodsID
							END
						END
						--========================================================================================================================
						FETCH NEXT FROM curStorageDocsInserted INTO	
							 @NewDate, @NewStoreID, @NewStoreID2, @NewGoodsID, @NewGoodsID2, @NewVolumeRowNo, @NewGoodsQuantity, @EnterKind, 
							 @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @NewRowNo, @NewDocStep,@SubUnitID, @NewBatchNo, @NewBatchNo2,@NewUserPriceID,@NewUserPriceID2
							 ,@VisitorPercent,@VirtualQuantity,@NewBaseProcessID,@NewBaseProcessNo,@NewBaseFiscalYear,@NewBaseSerialNo
					END -- WHILE 

				CLOSE curStorageDocsInserted
				Deallocate curStorageDocsInserted

				CLOSE curStorageDocsDeleted
				Deallocate curStorageDocsDeleted
			
			END TRY

			BEGIN Catch
				DECLARE @StrErrorMessage As NVARCHAR(1024)
				SET @StrErrorMessage = ERROR_MESSAGE() 
				RAISERROR (@StrErrorMessage, 16, 1)
			END Catch
--		END
END

GO
