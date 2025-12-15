USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER  [inv].[trgStorageDocsSerialsUpdate]
   ON  [inv].[tblStorageDocsSerials]
   WITH ENCRYPTION
   AFTER UPDATE
AS 

BEGIN
	--IF (SELECT top 1 CalculatingAmount FROM Inserted) = (SELECT top 1 CalculatingAmount FROM Deleted) 
		--BEGIN

			DECLARE 
			 @ProcessID			Smallint		,	@ProcessNo			Tinyint		,
			 @FiscalYear		Smallint		,	@SerialNo			Int			,
			 @NewDocRowNo		Int				,	@OldDocRowNo		Int			,
			 @NewAtomRowNo		Int				,	@OldAtomRowNo		Int			,
			 @NewContainerID	varchar(20)		,	@OldContainerID		varchar(20)	,
			 @NewContainerID2	varchar(20)		,	@OldContainerID2	varchar(20)	,
			 @NewContainerStoresID	varchar(20)	,	@OldContainerStoresID	varchar(20)	,
			 @NewContainerStoresID2	varchar(20)	,	@OldContainerStoresID2	varchar(20)	,
			 @OldVolumeRowNo	Int	,
			 @StoreID2		    VARCHAR(20)	,		
			 @ProductSerialID	int         ,   @ProductSerialID2	int,
			 @PSerialNo		VARCHAR(30)     ,	@PSerialNo2	VARCHAR(30)			
			
			BEGIN TRY
				
				DECLARE curStorageDocsSerialsInserted Cursor  For 
				SELECT	ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo,AtomRowNo,
						ContainerID,ContainerID2,ContainerStoresID,ContainerStoresID2,
			 		    isnull(ProductSerialID,''),isnull(ProductSerialID2,''),PSerialNo,PSerialNo2
				FROM	Inserted

				DECLARE curStorageDocsSerialsDeleted Cursor  For 
				SELECT	DocRowNo,AtomRowNo
				FROM	Deleted

				OPEN curStorageDocsSerialsInserted
				OPEN curStorageDocsSerialsDeleted
				
				FETCH NEXT FROM curStorageDocsSerialsInserted INTO	
					 @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @NewDocRowNo, @NewAtomRowNo,
					 @NewContainerID,@NewContainerID2,@NewContainerStoresID,@NewContainerStoresID2,
					 @ProductSerialID,@ProductSerialID2,@PSerialNo,@PSerialNo2
					
				WHILE @@FETCH_STATUS = 0
					BEGIN
						FETCH NEXT FROM curStorageDocsSerialsDeleted INTO	
							@OldDocRowNo,@OldAtomRowNo
	
						IF @ProcessID=120 
						BEGIN
							DECLARE @Result1 VARCHAR(4000);
							DECLARE @strSql NVARCHAR(4000)
							SET @Result1= ''
							
							EXEC [pub].[funCreateColumnsString] 
								@SchemaName='inv',
								@tableName='tblStorageDocsSerials',
								@ColumnsName='ProcessID'',''StoreID'',''ContainerID'',''ContainerID2'',''ContainerStoresID'',''ContainerStoresID2'',''EnterKind',
								@CompressTableName='N',
								@Result=@Result1 output
						
							SELECT * INTO #tblStorageDocsSerialsUpdate1 
							FROM Inserted
							WHERE ProcessID  = 120			AND 
								  ProcessNo  = @ProcessNo	AND 
								  FiscalYear = @FiscalYear	AND 
								  SerialNo   = @SerialNo	AND
								  DocRowNo      = @NewDocRowNo AND 
								  AtomRowNo      = @NewAtomRowNo 

							SELECT @StoreID2 = StoreID2 
							FROM inv.tblStorageDocsDtl 
							WHERE ProcessID = @ProcessID 
							  and ProcessNo=@ProcessNo
							  and FiscalYear=@FiscalYear
							  and SerialNo=@SerialNo
							  and DocRowNo=@NewDocRowNo

							SET @strSql = 
								N'UPDATE [inv].[tblStorageDocsSerials] 
								SET StoreID=''' + @StoreID2 + 
								''',ContainerID=''' + @NewContainerID2 + 
								''',ContainerID2=''' + @NewContainerID + 
								''',ContainerStoresID=''' + @NewContainerStoresID2 + 
								''',ContainerStoresID2=''' + @NewContainerStoresID + 
								''',' + @Result1 + '
								FROM [inv].[tblStorageDocsSerials] O 
								INNER JOIN #tblStorageDocsSerialsUpdate1 N
								ON    N.ProcessID  = 120 AND 
									  O.ProcessID  = 125 AND 
									  N.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
									  O.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
									  N.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
									  O.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
									  N.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
									  O.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
									  N.DocRowNo   = ' + CAST(@NewDocRowNo   AS VARCHAR(10)) + ' AND										  
									  O.DocRowNo   = ' + CAST(@OldDocRowNo   AS VARCHAR(10)) + ' AND										  
									  N.AtomRowNo  = ' + CAST(@NewAtomRowNo   AS VARCHAR(10)) + ' AND										  
									  O.AtomRowNo  = ' + CAST(@OldAtomRowNo   AS VARCHAR(10))
			
							EXEC sp_executesql @strSql

								IF (SELECT Count(*) FROM tempdb.sys.tables WHERE name LIKE '#tblStorageDocsSerialsUpdate1%') > 0 
									DROP TABLE #tblStorageDocsSerialsUpdate1
										
						END -- IF @ProcessID=120 
							
						--========================================================================================================================
						ELSE IF  @ProcessID=260
						
							BEGIN
							
								DECLARE @strSql2 NVARCHAR(4000)
								DECLARE @Result2 VARCHAR(4000);
								SET @Result2= ''
								
								EXEC [pub].[funCreateColumnsString] 
									@SchemaName='inv',
									@tableName='tblStorageDocsSerials',
									@ColumnsName='ProcessID'',''EnterKind'',''ProductSerialID'',''ProductSerialID2'',''ContainerStoresID'',''ContainerStoresID2'',''PSerialNo'',''PSerialNo2',
									@CompressTableName='N',
									@Result=@Result2 output
								
								 
								SELECT * INTO #tblStorageDocsSerialsUpdate2 
								FROM Inserted
								WHERE ProcessID  = 260			AND 
									  ProcessNo  = @ProcessNo	AND 
									  FiscalYear = @FiscalYear	AND 
									  SerialNo   = @SerialNo	AND
									  DocRowNo		 = @NewDocRowNo AND
									  AtomRowNo		 = @NewAtomRowNo
						
								SET @strSql2 = 
									N'UPDATE [inv].[tblStorageDocsSerials] 
									SET PSerialNo=''' + @PSerialNo2 + ''',PSerialNo2=''' + @PSerialNo + ''',
									    ProductSerialID='''+  str(@ProductSerialID2 ) + ''' ,
										ProductSerialID2='''+  str(@ProductSerialID ) + ''' ,
										ContainerStoresID='''+  @NewContainerStoresID2  + ''' ,
										ContainerStoresID2='''+  @NewContainerStoresID  + ''' , ' 
										+ @Result2 + '
									FROM [inv].[tblStorageDocsSerials] O 
									INNER JOIN #tblStorageDocsSerialsUpdate2 N
									ON    N.ProcessID  = 260 AND 
										  O.ProcessID  = 265 AND 
										  N.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
										  O.ProcessNo  = ' + CAST(@ProcessNo  AS VARCHAR(10)) + ' AND 
										  N.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
										  O.FiscalYear = ' + CAST(@FiscalYear AS VARCHAR(4 )) + ' AND 
										  N.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
										  O.SerialNo   = ' + CAST(@SerialNo   AS VARCHAR(10)) + ' AND 
										  N.DocRowNo   = ' + CAST(@NewDocRowNo   AS VARCHAR(10)) + ' AND										  
										  O.DocRowNo   = ' + CAST(@OldDocRowNo   AS VARCHAR(10)) + ' AND										  
										  N.AtomRowNo  = ' + CAST(@NewAtomRowNo   AS VARCHAR(10)) + ' AND										  
										  O.AtomRowNo  = ' + CAST(@OldAtomRowNo   AS VARCHAR(10))

								EXEC sp_executesql @strSql2

								IF (SELECT Count(*) FROM tempdb.sys.tables WHERE name LIKE '#tblStorageDocsSerialsUpdate2%') > 0 
								   DROP TABLE #tblStorageDocsSerialsUpdate2
								   
							END

						--========================================================================================================================
						FETCH NEXT FROM curStorageDocsSerialsInserted INTO	
							 @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @NewDocRowNo, @NewAtomRowNo,@NewContainerID,@NewContainerID2,@NewContainerStoresID,@NewContainerStoresID2,
							 @ProductSerialID,@ProductSerialID2,@PSerialNo,@PSerialNo2

					END -- WHILE 

				CLOSE curStorageDocsSerialsInserted
				Deallocate curStorageDocsSerialsInserted

				CLOSE curStorageDocsSerialsDeleted
				Deallocate curStorageDocsSerialsDeleted
			
			END TRY

			BEGIN Catch
				DECLARE @StrErrorMessage As NVARCHAR(1024)
				SET @StrErrorMessage = ERROR_MESSAGE() 
				RAISERROR (@StrErrorMessage, 16, 1)
			END Catch
--		END
END
GO
