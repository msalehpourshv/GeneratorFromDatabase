USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/11/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

CREATE  PROCEDURE [acc].[SpMissionPlacesInsertWithAcntCode]
	@AcntCode	varchar(50),
	@AcntName   Nvarchar(200)
	WITH ENCRYPTION
AS
BEGIN
	
delete from [emp].[tblMissionPlaces] where [MissionPlaceID]=@AcntCode

INSERT INTO [emp].[tblMissionPlaces] SELECT @AcntCode,'False',0,0,GETDATE()

INSERT INTO [emp].[tblMissionPlacesDtl] SELECT @AcntCode,1,@AcntName

END
GO
