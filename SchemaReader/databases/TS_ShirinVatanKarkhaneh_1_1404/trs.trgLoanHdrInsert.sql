USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [trs].[trgLoanHdrInsert] 
   ON  [trs].[tblLoanHdr]
   WITH ENCRYPTION
   AFTER INSERT
AS 

Begin
	
	Declare 
	 @ProcessID			Smallint,		
	 @ProcessNo			Smallint,		
	 @FiscalYear		int,		
	 @SerialNo			int		

	Begin TRY

		Declare curLoanHdr Cursor  For 
		Select	ProcessID,ProcessNo,FiscalYear,SerialNo
		From Inserted

		Open curLoanHdr

		FETCH NEXT FROM curLoanHdr INTO	
			@ProcessID,@ProcessNo,@FiscalYear,@SerialNo

		WHILE @@FETCH_STATUS = 0
			BEGIN

				UPDATE  [trs].[tblLoanHdr] 
				SET [CreateTime]= GETDATE() 
				WHERE ProcessID = @ProcessID
				  AND ProcessNo = @ProcessNo
				  AND FiscalYear = @FiscalYear
				  AND SerialNo = @SerialNo

				  				----- Fetch next record
				FETCH NEXT FROM curLoanHdr INTO	
					 @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

		    END
		Close curLoanHdr
		Deallocate curLoanHdr

	END TRY

	Begin Catch

		Declare @strErrorMessage As Nvarchar(1024)
		Set @strErrorMessage = ERROR_MESSAGE() 
		raiserror (@strErrorMessage, 16, 1)
		
	End Catch
    
END
GO
