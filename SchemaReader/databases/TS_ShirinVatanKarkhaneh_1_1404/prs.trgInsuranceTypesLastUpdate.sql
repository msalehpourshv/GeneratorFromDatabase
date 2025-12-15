USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgInsuranceTypesLastUpdate] 
   ON  prs.tblInsuranceTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @InsuranceTypeID varchar(20)
	

	Declare curInsuranceTypesLastUpdate Cursor For 
	Select InsuranceTypeID
	From Inserted

	Open curInsuranceTypesLastUpdate

	FETCH NEXT FROM curInsuranceTypesLastUpdate INTO	@InsuranceTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblInsuranceTypes
			SET LastUpdate = GETDATE()
			where InsuranceTypeID = @InsuranceTypeID
	        
				  
			FETCH NEXT FROM curInsuranceTypesLastUpdate INTO	@InsuranceTypeID
		END
		
	Close curInsuranceTypesLastUpdate
	Deallocate curInsuranceTypesLastUpdate
    
END
GO
