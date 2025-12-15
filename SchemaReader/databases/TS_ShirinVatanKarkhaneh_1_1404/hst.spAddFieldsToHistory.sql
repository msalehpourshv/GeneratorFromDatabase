USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Pishadast
-- Create date   : 1397/03/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE procedure [hst].[spAddFieldsToHistory]
	@ProcessID	  	int,
	@ProcessNo    	int,
	@DocStep	   	int,
	@LanguageID    	int,
	@TableName     	varchar(200),
	@xml      		xml
	
WITH ENCRYPTION
AS

BEGIN

	DECLARE @FName nvarchar(200)
	DECLARE @FText nvarchar(200)
	DECLARE @TypeID INT 
	DECLARE @FieldID INT
	
	DECLARE curCursor Cursor  For 
	select x.Rec.query('./FiledName').value('.', 'nvarchar(2000)') N
		  ,x.Rec.query('./FiledText').value('.', 'nvarchar(2000)') T
	from @xml.nodes('DocumentElement/H') x(Rec) 

	OPEN curCursor
	
	FETCH NEXT FROM curCursor INTO	
		 @FName, @FText
		 
	WHILE @@FETCH_STATUS = 0
	BEGIN					 

		set @FieldID = 0
		SET @TypeID = NULL
		
		SELECT @TypeID = TypeID
		FROM pub.tblTypes
		WHERE  TypeName = @FName
	    
		IF (SELECT convert(char(10),GETDATE() ,20))<'2023-03-30'
			DELETE 	from hst.tblFields
			where ProcessID = @ProcessID  AND
				  ProcessNo = @ProcessNo AND
				  DocStep = @DocStep AND
				  FieldName = @FName AND
			      TableName=@TableName

		select @FieldID = ISNULL(FieldID,0)
		from hst.tblFields
		where ProcessID = @ProcessID  AND
			  ProcessNo = @ProcessNo AND
			  DocStep = @DocStep AND
			  FieldName = @FName AND
			  TableName=@TableName

			IF @FieldID = 0 OR @ProcessID = 1120
				BEGIN 
					SELECT @FieldID=ISNULL(MAX(FieldID),0) + 1 
					FROM hst.tblFields		
			        
					INSERT INTO hst.tblFields
					VALUES (@FieldID,@ProcessID, @ProcessNo, @DocStep,
							@FName,@LanguageID,@FText,@TableName,@TypeID);
				END 
			ELSE
				BEGIN
					IF NOT @TypeID IS NULL
						UPDATE hst.tblFields 
						SET TypeID=@TypeID
						WHERE FieldID=@FieldID AND TypeID IS NULL
				END   
		
		FETCH NEXT FROM curCursor INTO	@FName, @FText
		 
	END -- WHILE 

	CLOSE curCursor
	Deallocate curCursor
	
END
GO
