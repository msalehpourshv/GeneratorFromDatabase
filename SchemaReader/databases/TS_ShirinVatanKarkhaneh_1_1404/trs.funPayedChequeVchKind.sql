USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_ArmanGholdasht_1_1396
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 1400/03/09
-- Description:	
-- نوع سند چک پرداختنی یادداشت هست یا نه
-- =============================================
Create FUNCTION [trs].[funPayedChequeVchKind] 
(	@VolumeFiscalYear AS Int, 
	@VolumeRowNo AS Int 
)
RETURNS INT
WITH ENCRYPTION
AS
BEGIN
	Declare @Result AS INT

	SELECT @Result=COUNT(VchKind) 
	FROM acc.tblVoucherDtl a
	INNER JOIN (
		SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,VchNo 
		FROM trs.tblPayHdr H
		INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo 
					FROM trs.tblPayDtl
					WHERE PayTypeID in (8,18,28) AND
						  VolumeFiscalYear=@VolumeFiscalYear
					AND   VolumeRowNo=@VolumeRowNo
					) D
		ON H.ProcessID=D.ProcessID
		AND H.ProcessNo=D.ProcessNo
		AND H.FiscalYear=D.FiscalYear
		AND H.SerialNo=D.SerialNo
				) b
	on a.SourceProcessID=b.ProcessID
	AND a.SourceProcessNo=b.ProcessNo
	AND a.SourceFiscalYear=b.FiscalYear
	AND a.SourceSerialNo=b.SerialNo
	WHERE a.VchKind=0

	RETURN @Result
END
GO
