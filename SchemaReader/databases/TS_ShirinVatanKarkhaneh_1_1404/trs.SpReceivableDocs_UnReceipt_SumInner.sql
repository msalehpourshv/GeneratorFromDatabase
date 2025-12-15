USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 89/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [trs].[SpReceivableDocs_UnReceipt_SumInner] 
	@AcntCode	AS VarChar(20),
	@ProcessNo	AS TinyInt = 1,
	@DateFrom	AS Char(10),
	@StartTargetLayer tinyint,
	@LenTargetLayer tinyint
WITH ENCRYPTION
As
DECLARE @StrSelect	AS NVarChar(4000)
Begin

	
	SELECT	ISNull(Sum(PD.Amount), 0) SumValue
	FROM	[trs].[tblPayDtl] AS PD
			INNER JOIN 
			(
				SELECT VolumeFiscalYear, VolumeRowNo,CreditCode  Credit
				,(
					SELECT	 Max(EventNo)
					FROM	[trs].tblPayDtl AS b
					WHERE	b.PayTypeID IN (6, 26) AND b.ProcessNo = @ProcessNo AND a.VolumeFiscalYear=b.VolumeFiscalYear and a.VolumeRowNo=b.VolumeRowNo
					GROUP BY VolumeFiscalYear, VolumeRowNo
				)EventNo
				 FROM	trs.tblPayDtl a
				 WHERE	ProcessID IN (1,10) AND 
						PayTypeID IN (6,26) AND 
						SUBSTRING(CreditCode,@StartTargetLayer,@LenTargetLayer) =SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer)
			) VOL ON 
				PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
				PD.VolumeRowNo = VOL.VolumeRowNo AND 
				PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			PD.ProcessID = 2 AND
			PD.ProcessNo = @ProcessNo AND
			PD.ChequeDate > @DateFrom AND
			SUBSTRING(VOL.Credit,@StartTargetLayer,@LenTargetLayer) = SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer)

	exec sp_executesql @StrSelect;
End
GO
