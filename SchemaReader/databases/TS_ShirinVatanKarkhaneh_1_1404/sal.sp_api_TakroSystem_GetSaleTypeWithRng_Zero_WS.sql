USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Moayed
-- Create date   : 1402-12-13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : لیست  نوع  فروش براساس حیطه اینداستری
-- =============================================
CREATE PROCEDURE [sal].[sp_api_TakroSystem_GetSaleTypeWithRng_Zero_WS]

@Skip As NVARCHAR(50),
@MaxResultCount As NVARCHAR(50),
@Filter as NVARCHAR(50),
@UserID as NVARCHAR(50),
@IsAdmin as bit

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
BEGIN TRY

	set @strQuery=
	'
	SELECT d.SaleTypeID,d.SaleTypeName 
    From sal.tblSaleTypesDtl d 
    INNER JOIN sal.tblSaleTypes s ON s.SaleTypeID=d.SaleTypeID 
    Where d.LanguageID = 1 AND LTRIM(RTRIM(s.SaleTypeID)) <> '''' AND LTRIM(RTRIM(d.SaleTypeName))<>''''  

	'

	if @IsAdmin='False'
	begin
		set @strQuery = @strQuery +
		' 
			AND(  
			(Select COUNT(*) from sal.tblSaleTypesRng 
			where sal.tblSaleTypesRng.UserID =' + @UserID + ' And AllowCodeView = 1 And 
			Left(d.SaleTypeID, Len(d.SaleTypeID)) >= Left(sal.tblSaleTypesRng.FromCode, Len(d.SaleTypeID)) 
			And LEFT(d.SaleTypeID,LEN(d.SaleTypeID))<=LEFT(sal.tblSaleTypesRng.ToCode,LEN(d.SaleTypeID)) 
				)>0
			)
		'
	End
	
	if @Filter<>''
	begin
		set @strQuery = @strQuery+ ' AND( d.SaleTypeName like ''%' + @Filter + '%'' OR d.SaleTypeID LIKE ''%' + @Filter + '%'')'
	End

	
	SET @strQuery = @strQuery + ' 
		 ORDER BY d.SaleTypeName DESC
		 OFFSET ' + @Skip + ' Rows 
		 FETCH NEXT ' + @MaxResultCount + ' Rows ONLY '

	PRINT @strQuery
	EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
