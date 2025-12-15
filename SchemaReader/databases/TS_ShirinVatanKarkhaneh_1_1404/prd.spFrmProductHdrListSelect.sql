USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 87/02/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[spFrmProductHdrListSelect] 
	@BaseProcessID	Tinyint,
	@ProcessID		Tinyint,
	@ProcessNo		Tinyint,
	@DocDate		Char(10),
	@AcntCode		VarChar(20),
	@StoreID		VarChar(20),
	@DocStep		Tinyint,
	@DocStep2		Tinyint,
	@GroupProduct	Tinyint,
	@ExtraParams		NVarChar(Max) = ''
	
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;
 
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	DECLARE @LanguageID AS TinyInt
	SET @LanguageID = pub.funGetCurrentLanguageID()

	--=======
	Declare @DecreasePrdQtyByPrdSendRet AS bit
	SELECT @DecreasePrdQtyByPrdSendRet = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DecreasePrdQtyByPrdSendRet'
	
	--=======
IF @DocDate = ''
	BEGIN
		IF @ProcessID = 80
			BEGIN
				SELECT Distinct a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocDate ,a.StoreID,
					   [pub].[GetStoreName](a.StoreID,@LanguageID)  StoreName,a.AcntCode,
					   [pub].[GetCodeName](a.AcntCode,@LanguageID) AcntName,GoodsID ProductID,[pub].[funGetGoodsName](GoodsID,@LanguageID) ProductName
				FROM inv.tblStorageDocsDtl a
				inner join inv.tblStorageDocsHdr b
				on a.ProcessID=b.ProcessID
				and a.ProcessNo=b.ProcessNo
				and a.FiscalYear=b.FiscalYear
				and a.SerialNo=b.SerialNo

				WHERE a.ProcessID= @ProcessID AND a.ProcessNo= @ProcessNo AND a.DocStep=@DocStep 
				 and (
				(@ConfirmCount=0 and (	(@Confirm=0 and a.DocStep=1)
									  or(@Confirm=1 and a.DocStep=2)
									  )
				)or 
				(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
								 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
								 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
								 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)		
			END
		ELSE IF @ProcessID = 70 AND @BaseProcessID = 70
			BEGIN

			--select @ConfirmCount,@Confirm,@Sgn1,@Sgn2
				SELECT H.ProductID,[pub].[funGetGoodsName](H.ProductID,@LanguageID) ProductName,H.ProductCount,H.StoreID,
				       pub.GetStoreName(H.StoreID,@LanguageID)  StoreName,D.* ,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
				FROM inv.tblStorageDocsHdr H 
				INNER JOIN 
					(
					SELECT Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate ,AcntCode,
						   [pub].[GetCodeName](AcntCode,@LanguageID) AcntName
					FROM inv.tblStorageDocsDtl
					WHERE ProcessID= @ProcessID AND ProcessNo= @ProcessNo AND DocStep=@DocStep And EnterKind<>0 
					)D
				ON 	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
				H.FiscalYear=D.FiscalYear AND  H.SerialNo=D.SerialNo
				where (H.ProcessID=@ProcessID OR H.StoreID2='') 
				  AND (SELECT COUNT(*) from inv.tblStorageDocsHdr H1 WHERE H1.ProcessID=80 and H.ProcessID=H1.BaseProcessID AND H.ProcessNo=H1.BaseProcessNo AND H.FiscalYear=H1.BaseFiscalYear AND H.SerialNo=H1.BaseSerialNo )=0
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
			END	
		ELSE
			BEGIN

			--select @ConfirmCount,@Confirm,@Sgn1,@Sgn2
				SELECT H.ProductID,[pub].[funGetGoodsName](H.ProductID,@LanguageID) ProductName,H.ProductCount,D.* ,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
				FROM inv.tblStorageDocsHdr H INNER JOIN 
					(
					SELECT Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate ,StoreID,
						   [pub].[GetStoreName](StoreID,@LanguageID)  StoreName,AcntCode,
						   [pub].[GetCodeName](AcntCode,@LanguageID) AcntName
					FROM inv.tblStorageDocsDtl
					WHERE ProcessID= @ProcessID AND ProcessNo= @ProcessNo AND DocStep=@DocStep And EnterKind<>0 
					)D
				ON 	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
				H.FiscalYear=D.FiscalYear AND  H.SerialNo=D.SerialNo
				where (H.ProcessID=@ProcessID OR H.StoreID2='')
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
			END	
	END
	
	
ELSE IF @ProcessID = 70
	SELECT 0 AS FiscalYear,SerialNo,AcntCode ,[pub].[GetCodeName](AcntCode,@LanguageID) AcntName
	FROM prd.tblProductGroupsHdr
	WHERE (@AcntCode IS NULL OR AcntCode=@AcntCode) AND 
	      SerialNo NOT IN (SELECT BaseSerialNo 
						   FROM inv.tblStorageDocsDtl 
						   WHERE ProcessID= @ProcessID AND ProcessNo= @ProcessNo AND BaseSerialNo <> 0 )
	
ELSE IF @ProcessID = 75

	SELECT H.ProductID,[pub].[funGetGoodsName](H.ProductID,@LanguageID) ProductName,D.* 
	FROM inv.tblStorageDocsHdr H INNER JOIN 
		(
		SELECT DISTINCT Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo ,DocDate,StoreID,
		   [pub].[GetStoreName](StoreID,@LanguageID)  StoreName, Cnf.AcntCode,
		   [pub].[GetCodeName](Cnf.AcntCode,@LanguageID) AcntName
		From  [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep2,@ProcessNo) Cnf 
		INNER JOIN inv.tblStorageDocsDtl A
		ON	Cnf.ProcessID = A.ProcessID AND Cnf.ProcessNo = A.ProcessNo AND 
			Cnf.FiscalYear = A.FiscalYear AND Cnf.SerialNo = A.SerialNo AND 
			Cnf.DocRowNo = A.DocRowNo 
		WHERE Cnf.ConfirmQuantity > 0
		) D
	ON 	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
	    H.FiscalYear=D.FiscalYear AND  H.SerialNo=D.SerialNo
		where 1=1  and (
				(@ConfirmCount=0 and (	(@Confirm=0 and DocStep in(1,2))
									  or(@Confirm=1 and DocStep in(1,2))
									  )
				)or 
				(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
								 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
								 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
								 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)		
ELSE IF @ProcessID = 77

	SELECT H.ProductID,H.ProductCount,H.AcntCode,[pub].[GetCodeName](H.AcntCode,@LanguageID) AcntName,
		   [pub].[funGetGoodsName](H.ProductID,@LanguageID) ProductName,  
		    case when ltrim(rtrim(H.StoreID))='' or H.StoreID is null then 
 (	Select top 1 GoodsInProductionAcntCode From  inv.tblStores S 	inner join   inv.tblStorageDocsDtl b
		on b.StoreID=S.StoreID 
		where  H.ProcessID=b.ProcessID AND H.ProcessNo=b.ProcessNo AND      
           H.FiscalYear=b.FiscalYear AND  b.SerialNo=b.SerialNo  ) 
  else 
 (Select GoodsInProductionAcntCode From  inv.tblStores S  where H.StoreID=S.StoreID  ) end 
 GoodsInProductionAcntCode ,D.* 
	FROM inv.tblStorageDocsHdr H INNER JOIN 
		(
			SELECT ProcessID,ProcessNo,FiscalYear,SerialNo 
			FROM [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep2,@ProcessNo)
			EXCEPT
			SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
			FROM [prd].[FunGetBaseProduct](@AcntCode,@DocDate,1,2,@ProcessNo)
		) D
	ON 	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
	    H.FiscalYear=D.FiscalYear AND  H.SerialNo=D.SerialNo
	
	where 1=1  and (
				(@ConfirmCount=0 and (	(@Confirm=0 and DocStep in(1,2))
									  or(@Confirm=1 and DocStep in(1,2))
									  )
				)or 
				(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
								 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
								 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
								 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)		
ELSE IF @ProcessID = 80
	BEGIN
		IF @GroupProduct = 1
		BEGIN
			SELECT DISTINCT Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo ,A.DocDate,A.StoreID,Cnf.ProductCount,[pub].[funGetGoodsName](A.ProductID,@LanguageID) ProductName,A.ProductID,
					[pub].[GetStoreName](StoreID,@LanguageID) StoreName,A.AcntCode,[pub].[GetCodeName](A.AcntCode,@LanguageID) AcntName,B.DocDesc
			From  	
			(
				SELECT ProcessID,ProcessNo,FiscalYear,SerialNo ,A.ProductCount  ProductCount
				FROM (SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo ,ProductCount FROM [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep2,@ProcessNo)) A
				LEFT JOIN [prd].[FunGetBaseProduct](@AcntCode,@DocDate,1,2,@ProcessNo) B
				ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo AND
					A.FiscalYear=B.BaseFiscalYear AND A.SerialNo=B.BaseSerialNo
				WHERE B.ConfirmQuantity IS NULL
			)Cnf 
			INNER JOIN inv.tblStorageDocsHdr A
			ON	Cnf.ProcessID = A.ProcessID AND Cnf.ProcessNo = A.ProcessNo AND 
				Cnf.FiscalYear = A.FiscalYear AND Cnf.SerialNo = A.SerialNo 
			LEFT JOIN prd.tblProductGroupsHdr B
			On A.BaseSerialNo = B.SerialNo AND A.AcntCode = B.AcntCode
			where 1=1  and (
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
		END
	ELSE
		BEGIN
			DECLARE @AllowEditQuantityInProductReceive AS BIT
			DECLARE @ProduceSendConfirmCount AS tinyint

			SET @AllowEditQuantityInProductReceive = 'False'
			SET @ProduceSendConfirmCount = 0
		
			SELECT @AllowEditQuantityInProductReceive = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'prdAllowEditQuantityInProductReceive' 
	
			SELECT @ProduceSendConfirmCount = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ProduceSendConfirmCount'

			SELECT H.ProductID,[pub].[funGetGoodsName](H.ProductID,@LanguageID) ProductName,H.ProductID,D.* 
			FROM inv.tblStorageDocsHdr H INNER JOIN 
				(
				SELECT DISTINCT Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, DocDate, IsNull(StoreID,'') StoreID, Cnf.ProductCount -isnull(RD.SubUnitQuantity,0)ProductCount ,
							    --IsNull(Case When @DecreasePrdQtyByPrdSendRet = 1 Then IsNull([prd].[FunGetProductSendRemain] (Cnf.ProcessNo, Cnf.SerialNo), 0) Else Cnf.ProductCount End, 0) ProductCount,
							    IsNull([pub].[GetStoreName](StoreID,@LanguageID), '') StoreName, AcntCode, [pub].[GetCodeName](AcntCode,@LanguageID) AcntName
				From  	
				(
					SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, 
						   A.ProductCount - 
						   IsNull((prd.funMaxRetProduct(ProcessID, ProcessNo, FiscalYear, SerialNo, 1)),0) - 
						   ISNULL(B.ConfirmQuantity,0) ProductCount
					FROM (SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo ,ProductCount FROM [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep2,@ProcessNo)) A
					LEFT JOIN [prd].[FunGetBaseProduct](@AcntCode,@DocDate,1,2,@ProcessNo) B
					ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo AND
					   A.FiscalYear=B.BaseFiscalYear AND A.SerialNo=B.BaseSerialNo
					WHERE (@AllowEditQuantityInProductReceive = 'False' AND 
						  ISNULL(B.ConfirmQuantity,0) = 0) OR 
						  (@AllowEditQuantityInProductReceive = 'True' AND 
						  A.ProductCount - 
						  IsNull((prd.funMaxRetProduct(ProcessID, ProcessNo, FiscalYear, SerialNo, 1)),0) - 
						  ISNULL(B.ConfirmQuantity,0) > 0)
				)Cnf 
				INNER JOIN inv.tblStorageDocsHdr A
				ON	Cnf.ProcessID = A.ProcessID AND Cnf.ProcessNo = A.ProcessNo AND 
					Cnf.FiscalYear = A.FiscalYear AND Cnf.SerialNo = A.SerialNo 
				Left JOIN 
				( select ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID,Sum(GoodsQuantity) GoodsQuantity,Sum(SubUnitQuantity) SubUnitQuantity from  inv.tblStorageDocsDtl
				  where BaseProcessID=79 and ProcessID=80
				  group by ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID) AS RD 
				  ON RD.BaseProcessID = A.BaseProcessID AND RD.BaseProcessNo = A.BaseProcessNo AND RD.BaseFiscalYear = A.BaseFiscalYear 
				  AND RD.BaseSerialNo = A.BaseSerialNo and A.ProductID =RD.GoodsID
			WHERE (
					(@ProduceSendConfirmCount = 0)
					OR (@ProduceSendConfirmCount = 1 AND SgnSN1<>0)
					OR (@ProduceSendConfirmCount = 2 AND SgnSN1<>0 AND SgnSN2<>0)
					OR (@ProduceSendConfirmCount = 3 AND SgnSN1<>0 AND SgnSN2<>0 AND SgnSN3<>0)
					OR (@ProduceSendConfirmCount = 4 AND SgnSN1<>0 AND SgnSN2<>0 AND SgnSN3<>0 AND SgnSN4<>0)
					OR (@ProduceSendConfirmCount = 5 AND SgnSN1<>0 AND SgnSN2<>0 AND SgnSN3<>0 AND SgnSN4<>0 AND SgnSN5<>0)
					)
				) D
			ON 	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
				H.FiscalYear=D.FiscalYear AND  H.SerialNo=D.SerialNo
			where D.ProductCount>0
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
		END
	END

END
GO
