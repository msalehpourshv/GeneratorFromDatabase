USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : چاپ فاکتورهای فروش بصورت گروه بندی شده
-- Dependencies  : [sal].[RptSal_Invoices] (These reports must return the same columns)
-- ==============================================
-- << This Report Is Not Used >>
-- ==============================================
CREATE PROCEDURE [sal].[RptSal_Invoices_Grouped]
	@ProcessNo		TinyInt = Null,
	@FiscalYearFrom	SmallInt = Null,
	@SerialNoFrom	SmallInt = Null,
	@FiscalYearTo	SmallInt = Null,
	@SerialNoTo		SmallInt = Null,
	@DateFrom		Char(10) = Null,
	@DateTo			Char(10) = Null,
	@AcntCode		VarChar(20) = Null,
	@ShowHeader		Bit = 1,
	@ShowEcCodeC	Bit = 0,
	@ShowEcCodeS	Bit = 0,
	@ShowRemain		Bit = 0,
	@ShowFooter		Bit = 0,
	@ShowIvcCode	Bit = 0,
	@ShowDiscount	Bit = 0,
	@ShowQuantity	Bit = 0,
	@RowsCount		TinyInt = 1 -- if 0 then no empty rows
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @LanguageID TinyInt;
DECLARE @BaseDate	NVarChar(10);
DECLARE @StrFields 	NVarChar(4000);
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------------------------
	IF (@ProcessNo Is Null) 
		SET @ProcessNo = 1;

	SELECT @LanguageID = pub.funGetCurrentLanguageID();

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	----------------------------------------------------------------------------------------------

	-- W H E R E ---------------------------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID = 90 AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@FiscalYearFrom	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFrom)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFrom)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DateFrom Is Not Null) OR (@DateTo Is Not Null)
		If (@DateFrom = @DateTo)
			SET @StrWhere = @StrWhere + ' AND D.DocDate  = ''' + @DateFrom + ''''
		Else 
		Begin
			If (@DateFrom Is Not Null)
				SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DateFrom + ''''
			If @DateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DateTo + ''''
		End

	If (@AcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AcntCode = ''' + @AcntCode + ''''

	-------------------------------------------------------------------------------------------
	SET @StrFrom = ' inv.tblStorageDocsDtl D INNER JOIN inv.tblStorageDocsHdr H 
				ON (H.ProcessID = D.ProcessID) AND (H.ProcessNo = D.ProcessNo) AND (H.FiscalYear = D.FiscalYear) AND (H.SerialNo = D.SerialNo)
			OUTER APPLY [acc].[funGetCodeInfo](D.AcntCode) AS F '
	-------------------------------------------------------------------------------------------

	SET @StrFields = ' D.DocDate, D.StoreID, D.StoreID2, ''' + @BaseDate + ''' AS CurrDate, D.VirtualQuantity, H.TaxOverWorthCost,
					   D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName,
					   IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, H.TransportationCost, H.TaxCost,
					   D.AcntCode, F.AcntName AS AcntName, F.EconomicalCode, Cast('''' AS NVarChar(2000)) AS Address1, Cast('''' AS NVarChar(2000)) AS Address2, 
					   H.Discount + H.Discount2+ H.Discount3 AS Discount, [pub].[funFarsiDateDiff](''Day'', ''' + @BaseDate + ''', D.DocDate) AS DateDuration, 
					   Cast('''' AS VarChar(50)) AS Tel, D.GoodsQuantity, D.GoodsPrice, D.AtomAmount AS OverloadAmount, H.DocDesc, 
					   Cast('''' AS NVarChar(2000)) AS DescDtl, H.VisitorAcntCode,	[pub].[GetCodeName](H.VisitorAcntCode, ' + Ltrim(Str(@LanguageID)) + ') VisitorAcntName,
					   D.AgreeNo, D.SubUnitID, 0 AS SubUnitQuantity, inv.funGetUnitQuantity(D.GoodsID, D.SubUnitID) AS SubQuantity, H.OtherCostAcntCode, H.OtherIncomeAcntCode, H.OtherCost, H.OtherIncome  '

	If (@ShowRemain = 1)
		SET @StrFields = @StrFields + ',
			(
				SELECT	IsNull(Sum(Debit - Credit), 0) Debit 
				FROM	acc.tblVoucherDtl VD INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = VD.SerialNo
				WHERE   (VH.DocRegisterState > 0) AND (VD.AcntCode = H.AcntCode) AND 
						(
							(VD.DocDate < H.DocDate) OR 
							(
								(VD.DocDate = H.DocDate) AND 
								(VD.SourceProcessID = 90) AND 
								(VD.SourceProcessNo = D.ProcessNo) AND 
								(VD.SourceFiscalYear = D.FiscalYear) AND 
								(VD.SourceSerialNo < D.SerialNo)
							)
						)
			) AS DebitRemain'
		Else
			SET @StrFields = @StrFields + ', 0 AS DebitRemain '
	-------------------------------------------------------------------------------------------

	-- S E L E C T ----------------------------------------------------------------------------

	DECLARE @Row Int;
	DECLARE @MaxRowNo Int;
	DECLARE @MinRowNo Int;
	DECLARE @FiscalYear SmallInt;
	DECLARE @SerialNo Int;

	SET @StrSelect = N'
	SELECT	D.FiscalYear FY, D.SerialNo SN, D.DocRowNo RN, ' + @StrFields + '
	INTO	#tblAll
	FROM	' + @StrFrom + '
	WHERE	' + @StrWhere + '

		CREATE TABLE #tblGroups
		(
			GD_ID	VarChar(20) COLLATE Arabic_CS_AS,
			GR_ID	VarChar(20) COLLATE Arabic_CS_AS,
			GR_Name NVarChar(50) COLLATE Arabic_CS_AS
		)
		
		INSERT INTO #tblGroups
		SELECT	GD.GoodsID, G.GoodsGroupID, G.GoodsGroupName
		FROM	inv.tblGoodsGroupsDtl G
					INNER JOIN inv.tblGoodsGroupsGoodsListDtl GD ON G.GoodsGroupID = GD.GoodsGroupID 

		UPDATE	#tblAll 
		SET		RN = 0, GoodsID = 
				(
					SELECT	TOP 1 G.GR_ID 
					FROM	#tblGroups G
					WHERE   G.GD_ID = GoodsID
					ORDER BY G.GR_ID
				), GoodsName = 
				(
					SELECT	TOP 1 G.GR_Name 
					FROM	#tblGroups G
					WHERE   G.GD_ID = GoodsID
					ORDER BY G.GR_ID 
				)
		WHERE	(
					SELECT	TOP 1 G.GR_ID 
					FROM	#tblGroups G
					WHERE   G.GD_ID = GoodsID
					ORDER BY G.GR_ID 
				) IS NOT NULL

		SELECT *
		INTO #tblTemp
		FROM #tblAll 

		UPDATE	#tblAll 
		SET		GoodsQuantity = T.GoodsQuantity
		FROM	#tblAll A INNER JOIN 
				(
					SELECT	FY, SN, GoodsID, GoodsPrice, Sum(GoodsQuantity) GoodsQuantity
					FROM	#tblTemp 
					GROUP BY FY, SN, GoodsID, GoodsPrice
					HAVING	COUNT(GoodsID) >= 1
				) T ON  A.FY = T.FY AND A.SN = T.SN AND A.GoodsID = T.GoodsID AND A.GoodsPrice = T.GoodsPrice 

		-- dont remove DISTINCT keyword & extra fields   

		SELECT DISTINCT FY AS FiscalYear, SN AS SerialNo, 0 AS DocRowNo, *
		FROM #tblAll '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

End
GO
