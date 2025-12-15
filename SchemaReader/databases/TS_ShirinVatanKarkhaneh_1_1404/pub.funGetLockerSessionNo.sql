USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetLockerSessionNo] 
(
	@ProcessID		INT,
	@ProcessNo		TINYINT,
	@FiscalYear		SMALLINT,
	@SerialNo		INT,
	@CodeFieldValue VARCHAR(150),
	@TableName		Varchar(150)
	
)
RETURNS INT
WITH ENCRYPTION
AS

BEGIN

	DECLARE @SessionNo INT
	SET @SessionNo = 0

    SELECT @SessionNo  = SessionNo 
    FROM pub.tblLockedDocs 
    WHERE TableName=@TableName AND 
           SerialNo=@SerialNo AND 
           ProcessID = @ProcessID AND 
           ProcessNo=@ProcessNo AND 
           FiscalYear=@FiscalYear AND 
           CodeFieldValue=@CodeFieldValue
               
	RETURN  @SessionNo              
END                   
GO
