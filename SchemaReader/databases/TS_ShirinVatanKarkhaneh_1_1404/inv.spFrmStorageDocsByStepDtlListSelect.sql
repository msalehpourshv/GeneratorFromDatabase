USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 1393/08/21 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE inv.spFrmStorageDocsByStepDtlListSelect
	@BaseProcessID	VarChar(20),
	@ProcessID		Tinyint,
	@ProcessNo		Tinyint,
	@AcntCode		VarChar(20),
	@GoodsID		VarChar(20),
	@StoreID		VarChar(20),
	@DocDate		Char(10),
	@LanguageID		int,
	@SerialNo		Int,
	@FiscalYear		SmallInt,
	@BaseFiscalYear	Smallint,
	@BaseSerialNo	Int ,
	@ExtraParams	NVarChar(Max) 
WITH ENCRYPTION
AS

BEGIN

DECLARE @buy_StoreDtl AS BIT

	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;

	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	
	SET @buy_StoreDtl = 'False'
		
	SELECT @buy_StoreDtl=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Buy_StoreDtl'
	
	-- ==================
	SET NOCOUNT ON;
	DECLARE @Buy_DontCheckDateConvertTempReceiptToBuy AS Bit

	SELECT @Buy_DontCheckDateConvertTempReceiptToBuy=SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'Buy_DontCheckDateConvertTempReceiptToBuy'
	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

IF @ProcessID=55 -- خرید
	BEGIN	
	IF @BaseProcessID=150 or  @BaseProcessID=160  or  @BaseProcessID=170 
	begin 
		if (SELECT isnull(SettingValue,0) FROM pub.tblSettings WHERE SettingKey = 'HasCMR234')=0
			set @ProcessNo=0
	end 	
	set @FiscalYear =isnull(@FiscalYear,0)
		IF @BaseProcessID = 150 or @BaseProcessID=160 -- درخواست خرید
			SELECT * FROM (
				SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, 
					OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep,
					OD.DocDate, OD.GoodsID, OD.SubUnitID, ConfirmQuantity SubUnitQuantity, ConfirmQuantity,
					[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,ConfirmQuantity) GoodsQuantity, 
					 DescDtl, OD.BaseProcessID,OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications, 0 As AgreeNo, 0 As HdrAgreeNo, DocDesc,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
								OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS GoodsRemain,
								ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,GoodsPrice,GoodsPrice SubUnitPrice
			
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0) OD
				WHERE OD.DocDate<=@DocDate AND ConfirmQuantity>0 AND 
					 (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) AND
					 (@GoodsID IS NULL OR OD.GoodsID = @GoodsID)
					 and (
							(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
												  or(@Confirm=1 and DocStep=2)
												  )
							)or 
							(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  							 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
											 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
											 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
											 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
							)
						)	
			) A WHERE IsCodeClosed = 0
			ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo

	ELSE IF @BaseProcessID=170  -- رسید موقت کالا

		SELECT * FROM (
			SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
					OD.DocDate, OD.GoodsID, OD.SubUnitID,  ConfirmQuantity SubUnitQuantity,ConfirmQuantity,
					[inv].[funGetGoodsQuantityFromSubUnit](OD.GoodsID, OD.SubUnitID,ConfirmQuantity) GoodsQuantity, 
					 DocDesc DescDtl, OD.BaseProcessID, 
					OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,Recognition,PenaltyPercent,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
							OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS GoodsRemain,
							ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5

			from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0) OD
			WHERE --(@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
				 (DocDate<=@DocDate or @Buy_DontCheckDateConvertTempReceiptToBuy='True') 
				  AND ConfirmQuantity>0  AND Recognition NOT IN (0,4) AND 
		          (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear))
		          and (
						(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
											  or(@Confirm=1 and DocStep=2)
											  )
						)or 
						(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  						 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)	
		) A WHERE IsCodeClosed = 0
		ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo

		ELSE IF @BaseProcessID = 56  -- باسکول خرید
			SELECT *, 0 FiscalYear, 0 DiscountDtl, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl
			FROM 
			(
			  SELECT D.*, H.AcntCode, pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName, 
					 H.DocDate, inv.funGetUnitName(D.SubUnitID,@LanguageID) AS SubUnitName, 
					 [inv].[funGetTechnicalSpecifications](D.GoodsID) AS TechnicalSpecifications, 
					 D.SubUnitQuantity As ConfirmQuantity, D.SubUnitQuantity As GoodsQuantity, D.Fee GoodsPrice,
    				 [inv].[funGetSubUnitFromGoodsQuantity](D.GoodsID, D.SubUnitID,D.SubUnitQuantity ) ConfirmSubUnitQuantity, 
					 D.Fee SubUnitPrice, H.TransportationCost, acc.funIsCodeClosed(H.AcntCode) IsCodeClosed
			  FROM 
			  (
					SELECT ProcessID, 0 ProcessNo, 0 FiscalYear, SerialNo
					FROM inv.tblBaskulSalesHdr H
					WHERE ProcessID = @BaseProcessID 
					EXCEPT
					SELECT BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, BaseSerialNo
					FROM inv.tblStorageDocsHdr 
					WHERE ProcessID = 55 And BaseProcessID = @BaseProcessID	  
			  ) H1
			  INNER JOIN inv.tblBaskulSalesHdr H ON H.ProcessID = H1.ProcessID And H.SerialNo = H1.SerialNo
			  INNER JOIN inv.tblBaskulSalesDtl D ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo
			  WHERE H.ProcessID = @BaseProcessID And 
					H.SerialNo Not In (SELECT BaseSerialNo
									   FROM inv.tblStorageDocsHdr 
									   WHERE ProcessID = 55 And BaseProcessID = 56)
			) A WHERE IsCodeClosed = 0
END

-------------------------------------------------------------------------------------------------------------

ELSE IF @ProcessID=60   -- برگشت از خرید
	SELECT * FROM (
		SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, 
				OD.RowNo, OD.VolumeRowNo, OD.DocStep, OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, 
				OD.VisitorAcntCode, BatchNo, OD.OrderAcntCode, OD.GoodsID,
				OD.QtyRemain, OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice,OD.SubUnitPrice, OD.DescDtl, OD.BaseProcessID,
				OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
				OD.TaxOverWorthCostDtl, OD.TollOverWorthCostDtl,
				pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID, @LanguageID) AS SubUnitName,
				[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
				UnitID, SubUnitID,Cn.ConfirmQuantity GoodsQuantity ,Cn.ConfirmQuantity,
				inv.funGetSubUnitFromGoodsQuantity(OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, 
				inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,([inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,
										   OD.SerialNo,OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,
										   OD.BatchNo,OD.DocDate,1))) AS Remain,
				
				inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,([inv].[funGetGoodsRemain](null,null,null,null,null,
									   CASE WHEN  @buy_StoreDtl = 'True' THEN DfStoreID ELSE @StoreID END,OD.GoodsID,OD.BatchNo,@DocDate,
									   OD.UserPriceID))) GoodsRemain,
									   				
				ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,
				OD.DiscountPercentDtl,(DiscountDtl * Cn.ConfirmQuantity )/OD.GoodsQuantity as DiscountDtl 
									
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 55 AND ProcessNo=@ProcessNo AND (@GoodsID IS NULL OR GoodsID = @GoodsID) AND 
					     (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
						  DocDate<=@DocDate AND DocStep in (0,2) 
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 55 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID  = OD.ProcessID  AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo  = OD.SerialNo  AND 
				Cn.DocRowNo   = OD.DocRowNo 
	INNER JOIN
	(
	 SELECT GoodsID, ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5, DfStoreID, UnitID  
	 FROM inv.tblGoods 
	 WHERE CodeClosed = 'False' AND PartNumber = @UnitPart) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID
	
	WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate AND Cn.ConfirmQuantity>0  AND 
		         (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear))
	) A WHERE IsCodeClosed = 0
	ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo			 
-------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID = 90
	IF @BaseProcessID = 240
		BEGIN
			DECLARE @DocStep1 tinyint
			DECLARE @HasConfirmForPreSale AS BIT
			
			SET @HasConfirmForPreSale = 'False'
			
			SELECT @HasConfirmForPreSale=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'HasConfirmForPreSale'

			IF @HasConfirmForPreSale = 'False' 
				SET @DocStep1 = 1
			ELSE
				SET @DocStep1 = 2
				
			SELECT DISTINCT CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo ,CmrCnf.DocDate  
			FROM [inv].[FunGetPreSale] (@AcntCode,@DocDate,@DocStep1) AS CmrCnf
			INNER JOIN 		
			(	
				SELECT DISTINCT ProcessID , ProcessNo , FiscalYear , SerialNo 
				FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@DocStep1)  
				WHERE ProcessNo = @ProcessNo			
			EXCEPT
				(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
				From [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear)
				UNION
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
				FROM sal.tblSaleOrderDtl
				WHERE BaseProcessID=240
				)				
			) AS StorageDocs
				ON CmrCnf.ProcessID = StorageDocs.ProcessID AND  CmrCnf.ProcessNo = StorageDocs.ProcessNo AND 
				CmrCnf.FiscalYear = StorageDocs.FiscalYear AND CmrCnf.SerialNo = StorageDocs.SerialNo 
		END
	ELSE
		BEGIN
			DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
			DECLARE @DocStep tinyint
			DECLARE @SalRet_RetToSalOdr AS BIT
			DECLARE @DontCheckProcessNoInSale AS BIT

			SET @SalOrder_ConfirmDocStep = 'False'
			SET @SalRet_RetToSalOdr = 'False'
			SET @DontCheckProcessNoInSale = 'False'
			
			SELECT @SalRet_RetToSalOdr = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'SalRet_RetToSalOdr' 
			
			SELECT @SalOrder_ConfirmDocStep=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'SalOrder_ConfirmDocStep'

			SELECT @DontCheckProcessNoInSale=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'DontCheckProcessNoInSale'
			
			if @DontCheckProcessNoInSale = 'True' and @ProcessID = 90
				SET @ProcessNo = NULL
			
			IF @SalOrder_ConfirmDocStep = 'False' 
				SET @DocStep = 1
			ELSE
				SET @DocStep = 2
				
		SELECT * FROM (
			SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo,
					OD.DocStep, OD.DocDate, OD.AcntCode, OD.GoodsID, OD.SubUnitID, CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity, 
				    [inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity) SubUnitQuantity, 
					CMRSaleOrderHdr.ConfirmQuantity, OD.DescDtl, 
					OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear,OD.BaseSerialNo, OD.BaseDocRowNo,
					[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
					pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName,inv.funGetUnitName(OD.SubUnitID,@LanguageID) AS SubUnitName  ,
					[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,OD.UserPriceID) GoodsRemain ,CMRSaleOrderHdr.GoodsPrice
			FROM	
				(
				Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,
						CmrCnf.ConfirmQuantity  AS ConfirmQuantity   ,GoodsPrice
						--CmrCnf.ConfirmQuantity  - ISNULL(CmrOrder.ConfirmQuantity,0)  AS ConfirmQuantity   ,GoodsPrice
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,@FiscalYear,@SerialNo) 
						WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo)			
					) CmrCnf 
				--LEFT JOIN 
				--	(
				--		SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
				--		FROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
				--	) CmrOrder
				--	ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
				--	CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
				--	CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 

				) CMRSaleOrderHdr
			INNER JOIN
			sal.tblSaleOrderDtl OD
			ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
				OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
				OD.DocRowNo = CMRSaleOrderHdr.DocRowNo 
			INNER JOIN
			(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart  ) G
			ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 		
			WHERE	(@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND  (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND
					OD.DocDate<=@DocDate AND CMRSaleOrderHdr.ConfirmQuantity>0 AND 
   					(@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
		) A WHERE IsCodeClosed = 0
		ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo			
		END
-------------------------------------------------------------------------------------------------------------
IF @ProcessID=110  -- مصرف داخلی

SELECT * FROM (
	SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
			OD.DocDate, OD.GoodsID, OD.SubUnitID, CMROrderHdr.ConfirmQuantity GoodsQuantity,CMROrderHdr.ConfirmQuantity,
			[inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,CMROrderHdr.ConfirmQuantity) SubUnitQuantity, 
			OD.DescDtl, OD.BaseProcessID,OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS Remain,
					ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
	FROM	
		(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
					CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity  
			From
			(
				Select	A.ProcessID , A.ProcessNo , A.FiscalYear , A.SerialNo,A.DocRowNo,A.DocDate,A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) as ConfirmQuantity
				FROM  inv.tblStoresRequestsDtl  A
				LEFT JOIN  inv.tblStoresRequestsDtl B
				ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND  A.FiscalYear = B.BaseFiscalYear AND 
    			   A.SerialNo  = B.BaseSerialNo AND  A.DocRowNo  = B.BaseDocRowNo AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) > 0
				WHERE A.ProcessID = 230 AND (@GoodsID IS NULL OR A.GoodsID = @GoodsID) 
			) CmrCnf 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetBaseStorageDocsGoodsUse](@AcntCode,@DocDate) 
			) StorageDocs
			ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
			   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
			   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<=@DocDate 
		) CMROrderHdr
	INNER JOIN
	inv.tblStoresRequestsDtl OD
	ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
	   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
	   OD.DocRowNo = CMROrderHdr.DocRowNo 
	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
	WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND CMROrderHdr.ConfirmQuantity>0 AND 
		  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
		) A WHERE IsCodeClosed = 0
		ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo
-------------------------------------------------------------------------------------------------------------
IF @ProcessID=115  -- برگشت مصرف داخلی
SELECT * FROM (
	SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo ,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, ConfirmQuantity GoodsQuantity, Cn.ConfirmQuantity, OD.QtyRemain, 
			[inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,OD.BatchNo,DocDate,1)  AS GoodsRemain,
						ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 110 AND ProcessNo=@ProcessNo AND (@GoodsID IS NULL OR GoodsID = @GoodsID) AND
					      (@AcntCode IS NULL OR AcntCode = @AcntCode) AND
						  DocDate<=@DocDate AND DocStep >= 1
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 110 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID  = OD.ProcessID  AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo  = OD.SerialNo  AND 
				Cn.DocRowNo   = OD.DocRowNo 
		INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart  ) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 				
		WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate AND Cn.ConfirmQuantity>0  AND 
  	          (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) 
		) A WHERE IsCodeClosed = 0
		ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo
-------------------------------------------------------------------------------------------------------------
IF @ProcessID=250  -- 

SELECT * FROM (
	SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
			OD.DocDate, OD.GoodsID, OD.SubUnitID, CMROrderHdr.ConfirmQuantity GoodsQuantity,CMROrderHdr.ConfirmQuantity,
			[inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,CMROrderHdr.ConfirmQuantity) SubUnitQuantity, 
			OD.DescDtl, OD.BaseProcessID,OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			[inv].[funGetGoodsRemain](null,null,null,null,null,@StoreID,OD.GoodsID,'',@DocDate,0) GoodsRemain,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS Remain,
					ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
	FROM	
		(
			Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
					CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity  
			From
			(
				Select	ProcessID , ProcessNo , FiscalYear , SerialNo,DocRowNo,DocDate,GoodsQuantity as ConfirmQuantity
				FROM  inv.tblStoresRequestsDtl 
				WHERE (@GoodsID IS NULL OR GoodsID = @GoodsID) 

			) CmrCnf 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [ast].[FunGetBaseStorageDocsGoodsAssetDelivery](@AcntCode,@DocDate) 
			) StorageDocs
			ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
			   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
			   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<=@DocDate 
		) CMROrderHdr
	INNER JOIN
	inv.tblStoresRequestsDtl OD
	ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
	   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
	   OD.DocRowNo = CMROrderHdr.DocRowNo 
	INNER JOIN
	(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart  ) G
	ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
	WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND OD.DocDate<=@DocDate AND CMROrderHdr.ConfirmQuantity>0 AND 
		  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear))
		) A WHERE IsCodeClosed = 0
	ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo
-------------------------------------------------------------------------------------------------------------
IF @ProcessID=255  -- 
SELECT * FROM (
	SELECT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo ,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, Cn.ConfirmQuantity, Cn.ConfirmQuantity GoodsQuantity, OD.QtyRemain, 
			[inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID, OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,OD.GoodsID,OD.BatchNo,DocDate,1)  AS GoodsRemain,
						ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.DocRowNo,
					Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) ConfirmQuantity
			From
				(
					Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where ProcessID = 250 AND ProcessNo=@ProcessNo AND (@GoodsID IS NULL OR GoodsID = @GoodsID) AND 
						  (@AcntCode IS NULL OR AcntCode = @AcntCode) AND
						  DocDate<=@DocDate AND DocStep >= 1
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
						BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 250 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						 BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
		) Cn ON Cn.ProcessID  = OD.ProcessID  AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo  = OD.SerialNo  AND 
				Cn.DocRowNo   = OD.DocRowNo 
		INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart  ) G
		ON SUBSTRING(OD.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID 
		WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate AND Cn.ConfirmQuantity>0  AND 
  	          (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear))
		) A WHERE IsCodeClosed = 0
		ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo
END
GO
