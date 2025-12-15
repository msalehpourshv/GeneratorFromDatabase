USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[sp_api_Brango_DiscountPolicy]
@GoodsId AS NVARCHAR(50),--='10',
@Skip As  NVARCHAR(50),--='0',
@MaxResultCount As  NVARCHAR(50),--='100',
@DateFrom As NVARCHAR(10),--='1400/10/05',
@DateTo AS NVARCHAR(10)--='1400/10/04'


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrQuery  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY

	SET @StrQuery= 'SELECT dD.GoodsID,dD.DiscountPercent,dH.FromDate,dH.ToDate from sal.tblDiscountPoliciesHdr dH
					LEFT JOIN sal.tblDiscountPoliciesDtl dD
					ON dH.ProcessID=dD.ProcessID
					AND dH.SerialNo=dD.SerialNo 
					Where  dH.ProcessID=''201''
				   '

	IF(@GoodsId<>'')
		SET @StrQuery=@StrQuery+' AND GoodsID='''+@GoodsId+''''

	IF(@DateFrom<>'')
		SET @StrQuery=@StrQuery+' AND dH.FromDate>='''+@DateFrom+''''

	IF(@DateTo<>'')
		SET @StrQuery=@StrQuery+' AND dH.ToDate>='''+@DateTo+''''


	SET @StrQuery=@StrQuery+' 
				   ORDER BY dD.GoodsID 
				   OFFSET ' +@Skip +' Rows 
				   FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	PRINT @StrQuery
	EXEC sp_executesql @StrQuery



 
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
