USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : HamidReza Soltani
-- Create date   : 1389/08/11
-- Viewed By	 : 
-- Last Modified : 1389/11/10
-- Last Modifier : Zia
-- Description   : برگ کنترل کیفی
-- =============================================
CREATE PROCEDURE [qty].[RptQty_QCDoc]
	@ProcessID		Int = 710,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null
WITH ENCRYPTION

AS
Begin


	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	Select D.*, H.DocDate, H.DocTime, H.DocType, H.ProductID, H.ProductSerialID, H.Signer1ID,
		H.Signer2ID, H.Signer3ID, H.Signer4ID, G.GoodsName, PS1.ProduceStepName as CurProduceStepName,
		PS2.ProduceStepName as RefProduceStepName, F.FaultName, P.AcntCode, P.DocDate As RetDate, 
		pub.GetCodeName(P.AcntCode, 1) As AcntName, G1.GoodsName As ProductName, 
		P1.FirstName + ' ' + P1.LastName as Signer1Name, P2.FirstName + ' ' + P2.LastName as Signer2Name,
		P3.FirstName + ' ' + P3.LastName as Signer3Name,
		P4.FirstName + ' ' + P4.LastName as Signer4Name, pub.funGetTypeText(21, DocType, 1) as DocTypeName,
		H.IsDecomposed, DP.DepartmentName
	From qty.tblQCDocsDtl D
		Inner Join qty.tblQCDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
		Left Join pln.tblItemRelations R ON R.ProcessID = H.ProcessID AND R.ProcessNo = H.ProcessNo AND R.FiscalYear = H.FiscalYear AND R.SerialNo = H.SerialNo
		Left Join inv.tblGoodsDtl G1 ON G1.GoodsID = H.ProductID
		Left Join qty.tblRetProdsHdr P ON P.ProcessID = R.BaseProcessID AND P.ProcessNo = R.BaseProcessNo AND P.FiscalYear = R.BaseFiscalYear AND P.SerialNo = R.BaseSerialNo 
		Left Join inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID 
		Left Join pln.tblProduceStepDtl PS1 ON PS1.ProductID = D.GoodsID and PS1.SerialNo = D.CurProdStepSerialNo And PS1.ProduceStepID = D.CurProduceStepID
		Left Join pln.tblProduceStepDtl PS2 ON PS2.ProductID = D.GoodsID and PS2.SerialNo = D.RefProdStepSerialNo And PS2.ProduceStepID = D.RefProduceStepID
		Left Join pln.tblFaults F On F.FaultID = D.FaultID
		Left Join prs.tblPersonnelsDtl P1 ON P1.PersonnelID = H.Signer1ID 
		Left Join prs.tblPersonnelsDtl P2 ON P2.PersonnelID = H.Signer2ID 
		Left Join prs.tblPersonnelsDtl P3 ON P3.PersonnelID = H.Signer3ID 
		Left Join prs.tblPersonnelsDtl P4 ON P4.PersonnelID = H.Signer4ID 
		Left Join prs.tblDepartmentsDtl DP ON DP.DepartmentID = D.DepartmentID
	Where D.ProcessID = @ProcessID And D.ProcessNo = @ProcessNo
		And D.FiscalYear >= @FiscalYear And D.SerialNo >= @SerialNo
		And D.FiscalYear <= @FiscalYearTo And D.SerialNo <= @SerialNoTo

End
GO
