USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetMaxGoodsRemain]
(
	-- Add the parameters for the function here
	@ProcessID		Smallint,
	@ProcessNo		Tinyint,
	@FiscalYear		Smallint,
	@SerialNo		Int,
	@BaseProcessID	Smallint,
	@BaseProcessNo	Tinyint,
	@BaseFiscalYear	Smallint,
	@BaseSerialNo	Int,
	@BaseDocRowNo	Int,
	@StoreID		Varchar(20),
	@GoodsID		Varchar(20),
	@BatchNo		Varchar(20),
	@DocDate		Char(10),
	@BaseDocType	Bit
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MaxGoodsQuantity Float
	DECLARE @Result			Float
	DECLARE @NewVolumeRowNo Float
	DECLARE @PrevQtyRemain	Float
	DECLARE @TmpProcessID	Smallint
	DECLARE @TmpProcessNo	Tinyint
	DECLARE @TmpFiscalYear	SmallInt
	DECLARE @TmpSerialNo	Int

	IF @TmpSerialNo=0
		BEGIN
			SET @TmpProcessID  = 0
			SET @TmpProcessNo  = 0
			SET @TmpFiscalYear = 0
			SET @TmpSerialNo   = 0
		END
	ELSE
		BEGIN
			SET @TmpProcessID  = @ProcessID
			SET @TmpProcessNo  = @ProcessNo
			SET @TmpFiscalYear = @FiscalYear
			SET @TmpSerialNo   = @SerialNo
		END

	SET @Result =0

--	Select TOP(1) @PrevQtyRemain = QtyRemain 
--	From [inv].[tblStorageDocsDtl] 
--	Where	GoodsID = @GoodsID AND StoreID = @StoreID AND DocDate <= @DocDate AND VolumeRowNo > 0
--	Order By DocDate Desc, VolumeRowNo Desc

	Select @PrevQtyRemain = [inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,@StoreID,@GoodsID,@BatchNo,@DocDate,0)

	Set @PrevQtyRemain = ISNULL(@PrevQtyRemain,0) 

	SET @MaxGoodsQuantity = 0

	IF @BaseDocType>0
		BEGIN
			Select @MaxGoodsQuantity=Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) 
			From
				(
					Select	OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo , 
							OD.DocRowNo , OD.GoodsQuantity
					From inv.tblStorageDocsDtl OD
					Where	OD.ProcessID = @BaseProcessID AND OD.ProcessNo = @BaseProcessNo AND 
							OD.FiscalYear= @BaseFiscalYear AND OD.SerialNo = @BaseSerialNo AND 
							OD.DocRowNo=@BaseDocRowNo AND OD.DocStep IN (0,2)
				) Cnf
			LEFT JOIN 
			(
				Select	OD.BaseProcessID , OD.BaseProcessNo , OD.BaseFiscalYear , OD.BaseSerialNo , 
						OD.BaseDocRowNo , Sum(OD.GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl OD
				Where	OD.BaseProcessID = @BaseProcessID AND OD.BaseProcessNo = @BaseProcessNo AND 
						OD.BaseFiscalYear= @BaseFiscalYear AND OD.BaseSerialNo = @BaseSerialNo AND 
						OD.BaseDocRowNo = @BaseDocRowNo AND DocDate <= @DocDate AND 
					not(ProcessID  = @TmpProcessID AND 
						ProcessNo  = @TmpProcessNo AND 
						FiscalYear = @TmpFiscalYear AND 
						SerialNo   = @TmpSerialNo )
				Group BY OD.BaseProcessID , OD.BaseProcessNo , OD.BaseFiscalYear , 
						 OD.BaseSerialNo , OD.BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo	
		END

	SET @MaxGoodsQuantity=ISNULL(@MaxGoodsQuantity,0)

	IF @MaxGoodsQuantity<@PrevQtyRemain
		SET @Result = @MaxGoodsQuantity
	ELSE
		SET @Result = @PrevQtyRemain

	-- Return the result of the function
	RETURN @Result

END












GO
