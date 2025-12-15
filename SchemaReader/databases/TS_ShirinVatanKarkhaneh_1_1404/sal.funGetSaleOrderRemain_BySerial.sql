USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 90/11/09
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--SELECT [sal].[funGetSaleOrderRemain_BySerial](180, 2, 96, 722, Null, '1396/02/25', '5000099800140', '101')
CREATE FUNCTION [sal].[funGetSaleOrderRemain_BySerial]
(	
	@ProcessID		TinyInt,
	@ProcessNo		TinyInt,
	@FiscalYear		Smallint,
	@SerialNo		Int,
	@DocRowNo		Int,	
	@DocDate		Char(10),
	@GoodsID		Varchar(20),
	@StoreID		Varchar(20)
)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Sal_StoreDtl Bit
	SET @Sal_StoreDtl = ISNULL((Select SettingValue From pub.tblSettings
								Where SettingKey = 'Sal_StoreDtl'), 'False')
	-- ======
	IF @FiscalYear IS NULL OR @FiscalYear = 0
		SET @FiscalYear =  RIGHT(db_name(),4)
		
	DECLARE @QtyRemain Float
	DECLARE @GetRemainSaleOrder AS  Nvarchar(5);
	DECLARE @SalRet_RetToSalOdr AS BIT
	
	SET @QtyRemain =0
	SET @GetRemainSaleOrder = 'False'
	SET @SalRet_RetToSalOdr = 'False'

	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 

	DECLARE @SorHasFirstConfirm AS BIT
	SET @SorHasFirstConfirm = 'False'
	
	SELECT @SorHasFirstConfirm = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SorHasFirstConfirm'
	
	IF @DocDate = '' OR @GoodsID = ''
	BEGIN 
		RETURN 0
	END

  	-- ======
	IF @GetRemainSaleOrder = 'True'
		BEGIN
  			-- ======
			SELECT @QtyRemain = ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End 
			FROM sal.tblSaleOrderDtl
			WHERE ProcessID  = @ProcessID  AND
				  ProcessNo  = @ProcessNo  AND
				  FiscalYear = @FiscalYear AND
				  SerialNo   = @SerialNo   AND
				  (@DocRowNo Is Null OR DocRowNo = @DocRowNo) AND
				  DocDate   <= @DocDate    AND 
				  GoodsID	 = @GoodsID    AND 
				  (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))
				  
			SELECT @QtyRemain = @QtyRemain - ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End
			FROM sal.tblSaleOrderDtl
			WHERE BaseProcessID  = @ProcessID  AND
				  BaseProcessNo  = @ProcessNo  AND
				  BaseFiscalYear = @FiscalYear AND
				  BaseSerialNo   = @SerialNo   AND
				  (@DocRowNo Is Null OR BaseDocRowNo = @DocRowNo) AND
				  DocDate		<= @DocDate    AND 
				  GoodsID		 = @GoodsID    AND 
				  (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))
	
  			-- ======
			SELECT	@QtyRemain= @QtyRemain - ISNULL(SUM(case when b.GoodsQuantity<a.GoodsQuantity then b.GoodsQuantity else a.GoodsQuantity end),0)
			FROM inv.tblStorageDocsDtl a
			LEFT JOIN sal.tblSaleOrderDtl b
			ON a.BaseProcessID=b.ProcessID and a.BaseProcessNo=b.ProcessNo and a.BaseFiscalYear=b.FiscalYear and 
			   a.BaseSerialNo=b.SerialNo and a.BaseDocRowNo=b.DocRowNo and a.GoodsID=b.GoodsID
			WHERE a.BaseProcessID  = @ProcessID  AND
				  a.BaseProcessNo  = @ProcessNo  AND
				  a.BaseFiscalYear = @FiscalYear AND
				  a.BaseSerialNo   = @SerialNo   AND
				  (@DocRowNo Is Null OR a.BaseDocRowNo = @DocRowNo) AND
				  a.DocDate		  <= @DocDate    AND 
				  a.GoodsID		   = @GoodsID    AND 
				  (@StoreID IS NULL OR (a.StoreID = @StoreID))
				  					
  			-- ======
			IF @SalRet_RetToSalOdr = 'True'
				BEGIN
					SELECT @QtyRemain= @QtyRemain + ISNULL(SUM (A.GoodsQuantity),0)
					FROM inv.tblStorageDocsDtl A 
					INNER JOIN
					(Select	*
					From inv.tblStorageDocsDtl
					WHERE BaseProcessID  = @ProcessID  AND
						  BaseProcessNo  = @ProcessNo  AND
						  BaseFiscalYear = @FiscalYear AND
						  BaseSerialNo   = @SerialNo   AND
						  --BaseDocRowNo	 = @DocRowNo   AND
						  DocDate		<= @DocDate    AND 
						  GoodsID = @GoodsID AND (@StoreID IS NULL OR (StoreID = @StoreID))) B
					ON B.ProcessID = A.BaseProcessID AND B.ProcessNo = A.BaseProcessNo AND 
					   B.FiscalYear = A.BaseFiscalYear AND B.SerialNo = A.BaseSerialNo AND 
					   B.DocRowNo = A.BaseDocRowNo AND A.GoodsID = @GoodsID AND 
					   (@StoreID IS NULL OR (A.StoreID = @StoreID))
					   AND A.ProcessID=100
				END
		END
	ELSE
		BEGIN

  			-- ======
			SELECT @QtyRemain = ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End
			FROM sal.tblSaleOrderDtl S INNER JOIN
			(
				SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
				WHERE ProcessID=@ProcessID  
				EXCEPT
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				WHERE BaseProcessID=@ProcessID AND ProcessID=90  
			) A
			ON A.ProcessID=S.ProcessID AND A.ProcessNo=S.ProcessNo AND A.FiscalYear=S.FiscalYear AND 
			   A.SerialNo=S.SerialNo
			WHERE S.ProcessID  = @ProcessID  AND
				  S.ProcessNo  = @ProcessNo  AND
				  S.FiscalYear = @FiscalYear AND
				  S.SerialNo   = @SerialNo   AND
				  (@DocRowNo Is Null OR S.DocRowNo = @DocRowNo) AND
				  DocDate	  <= @DocDate    AND 
				  GoodsID	   = @GoodsID    AND (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))

  			-- ======
			SELECT @QtyRemain= @QtyRemain - ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End 
			FROM sal.tblSaleOrderDtl S INNER JOIN
			(
				SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
				WHERE ProcessID=@ProcessID  
				EXCEPT
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				WHERE BaseProcessID=@ProcessID AND ProcessID=90  
			) A
			ON A.ProcessID=S.BaseProcessID AND A.ProcessNo=S.BaseProcessNo AND 
			   A.FiscalYear=S.BaseFiscalYear AND A.SerialNo=S.BaseSerialNo
			WHERE BaseProcessID  = @ProcessID  AND
				  BaseProcessNo  = @ProcessNo  AND
				  BaseFiscalYear = @FiscalYear AND
				  BaseSerialNo   = @SerialNo   AND
				  (@DocRowNo Is Null OR BaseDocRowNo = @DocRowNo) AND
				  DocDate		<= @DocDate    AND 
				  GoodsID = @GoodsID AND (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))
		END

	RETURN @QtyRemain 

END
GO
