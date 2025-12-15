USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [sal].[spFrmSaleOrderForDistHdrListSelect] 
	@DocDate		Char(10),
	@AcntCodeFrom	varchar(20),
	@AcntCodeTo		varchar(20)
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

	DECLARE @LanguageID AS TinyInt
	SET @LanguageID = pub.funGetCurrentLanguageID()
	
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @SalOrderDocStep tinyint
	Declare @StrSelect AS NVarChar(4000);
	Declare @StrAcnt   AS NVarChar(100);

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @StrAcnt = ''
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @SalOrderDocStep = 1
	ELSE
		SET @SalOrderDocStep = 2

	If (@AcntCodeFrom Is Not Null) And (Len(Ltrim(@AcntCodeFrom)) <> 0)
		Set @StrAcnt =  ' AND LEFT(AcntCode,' +LTRIM(STR(LEN(@AcntCodeFrom))) + ') >= ''' + LTrim(RTrim(@AcntCodeFrom)) + ''''
	ELSE

		SET @AcntCodeFrom = '00000000000000000000'

	If (@AcntCodeTo Is Not Null) AND (Len(LTrim(@AcntCodeTo)) <> 0)
		Set @StrAcnt =  @StrAcnt + ' AND LEFT(AcntCode,' +LTRIM(STR(LEN(@AcntCodeTo))) + ') <= ''' + LTrim(RTrim(@AcntCodeTo)) + ''''
	ELSE
		SET @AcntCodeTo = '99999999999999999999'

	SET @StrSelect = N'SELECT * FROM (
		SELECT  DISTINCT acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo ,CmrCnf.DocDate,AcntCode,[pub].[GetCodeName](AcntCode,' + LTRIM(STR(@LanguageID)) + ') AcntName
					   From
		(
			SELECT DISTINCT D.*,H.VisitorAcntCode,H.SaleTypeID
			FROM (
					Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo ,
							Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
							Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity ,DocDate,AcntCode,GoodsPrice
					From
						(
							Select	TOD.ProcessID , TOD.ProcessNo , TOD.FiscalYear , TOD.SerialNo ,TOD.DocRowNo , 
									RG.ConfirmQuantity,TOD.BaseProcessID , TOD.BaseProcessNo , 
									TOD.BaseFiscalYear , TOD.BaseSerialNo , TOD.BaseDocRowNo,DocDate,AcntCode,TOD.GoodsPrice
							FROM (
									Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
									From sal.tblSaleOrderDtl
									Where ProcessID = 180 AND  BaseProcessID > 0 ' + @StrAcnt + ' AND  DocDate <= ''' + @DocDate + ''' AND DocStep = ' + LTrim(Str(@SalOrderDocStep)) + '
									Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
											 BaseDocRowNo
								 ) RG
							INNER JOIN  
								sal.tblSaleOrderDtl TOD
							ON	TOD.BaseProcessID =RG.BaseProcessID AND TOD.BaseProcessNo =RG.BaseProcessNo AND TOD.BaseFiscalYear=RG.BaseFiscalYear AND 
								TOD.BaseSerialNo=RG.BaseSerialNo AND TOD.BaseDocRowNo=RG.BaseDocRowNo
							WHERE  TOD.DocDate <= ''' + @DocDate + '''' + @StrAcnt + ' 
						UNION
							Select	ProcessID , ProcessNo , FiscalYear , SerialNo ,DocRowNo , 
									ConfirmQuantity AS ConfirmQuantity,BaseProcessID , BaseProcessNo , 
									BaseFiscalYear , BaseSerialNo , BaseDocRowNo,DocDate,AcntCode,GoodsPrice
							FROM sal.tblSaleOrderDtl	
							Where ProcessID = 180 AND BaseProcessID = 0 ' + @StrAcnt + ' AND  DocDate <= ''' + @DocDate + ''' AND DocStep = ' + LTrim(Str(@SalOrderDocStep)) + '

						) Cnf
					LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
								Sum(GoodsQuantity) ConfirmQuantity
						From sal.tblSaleOrderDtl 
						Where BaseProcessID = 180 ' + @StrAcnt + '
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
								BaseDocRowNo
					) Rtn
					ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
						Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
						Cnf.DocRowNo = Rtn.BaseDocRowNo
				WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)  > 0 ) D INNER JOIN sal.tblSaleOrderHdr H
				ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
				   H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
		) CmrCnf 
	LEFT JOIN 
		(
			SELECT * from [sal].[FunGetBaseSaleGoodsForDist](''' + @AcntCodeFrom + ''',''' + @AcntCodeTo + ''',''' + @DocDate + ''')		

 		) StorageDocs
		ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
		CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
		CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
	WHERE (CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0))>0 
	) A WHERE IsCodeClosed = 0'
	print @StrSelect
	Exec sp_executesql @StrSelect;

END
GO
