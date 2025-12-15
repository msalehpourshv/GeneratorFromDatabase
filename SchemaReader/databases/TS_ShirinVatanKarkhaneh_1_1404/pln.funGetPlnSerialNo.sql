USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--===================================
--Aoutor: HSR
--Date:1395/01/22
--===================================

CREATE FUNCTION [pln].[funGetPlnSerialNo]
 
(
	@ProductID	Char(20) ,
	@PSerialNo	varchar(30) 
)
RETURNS INT
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @SerialNo INT

	Set @SerialNo = 0

	SELECT @SerialNo = SerialNo
	From  pln.tblProductSerials
	Where ProductID = @ProductID AND  ProductSerialID =@PSerialNo

	-- Return the result of the function
	RETURN @SerialNo 

END
GO
