USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 87/06/28
-- Description:	
-- =============================================
CREATE TRIGGER [inv].[trgStorageDocsHdrInsert] 
   ON  [inv].[tblStorageDocsHdr] 
   WITH ENCRYPTION
   AFTER INSERT
AS 

Begin

	Declare 
	 @NewStoreID		VarChar(20) ,
	 @NewStoreID2		VarChar(20) ,
	 @ProcessID			Smallint,		
	 @ProcessNo			Smallint,		
	 @FiscalYear		int,		
	 @SerialNo			int		

	Begin TRY

		Declare curStorageInsertDocs Cursor  For 
		Select	StoreID, StoreID2,ProcessID,ProcessNo,FiscalYear,SerialNo
		From Inserted

		Open curStorageInsertDocs

		FETCH NEXT FROM curStorageInsertDocs INTO	
			@NewStoreID, @NewStoreID2, @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

		WHILE @@FETCH_STATUS = 0
			BEGIN

				UPDATE [inv].[tblStorageDocsHdr] 
				SET CreateTime = GETDATE() 
				WHERE ProcessID = @ProcessID
				  AND ProcessNo = @ProcessNo
				  AND FiscalYear = @FiscalYear
				  AND SerialNo = @SerialNo

				IF @ProcessID=90 OR @ProcessID=100
					UPDATE [inv].[tblStorageDocsHdr] 
					SET DocTime = convert(varchar(8),GETDATE(),108)
					WHERE ProcessID = @ProcessID
					  AND ProcessNo = @ProcessNo
					  AND FiscalYear = @FiscalYear
					  AND SerialNo = @SerialNo
					----------------------------------
				IF @ProcessID=120
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
							
								Update #InvInserted Set ProcessID=125, StoreID=StoreID2, StoreID2=@NewStoreID;
							
								Insert Into [inv].[tblStorageDocsHdr] Select * From  #InvInserted
								
								Drop table #InvInserted;
							END
					End
					
				ELSE IF @ProcessID=260
					Begin

						Select * Into #InvInserted2 From Inserted;
					
						Update #InvInserted2 Set ProcessID=265;
					
						Insert Into [inv].[tblStorageDocsHdr] Select * From  #InvInserted2
						
						Drop table #InvInserted2;

					End
				----- Fetch next record
				FETCH NEXT FROM curStorageInsertDocs INTO	
					@NewStoreID, @NewStoreID2, @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

			END

		Close curStorageInsertDocs
		Deallocate curStorageInsertDocs

	END TRY

	Begin Catch

		Declare @strErrorMessage As Nvarchar(1024)
		Set @strErrorMessage = ERROR_MESSAGE() 
		raiserror (@strErrorMessage, 16, 1)
		
	End Catch

END
GO
