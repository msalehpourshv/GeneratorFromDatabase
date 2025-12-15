USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE acc.sp_api_AsmanRasa_IsCreatePayment
@OrderID AS NVARCHAR(50),
@CheckAcnt as int



WITH ENCRYPTION
 AS
BEGIN
DECLARE @Result as int 
DECLARE @StrErrorMessage As Nvarchar(1024)

BEGIN TRY

	IF(@CheckAcnt=1)
	BEGIN
		IF(SELECT count (*) FROM acc.tblVoucherDtl WHERE  SourceCodeFieldValue=@OrderID)>0  
			set @Result =0 
		ELSE
			set @Result = 1 
	END	

	ELSE
	BEGIN
		IF(SELECT count (*) FROM acc.tblVoucherDtl WHERE  SourceCodeFieldValue=@OrderID+'_Deb' OR SourceCodeFieldValue=@OrderID+'_Cre')>0  
			set @Result = 0 
		ELSE
			set @Result = 1
	END	

	-- if(@Result=0)
	-- begin
		-- IF(select count (*) FROM acc.tblVoucherDtl WHERE 
		-- pub.funSplitString( SourceCodeFieldValue,'_',1)=pub.funSplitString( @OrderID,'_',1) AND 
		-- ISNULL(pub.funSplitString( SourceCodeFieldValue,'_',3),'')=12 AND 
		-- (Debit=  @Amount or Credit=@Amount))>0
			-- SET @Result=1
	-- end
	if(@OrderID ='158106_76365')
	 set @Result =0
	 
	select @Result as IsCreate
	


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
