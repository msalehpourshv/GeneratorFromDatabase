USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1398/07/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.spFrmBaskulHdrListSelect
	@ProcessID		int,
	@ProcessNo		int,
	@BaseProcessID	int,
	@DocDate		Char(10),
	@AcntCode		varchar(20),
	@StoreID		varchar(20),
	@DocStep		Tinyint,
	@SerialNo       Int,
	@FiscalYear     SmallInt   ,
	@ExtraParams		NVarChar(Max) 
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

-- ===============================================
		
DECLARE @LanguageID AS TinyInt
SET @LanguageID = pub.funGetCurrentLanguageID()
--======================================

DECLARE @StrSelect				NVarChar(max);
DECLARE @StrWhere				NVarChar(max);

IF @ProcessID Is Null	SET @ProcessID = 0
IF @SerialNo Is Null	SET @SerialNo = 0
IF @FiscalYear Is Null	SET @FiscalYear = 0
IF @DocDate Is Null		SET @DocDate = ''
IF @AcntCode Is Null	SET @AcntCode = ''
IF @StoreID Is Null		SET @StoreID = ''
	
if @BaseProcessID=194
begin
	SET @StrWhere = ' Where a.ProcessID=194   and a.BaseProcessID=194   and a.Step=4   and  a.IsCancel=0 '
	if @AcntCode<>''
		SET @StrWhere = @StrWhere + ' and AcntCodeDtl like '''+ @AcntCode+ '%'''
	--if @StoreID<>''
	--	SET @StrWhere = @StrWhere + ' and (StoreID = '''+ @StoreID+ ''' ) '
	if @DocDate<>''
		SET @StrWhere = @StrWhere + ' and (a.DocDate <= '''+ @DocDate+ ''' ) '
	if @SerialNo<>0
		SET @StrWhere = @StrWhere + ' and (a.SerialNo='+ str(@SerialNo) +' AND a.FiscalYear ='+str(@FiscalYear)+' )  '

	--SET @StrWhere = @StrWhere + ' and SerialNo not in ( select BaskulSerialNo from inv.tblStorageDocsHdr Where BaskulSerialNo<>0 and ProcessID= '+ str(@ProcessID-1)+ ') '

	SET @StrSelect ='select b.BaseProcessID,  b.BaseProcessNo,  b.BaseFiscalYear, b.BaseSerialNo, b.BaseDocRowNo,a.ProcessID	,a.FiscalYear,a.SerialNo,a.ProcessNo,	a.DocDate,SubUnitQuantity,AcntCodeDtl AcntCode
		,[pub].[GetCodeName](AcntCodeDtl,1) AcntName  
		from 
		(
		SELECT ProcessID,  ProcessNo,  FiscalYear, SerialNo, DocRowNo
		FROM inv.tblBaskulSalesDtl
		where BaseProcessID=194
		EXCEPT
		SELECT BaseProcessID,  BaseProcessNo,  BaseFiscalYear, BaseSerialNo, BaseDocRowNo
		FROM inv.tblStorageDocsDtl
		WHERE ProcessID = 90 And BaseProcessID=194  
		) H1
		inner join  inv.tblBaskulSalesDtl b 
		ON b.ProcessID = H1.ProcessID And  b.ProcessNo = H1.ProcessNo And  b.FiscalYear = H1.FiscalYear And  b.SerialNo = H1.SerialNo And  b.DocRowNo = H1.DocRowNo  
		INNER JOIN  inv.tblBaskulSalesHdr a  on a.ProcessID=b.ProcessID and a.SerialNo=b.SerialNo
		' +@StrWhere
end 
else
begin

	SET @StrWhere = ' Where ProcessID='+ str(@ProcessID)+ '  and Step=4   and  IsCancel=0 '
	if @AcntCode<>''
		SET @StrWhere = @StrWhere + ' and (AcntCode = '''+ @AcntCode+ ''' ) '
	if @DocDate<>''
		SET @StrWhere = @StrWhere + ' and (DocDate <= '''+ @DocDate+ ''' ) '
	if @SerialNo<>0
		SET @StrWhere = @StrWhere + ' and (SerialNo='+ str(@SerialNo) +' AND FiscalYear ='+str(@FiscalYear)+' )  '

	SET @StrWhere = @StrWhere + ' and SerialNo not in ( select BaskulSerialNo from inv.tblStorageDocsHdr Where BaskulSerialNo<>0 and ProcessID= '+ str(@ProcessID-1)+ ') '

	SET @StrSelect ='select *,[pub].[GetCodeName](AcntCode,1) AcntName  from inv.tblBaskulSalesHdr ' +@StrWhere

end 
 
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
END
GO
