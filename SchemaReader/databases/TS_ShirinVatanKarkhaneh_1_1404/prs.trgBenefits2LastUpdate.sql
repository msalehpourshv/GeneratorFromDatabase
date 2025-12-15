USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgBenefits2LastUpdate] 
   ON  prs.tblBenefits2
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BenefitID varchar(20)
	

	Declare curBenefits2LastUpdate Cursor For 
	Select BenefitID
	From Inserted

	Open curBenefits2LastUpdate

	FETCH NEXT FROM curBenefits2LastUpdate INTO	@BenefitID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblBenefits2
			SET LastUpdate = GETDATE()
			where BenefitID = @BenefitID
	        
				  
			FETCH NEXT FROM curBenefits2LastUpdate INTO	@BenefitID
		END
		
	Close curBenefits2LastUpdate
	Deallocate curBenefits2LastUpdate
    
END
GO
