USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION inv.funGetGoodsRemainInSaleOrderWhithOutThisSale
(
	-- Add the parameters for the function here
	@BaseProcessID		Smallint,
	@BaseProcessNo		Smallint,
	@BaseFiscalYear		Smallint,
	@BaseSerialNo		Int,
	@BaseDocRowNo		Int,
	@DocDate			Char(10),
	@AcntCode			VarChar(20),
	@ProcessID		Smallint,
	@ProcessNo		Smallint,
	@FiscalYear		Smallint,
	@SerialNo		Int
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result			Float

	SET @Result =0
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @DocStep tinyint
	DECLARE @SalRet_RetToSalOdr AS BIT

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2

	--DECLARE 
	--set @ProcessID=90
	--set @ProcessNo=1
	--set @FiscalYear=1399
	--set @SerialNo=2095
	
	

	IF @SalRet_RetToSalOdr = 'False'
		Select	@Result = 
			   (Select	GoodsQuantity
				FROM sal.tblSaleOrderDtl	
				Where ProcessID = 180 AND 
					  ProcessID=@BaseProcessID AND
				  	  ProcessNo=@BaseProcessNo AND
					  FiscalYear=@BaseFiscalYear AND
					  SerialNo=@BaseSerialNo AND
					  DocRowNo=@BaseDocRowNo AND DocStep >= @DocStep) - 
				ISNULL(
				(--  ������ �� ������ �����
				Select	Sum(GoodsQuantity) 
				From sal.tblSaleOrderDtl 
				Where BaseProcessID = 180 AND 
					  BaseProcessID=@BaseProcessID AND
			  		  BaseProcessNo=@BaseProcessNo AND
					  BaseFiscalYear=@BaseFiscalYear AND
					  BaseSerialNo=@BaseSerialNo AND
					  BaseDocRowNo=@BaseDocRowNo
				) 
				,0) - 
				ISNULL(
				( Select SUM(GoodsQuantity) 
				 From inv.tblStorageDocsDtl 
				 WHERE ProcessID = 90 AND
					   BaseProcessID=180 AND 
					   BaseProcessID=@BaseProcessID AND
			  		   BaseProcessNo=@BaseProcessNo AND
					   BaseFiscalYear=@BaseFiscalYear AND
					   BaseSerialNo=@BaseSerialNo AND
					   BaseDocRowNo=@BaseDocRowNo 
					   and not (  ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo )
					   )
				,0) 
	ELSE
		Select	@Result = Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) + ISNULL(SalRet.ConfirmQuantity,0) 
		From
			(
				Select	ProcessID , ProcessNo , FiscalYear , SerialNo ,DocRowNo,
						GoodsQuantity,GoodsID--,ConfirmQuantity SubUnitQuantity
				FROM sal.tblSaleOrderDtl	
				Where ProcessID = 180 AND 
					  ProcessID=@BaseProcessID AND
				  	  ProcessNo=@BaseProcessNo AND
					  FiscalYear=@BaseFiscalYear AND
					  SerialNo=@BaseSerialNo AND
					  DocRowNo=@BaseDocRowNo AND DocStep >= @DocStep
			) Cnf
		LEFT JOIN 
		(--  ������ �� ������ �����
			Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
					Sum(GoodsQuantity) ConfirmQuantity,GoodsID
			From sal.tblSaleOrderDtl 
			Where BaseProcessID = 180 AND 
				  BaseProcessID=@BaseProcessID AND
			  	  BaseProcessNo=@BaseProcessNo AND
				  BaseFiscalYear=@BaseFiscalYear AND
				  BaseSerialNo=@BaseSerialNo AND
				  BaseDocRowNo=@BaseDocRowNo
			Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
					BaseDocRowNo,GoodsID
		) Rtn
		ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
			Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
			Cnf.DocRowNo = Rtn.BaseDocRowNo AND Cnf.GoodsID = Rtn.GoodsID 
		LEFT JOIN
		(
			SELECT a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo ,SUM(ConfirmQuantity) ConfirmQuantity,a.GoodsID --,SUM(SubUnitQuantity) SubUnitQuantity
			from (
			SELECT SD.BaseProcessID , SD.BaseProcessNo , SD.BaseFiscalYear , SD.BaseSerialNo , SD.BaseDocRowNo ,
			CASE WHEN @SalRet_RetToSalOdr = 'False' THEN - ISNULL(SD.GoodsQuantity,0) 
				ELSE ISNULL(ConfirmQuantity,0) - ISNULL(SD.GoodsQuantity,0) END ConfirmQuantity,SD.GoodsID
		from ( -- ������ �� ���� ��
			  Select	  DISTINCT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo 
					, BaseProcessID, BaseProcessNo, BaseFiscalYear , BaseSerialNo, BaseDocRowNo, 
					GoodsID, GoodsQuantity
			 From inv.tblStorageDocsDtl 
			 WHERE ProcessID = 90 AND
			       BaseProcessID=180 AND 
			       BaseProcessID=@BaseProcessID AND
			  	   BaseProcessNo=@BaseProcessNo AND
				   BaseFiscalYear=@BaseFiscalYear AND
				   BaseSerialNo=@BaseSerialNo AND
				   BaseDocRowNo=@BaseDocRowNo 
				   and not (  ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo )
			)SD
			LEFT JOIN
			(-- ������ �� �ѐ�� �� ���� ��
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
						, BaseDocRowNo , SUM(GoodsQuantity) ConfirmQuantity,GoodsID--, SUM(SubUnitQuantity) SubUnitQuantity
				From inv.tblStorageDocsDtl 
				WHERE ProcessID = 100 AND BaseProcessID=90 AND (@AcntCode IS NULL OR AcntCode like @AcntCode+'%')
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsID
			)SDRet		
			ON	SD.ProcessID = SDRet.BaseProcessID AND SD.ProcessNo = SDRet.BaseProcessNo AND 
				SD.FiscalYear = SDRet.BaseFiscalYear AND SD.SerialNo = SDRet.BaseSerialNo AND 
				SD.DocRowNo = SDRet.BaseDocRowNo AND SD.GoodsID = SDRet.GoodsID 
			) a 
			Group BY a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo,a.GoodsID
		)	SalRet
		ON	Cnf.ProcessID = SalRet.BaseProcessID AND Cnf.ProcessNo = SalRet.BaseProcessNo AND 
			Cnf.FiscalYear = SalRet.BaseFiscalYear AND Cnf.SerialNo = SalRet.BaseSerialNo AND 
			Cnf.DocRowNo = SalRet.BaseDocRowNo AND Cnf.GoodsID = SalRet.GoodsID	

	RETURN @Result

END
GO
