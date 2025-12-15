USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/06/30
-- Viewed By	 : 
-- Last Modified : 1390/07/28
-- Last Modifier : TakroSystem\Zia
-- Description	 : مرخصی
-- =============================================
CREATE PROCEDURE [emp].[RptEmp_VacationRet]
	@BaseProcessID	int,
	@BaseSerialNo	int
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
BEGIN

	SET NOCOUNT ON;


	-- Init Variables --------

	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(1=1)'
	SET @StrWhere = @StrWhere + ' AND (H.BaseProcessID = ' + LTrim(Str(@BaseProcessID)) + ')'
	SET @StrWhere = @StrWhere + ' AND (H.BaseSerialNo = ' + LTrim(Str(@BaseSerialNo)) + ')'
	---------------------------------------------------------------------------

	SET @StrSelect = '
	SELECT	D.*, 
			CASE WHEN D.ProcessID in (351,353,355) THEN 0 else D.Interval end As DurationDays, 
			CASE WHEN D.ProcessID in (351,353,355) THEN D.Interval else 0 end As DurationMins 
	FROM	emp.tblVacationDtl D 
				inner join emp.tblVacationHdr H on H.ProcessID=D.ProcessID and H.SerialNo=D.SerialNo
	WHERE ' + @StrWhere

	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
