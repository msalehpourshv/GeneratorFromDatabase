USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : HamidReza Soltani
-- Create date   : 1389/08/18
-- Viewed By	 : 
-- Last Modified : 1386/08/09
-- Description: برگ کالاهای مرجوعی
-- =============================================
Create PROCEDURE [qty].[RptQty_RetProdDoc]

	@ProcessID		Int = 710,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null
WITH ENCRYPTION

AS
BEGIN

	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	SELECT H.*,
		   D.RowNo,
		   D.DocRowNo,
		   D.ProductSerialID,
		   D.GoodsID,
		   IsNull((SELECT STUFF (
						  (SELECT IsNull(CAST(FI.FaultID as NVarChar),'') + ' / '
						  FROM qty.tblRetProdsDtl DD
						  LEFT JOIN pln.tblFaultItems FI ON 
						 	DD.ProcessID = FI.ProcessID AND 
						  	DD.ProcessNo = FI.ProcessNo AND 
						  	DD.FiscalYear = FI.FiscalYear AND 
						  	DD.SerialNo = FI.SerialNo AND 
						  	DD.DocRowNo = FI.DocRowNo
						  WHERE DD.SerialNo = D.SerialNo
						  GROUP BY DD.SerialNo, FI.FaultID
						  FOR XML PATH(''),TYPE).value('.','NVARCHAR(MAX)'),1,0,'')),'') as ReasonID,
		   D.ItemDesc,
		   D.[Count],
		   G.GoodsName,
		   IsNull((SELECT STUFF (
						  (SELECT IsNull(F.FaultName,'') + ' / '
						  FROM qty.tblRetProdsDtl DD
						  LEFT JOIN pln.tblFaultItems FI ON 
						 	DD.ProcessID = FI.ProcessID AND 
						  	DD.ProcessNo = FI.ProcessNo AND 
						  	DD.FiscalYear = FI.FiscalYear AND 
						  	DD.SerialNo = FI.SerialNo AND 
						  	DD.DocRowNo = FI.DocRowNo
						  LEFT JOIN pln.tblFaults F ON F.FaultID = FI.FaultID
						  WHERE DD.SerialNo = D.SerialNo
						  GROUP BY DD.SerialNo, F.FaultName
						  FOR XML PATH(''),TYPE).value('.','NVARCHAR(MAX)'),1,0,'')),'') as Reason,
		   T.TransporterName,
		   V.FirstName + ' ' + V.LastName As DriverName,
		   DP.DepartmentName,
		   L.LocationName,
		   PS.SerialPrefix,
		   PS.SerialNo As GoodsSerialNo,
		   pub.GetCodeName(H.AcntCode ,1) As AcntName,
		   P1.FirstName + ' ' + P1.LastName as Signer1Name,
		   P2.FirstName + ' ' + P2.LastName as Signer2Name,
		   P3.FirstName + ' ' + P3.LastName as Signer3Name,
		   P4.FirstName + ' ' + P4.LastName as Signer4Name
	FROM qty.tblRetProdsDtl D
		INNER JOIN qty.tblRetProdsHdr H ON H.ProcessID = D.ProcessID 
									   AND H.ProcessNo = D.ProcessNo 
									   AND H.FiscalYear = D.FiscalYear 
									   AND H.SerialNo = D.SerialNo 
		LEFT JOIN pub.tblLocationsDtl L ON L.LocationID = H.LocationID
		LEFT JOIN prs.tblDepartmentsDtl DP ON DP.DepartmentID = H.DepartmentID
	    LEFT JOIN pub.tblDriversDtl V ON V.DriverID = H.DriverID
		LEFT JOIN sal.tblTransportersDtl T ON T.TransporterID = H.TransporterID
		LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID 
		LEFT JOIN pln.tblProductSerials PS ON PS.ProductSerialID = D.ProductSerialID
		LEFT JOIN prs.tblPersonnelsDtl P1 ON P1.PersonnelID = H.Signer1ID 
		LEFT JOIN prs.tblPersonnelsDtl P2 ON P2.PersonnelID = H.Signer2ID 
		LEFT JOIN prs.tblPersonnelsDtl P3 ON P3.PersonnelID = H.Signer3ID 
		LEFT JOIN prs.tblPersonnelsDtl P4 ON P4.PersonnelID = H.Signer4ID 
	WHERE D.ProcessID = @ProcessID 
	  AND D.ProcessNo = @ProcessNo
	  AND D.FiscalYear >= @FiscalYear 
	  AND D.SerialNo >= @SerialNo
	  AND D.FiscalYear <= @FiscalYearTo 
	  AND D.SerialNo <= @SerialNoTo

END

GO
