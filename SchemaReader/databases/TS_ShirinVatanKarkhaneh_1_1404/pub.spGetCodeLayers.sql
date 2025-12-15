USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MM
-- =============================================
CREATE PROCEDURE [pub].[spGetCodeLayers]
(
	@TableName  VarChar(50),
	@LanguageID tinyint,
	@PartNumber tinyint
)
WITH ENCRYPTION
AS

BEGIN
	SET NOCOUNT ON;

	SELECT Hdr.TableName ,
		   Layer1,Layer2,Layer3,Layer4,Layer5,Layer6,Layer7,Layer8,Layer9,
		   Dtl.Layer1Name,Dtl.Layer2Name,Dtl.Layer3Name,Dtl.Layer4Name,Dtl.Layer5Name,
		   Dtl.Layer6Name,Dtl.Layer7Name,Dtl.Layer8Name,Dtl.Layer9Name,
		   Hdr.PartNumber

	FROM pub.tblCodeLayer AS Hdr , pub.tblCodeLayerDtl AS Dtl 

    WHERE Hdr.TableName  = @TableName   AND 
		  Hdr.PartNumber = @PartNumber  AND 
	      Dtl.TableName  = @TableName   AND 
	      Dtl.PartNumber = @PartNumber  AND 
		  Dtl.LanguageID = @LanguageID  

END

GO
