USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trs].[trgOurBanksLastUpdate] 
   ON  trs.tblOurBanks
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BankCode varchar(20)
	

	Declare curOurBanksLastUpdate Cursor For 
	Select BankCode
	From Inserted

	Open curOurBanksLastUpdate

	FETCH NEXT FROM curOurBanksLastUpdate INTO	@BankCode


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trs.tblOurBanks
			SET LastUpdate = GETDATE()
			where BankCode = @BankCode
	        
				  
			FETCH NEXT FROM curOurBanksLastUpdate INTO	@BankCode
		END
		
	Close curOurBanksLastUpdate
	Deallocate curOurBanksLastUpdate
    
END
GO
