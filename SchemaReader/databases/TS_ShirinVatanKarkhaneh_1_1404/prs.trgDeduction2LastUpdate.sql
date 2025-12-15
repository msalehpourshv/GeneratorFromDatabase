USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgDeduction2LastUpdate] 
   ON  prs.tblDeduction2
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BenefitID varchar(20)
	

	Declare curDeduction2LastUpdate Cursor For 
	Select BenefitID
	From Inserted

	Open curDeduction2LastUpdate

	FETCH NEXT FROM curDeduction2LastUpdate INTO	@BenefitID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblDeduction2
			SET LastUpdate = GETDATE()
			where BenefitID = @BenefitID
	        
				  
			FETCH NEXT FROM curDeduction2LastUpdate INTO	@BenefitID
		END
		
	Close curDeduction2LastUpdate
	Deallocate curDeduction2LastUpdate
    
END
GO
