USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/09/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpRegisterLastSortDate]
    @Date	Char(10)
WITH ENCRYPTION
AS
BEGIN
	IF (SELECT COUNT(*) 
		FROM pub.tblSettings
		WHERE SettingKey='LastSortDate')=0
		BEGIN
			INSERT INTO pub.tblSettings 
			(SettingKey, SettingValue, SettingDesc, Parent, SortOrder, Visible)
			VALUES(	'LastSortDate',@Date,'','',1,0)
		END
	ELSE
		BEGIN
			UPDATE pub.tblSettings
			SET SettingValue=@Date
			WHERE SettingKey='LastSortDate'		
		END	
END
GO
