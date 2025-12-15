USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgLoanTypesLastUpdate] 
   ON  prs.tblLoanTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @LoanTypeID varchar(20)
	

	Declare curLoanTypesLastUpdate Cursor For 
	Select LoanTypeID
	From Inserted

	Open curLoanTypesLastUpdate

	FETCH NEXT FROM curLoanTypesLastUpdate INTO	@LoanTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblLoanTypes
			SET LastUpdate = GETDATE()
			where LoanTypeID = @LoanTypeID
	        
				  
			FETCH NEXT FROM curLoanTypesLastUpdate INTO	@LoanTypeID
		END
		
	Close curLoanTypesLastUpdate
	Deallocate curLoanTypesLastUpdate
    
END
GO
