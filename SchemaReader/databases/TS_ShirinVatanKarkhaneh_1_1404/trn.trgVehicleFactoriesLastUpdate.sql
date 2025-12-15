USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trn].[trgVehicleFactoriesLastUpdate] 
   ON  trn.tblVehicleFactories
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @FactoryID varchar(20)
	

	Declare curVehicleFactoriesLastUpdate Cursor For 
	Select FactoryID
	From Inserted

	Open curVehicleFactoriesLastUpdate

	FETCH NEXT FROM curVehicleFactoriesLastUpdate INTO	@FactoryID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trn.tblVehicleFactories
			SET LastUpdate = GETDATE()
			where FactoryID = @FactoryID
	        
				  
			FETCH NEXT FROM curVehicleFactoriesLastUpdate INTO	@FactoryID
		END
		
	Close curVehicleFactoriesLastUpdate
	Deallocate curVehicleFactoriesLastUpdate
    
END
GO
