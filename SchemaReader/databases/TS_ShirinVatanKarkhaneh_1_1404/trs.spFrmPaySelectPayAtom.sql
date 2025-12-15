USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date:(1386/07/18)
-- ==============================================
Create PROCEDURE [trs].[spFrmPaySelectPayAtom]
	@ProcessID   tinyint,
	@ProcessNO   tinyint,
	@FiscalYear  smallint,
	@SerialNo    int,
	@LanguageID  tinyint
WITH ENCRYPTION
AS

BEGIN


SELECT *, pub.GetCodeName(AtomAcntCode, @LanguageID) AS AtomAcntName , rtrim(ltrim( str(VolumeFiscalYearAtm)))+'/'+rtrim(ltrim( str(VolumeRowNoAtm))) FSVOL
,(select top 1 ChequeNo from trs.tblPayDtl where VolumeFiscalYear=VolumeFiscalYearAtm and VolumeRowNo=VolumeRowNoAtm) ChequeNo
FROM trs.tblPayAtm 
WHERE ProcessID =@ProcessID AND 
      ProcessNo=@ProcessNO AND 
      FiscalYear=@FiscalYear AND 
      SerialNo=@SerialNo 


END 










GO
