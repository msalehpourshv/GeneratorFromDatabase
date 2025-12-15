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
CREATE FUNCTION [sal].[funGetSaleOrderGoodsRemain_Store2]
(	
	@GoodsID		Varchar(20),
	@StoreID		Varchar(20),
	@DocDate		Char(10),
	@FiscalYear		INT,
	@UserPriceID	INT
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
			--SELECT @QtyRemain = ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End 
			--FROM sal.tblSaleOrderDtl
			--WHERE ProcessID = 180 AND
			--	  DocDate <= @DocDate AND 
			--	  FiscalYear= @FiscalYear AND
			--	  GoodsID = @GoodsID AND (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))  AND 
			--	  (@UserPriceID =0 or UserPriceID=@UserPriceID)
				  
			--SELECT @QtyRemain = @QtyRemain - ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End
			--FROM sal.tblSaleOrderDtl
			--WHERE BaseProcessID = 180 AND
			--	  DocDate <= @DocDate AND 
			--	  BaseFiscalYear= @FiscalYear AND
			--	  GoodsID = @GoodsID AND (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))  AND 
			--	  (@UserPriceID =0 or UserPriceID=@UserPriceID)
	
			--Select	@QtyRemain= @QtyRemain - ISNULL(SUM(case when b.GoodsQuantity<a.GoodsQuantity then b.GoodsQuantity else a.GoodsQuantity end),0)
			----Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(case when b.ConfirmQuantity<a.GoodsQuantity then b.ConfirmQuantity else a.GoodsQuantity end),0) Else 
			----ISNULL(SUM(case when b.GoodsQuantity<a.GoodsQuantity then b.GoodsQuantity else a.GoodsQuantity end),0) End
			
			--From inv.tblStorageDocsDtl a
			--left join sal.tblSaleOrderDtl b
			--on a.BaseProcessID=b.ProcessID and a.BaseProcessNo=b.ProcessNo and a.BaseFiscalYear=b.FiscalYear and 
			--   a.BaseSerialNo=b.SerialNo and a.BaseDocRowNo=b.DocRowNo and a.GoodsID=b.GoodsID
			--WHERE a.BaseProcessID = 180 AND
			--	  a.DocDate <= @DocDate AND 
			--	  a.BaseFiscalYear= @FiscalYear AND
			--	  a.GoodsID = @GoodsID AND (@StoreID IS NULL OR (a.StoreID = @StoreID))  AND 
			--	  (@UserPriceID =0 or a.UserPriceID=@UserPriceID)
				

			select @QtyRemain = SUM(q) from (
			select CASE WHEN (GoodsQuantity-ISNULL(b.q,0)-ISNULL(c.q,0)) <0 THEN  0 ELSE GoodsQuantity-ISNULL(b.q,0)-ISNULL(c.q,0) END q 
			from sal.tblSaleOrderDtl a
			Left join 
			(
				select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo,StoreID,GoodsID,
				SUM(GoodsQuantity) q
				from inv.tblStorageDocsDtl
				where ProcessID=90 AND BaseProcessID=180 and  DocDate <= @DocDate AND GoodsID=@GoodsID 

				group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo,StoreID,GoodsID
			)b
			on a.ProcessID=b.BaseProcessID AND a.ProcessNo=b.BaseProcessNo AND a.FiscalYear=b.BaseFiscalYear
			and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo and  a.GoodsID=b.GoodsID
			left join 
			(
				select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo,StoreID,GoodsID,
				SUM(GoodsQuantity) q
				from sal.tblSaleOrderDtl
				where BaseProcessID=180 and  DocDate <= @DocDate AND GoodsID=@GoodsID
				group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo,StoreID,GoodsID
			)c
			on a.ProcessID=c.BaseProcessID AND a.ProcessNo=c.BaseProcessNo AND a.FiscalYear=c.BaseFiscalYear
			and a.SerialNo=c.BaseSerialNo and a.DocRowNo=c.BaseDocRowNo and  a.GoodsID=c.GoodsID
			where a.ProcessID=180 and a.GoodsID=@GoodsID and (@StoreID IS NULL OR (a.StoreID = @StoreID))
			 AND  a.DocDate <= @DocDate AND (@UserPriceID =0 or a.UserPriceID=@UserPriceID)
			) a	
			
  			-- ======
			IF @SalRet_RetToSalOdr = 'True'
				BEGIN
					SELECT @QtyRemain= @QtyRemain + ISNULL(SUM (A.GoodsQuantity),0)
					FROM inv.tblStorageDocsDtl A INNER JOIN
					(Select	*
					From inv.tblStorageDocsDtl
					WHERE BaseProcessID = 180 AND
						  BaseFiscalYear= @FiscalYear AND
						  DocDate <= @DocDate AND 
						  GoodsID = @GoodsID AND (@StoreID IS NULL OR (StoreID = @StoreID))) B
					ON B.ProcessID = A.BaseProcessID AND B.ProcessNo = A.BaseProcessNo AND 
					   B.FiscalYear = A.BaseFiscalYear AND B.SerialNo = A.BaseSerialNo AND 
					   B.DocRowNo = A.BaseDocRowNo AND A.GoodsID = @GoodsID AND 
					   (@StoreID IS NULL OR (A.StoreID = @StoreID))  AND 
					   (@UserPriceID =0 or A.UserPriceID=@UserPriceID)
					   AND A.ProcessID=100
				END
		END
	ELSE
		BEGIN

  			-- ======
			SELECT @QtyRemain = ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End
			FROM sal.tblSaleOrderDtl S INNER JOIN
			(
				SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderHdr 
				WHERE ProcessID=180  
				EXCEPT
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				WHERE BaseProcessID=180 AND ProcessID=90  
			) A
			ON A.ProcessID=S.ProcessID AND A.ProcessNo=S.ProcessNo AND A.FiscalYear=S.FiscalYear AND 
			   A.SerialNo=S.SerialNo
			WHERE S.ProcessID = 180 AND
				  DocDate <= @DocDate AND 
				  S.FiscalYear= @FiscalYear AND
				  GoodsID = @GoodsID AND (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))  AND 
				  (@UserPriceID =0 or UserPriceID=@UserPriceID)

  			-- ======
			SELECT @QtyRemain= @QtyRemain - ISNULL(SUM(GoodsQuantity),0) --Case When @SorHasFirstConfirm = 'True' Then ISNULL(SUM(ConfirmQuantity),0) Else ISNULL(SUM(GoodsQuantity),0) End 
			FROM sal.tblSaleOrderDtl S INNER JOIN
			(
				SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderHdr
				WHERE ProcessID=180  
				EXCEPT
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				WHERE BaseProcessID=180 AND ProcessID=90  
			) A
			ON A.ProcessID=S.BaseProcessID AND A.ProcessNo=S.BaseProcessNo AND 
			   A.FiscalYear=S.BaseFiscalYear AND A.SerialNo=S.BaseSerialNo
			WHERE BaseProcessID = 180 AND
				  DocDate <= @DocDate AND 
				  BaseFiscalYear= @FiscalYear AND
				  GoodsID = @GoodsID AND (StoreID = '' OR @StoreID IS NULL OR (StoreID = @StoreID))  AND 
				  (@UserPriceID =0 or UserPriceID=@UserPriceID)

		END

		IF @QtyRemain<0
			set @QtyRemain = 0

		SELECT @QtyRemain=  ISNULL(SUM(GoodsQuantity * EnterKind),0) - ISNULL(@QtyRemain,0)
		FROM inv.tblStorageDocsDtl
		WHERE (StoreID = @StoreID) AND GoodsID = @GoodsID AND  FiscalYear =@FiscalYear  AND 
			  (@UserPriceID =0 or UserPriceID=@UserPriceID)


	RETURN @QtyRemain 

END
GO
