USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [trs].[spRecivableRemainForTabletApp] 
(
  @CurentDate AS CHAR(10),
  @AcntPart AS INT
)
WITH ENCRYPTION
AS

BEGIN
	
	
	SELECT 	[pub].[funSplitString](
					(SELECT Top 1 CreditCode
					 FROM	trs.tblPayDtl
					 WHERE	ProcessID IN (1,10,20,31) AND 
							PayTypeID IN (6,16,26,31) AND 
							VolumeFiscalYear = d.VolumeFiscalYear AND 
							VolumeRowNo = d.VolumeRowNo
					 ORDER By EventNo ASC)
								,' ',@AcntPart)As ChequOwner,
	d.Amount,d.ChequeNo,d.ChequeDate,d.VolumeFiscalYear,d.VolumeRowNo,
	bd.BankTypeName,ld.LocationName,
	
	[trs].[funGetChequStatus](( 
		SELECT TOP 1 D2.ProcessID 
		FROM trs.tblPayDtl D2
		WHERE  (D2.PayTypeID In (6,26)) 
			AND D2.VolumeFiscalYear = LST.VolumeFiscalYear 
			AND D2.VolumeRowNo = LST.VolumeRowNo 
			AND D2.EventNo = LST.EventNo
	))AS LastStatus
	
	FROM trs.tblPayDtl  d INNER JOIN
		(
			SELECT VolumeFiscalYear,e.VolumeRowNo
			FROM trs.tblPayDtl e
			
			WHERE   e.ProcessID in(1,10) AND e.PayTypeID in (6,26)
		EXCEPT
			SELECT VolumeFiscalYear,dd.VolumeRowNo
			FROM trs.tblPayDtl dd
			WHERE   dd.ProcessID  IN (12,22,13,24,18) AND dd.PayTypeID IN (6,26)
	
		EXCEPT
			SELECT cc.VolumeFiscalYear,cc.VolumeRowNo
			FROM trs.tblPayDtl cc
			WHERE   cc.ProcessID  IN (2) AND cc.PayTypeID IN (6,26) AND cc.ChequeDate < @CurentDate
			
		) a ON  a.VolumeFiscalYear=d.VolumeFiscalYear AND a.VolumeRowNo=d.VolumeRowNo
			INNER JOIN trs.tblBankTypesDtl bd
			ON d.BankTypeID=bd.BankTypeID
			INNER JOIN pub.tblLocationsDtl ld
			ON d.LocationID=ld.LocationID 
			INNER JOIN trs.vwLastVolumeInfo_Receipt LST 
			ON a.VolumeFiscalYear = LST.VolumeFiscalYear AND a.VolumeRowNo = LST.VolumeRowNo
		
	WHERE d.EventNo=1 AND d.PayTypeID IN (6,26)


END

GO
