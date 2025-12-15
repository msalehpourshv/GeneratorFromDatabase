USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgBenefits1LastUpdate] 
   ON  prs.tblBenefits1
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BenefitID varchar(20)
	

	Declare curBenefits1LastUpdate Cursor For 
	Select BenefitID
	From Inserted

	Open curBenefits1LastUpdate

	FETCH NEXT FROM curBenefits1LastUpdate INTO	@BenefitID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblBenefits1
			SET LastUpdate = GETDATE()
			where BenefitID = @BenefitID
	        
				  
			FETCH NEXT FROM curBenefits1LastUpdate INTO	@BenefitID
		END
		
	Close curBenefits1LastUpdate
	Deallocate curBenefits1LastUpdate
    
END
GO
