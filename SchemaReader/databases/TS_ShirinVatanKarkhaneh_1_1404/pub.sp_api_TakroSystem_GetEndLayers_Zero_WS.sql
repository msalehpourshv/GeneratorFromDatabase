USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Moayed
-- Create date   : 1402-12-14
-- Viewed By	 : 
-- Last Modified : 
-- Description   : لیست لایه ها
-- =============================================
CREATE PROCEDURE [pub].[sp_api_TakroSystem_GetEndLayers_Zero_WS]

-- @TableName='acc.tblAcnt'
@TableName as NVARCHAR(MAX)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	  
BEGIN TRY

	select case when [Layer9Name]<>'' THEN [Layer9Name] 
       ELSE case when [Layer8Name]<>'' THEN [Layer8Name] 
			ELSE case when [Layer7Name]<>'' THEN [Layer7Name] 	
				ELSE case when [Layer6Name]<>'' THEN [Layer6Name] 	
					ELSE case when [Layer5Name]<>'' THEN [Layer5Name] 	
						ELSE case when [Layer4Name]<>'' THEN [Layer4Name] 	
							ELSE case when [Layer3Name]<>'' THEN [Layer3Name] 	
								ELSE case when [Layer2Name]<>'' THEN [Layer2Name] 	
									ELSE case when [Layer1Name]<>'' THEN [Layer1Name] 	
			END 
			END 
			END 
			END 
			END 
			END 
			END 
			END 
			END PartName,PartNumber
	from [pub].[tblCodeLayerDtl]
	where [TableName] ='' + @TableName + ''  and LanguageID=1 and [Layer1Name] <> ''

	
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
