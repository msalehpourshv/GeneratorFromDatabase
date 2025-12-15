USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/05
-- Viewed By	 : 
-- Last Modified : 1392/01/16
-- Description	 : Pay Transfer Docs
-- ----------------------------------------------
--  اسناد خزانه داری جهت انتقال
-- ==============================================
CREATE PROCEDURE [trs].[SpTransferDocsList]
	@ProcessIDCur	VarChar(50), -- Current ProcessID 
	@ProcessIDFin	VarChar(50), -- Final ProcessID 
	@ProcessNo		Char(1), 
	@PayTypeID		VarChar(50),
	@RepOptions		VarChar(20)
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @Conf char;
BEGIN

	SET NOCOUNT ON;
	
	SET @Conf = Substring(@RepOptions, 1, 1);

	SET @StrSelect = '(T.ProcessNo=' + @ProcessNo + ' AND PAY.ProcessNo=' + @ProcessNo + ')'
	
	if @Conf = '1'
		SET @StrSelect = @StrSelect + ' AND (T.IsConfirmed1>0)'
	if @Conf = '0'
		SET @StrSelect = @StrSelect + ' AND (T.IsConfirmed1=0)'
	
	IF @ProcessIDFin LIKE '%17%'
		SET @ProcessIDFin = @ProcessIDFin + ',13,18,24'
	/* ========= Create Sub String Query Section =============== */
	SET @StrSelect = '	
	SELECT	DISTINCT PAY.*
	FROM	trs.tblPayDtl AS PAY INNER JOIN
	(
		SELECT	PD2.*,VOL.IsConfirmed1
		FROM	trs.tblPayDtl AS PD2
				INNER JOIN 
				(
					SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS MaxEventNo,SUM(case when IsConfirmed = ''True'' THEN 1 ELSE 0 END ) IsConfirmed1
					FROM	trs.tblPayDtl AS PD1
					WHERE	PD1.ProcessNo = ' + @ProcessNo + ' AND PD1.PayTypeID IN (' + @PayTypeID + ')
					GROUP BY VolumeFiscalYear, VolumeRowNo
				 ) VOL ON PD2.VolumeFiscalYear = VOL.VolumeFiscalYear AND PD2.VolumeRowNo = VOL.VolumeRowNo AND PD2.EventNo = VOL.MaxEventNo AND PD2.PayTypeID IN (' + @PayTypeID + ')
		WHERE	(PD2.ProcessNo = ' + @ProcessNo + ') AND (PD2.ProcessID IN (' + @ProcessIDFin + '))
	)  T ON T.VolumeFiscalYear = PAY.VolumeFiscalYear AND T.VolumeRowNo = PAY.VolumeRowNo AND PAY.PayTypeID IN (' + @PayTypeID + ') 
	WHERE ' + @StrSelect

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

End
GO
