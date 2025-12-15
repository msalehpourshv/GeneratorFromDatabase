USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[funRecivableRemainForTabletAppSum] 
(
	@CuurentDate AS CHAR(10),
	@StartTargetLayer tinyint,
	@LenTargetLayer TINYINT,
	@CreditCode AS VARCHAR(20)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN
	
	DECLARE @Remain  FLOAT
	
	SELECT @Remain=ISNULL(SUM(d.Amount),0)--,substring(d.CreditCode,@StartTargetLayer,@LenTargetLayer)
	FROM trs.tblPayDtl  d INNER JOIN
		(
			SELECT VolumeFiscalYear,e.VolumeRowNo
			FROM trs.tblPayDtl e
			
			WHERE   e.ProcessID in(1,10) AND e.PayTypeID IN (6,26)
		EXCEPT
			SELECT VolumeFiscalYear,dd.VolumeRowNo
			FROM trs.tblPayDtl dd
			WHERE   dd.ProcessID  IN (12,22,13,24,18) AND dd.PayTypeID IN (6,26)
		EXCEPT
			SELECT cc.VolumeFiscalYear,cc.VolumeRowNo
			FROM trs.tblPayDtl cc
			WHERE   cc.ProcessID  IN (2) AND cc.PayTypeID IN (6,26) AND cc.ChequeDate < @CuurentDate
			
		) a ON  a.VolumeFiscalYear=d.VolumeFiscalYear AND a.VolumeRowNo=d.VolumeRowNo
	WHERE d.EventNo=1 AND d.PayTypeID IN (6,26) 
		and substring(d.CreditCode,@StartTargetLayer,@LenTargetLayer)=@CreditCode
	GROUP BY d.CreditCode
	ORDER BY substring(d.CreditCode,@StartTargetLayer,@LenTargetLayer)

RETURN @Remain

END
GO
