USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create FUNCTION [cmr].[FunGetBaseSaleGoods]
(
@AcntCode Varchar(20),
@DocDate  char(10),
@DocStep1 Tinyint,
@DocStep2 Tinyint,
@SerialNo int=NULL,
@FiscalYear SmallInt=NULL
)
RETURNS 	@tbl Table 
(	[BaseProcessID] [smallint] NOT NULL,
	[BaseProcessNo] [tinyint] NOT NULL,
	[BaseFiscalYear] [smallint] NOT NULL,
	[BaseSerialNo] [int] NOT NULL,
	[BaseDocRowNo] [int] NOT NULL,
	[SubUnitQuantity] [float] NOT NULL,
	[ConfirmQuantity] [float] NOT NULL,
	[GoodsID] [varchar](20) NOT NULL
)  
WITH ENCRYPTION
AS
BEGIN

	declare @sal_AllowIncompleteGoodsIDInSaleOrder BIt
	SET @sal_AllowIncompleteGoodsIDInSaleOrder = 'False'
	SELECT @sal_AllowIncompleteGoodsIDInSaleOrder = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'sal_AllowIncompleteGoodsIDInSaleOrder'

	IF @sal_AllowIncompleteGoodsIDInSaleOrder = 'False'
		insert into @tbl(BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity,SubUnitQuantity,GoodsID)
		Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
				Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity, 
				Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) AS SubUnitQuantity ,Cnf.GoodsID
		From
			(
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity,Sum(SubUnitQuantity) SubUnitQuantity,GoodsID
				From inv.tblStorageDocsDtl
				Where ProcessID = 90 AND BaseProcessID > 0 AND
					 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND  --DocDate <= @DocDate AND(DocStep = @DocStep1 OR DocStep  >= @DocStep2) AND 
					 (@SerialNo IS NULL OR (BaseSerialNo=@SerialNo AND BaseFiscalYear =@FiscalYear))
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						 BaseDocRowNo,GoodsID
			UNION
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsQuantity AS ConfirmQuantity,SubUnitQuantity,GoodsID
				From inv.tblStorageDocsDtl
				Where ProcessID = 90 AND BaseProcessID = 0 AND
					 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  --DocDate <= @DocDate AND (DocStep = @DocStep1 OR DocStep  = @DocStep2) AND
					  (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))				 
			) Cnf
		LEFT JOIN 
		(
			SELECT a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo ,SUM(ConfirmQuantity) ConfirmQuantity,SUM(SubUnitQuantity) SubUnitQuantity,a.GoodsID from 
				(SELECT SD.BaseProcessID , SD.BaseProcessNo , SD.BaseFiscalYear , SD.BaseSerialNo , SD.BaseDocRowNo ,SDRet.ConfirmQuantity ConfirmQuantity,SDRet.SubUnitQuantity SubUnitQuantity,SD.GoodsID from 
				(Select	  DISTINCT ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo 
						, BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,GoodsID,GoodsQuantity
				From inv.tblStorageDocsDtl 
				WHERE ProcessID = 90 AND BaseProcessID=180 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				)SD
				LEFT JOIN
				(Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
						, BaseDocRowNo , SUM(GoodsQuantity) ConfirmQuantity, SUM(SubUnitQuantity) SubUnitQuantity,GoodsID
				From inv.tblStorageDocsDtl 
				WHERE ProcessID = 100 AND BaseProcessID=90 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsID
				)SDRet		
				ON	SD.ProcessID = SDRet.BaseProcessID AND SD.ProcessNo = SDRet.BaseProcessNo AND 
					SD.FiscalYear = SDRet.BaseFiscalYear AND SD.SerialNo = SDRet.BaseSerialNo AND 
					SD.DocRowNo = SDRet.BaseDocRowNo AND SD.GoodsID = SDRet.GoodsID 
				WHERE ConfirmQuantity IS NOT NULL) a 
				Group BY a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo,a.GoodsID
				
		) Rtn
		ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
			Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
			Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	AND Cnf.GoodsID = Rtn.GoodsID 
		WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
	ELSE
		insert into @tbl(BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity,SubUnitQuantity,GoodsID)
		Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
				Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity, 
				Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) AS SubUnitQuantity ,''
		From
			(
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity,Sum(SubUnitQuantity) SubUnitQuantity
				From inv.tblStorageDocsDtl
				Where ProcessID = 90 AND BaseProcessID > 0 AND
					 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND  --DocDate <= @DocDate AND(DocStep = @DocStep1 OR DocStep  >= @DocStep2) AND 
					 (@SerialNo IS NULL OR (BaseSerialNo=@SerialNo AND BaseFiscalYear =@FiscalYear))
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						 BaseDocRowNo
			UNION
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsQuantity AS ConfirmQuantity,SubUnitQuantity
				From inv.tblStorageDocsDtl
				Where ProcessID = 90 AND BaseProcessID = 0 AND
					 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  --DocDate <= @DocDate AND (DocStep = @DocStep1 OR DocStep  = @DocStep2) AND
					  (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))				 
			) Cnf
		LEFT JOIN 
		(
			SELECT a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo ,SUM(ConfirmQuantity) ConfirmQuantity,SUM(SubUnitQuantity) SubUnitQuantity from 
				(SELECT SD.BaseProcessID , SD.BaseProcessNo , SD.BaseFiscalYear , SD.BaseSerialNo , SD.BaseDocRowNo ,SDRet.ConfirmQuantity ConfirmQuantity,SDRet.SubUnitQuantity SubUnitQuantity from 
				(Select	  DISTINCT ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo 
						, BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,GoodsQuantity
				From inv.tblStorageDocsDtl 
				WHERE ProcessID = 90 AND BaseProcessID=180 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				)SD
				LEFT JOIN
				(Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
						, BaseDocRowNo , SUM(GoodsQuantity) ConfirmQuantity, SUM(SubUnitQuantity) SubUnitQuantity
				From inv.tblStorageDocsDtl 
				WHERE ProcessID = 100 AND BaseProcessID=90 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
				)SDRet		
				ON	SD.ProcessID = SDRet.BaseProcessID AND SD.ProcessNo = SDRet.BaseProcessNo AND 
					SD.FiscalYear = SDRet.BaseFiscalYear AND SD.SerialNo = SDRet.BaseSerialNo AND 
					SD.DocRowNo = SDRet.BaseDocRowNo 
				WHERE ConfirmQuantity IS NOT NULL) a 
				Group BY a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo
				
		) Rtn
		ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
			Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
			Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
		WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0

	return
END
GO
