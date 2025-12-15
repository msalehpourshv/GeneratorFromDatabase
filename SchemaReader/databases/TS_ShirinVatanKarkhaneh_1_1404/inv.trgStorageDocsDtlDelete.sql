USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [inv].[trgStorageDocsDtlDelete]
   ON  [inv].[tblStorageDocsDtl] 
   WITH ENCRYPTION     
   AFTER DELETE
AS 

BEGIN
	Declare 
	  @DocDate			Char(10)	,
	  @DocDateErr		Char(10)	,
	  @GoodsID			VarChar(20)	,
	  @GoodsID2			VarChar(20)	,
	  @StoreID			VarChar(20)	,
	  @StoreID2			VarChar(20)	,
	  @BatchNo			NVarChar(20),
	  @VolumeRowNo		FLOAT		,
	  @GoodsQuantity	Decimal(28,9),
	  @EnterKind		SmallInt	,
	  @ProcessID		Smallint    ,	
	  @ProcessNo		Tinyint		,
	  @FiscalYear		Smallint	,	
	  @SerialNo			Int			,
	  @RowNo			int			,
	  @UserPriceID		Int,
	  @AllowStoreNegativeBalance	Bit,
	  @ChangeLastUpdateInGoodsList	Bit
	  
	Begin TRY
		
		SET @ChangeLastUpdateInGoodsList = 0
		
		SELECT @ChangeLastUpdateInGoodsList = SettingValue from pub.tblSettings where SettingKey = 'ChangeLastUpdateInGoodsList'
		
		Set @AllowStoreNegativeBalance = 0
		
		SELECT @AllowStoreNegativeBalance = SettingValue
		FROM   pub.tblSettings
		Where  SettingKey = N'AllowStoreNegativeBalance'

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
				
		Declare curStorageDocs Cursor For 
		Select	ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,GoodsID, DocDate, VolumeRowNo, 
				GoodsQuantity, EnterKind, StoreID, StoreID2,GoodsID2,BatchNo,UserPriceID
		From	Deleted

		Open curStorageDocs

		FETCH NEXT FROM curStorageDocs INTO 
			@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo,@GoodsID, @DocDate, @VolumeRowNo, 
			@GoodsQuantity, @EnterKind, @StoreID, @StoreID2,@GoodsID2,@BatchNo,@UserPriceID

		WHILE @@FETCH_STATUS = 0
			BEGIN
							
			IF (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart AND IsService='True' ) = 0
				BEGIN
								
		Delete_Begin:
		
				SET @DocDateErr = ''
				IF @ChangeLastUpdateInGoodsList = 1
					update inv.tblGoods SET LastUpdate = GETDATE() WHERE GoodsID = @GoodsID
				IF  @AllowStoreNegativeBalance <> 'True' AND @EnterKind > 0
				BEGIN

					--	Calculate QtyRemain
					DECLARE @BeforeDateSum Decimal(28, 9)
					
					SELECT @BeforeDateSum = ISNULL (Sum(GoodsQuantity * EnterKind), 0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID = @StoreID AND GoodsID = @GoodsID AND 
						   BatchNo=@BatchNo AND UserPriceID=@UserPriceID AND	
						  (DocDate < @DocDate OR (DocDate = @DocDate AND VolumeRowNo < @VolumeRowNo))

					SELECT TOP 1 @DocDateErr = T.DocDate ,@BeforeDateSum = Balance
					FROM 
					(
						SELECT DM.DocDate, 
						       @BeforeDateSum + SUM(GoodsQuantity * EnterKind)over (partition by StoreID,GoodsID,BatchNo,UserPriceID order by StoreID,GoodsID,DocDate,VolumeRowNo) Balance
						FROM  inv.tblStorageDocsDtl DM 
						WHERE DM.StoreID = @StoreID AND DM.GoodsID = @GoodsID AND 
							  DM.BatchNo=@BatchNo AND DM.UserPriceID=@UserPriceID AND	
						     (DM.DocDate > @DocDate OR (DM.DocDate = @DocDate AND DM.VolumeRowNo > @VolumeRowNo))
											
					) T 
						
					WHERE (T.Balance < -0.0001) 

					IF @DocDateErr<>''
						BEGIN
							--ROlLBACK
							Close curStorageDocs
							Deallocate curStorageDocs
							DECLARE @StrErr NVARCHAR(4000)
							IF @UserPriceID <> 0 AND  @BatchNo<>''
								SET @StrErr = '#$با حذف کالای ' + @GoodsID +  ' به کد مصرف کننده ' + RTRIM(LTRIM(STR(@UserPriceID))) +  ' به کد بچ ' + @BatchNo +  ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
							ELSE IF @UserPriceID <> 0 
								SET @StrErr = '#$با حذف کالای ' + @GoodsID +  ' به کد مصرف کننده ' + RTRIM(LTRIM(STR(@UserPriceID))) + ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
							ELSE IF @BatchNo<>''
								SET @StrErr = '#$با حذف کالای ' + @GoodsID +  ' به کد بچ ' + @BatchNo +  ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
							ELSE
								SET @StrErr = '#$با حذف کالای ' + @GoodsID + ' به تاریخ ' + @DocDateErr + ' در انبار ' + @StoreID + 'کارت کالا به مقدار ' + ltrim(str(@BeforeDateSum,20,4)) + '  منفی میشود #$'
							raiserror (@StrErr, 16, 1)
						END
				END
					
				IF @ProcessID = 120
					BEGIN
						SET @VolumeRowNo = -1
						
						SELECT @VolumeRowNo = VolumeRowNo
						FROM [inv].[tblStorageDocsDtl] 
						WHERE ProcessID  = 125  AND 
							  ProcessNo  = @ProcessNo  AND
							  FiscalYear = @FiscalYear AND 
							  SerialNo   = @SerialNo   AND 
							  RowNo      = @RowNo
						
						If (@VolumeRowNo <> -1)
						BEGIN
							DELETE FROM [inv].[tblStorageDocsDtl] 
							WHERE ProcessID  = 125  AND 
								  ProcessNo  = @ProcessNo  AND
								  FiscalYear = @FiscalYear AND 
								  SerialNo   = @SerialNo   AND 
								  RowNo      = @RowNo
									
							Set @ProcessID = 125
							Set @StoreID   = @StoreID2
							Set @EnterKind = 1
									
							GOTO Delete_Begin
						END
					END

				ELSE IF @ProcessID = 260
					BEGIN
						DELETE FROM [inv].[tblStorageDocsDtl] 
						WHERE	ProcessID  = 265  AND 
								ProcessNo  = @ProcessNo  AND
								FiscalYear = @FiscalYear AND 
								SerialNo   = @SerialNo   AND 
								RowNo      = @RowNo
								
						SET @GoodsID = @GoodsID2
						Set @StoreID   = @StoreID2
						Set @EnterKind = 1
						SET @ProcessID = 265
								
						GOTO Delete_Begin
					END
					
			END
				FETCH NEXT FROM curStorageDocs INTO 
					@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo,@GoodsID, @DocDate, @VolumeRowNo, 
					@GoodsQuantity, @EnterKind, @StoreID, @StoreID2,@GoodsID2,@BatchNo,@UserPriceID

			END

		Close curStorageDocs
		Deallocate curStorageDocs

	End TRY

	Begin Catch
		Declare @strErrorMessage As Nvarchar(1024)
		Set @strErrorMessage = ERROR_MESSAGE() 
		raiserror (@strErrorMessage, 16, 1)
	
	End Catch

END
GO
