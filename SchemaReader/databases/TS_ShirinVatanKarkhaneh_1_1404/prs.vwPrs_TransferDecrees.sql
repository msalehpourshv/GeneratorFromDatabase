USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/06/13
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Decrees Transfer Docs
-- ==============================================
CREATE VIEW [prs].[vwPrs_TransferDecrees]
WITH ENCRYPTION
AS
	select DH.*
	from prs.tblDecreeHdr DH
		inner join 
		(
			select PersonnelID, Max(SerialNo) SerialNo
			from prs.tblDecreeHdr
			group by PersonnelID
		) M on M.PersonnelID = DH.PersonnelID and M.SerialNo = DH.SerialNo
	where DecreeTypeID in (select DecreeTypeID from prs.tblDecreeTypes where Payable = 1)
GO
