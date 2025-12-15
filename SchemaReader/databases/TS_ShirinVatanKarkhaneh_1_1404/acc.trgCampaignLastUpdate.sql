USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgCampaignLastUpdate] 
   ON  acc.tblCampaign
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CampaignID varchar(20)
	

	Declare curCampaignLastUpdate Cursor For 
	Select CampaignID
	From Inserted

	Open curCampaignLastUpdate

	FETCH NEXT FROM curCampaignLastUpdate INTO	@CampaignID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblCampaign
			SET LastUpdate = GETDATE()
			where CampaignID = @CampaignID
	        
				  
			FETCH NEXT FROM curCampaignLastUpdate INTO	@CampaignID
		END
		
	Close curCampaignLastUpdate
	Deallocate curCampaignLastUpdate
    
END
GO
