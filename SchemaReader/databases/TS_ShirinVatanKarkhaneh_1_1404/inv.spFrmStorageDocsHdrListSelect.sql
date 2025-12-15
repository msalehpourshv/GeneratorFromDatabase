USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/11/06
-- Description:	Control Receipt 
-- =============================================
Create PROCEDURE [inv].[spFrmStorageDocsHdrListSelect] 
	@ProcessID		Smallint,
	@ProcessNo		TinyInt,
	@DocDate		Char(10),
	@AcntCode		varchar(20),
	@StoreID		varchar(20)
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @ReturnProcessID INt
	IF @ProcessID=60
	BEGIN
		SET @ReturnProcessID = 55
	END
	ELSE IF @ProcessID=100
	BEGIN
		SET @ReturnProcessID = 90
	END
	ELSE IF @ProcessID=115
	BEGIN
		SET @ReturnProcessID = 110
	END

	Declare @SaleOrderAcntCode Varchar(20) = ''
	IF  @ProcessID=100
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SaleOrderAcntCode'
	IF  @ProcessID=60
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'BuyOrderAcntCode'

IF @ProcessID=60 OR @ProcessID=100 OR @ProcessID=115
	BEGIN
	DECLARE @YR VARCHAR(4) = right(DB_Name(),4)
	
	SELECT TOP 0 CD.BaseProcessID, 
			   CD.BaseProcessNo, 
			   CD.BaseFiscalYear, 
			   CD.BaseSerialNo,
			   CD.BaseDocRowNo,
			   CD.GoodsQuantity 
	INTO #tblRetAllYears1
	FROM inv.tblStorageDocsDtl CD
	
	INSERT INTO #tblRetAllYears1
	EXEC [inv].[spGetBaseRetInAllYears] @ReturnProcessID, @ProcessNo, @YR, NULL

	SELECT a.*,
		   b.SgnSN1,
		   b.SgnSN2,
		   b.SgnSN3, 
		   b.SgnSN4, 
		   b.SgnSN5 
	FROM ( SELECT * 
		   FROM ( SELECT DISTINCT acc.funIsCodeClosed(AcntCode) IsCodeClosed, 
								  Cnf.ProcessID, 
								  Cnf.ProcessNo, 
								  Cnf.FiscalYear, 
								  Cnf.SerialNo,
								  Cnf.AcntCode,
								  Cnf.StoreID,
								  Cnf.DocDate
				  FROM ( SELECT	CD.ProcessID, 
								CD.ProcessNo, 
								CD.FiscalYear, 
								CD.SerialNo, 
								CD.DocRowNo,
								CD.GoodsQuantity,
								CD.AcntCode,
								CD.DocDate,
								StoreID
						 FROM inv.tblStorageDocsDtl CD		
						 -------------------------------------------------------------------			
						 Where CD.ProcessID = @ReturnProcessID 
						   AND CD.ProcessNo = @ProcessNo 
						   AND (@AcntCode IS NULL OR CD.AcntCode = @AcntCode) 
						   AND CD.DocDate <= @DocDate
						   AND (( SELECT COUNT(*) 
								  FROM acc.tblVoucherDtl  v 
								  WHERE v.SourceProcessID = CD.ProcessID 
								    AND v.SourceProcessNo = CD.ProcessNo
								    AND v.SourceFiscalYear = CD.FiscalYear 
									AND v.SourceSerialNo = CD.SerialNo
									AND (v.AcntCode = SUBSTRING(CD.AcntCode, 1, LEN(v.AcntCode)) OR v.AcntCode = [pub].[funMergCode](@SaleOrderAcntCode, CD.AcntCode)) 
									------------حذف اطلاعاتی که اسناد آنها ازنوع یادداشت است------------------------------------------------------
									AND v.VchKind<>0) > 0  OR @ProcessID = 115)
					   ) Cnf
		   LEFT JOIN ( SELECT * 
					   FROM #tblRetAllYears1
					--Select	CD.BaseProcessID , CD.BaseProcessNo , CD.BaseFiscalYear , CD.BaseSerialNo , 
					--		CD.BaseDocRowNo , SUM(CD.GoodsQuantity) GoodsQuantity
					--From inv.tblStorageDocsDtl CD
					--Where CD.BaseProcessID = @ReturnProcessID AND CD.ProcessNo = @ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					--Group BY CD.BaseProcessID , CD.BaseProcessNo , CD.BaseFiscalYear , CD.BaseSerialNo , CD.BaseDocRowNo
					 ) Rtn ON Cnf.ProcessID = Rtn.BaseProcessID 
					      AND Cnf.ProcessNo = Rtn.BaseProcessNo 
						  AND Cnf.FiscalYear = Rtn.BaseFiscalYear 
						  AND Cnf.SerialNo = Rtn.BaseSerialNo 
						  AND Cnf.DocRowNo = Rtn.BaseDocRowNo
		   WHERE Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) > 0 
		  -- AND (@StoreID IS NULL OR Cnf.StoreID = @StoreID) 
		  ) A 
	WHERE IsCodeClosed = 0) a
	INNER JOIN inv.tblStorageDocsHdr b ON a.ProcessID = b.ProcessID 
									  AND a.ProcessNo = b.ProcessNo 
									  AND a.FiscalYear = b.FiscalYear 
									  AND a.SerialNo = b.SerialNo
	WHERE b.ProcessID <> 90 
	   OR (b.ProcessID = 90 AND b.TPInp <> 7)		
	END
END
GO
