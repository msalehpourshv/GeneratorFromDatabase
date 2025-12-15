USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [inv].[trgStorageDocsSerialsDelete]
   ON  [inv].[tblStorageDocsSerials] 
   WITH ENCRYPTION     
   AFTER DELETE
AS 

BEGIN
	Declare 
	  @ProcessID		Smallint    ,	
	  @ProcessNo		Tinyint		,
	  @FiscalYear		Smallint	,	
	  @SerialNo			Int			,
	  @RowNo			int			,
	  @DocRowNo			int			,
	  @AtomRowNo		int			
	  
	Begin TRY
			
		Declare curStorageDocs1 Cursor For 
		Select	ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,AtomRowNo
		From	Deleted

		Open curStorageDocs1

		FETCH NEXT FROM curStorageDocs1 INTO 
			@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@DocRowNo,@AtomRowNo

		WHILE @@FETCH_STATUS = 0
			BEGIN
							
				IF @ProcessID = 120
					BEGIN
						DELETE FROM [inv].[tblStorageDocsSerials] 
						WHERE ProcessID  = 125  AND 
							ProcessNo  = @ProcessNo  AND
							FiscalYear = @FiscalYear AND 
							SerialNo   = @SerialNo   AND 
							DocRowNo   = @DocRowNo AND
							AtomRowNo  = @AtomRowNo
					END

				ELSE IF @ProcessID = 260
					BEGIN
						DELETE FROM [inv].[tblStorageDocsSerials] 
						WHERE	ProcessID  = 265  AND 
								ProcessNo  = @ProcessNo  AND
								FiscalYear = @FiscalYear AND 
								SerialNo   = @SerialNo   AND 
								DocRowNo   = @DocRowNo AND
								AtomRowNo  = @AtomRowNo
					END
					
				FETCH NEXT FROM curStorageDocs1 INTO 
					@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@DocRowNo,@AtomRowNo
					
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
