USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [lyl].[funCustomerDefaultPrivilege](
	@CCNo	Varchar(20),
	@Date   Char(10)
)
RETURNS Float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	Declare @Result AS Float
	Declare @CustomerInfoID AS Varchar(20)
	
	Select @CustomerInfoID = CustomerInfoID
	From lyl.tblLoyalCardDtl
	Where LoyalCardNo = @CCNo
	
	SELECT TOP 1 @Result = ISNULL(DefaultPrivilege ,0)
	From lyl.tblCustomerInfo
	WHERE DefaultPrivilegeDate <= @Date And CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))
	Order By LEN(CustomerInfoID) Desc
 
	Return @Result
End   -- === E N D ===============================================
GO
