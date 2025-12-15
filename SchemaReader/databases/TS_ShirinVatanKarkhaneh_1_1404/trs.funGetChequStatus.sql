USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [trs].[funGetChequStatus] 
(
	@LastProcessID AS INT
	
)
RETURNS NVARCHAR(100)
WITH ENCRYPTION
AS

BEGIN
	
	DECLARE @Name  NVARCHAR(100)
	SET @Name  =''
	
    IF @LastProcessID IN (1, 10, 17, 23, 40)
        SET @Name ='موجود در صندوق'
    
    IF @LastProcessID= 12
         SET @Name = 'وصول چک' 
    IF @LastProcessID= 13
         SET @Name = 'برگشت در صندوق'
    IF @LastProcessID= 2
         SET @Name = 'واگذار شده به اشخاص' 
    IF @LastProcessID= 18
         SET @Name = 'برگشت شده به صاحب چک'
    IF @LastProcessID IN (20, 21)
         SET @Name = 'واگذار شده به بانک'
    IF @LastProcessID= 22
         SET @Name = 'وصول شده'
    IF @LastProcessID= 24
         SET @Name = 'برگشت شده به صاحب چک'
	
	RETURN @Name


 END 


    
    
GO
