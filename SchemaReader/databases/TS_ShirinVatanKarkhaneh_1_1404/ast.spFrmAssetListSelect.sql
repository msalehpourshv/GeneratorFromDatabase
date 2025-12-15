USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 1387/09/29
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create  PROCEDURE [ast].[spFrmAssetListSelect] 
	@ProcessID	Int,
	@ProcessNo	Int,
	@AcntCode	VarChar(20),
	@DocDate	Char(10),
	@LanguageID Int,
	@SerialNo	Int,
	@FiscalYear Smallint,
	@BaseSerialNo	Int,
	@BaseFiscalYear Smallint 
	WITH ENCRYPTION
 AS
BEGIN

SET NOCOUNT ON;
 

DECLARE	@StrQuery	NVarChar(4000);

if @ProcessID=469
begin
	 SET @StrQuery	= '
	select Distinct a.*,h.DescHdr from 
	ast.tblAssetRequstRepairHdr  h inner join 
	ast.tblAssetRequstRepairDtl a
	on a.ProcessID=h.ProcessID and a.ProcessNo =h.ProcessNo and a.FiscalYear=h.FiscalYear and a.SerialNo=h.SerialNo

	INNER JOIN 
	(
		SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo
		FROM  ast.tblAssetRequstRepairDtl
	Except 
		SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
		FROM  ast.tblAssetsDtl
	)  b
	on a.ProcessID=b.ProcessID and a.ProcessNo =b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
	WHERE      (a.ProcessID = '+ str(@ProcessID) +' ) AND (a.ProcessNo = '+ str(@ProcessNo) +' )'
	if not (@SerialNo is Null)
		SET @StrQuery	= @StrQuery + ' AND ( a.SerialNo = '+ str(@SerialNo) +')'
	if not (@FiscalYear is Null)
		SET @StrQuery	= @StrQuery +' AND ( a.FiscalYear = '+ str(@FiscalYear) +')' 
end 
else
begin
	SET @StrQuery	= 'select ProcessID,ProcessNo , FiscalYear ,SerialNo,DocRowNo as DocRowNo,DocDate  ,ObverseAcntCode
		,GoodsID ,SUM(ConfirmQuantity) as ConfirmQuantity ,GoodsName
		from ( 
			SELECT   Distinct   B.ProcessID,B.ProcessNo, B.FiscalYear, B.SerialNo,B.DocDate, B.ObverseAcntCode
				, B.GoodsID,DocRowNo,  B.GoodsQuantity - ISNULL(A.GoodsQuantity, 0) as ConfirmQuantity,
				pub.funGetGoodsName(B.GoodsID,1) AS GoodsName
			FROM         (
				Select BaseProcessID, BaseSerialNo, BaseFiscalYear, BaseProcessNo, GoodsID, Sum(ISNULL(GoodsQuantity, 0)) as GoodsQuantity
				From ( 
					SELECT     H.BaseProcessID, H.BaseSerialNo, H.BaseFiscalYear, H.BaseProcessNo, D.GoodsID,DocRowNo, 1 AS GoodsQuantity
					FROM          ast.tblAssetsHdr AS H 
						INNER JOIN ast.tblAssetsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					WHERE       (H.ProcessID = 455) '
	if not (@SerialNo is Null)
		SET @StrQuery	= @StrQuery + ' AND ( H.BaseSerialNo = '+ str(@SerialNo) +')'
	if not (@BaseSerialNo is Null)
		SET @StrQuery	= @StrQuery + ' and  H.SerialNo <> '+ str(@BaseSerialNo) +''

	SET @StrQuery	= @StrQuery + '  )C 
		group by  BaseProcessID, BaseSerialNo, BaseFiscalYear, BaseProcessNo, GoodsID ) AS A RIGHT OUTER JOIN
		(SELECT    ProcessID,ProcessNo, FiscalYear, SerialNo, DocDate, AcntCode AS ObverseAcntCode
			, GoodsID,DocRowNo ,sum( GoodsQuantity) as GoodsQuantity
		FROM          inv.tblStorageDocsDtl
		WHERE      (ProcessID = '+ str(@ProcessID) +' ) AND (ProcessNo = '+ str(@ProcessNo) +' )'
	if not (@SerialNo is Null)
		SET @StrQuery	= @StrQuery + ' AND ( SerialNo = '+ str(@SerialNo) +')'
	if not (@FiscalYear is Null)
		SET @StrQuery	= @StrQuery +' AND ( FiscalYear = '+ str(@FiscalYear) +')'
	SET @StrQuery	= @StrQuery + '
		group by  ProcessID,ProcessNo, FiscalYear, SerialNo, DocDate, AcntCode 	, GoodsID ,DocRowNo
		) AS B  ON A.BaseSerialNo = B.SerialNo AND A.BaseFiscalYear = B.FiscalYear AND 
					  A.BaseProcessNo = B.ProcessNo AND A.BaseProcessID = B.ProcessID AND A.GoodsID = B.GoodsID
		WHERE     (B.GoodsQuantity - ISNULL(A.GoodsQuantity, 0) > 0)
		)x 
		group by ProcessID,ProcessNo , FiscalYear  ,DocDate  ,ObverseAcntCode,GoodsID,DocRowNo ,SerialNo,GoodsName
	'
end

	print @StrQuery;
	exec sp_executesql @StrQuery;

END
GO
