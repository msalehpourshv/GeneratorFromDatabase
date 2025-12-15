USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1402/04/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : ����� ���� ����� ������ ���
-- ==============================================
Create FUNCTION prs.funGetAccountNoWithBankType
(
	@PersonnelID	VarChar(20) ,
	@BankTypeID     VarChar(20) 
	
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @AccountNo NVarChar(50)

	Set @AccountNo = N'-'
	set @BankTypeID=isnull(@BankTypeID,'')

	SELECT @AccountNo = isnull(AccountNo , '-')
	From  prs.tblPersonnelAccountsDtl
	Where  PersonnelID = @PersonnelID AND ((@BankTypeID<>'' and  BankTypeID=@BankTypeID)  or (@BankTypeID='' and IsDefault = 1) )

	-- Return the result of the function
	RETURN @AccountNo 

END
GO
