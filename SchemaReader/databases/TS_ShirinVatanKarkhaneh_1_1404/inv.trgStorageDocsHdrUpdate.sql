USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create Date: 87/06/28
-- Modified Date: 
-- Description:	
-- =============================================
Create TRIGGER  [inv].[trgStorageDocsHdrUpdate]
      ON  [inv].[tblStorageDocsHdr]
   WITH ENCRYPTION
   AFTER UPDATE
AS 

BEGIN

Declare 
@NewStoreID		Varchar(20)	,
@NewStoreID2	Varchar(20)	,
@ProcessID		Smallint    ,	
@ProcessNo		Tinyint		,
@FiscalYear		Smallint	,
@SerialNo		Int			,
@OldSerialNo	Int			,
@NewDocStep		Tinyint		,
@OldDocStep		Tinyint		,
@DoingSort		bit		

SET @DoingSort = 'False'

SELECT  @DoingSort=SettingValue 
FROM pub.tblSettings 
WHERE SettingKey='DoingSort'

Declare curStorageDocsInserted Cursor  For 
Select	StoreID, StoreID2,ProcessID,ProcessNo,FiscalYear,SerialNo,DocStep
From	Inserted

Declare curStorageDocsDeleted Cursor  For 
Select	DocStep,SerialNo
From	Deleted

Open curStorageDocsInserted
Open curStorageDocsDeleted

FETCH NEXT FROM curStorageDocsInserted INTO	
	 @NewStoreID, @NewStoreID2,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@NewDocStep

WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @ProcessID=120
			Begin
				----- ���� ��� ��� ����� 
				FETCH NEXT FROM curStorageDocsDeleted INTO	@OldDocStep,@OldSerialNo

				Declare @SettingValue NVarchar(10)
				declare @Result1 Varchar(MAX);
				DECLARE @strSql NVarchar(MAX)
				
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
						
						SET @Result1= ''
						IF @DoingSort = 'False'
						BEGIN
								exec [pub].[funCreateColumnsString] @SchemaName='inv',@tableName='tblStorageDocsHdr',
												@ColumnsName='StoreID'',''StoreID2'',''ProcessID',
												@CompressTableName='A',@Result=@Result1 output
												   
								SELECT * INTO #tblStorageDocsHdrUpdate0 FROM Inserted
								Where	ProcessID  = 120 AND 
										ProcessNo  = @ProcessNo AND 
										FiscalYear = @FiscalYear AND 
										SerialNo   = @SerialNo 

								SET @strSql = N'UPDATE [inv].[tblStorageDocsHdr] 
												SET StoreID=''' + @NewStoreID2 + ''',StoreID2=''' + @NewStoreID + ''',' + @Result1 + '
												FROM [inv].[tblStorageDocsHdr] B INNER JOIN #tblStorageDocsHdrUpdate0 A
												ON    A.ProcessNo  = B.ProcessNo   AND 
													  A.FiscalYear = B.FiscalYear  AND 
													  A.SerialNo   = B.SerialNo   AND 
													  A.ProcessID  = 120 AND 
													  B.ProcessID  = 125 AND 
													  B.ProcessNo  = ' + CAST(@ProcessNo as Varchar(10)) + ' AND 
													  B.FiscalYear = ' + CAST(@FiscalYear as Varchar(4)) + ' AND 
													  B.SerialNo   = ' + CAST(@SerialNo as Varchar(10))
							Exec sp_executesql @strSql

							IF (Select Count(*) From tempdb.sys.tables Where name LIKE '#tblStorageDocsHdrUpdate0%') > 0 
								DROP TABLE #tblStorageDocsHdrUpdate0
						END	
						ELSE
						BEGIN
							exec [pub].[funCreateColumnsString] @SchemaName='inv',@tableName='tblStorageDocsHdr',
											@ColumnsName='StoreID'',''StoreID2'',''SerialNo'',''ProcessID',
											@CompressTableName='A',@Result=@Result1 output
												   
							SELECT * INTO #tblStorageDocsHdrUpdate1 FROM Inserted
							Where	ProcessID  = 120 AND 
									ProcessNo  = @ProcessNo AND 
									FiscalYear = @FiscalYear AND 
									SerialNo   = @SerialNo 

							SET @strSql = N'UPDATE [inv].[tblStorageDocsHdr] 
											SET SerialNo=' + STR(@SerialNo) + ',StoreID=''' + @NewStoreID2 + ''',StoreID2=''' + @NewStoreID + '''
											FROM [inv].[tblStorageDocsHdr] B INNER JOIN #tblStorageDocsHdrUpdate1 A
											ON    A.ProcessNo  = B.ProcessNo   AND 
												  A.FiscalYear = B.FiscalYear  AND 
												  A.SerialNo   =' + CAST(@SerialNo as Varchar(10)) +' AND 
												  A.ProcessID  = 120 AND 
												  B.ProcessID  = 125 AND 
												  B.ProcessNo  = ' + CAST(@ProcessNo as Varchar(10)) + ' AND 
												  B.FiscalYear = ' + CAST(@FiscalYear as Varchar(4)) + ' AND 
												  B.SerialNo   = ' + CAST(@OldSerialNo as Varchar(10))
							Exec sp_executesql @strSql

							IF (Select Count(*) From tempdb.sys.tables Where name LIKE '#tblStorageDocsHdrUpdate1%') > 0 
								DROP TABLE #tblStorageDocsHdrUpdate1
						END
					
					
					END

				ELSE

					BEGIN
--						IF @NewDocStep=3 AND @OldDocStep=2
--							BEGIN	
--								Select * Into #InvInserted From [inv].[tblStorageDocsHdr] 
--								Where	ProcessID  = @ProcessID  AND ProcessNo = @ProcessNo AND 
--										FiscalYear = @FiscalYear AND SerialNo  = @SerialNo 
--					
--								Update #InvInserted Set ProcessID=125, StoreID=StoreID2, StoreID2=@NewStoreID;
--							
--								Insert Into [inv].[tblStorageDocsHdr] Select * From  #InvInserted
--								
--								Drop table #InvInserted;
--							END
--					
--						ELSE 
--						IF @NewDocStep=2 AND @OldDocStep=3
--							BEGIN
--								DELETE FROM inv.tblStorageDocsAtom
--								WHERE	ProcessID = 125 AND 
--										ProcessNo = @ProcessNo AND 
--										FiscalYear = @FiscalYear AND 
--										SerialNo = @SerialNo 
--
--								DELETE FROM inv.tblStorageDocsDtl 
--								WHERE	ProcessID = 125 AND 
--										ProcessNo = @ProcessNo AND 
--										FiscalYear = @FiscalYear AND 
--										SerialNo = @SerialNo 
--
--								DELETE FROM inv.tblStorageDocsHdr 
--								WHERE	ProcessID = 125 AND 
--										ProcessNo = @ProcessNo AND 
--										FiscalYear = @FiscalYear AND 
--										SerialNo = @SerialNo 
--							END
--
--						ELSE 
						IF @NewDocStep>=3 
							BEGIN
								SET @Result1= ''
								exec [pub].[funCreateColumnsString] @SchemaName='inv',@tableName='tblStorageDocsHdr',
												@ColumnsName='StoreID'',''StoreID2'',''ProcessID',
												@CompressTableName='A',@Result=@Result1 output
																		   
								SELECT * INTO #tblStorageDocsHdrUpdate125 FROM Inserted
								Where	ProcessID  = 120 AND 
										ProcessNo  = @ProcessNo AND 
										FiscalYear = @FiscalYear AND 
										SerialNo   = @SerialNo 

								SET @strSql = N'UPDATE [inv].[tblStorageDocsHdr] 
												SET StoreID=''' + @NewStoreID2 + ''',StoreID2=''' + @NewStoreID + ''',' + @Result1 + '
												FROM [inv].[tblStorageDocsHdr] B INNER JOIN #tblStorageDocsHdrUpdate125 A
												ON    A.ProcessNo  = B.ProcessNo   AND 
													  A.FiscalYear = B.FiscalYear  AND 
													  A.SerialNo   = B.SerialNo   AND 
													  A.ProcessID  = 120 AND 
													  B.ProcessID  = 125 AND 
													  B.ProcessNo  = ' + CAST(@ProcessNo as Varchar(10)) + ' AND 
													  B.FiscalYear = ' + CAST(@FiscalYear as Varchar(4)) + ' AND 
													  B.SerialNo   = ' + CAST(@SerialNo as Varchar(10))

								Exec sp_executesql @strSql

								IF (Select Count(*) From tempdb.sys.tables Where name LIKE '#tblStorageDocsHdrUpdate125%') > 0 
								   DROP TABLE #tblStorageDocsHdrUpdate125
								   
							END		
					END		
			End
			
		ELSE IF @ProcessID=260
			Begin

				DECLARE @strSql2 NVarchar(MAX)
				declare @Result2 Varchar(MAX);

				SET @Result2= ''

				exec [pub].[funCreateColumnsString] @SchemaName='inv',@tableName='tblStorageDocsHdr',
								@ColumnsName='ProcessID',
								@CompressTableName='A',@Result=@Result2 output
				 
				SELECT * INTO #tblStorageDocsHdrUpdate2 FROM Inserted
				Where	ProcessID  = 260 AND 
						ProcessNo  = @ProcessNo AND 
						FiscalYear = @FiscalYear AND 
						SerialNo   = @SerialNo 

				SET @strSql2 = N'UPDATE [inv].[tblStorageDocsHdr] 
							    SET ' + @Result2 + '
								FROM [inv].[tblStorageDocsHdr] B INNER JOIN #tblStorageDocsHdrUpdate2 A
							    ON    A.ProcessNo  = B.ProcessNo   AND 
								      A.FiscalYear = B.FiscalYear  AND 
								      A.SerialNo   = B.SerialNo   AND 
									  A.ProcessID  = 260 AND 
									  B.ProcessID  = 265 AND 
									  B.ProcessNo  = ' + CAST(@ProcessNo as Varchar(10)) + ' AND 
								      B.FiscalYear = ' + CAST(@FiscalYear as Varchar(4)) + ' AND 
								      B.SerialNo   = ' + CAST(@SerialNo as Varchar(10))

				Exec sp_executesql @strSql2
				
				IF (Select Count(*) From tempdb.sys.tables Where name LIKE '#tblStorageDocsHdrUpdate2%') > 0 
				   DROP TABLE #tblStorageDocsHdrUpdate2 

			End
		--========================================================================================================================
		FETCH NEXT FROM curStorageDocsInserted INTO	
			 @NewStoreID, @NewStoreID2,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@NewDocStep

	END -- WHILE 

Close curStorageDocsInserted
Deallocate curStorageDocsInserted

Close curStorageDocsDeleted
Deallocate curStorageDocsDeleted

END
GO
