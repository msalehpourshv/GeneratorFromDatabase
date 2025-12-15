USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1404/07/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : �ѐ ����� ����
-- ==============================================
Create PROCEDURE pln.RptPln_DeclareUseGoods
	@ProcessID		Int = 630,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 1404,
	@SerialNo		Int = 1,
	@FiscalYear2	Int = 1404,
	@SerialNo2		Int = 1

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	set @StrSelect = '
	SELECT	D.*,H.DocDate, H.DocDesc, pub.funGetGoodsName(D.GoodsID,1) GoodsName, 
			G.ExtraField1, G.ExtraField2, G.ExtraField3, G.ExtraField4, G.ExtraField5,
			U.UnitName, V.UnitValue, V.MainUnitValue,inv.funGetUnitName(G.UnitID,1) UnitName2
			,pub.GetUserName(H.SessionNo) AS UserName, pub.GetUserName(H.SessionNo) AS UserName1
			,T.ProductID,pub.funGetGoodsName(T.ProductID,1) AS ProductName,T.BatchNo BatchNoTask,T.OrderCount,T.FormulaNo
			,H.BaseProcessID ,H.BaseProcessNo ,H.BaseFiscalYear ,H.BaseSerialNo 
	FROM pln.tblDeclareUseGoodsDtl D 
				INNER JOIN pln.tblDeclareUseGoodsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				Left JOIN pln.tblTaskOrderHdr T ON H.BaseProcessID = T.ProcessID AND H.BaseProcessNo = T.ProcessNo AND H.BaseFiscalYear = T.FiscalYear AND H.BaseSerialNo = T.SerialNo
				LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = 1
				LEFT JOIN inv.tblGoods	  G ON G.GoodsID = D.GoodsID 
				LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.SubUnitID=D.SubUnitID
	WHERE 	D.ProcessID = ' + str(@ProcessID) + '
			AND D.ProcessNo = ' + str(@ProcessNo) + '
			AND	D.FiscalYear >= ' + str(@FiscalYear) + '
			AND D.SerialNo >= ' + str(@SerialNo) + '
			AND	D.FiscalYear <= ' + str(@FiscalYear) + '
			AND D.SerialNo <= ' + str(@SerialNo2) + '
	ORDER BY DocRowNo'
	------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
