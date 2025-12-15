USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [acc].[trgAcntInsert] 
   ON  [acc].[tblAcnt]
   WITH ENCRYPTION
   AFTER INSERT
AS 

Begin
	
	DECLARE @AcntCode varchar(20)
	Declare @InsertDate  char(10)
	SELECT  @InsertDate = pub.funChangeDate_GergorianToPersian(getdate())
	
	Declare curAcnt Cursor For 
	Select AcntCode
	From Inserted

	Open curAcnt

	FETCH NEXT FROM curAcnt INTO	@AcntCode


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE [acc].[tblAcnt]
			SET InsertDate = @InsertDate
			where AcntCode = @AcntCode
				  
			FETCH NEXT FROM curAcnt INTO	@AcntCode
		END
		
		
	Close curAcnt
	Deallocate curAcnt
    
END
GO
