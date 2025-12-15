USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Pishadast
-- Create date   : 1388/05/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [hst].[SpRegisterHistoryDtl]
	@ProcessID			int,
	@ProcessNo		    int,
	@DocStep		    int,
	@FieldName	        varchar(50), 
	@LanguageID	        tinyint, 
	@FieldText	        nvarchar(50),
    @HistoryID	        bigint,   
    @OldValue	        nvarchar(500),
    @NewValue	        nvarchar(500),	
    @TableName	        nvarchar(500)	
	WITH ENCRYPTION
AS
	
BEGIN ------------------------------------------------------------------------

	SET NOCOUNT ON;
	
	DECLARE @TypeID INT 
	DECLARE @FieldID INT
	 
	set @FieldID = 0
	SET @TypeID = NULL
	
	SELECT @TypeID = TypeID
    FROM pub.tblTypes
    WHERE  TypeName = @FieldName
    
	select @FieldID = ISNULL(FieldID,0)
	from hst.tblFields
	where ProcessID = @ProcessID  AND
		  ProcessNo = @ProcessNo AND
		  DocStep = @DocStep AND
		  FieldName = @FieldName AND
		  TableName=@TableName

    IF @FieldID = 0 OR @ProcessID = 1120
		BEGIN 
			SELECT @FieldID=ISNULL(MAX(FieldID),0) + 1 
			FROM hst.tblFields		
	        
			INSERT INTO hst.tblFields
			   (FieldID, ProcessID, ProcessNo, DocStep, FieldName, LanguageID, FieldText, TableName, TypeID)
		VALUES (@FieldID,@ProcessID, @ProcessNo, @DocStep,@FieldName,@LanguageID,@FieldText,@TableName,@TypeID);
		END 
    ELSE
		BEGIN
			IF NOT @TypeID IS NULL
				UPDATE hst.tblFields 
				SET TypeID=@TypeID
				WHERE FieldID=@FieldID AND TypeID IS NULL
		END   
   
    INSERT INTO hst.tblHistoryFields
    VALUES (@HistoryID,@FieldID, @OldValue, @NewValue);
	
END
GO
