USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgDeduction1LastUpdate] 
   ON  prs.tblDeduction1
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BenefitID varchar(20)
	

	Declare curDeduction1LastUpdate Cursor For 
	Select BenefitID
	From Inserted

	Open curDeduction1LastUpdate

	FETCH NEXT FROM curDeduction1LastUpdate INTO	@BenefitID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblDeduction1
			SET LastUpdate = GETDATE()
			where BenefitID = @BenefitID
	        
				  
			FETCH NEXT FROM curDeduction1LastUpdate INTO	@BenefitID
		END
		
	Close curDeduction1LastUpdate
	Deallocate curDeduction1LastUpdate
    
END
GO
