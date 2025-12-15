USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [cnt].[trgContractTypeLastUpdate] 
   ON  cnt.tblContractType
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ContractTypeID varchar(20)
	

	Declare curContractTypeLastUpdate Cursor For 
	Select ContractTypeID
	From Inserted

	Open curContractTypeLastUpdate

	FETCH NEXT FROM curContractTypeLastUpdate INTO	@ContractTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE cnt.tblContractType
			SET LastUpdate = GETDATE()
			where ContractTypeID = @ContractTypeID
	        
				  
			FETCH NEXT FROM curContractTypeLastUpdate INTO	@ContractTypeID
		END
		
	Close curContractTypeLastUpdate
	Deallocate curContractTypeLastUpdate
    
END
GO
