USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [inv].[trgStorageDocsHdrDelete]
   ON  [inv].[tblStorageDocsHdr] 
   WITH ENCRYPTION     
   AFTER DELETE
AS 

BEGIN
	Declare 
	  @ProcessID		Smallint    ,	
	  @ProcessNo		Tinyint		,
	  @FiscalYear		Smallint	,	
	  @SerialNo			Int				
	  
	Begin TRY
			
		Declare curStorageDocs1 Cursor For 
		Select	ProcessID,ProcessNo,FiscalYear,SerialNo
		From	Deleted

		Open curStorageDocs1

		FETCH NEXT FROM curStorageDocs1 INTO 
			@ProcessID,@ProcessNo,@FiscalYear,@SerialNo

		WHILE @@FETCH_STATUS = 0
			BEGIN
							
				--IF @ProcessID = 120
				--	BEGIN
				--		DELETE FROM [inv].[tblStorageDocsAtom] 
				--		WHERE ProcessID  = 125  AND 
				--			ProcessNo  = @ProcessNo  AND
				--			FiscalYear = @FiscalYear AND 
				--			SerialNo   = @SerialNo   
							
				--		DELETE FROM [inv].[tblStorageDocsHdr] 
				--		WHERE ProcessID  = 125  AND 
				--			ProcessNo  = @ProcessNo  AND
				--			FiscalYear = @FiscalYear AND 
				--			SerialNo   = @SerialNo   
				--	END

				--ELSE 
				IF @ProcessID = 260
					BEGIN
						DELETE FROM [inv].[tblStorageDocsAtom] 
						WHERE ProcessID  = 265  AND 
							ProcessNo  = @ProcessNo  AND
							FiscalYear = @FiscalYear AND 
							SerialNo   = @SerialNo 
							
						DELETE FROM [inv].[tblStorageDocsHdr] 
						WHERE	ProcessID  = 265  AND 
								ProcessNo  = @ProcessNo  AND
								FiscalYear = @FiscalYear AND 
								SerialNo   = @SerialNo  
					END
					
				FETCH NEXT FROM curStorageDocs1 INTO 
					@ProcessID,@ProcessNo,@FiscalYear,@SerialNo
					
			END


		Close curStorageDocs1
		Deallocate curStorageDocs1

	End TRY

	Begin Catch
		Declare @strErrorMessage As Nvarchar(1024)
		Set @strErrorMessage = ERROR_MESSAGE() 
		raiserror (@strErrorMessage, 16, 1)
	
	End Catch

END
GO
