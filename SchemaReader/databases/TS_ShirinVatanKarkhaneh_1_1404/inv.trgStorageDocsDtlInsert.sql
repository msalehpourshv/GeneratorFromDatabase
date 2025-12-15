USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [inv].[trgStorageDocsDtlInsert] 
   ON  [inv].[tblStorageDocsDtl] 
   WITH ENCRYPTION
   AFTER INSERT
AS 

Begin

	Declare 
     @DocDate		Char(10)	,
	 @DocDateErr	Char(10)	,
	 @StoreID		VarChar(20) ,
	 @StoreID2		VarChar(20) ,
	 @GoodsID		VarChar(20) ,
	 @GoodsID2		VarChar(20) ,
	 @BatchNo		NVarChar(20) ,
	 @BatchNo2		NVarChar(20) ,
	 @SubUnitID		VarChar(20) ,
	 @VolumeRowNo	FLOAT		,	
	 @TmpVolumeRowNo	FLOAT	,	
	 @TmpVolumeRowNo2	FLOAT	,	
	 @VisitorPercent	FLOAT	,	
	 @VirtualQuantity	FLOAT	,	
	 @GoodsQuantity	Decimal(28,9),	
	 @ProcessID		Smallint	,	
	 @ProcessNo		Tinyint		,
	 @FiscalYear	Smallint	,	
	 @SerialNo		Bigint			,
	 @RowNo			Int			,
	 @EnterKind		SmallInt	,
	 @AllowStoreNegativeBalance	BIT,
	 @StrErr		NVARCHAR(4000),
	 @BaseProcessID	Smallint	,	
	 @BaseProcessNo	Tinyint		,
	 @BaseFiscalYear Smallint	,	
	 @BaseSerialNo	Bigint			,
	 @BaseDocRowNo	Int			,
	 @UserPriceID	Int			,
	 @UserPriceID2	Int			,
	 @ChangeLastUpdateInGoodsList BIT
	 
	Begin TRY
		
		Set @AllowStoreNegativeBalance = 0
		Set @TmpVolumeRowNo = 0
		Set @TmpVolumeRowNo2 = 0
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
		Where SettingKey = N'AllowStoreNegativeBalance'
		
		Declare curStorageInsertDocs Cursor For 
		Select StoreID, StoreID2, GoodsID, GoodsID2, DocDate, GoodsQuantity, EnterKind,
			   ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo,SubUnitID,
			   BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo,BatchNo,BatchNo2,UserPriceID,UserPriceID2
			   ,VisitorPercent,VirtualQuantity
		From Inserted

		Open curStorageInsertDocs

		FETCH NEXT FROM curStorageInsertDocs INTO	
			@StoreID, @StoreID2, @GoodsID, @GoodsID2, @DocDate, @GoodsQuantity, @EnterKind, 
			@ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @RowNo ,@SubUnitID,
			@BaseProcessID, @BaseProcessNo, @BaseFiscalYear, @BaseSerialNo, @BaseDocRowNo,@BatchNo,@BatchNo2,@UserPriceID,@UserPriceID2
			,@VisitorPercent,@VirtualQuantity

--------			,@VisitorPercent,VirtualQuantity    برای حالت kpn  سرخانه ها برای کارت به کارت

		WHILE @@FETCH_STATUS = 0
			BEGIN
				IF (SELECT COUNT(*) +
						isnull((SELECT COUNT(*) FROM  inv.tblSubUnitsDtl 
								WHERE GoodsID='' AND UnitID in 
											 (SELECT UnitID FROM inv.tblGoods 
											  WHERE GoodsID = SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber = @UnitPart )),0)
					FROM
					(SELECT UnitID UnitID  FROM inv.tblGoods
					WHERE GoodsID =  SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum)  AND PartNumber = @UnitPart 
					UNION
					SELECT SubUnitID UnitID FROM inv.tblSubUnitsDtl
					WHERE GoodsID = @GoodsID) G
					WHERE UnitID = @SubUnitID) =0
				BEGIN
					--ROlLBACK
					Close curStorageInsertDocs
					Deallocate curStorageInsertDocs
					SET @StrErr = N'#$ کالا تعریف نشده و یا واحد کالای ' + @GoodsID +  ' درست نيست #$'
					RAISERROR (@StrErr, 16, 1)
				END 
				
				IF (SELECT COUNT(*) FROM sal.tblSaleServiceDtl WHERE NegativeFlag='True' AND GoodsID = @GoodsID ) = 0 AND 
				   (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart AND (IsService='True' OR (@ProcessID=90 and OurTrustInSale='True')) ) = 0
					BEGIN					

					Update_Begin:
						IF @ChangeLastUpdateInGoodsList = 1
							update inv.tblGoods SET LastUpdate = GETDATE() WHERE GoodsID = @GoodsID
						------ جديد VolumeRowNo 
						IF @ProcessID = 82 AND @BaseProcessID >0 AND 
						   (Select COUNT(*) 
						    FROM  inv.tblStorageDocsDtl 	
						    WHERE ProcessID IN (72,73) AND BaseProcessID  = @BaseProcessID  AND BaseProcessNo = @BaseProcessNo AND 
							      BaseFiscalYear = @BaseFiscalYear AND BaseSerialNo  = @BaseSerialNo  AND BaseDocRowNo = @BaseDocRowNo)>0
						BEGIN
							Select @TmpVolumeRowNo = ISNULL(MAX(VolumeRowNo),0) 
						    FROM  inv.tblStorageDocsDtl 	
						    WHERE ProcessID IN (82,83) AND BaseProcessID  = @BaseProcessID  AND BaseProcessNo = @BaseProcessNo AND 
							      BaseFiscalYear = @BaseFiscalYear AND BaseSerialNo  = @BaseSerialNo  AND BaseDocRowNo = @BaseDocRowNo
							      
							IF @TmpVolumeRowNo=0
							BEGIN
								Select @TmpVolumeRowNo = ISNULL(MIN(VolumeRowNo),0) 
								FROM  inv.tblStorageDocsDtl 	
								WHERE ProcessID IN (72,73) AND BaseProcessID  = @BaseProcessID  AND BaseProcessNo = @BaseProcessNo AND 
									  BaseFiscalYear = @BaseFiscalYear AND BaseSerialNo  = @BaseSerialNo  AND BaseDocRowNo = @BaseDocRowNo 
								
								IF @TmpVolumeRowNo = 1
									SET @TmpVolumeRowNo = 0.0001
								ELSE
									SET @TmpVolumeRowNo = @TmpVolumeRowNo -1		  									    
							END	
						END
						
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
												
												IF @TmpVolumeRowNo = 1
													SET @TmpVolumeRowNo = 0.0001
												ELSE
													SET @TmpVolumeRowNo = @TmpVolumeRowNo -1	    									    
											END	  
									END
							END
						IF @ProcessID = 75 AND @BaseSerialNo>0
							BEGIN
								IF (Select  COUNT(VolumeRowNo)
									FROM  inv.tblStorageDocsDtl 	
									WHERE ProcessID IN (80) AND BaseProcessID  = @BaseProcessID  AND BaseProcessNo = @BaseProcessNo AND 
										  BaseFiscalYear = @BaseFiscalYear AND BaseSerialNo  = @BaseSerialNo AND DocDate=@DocDate  ) > 0
									BEGIN
										Select @TmpVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
										FROM  inv.tblStorageDocsDtl 	
										WHERE ProcessID IN (70) AND ProcessID  = @BaseProcessID  AND ProcessNo = @BaseProcessNo AND 
											  FiscalYear = @BaseFiscalYear AND SerialNo  = @BaseSerialNo

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
												WHERE ProcessID IN (80) AND BaseProcessID  = @BaseProcessID  AND BaseProcessNo = @BaseProcessNo AND 
													  BaseFiscalYear = @BaseFiscalYear AND BaseSerialNo  = @BaseSerialNo
												if @TmpVolumeRowNo = 1
													set @TmpVolumeRowNo = 0.0001
												else
													SET @TmpVolumeRowNo = @TmpVolumeRowNo -1	  									    
												
											END	  
									END
							END

						IF @ProcessID = 78
							BEGIN
								IF (Select  COUNT(VolumeRowNo)
									FROM  inv.tblStorageDocsDtl 	
									WHERE ProcessID IN (88) AND ProcessNo = @ProcessNo AND 
										  FiscalYear = @FiscalYear AND SerialNo  = @BaseSerialNo  ) > 0
									BEGIN
										Select @TmpVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
										FROM  inv.tblStorageDocsDtl 	
										WHERE ProcessID IN (78) AND  ProcessNo = @ProcessNo AND 
											  FiscalYear = @FiscalYear AND SerialNo  = @SerialNo
									
										IF @TmpVolumeRowNo = 0	
											BEGIN
												Select  @TmpVolumeRowNo = ISNULL(MIN(VolumeRowNo),0)
												FROM  inv.tblStorageDocsDtl 	
												WHERE ProcessID IN (88) AND ProcessNo = @ProcessNo AND 
													  FiscalYear = @FiscalYear AND SerialNo  = @BaseSerialNo
												if @TmpVolumeRowNo = 1
													set @TmpVolumeRowNo = 0.0001
												else
													SET @TmpVolumeRowNo = @TmpVolumeRowNo -1	  									    
												
											END	  
									END
							END		
							

						IF @TmpVolumeRowNo >0
							BEGIN
								SET @VolumeRowNo = @TmpVolumeRowNo 
							END
						ELSE IF @ProcessID = 50 OR @ProcessID = 55
							BEGIN
								
								Select @VolumeRowNo = ISNULL(MAX(VolumeRowNo),-1000000000)
								From inv.tblStorageDocsDtl
								Where DocDate = @DocDate AND ProcessID IN (50,55) AND VolumeRowNo < 0
	
								IF @VolumeRowNo = 0
									SET @VolumeRowNo = -1000000000
							END
						ELSE
							BEGIN
								Select TOP(1) @VolumeRowNo = VolumeRowNo
								From inv.tblStorageDocsDtl
								Where DocDate = @DocDate AND VolumeRowNo > 0
								Order By DocDate Desc, VolumeRowNo Desc
							END	

						IF @ProcessID = 72 OR @ProcessID = 73
							Set @VolumeRowNo = ISNULL(@VolumeRowNo,0) + 1000
							
						IF (@ProcessID = 70 OR @ProcessID = 78 OR @ProcessID = 82 OR @ProcessID = 83) AND @TmpVolumeRowNo >0							
							Set @VolumeRowNo = ISNULL(@VolumeRowNo,0) + 0.0001
						ELSE	
							Set @VolumeRowNo = ISNULL(@VolumeRowNo,0) + 1

						IF @EnterKind = 0 and @ProcessID=90
							SET @VolumeRowNo =0
						----- بروز رساني سطر جاري
						Update  inv.tblStorageDocsDtl
						Set VolumeRowNo = @VolumeRowNo ,LastUpdate=GETDATE()
						Where ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
							  FiscalYear = @FiscalYear AND SerialNo  = @SerialNo  AND RowNo = @RowNo

						If (@AllowStoreNegativeBalance = 0 OR @AllowStoreNegativeBalance = 'False') AND @EnterKind < 0
							BEGIN
								--	Calculate QtyRemain
								DECLARE @BeforeDateSum Decimal(28, 9)
								
								SELECT @BeforeDateSum = ISNULL (Sum(GoodsQuantity * EnterKind), 0)
								FROM inv.tblStorageDocsDtl
								WHERE StoreID = @StoreID AND GoodsID = @GoodsID AND BatchNo=@BatchNo AND UserPriceID=@UserPriceID AND (DocDate < @DocDate  OR (DocDate = @DocDate AND VolumeRowNo <= @VolumeRowNo) ) 
								 AND (FiscalYear = @FiscalYear OR (FiscalYear <> @FiscalYear AND EnterKind=1))


								 --IF @BeforeDateSum > @MinStoreBalance
								 --		SELECT @BeforeDateSum = ISNULL (Sum(GoodsQuantity * EnterKind), 0)
									--	FROM inv.tblStorageDocsDtl
									--	WHERE StoreID = @StoreID AND GoodsID = @GoodsID 
									--	  AND BatchNo=@BatchNo AND UserPriceID=@UserPriceID AND DocDate <= @DocDate  
									--	  AND (FiscalYear = @FiscalYear OR (FiscalYear <> @FiscalYear AND EnterKind=1))
										 

								--------------
								IF @BeforeDateSum < @MinStoreBalance
									
									SET @DocDateErr = @DocDate
									
								ELSE
								
									SELECT TOP 1 @DocDateErr = T.DocDate ,@BeforeDateSum=T.Balance
									FROM 
									(
										SELECT DM.DocDate, 
											   @BeforeDateSum +  SUM(GoodsQuantity * EnterKind)over (partition by StoreID,GoodsID,BatchNo,UserPriceID order by StoreID,GoodsID,DocDate,VolumeRowNo) Balance
										FROM  inv.tblStorageDocsDtl DM 
										WHERE DM.StoreID = @StoreID AND DM.GoodsID = @GoodsID AND 
										      BatchNo=@BatchNo AND UserPriceID=@UserPriceID AND (DM.DocDate > @DocDate OR (DM.DocDate = @DocDate AND VolumeRowNo > @VolumeRowNo ))
									) T 
									WHERE (T.Balance < @MinStoreBalance) 

								--------------
								IF @DocDateErr<>''
									BEGIN
										--ROlLBACK
										Close curStorageInsertDocs
										Deallocate curStorageInsertDocs
										IF @UserPriceID <> 0 AND  @BatchNo<>''
											SET @StrErr = '#$با افزودن کالای ' + @GoodsID +  ' به کد مصرف کننده ' + RTRIM(LTRIM(STR(@UserPriceID))) +  ' به کد بچ ' + @BatchNo +  ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
										ELSE IF @UserPriceID <> 0 
											SET @StrErr = '#$با افزودن کالای ' + @GoodsID +  ' به کد مصرف کننده ' + LTRIM(RTRIM(STR(@UserPriceID))) + ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
										ELSE IF @BatchNo<>''
											SET @StrErr = '#$با افزودن کالای ' + @GoodsID +  ' به کد بچ ' + @BatchNo +  ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
										ELSE
											SET @StrErr = '#$با افزودن کالای ' + @GoodsID + ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
										raiserror (@StrErr, 16, 1)
									END									
													
							END
						
						IF @ProcessID=120  -- انتقال داخلی
							Begin
								Declare @SettingValue NVarchar(10)
								
								IF @ProcessNo = 2
									SELECT @SettingValue=SettingValue 
									FROM pub.tblSettings 
									WHERE SettingKey='IsAutoTransfer2'
								ELSE
									SELECT @SettingValue=SettingValue 
									FROM pub.tblSettings 
									WHERE SettingKey='IsAutoTransfer'

								IF UPPER(@SettingValue) = 'TRUE' OR @SettingValue = '1'
									BEGIN
										Select * Into #InvInserted From Inserted;

										Update #InvInserted 
										Set ProcessID=125, StoreID=StoreID2, StoreID2=@StoreID, EnterKind=1, QtyRemain=0;
									
										Insert Into [inv].[tblStorageDocsDtl] Select * From #InvInserted
										
										Drop table #InvInserted;
										
										Set @ProcessID = 125
										Set @StoreID   = @StoreID2
										Set @EnterKind = 1

										Goto Update_Begin 
									END
									--print ''
							End

						ELSE IF @ProcessID=260 -- کارت به کالا
							Begin

								Select * Into #InvInserted2 From Inserted;

								declare @UnitID AS varchar(20)
								SET @UnitID = ''
   							    IF (select  UnitID from inv.tblGoods WHERE PartNumber = @UnitPart AND GoodsID = SUBSTRING(@GoodsID2,@str_Goods+1,@str_GoodsSum) ) <>  (select  UnitID from inv.tblGoods WHERE PartNumber = @UnitPart AND GoodsID = SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) )
									select  @UnitID = UnitID from inv.tblGoods WHERE PartNumber = @UnitPart AND GoodsID = SUBSTRING(@GoodsID2,@str_Goods+1,@str_GoodsSum) 

								IF @UnitID = ''
									Update #InvInserted2 
									Set ProcessID=265, GoodsID=@GoodsID2, GoodsID2=@GoodsID, StoreID=@StoreID2, StoreID2=@StoreID,BatchNo=@BatchNo2,BatchNo2=@BatchNo, UserPriceID=@UserPriceID2, UserPriceID2=@UserPriceID, EnterKind=1, QtyRemain=0					  ,VisitorPercent=@VirtualQuantity,VirtualQuantity=@VisitorPercent;
								ELSE
									Update #InvInserted2 
									Set ProcessID=265, GoodsID=@GoodsID2, GoodsID2=@GoodsID, StoreID=@StoreID2, StoreID2=@StoreID,BatchNo=@BatchNo2,BatchNo2=@BatchNo, UserPriceID=@UserPriceID2, UserPriceID2=@UserPriceID, SubUnitID=@UnitID, EnterKind=1, QtyRemain=0,VisitorPercent=@VirtualQuantity,VirtualQuantity=@VisitorPercent;
								
								Insert Into [inv].[tblStorageDocsDtl] Select * From #InvInserted2
								
								Drop table #InvInserted2;
								
								Set @ProcessID = 265
								Set @GoodsID   = @GoodsID2
								Set @StoreID   = @StoreID2
								Set @UserPriceID   = @UserPriceID2
								Set @EnterKind = 1

								Goto Update_Begin 

							End
				END

				----- Fetch next record
				FETCH NEXT FROM curStorageInsertDocs INTO	
					@StoreID, @StoreID2, @GoodsID, @GoodsID2, @DocDate, @GoodsQuantity, @EnterKind, 
					@ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @RowNo ,@SubUnitID,
					@BaseProcessID, @BaseProcessNo, @BaseFiscalYear, @BaseSerialNo, @BaseDocRowNo,@BatchNo,@BatchNo2,@UserPriceID,@UserPriceID2
					,@VisitorPercent,@VirtualQuantity


			END

		Close curStorageInsertDocs
		Deallocate curStorageInsertDocs

	END TRY

	Begin Catch
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)
		
	End Catch

END
GO
