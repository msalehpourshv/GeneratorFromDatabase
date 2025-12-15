USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 89/05/05
-- Description:	
-- =============================================

Create PROCEDURE [sal].[spFrmVisitorsCustomersSave] 
 @VisitorAcntCode	Varchar(30),
 @SerialNo			int,
 @FromDate			varchar(10),
 @ToDate			varchar(10)
 
WITH ENCRYPTION
AS

BEGIN

	-----------------------------------------------------------------------------
	SELECT D.VisitorAcntCode,CustomerAcntCode,LocationID
	FROM sal.tblVisitorsCustomersDtl D
	INNER JOIN sal.tblVisitorsCustomersHdr H 
	ON D.VisitorAcntCode=H.VisitorAcntCode AND D.SerialNo=H.SerialNo
	WHERE CustomerAcntCode <>'' AND D.VisitorAcntCode <> @VisitorAcntCode  AND
		  CustomerAcntCode IN (SELECT CustomerAcntCode 
							 FROM sal.tblVisitorsCustomersDtl D
							 WHERE D.CustomerAcntCode <>'' AND 
							       D.VisitorAcntCode = @VisitorAcntCode AND 
								   D.SerialNo=@SerialNo 
							 )
   AND((FromDate<=@ToDate and ToDate>=@FromDate))

END
GO
