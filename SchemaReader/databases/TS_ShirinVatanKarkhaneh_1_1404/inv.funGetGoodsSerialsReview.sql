USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 98/11/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--select * from [inv].[funGetGoodsSerialsReview](2,9,5,1,1,7,1,'True',0,'','','','','','',0)
Create FUNCTION [inv].[funGetGoodsSerialsReview]
(
@AcntPart as tinyint,
@AcntStart as tinyint,
@AcntLen as tinyint,
@GoodsPart as tinyint,
@GoodsStart as tinyint,
@GoodsLen as tinyint,
@LanguageID as tinyint,
@UserIsAdmin as bit,
@UserID as integer,
@StoreID as varchar(20),
@GoodsID as varchar(20),
@FromDate as varchar(10),
@ToDate as varchar(10),
@AcntCode as varchar(20),
@BatchNo as varchar(20),
@UserPriceID as bigint,
@SerialNo as bigint
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	SELECT H.ProcessID,
	H.ProcessNo,
	H.FiscalYear,
	H.SerialNo,
	H.DocDate,
	H.VchDate,
	H.VchNo, 
	CASE WHEN H.ProcessID = 188 THEN 1 WHEN H.ProcessID = 189 THEN -1 ELSE D.EnterKind END EnterKind,
	D.DocRowNo,
	D.AcntCode,
	D.StoreID,
	D.GoodsID,
	D.SubUnitID,
	D.BatchNo, 
	ISNULL(SS.ProductSerialID,0) ProductSerialID,
	SS.PSerialNo,
	SS.ContainerID,
	SS.NumberPerContainer,
	D.UserPriceID,
	CAST (D.GoodsQuantity AS FLOAT) GoodsQuantity,
	CAST (D.SubUnitQuantity AS FLOAT) SubUnitQuantity,
	D.GoodsAmount,
	D.GoodsPrice,
	D.VolumeRowNo,
	ISNULL(BD.BatchName,'') BatchName,
	ISNULL(BD.BatchExtraField1,'') BatchExtraField1,
	ISNULL(BD.BatchExtraField2,'') BatchExtraField2,
	ISNULL(BD.BatchExtraField3,'') BatchExtraField3,
	ISNULL(BD.BatchExtraField4,'') BatchExtraField4, 
	ISNULL(B.BatchCount,0.0) BatchCount,
	ISNULL(B.ExpireDate,'') ExpireDateBatch,
	ISNULL(SS.ExpireDate,'') ExpireDate,
	ISNULL(SS.ProductionDate,'') ProductionDate, 
	ISNULL(A.AcntName,'') AcntName,
	ISNULL(S.StoreName,'') StoreName,
	ISNULL(pub.funGetProcessName(H.ProcessID,H.ProcessNo,1),'') ProcessName, 
	ISNULL(G.GoodsName,'') GoodsName,
	ISNULL(U.UnitName,'') UnitName, 
	inv.funGetContainerStoresName(SS.ContainerStoresID,1) ContainerStoresName,
	SS.ContainerStoresID, 
	CAST(ISNULL(Faults.Diff,0) AS INT) ContainerDifference
	FROM inv.tblStorageDocsHdr H 
	INNER JOIN inv.tblStorageDocsDtl D ON H.ProcessID = D.ProcessID 
									  AND H.ProcessNo = D.ProcessNo 
									  AND H.FiscalYear = D.FiscalYear 
									  AND H.SerialNo = D.SerialNo 
	INNER JOIN inv.tblStorageDocsSerials SS ON SS.ProcessID = D.ProcessID 
										   AND SS.ProcessNo = D.ProcessNo 
										   AND SS.FiscalYear = D.FiscalYear 
										   AND SS.SerialNo = D.SerialNo 
										   AND SS.DocRowNo = D.DocRowNo
	LEFT JOIN acc.tblAcntDtl A ON SUBSTRING(D.AcntCode,@AcntStart,@AcntLen) = A.AcntCode 
							  AND A.LanguageID = @LanguageID 
							  AND A.PartNumber = @AcntPart 
	LEFT JOIN inv.tblStoresDtl S ON D.StoreID=S.StoreID 
								AND S.LanguageID = @LanguageID
	--Left Join pub.tblProcess P ON H.ProcessID=P.ProcessID and H.ProcessNo=P.ProcessNo 
	LEFT JOIN inv.tblGoodsDtl G ON SUBSTRING(D.GoodsID,@GoodsStart,@GoodsLen) = G.GoodsID 
							   AND G.LanguageID = @LanguageID 
							   AND G.PartNumber = @GoodsPart 
	LEFT JOIN inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID 
							   AND A.LanguageID = @LanguageID
	LEFT JOIN inv.tblBatch B ON D.BatchNo=B.BatchNo 
	LEFT JOIN inv.tblBatchDtl BD ON D.BatchNo = BD.BatchNo 
								AND BD.LanguageID = @LanguageID 
	LEFT JOIN 
		 (SELECT a.ProcessID, 
				 a.ProcessNo, 
				 a.FiscalYear, 
				 a.SerialNo, 
				 a.GoodsQuantity - b.NumberPerContainer Diff, 
				 GoodsID
		  FROM (
				SELECT ProcessID, 
					   ProcessNo, 
					   FiscalYear, 
					   SerialNo, 
					   DocRowNo, 
					   StoreID, 
					   EnterKind, 
					   (EnterKind * GoodsQuantity) GoodsQuantity, 
					   SubUnitQuantity, 
					   GoodsID
				FROM inv.tblStorageDocsDtl 
				WHERE GoodsID in (SELECT GoodsID 
								  FROM inv.tblGoods 
								  WHERE HasContainer = 1)
				) a 
		  INNER JOIN (
					  SELECT ProcessID, 
							 ProcessNo, 
							 FiscalYear, 
							 SerialNo, 
							 DocRowNo, 
							 StoreID, 
							 EnterKind, 
							 Sum(NumberPerContainer * a.EnterKind) NumberPerContainer
					  FROM inv.tblStorageDocsSerials a
					  GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, StoreID, DocRowNo, EnterKind 
					  ) b ON a.ProcessID=b.ProcessID
						 AND a.ProcessNo=b.ProcessNo
						 AND a.FiscalYear=b.FiscalYear
						 AND a.SerialNo=b.SerialNo
						 AND a.DocRowNo=b.DocRowNo
						 AND a.StoreID=b.StoreID
		  WHERE GoodsQuantity <> NumberPerContainer
		  ) Faults ON Faults.ProcessID = H.ProcessID 
				  AND Faults.ProcessNo = H.ProcessNo 
				  AND Faults.FiscalYear = H.FiscalYear 
				  AND Faults.SerialNo = H.SerialNo
				  AND Faults.GoodsID = D.GoodsID
	WHERE (@StoreID='' OR D.StoreID=@StoreID) 
	  AND (@GoodsID='' OR D.GoodsID=@GoodsID) 
	  AND (@AcntCode='' OR D.AcntCode=@AcntCode) 
	  AND (@BatchNo='' OR D.BatchNo=@BatchNo) 
	  AND (@UserPriceID=0 OR D.UserPriceID=@UserPriceID) 
	  AND (@SerialNo=0 OR D.SerialNo=@SerialNo) 
	  AND (@FromDate='' OR D.DocDate>=@FromDate) 
	  AND (@ToDate='' OR D.DocDate<=@ToDate) 
	  AND (D.EnterKind<>0 or H.ProcessID in(188,189)) 
	  AND (@UserIsAdmin = 'True' OR ( 
			(SELECT	 IsNull(COUNT(*), 0)
		 	 FROM inv.tblGoodsRng
			 WHERE (UserID = @UserID) 
			   AND (PartNumber = @GoodsPart) 
			   AND (AccessAllCode=1 OR ((AllowCodeView = 1) 
			   AND (LEFT(ISNULL(D.GoodsID,''), LEN(ToCode)) >= FromCode) 
			   AND (LEFT(ISNULL(D.GoodsID,''), LEN(ToCode)) <= ToCode))))>0 
			   AND (SELECT IsNull(COUNT(*), 0)
		 			FROM inv.tblStoresRng
					WHERE (UserID = @UserID) 
					  AND (AccessAllCode=1 OR ((AllowCodeView = 1) 
					  AND (LEFT(ISNULL(D.StoreID,''), LEN(ToCode)) >= FromCode) 
					  AND (LEFT(ISNULL(D.StoreID,''), LEN(ToCode)) <= ToCode))))>0))

	--UNION ALL
	
	--SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,H.DocDate,H.DocDate VchDate,H.VchNo, 
	--	   Case when  SS.ProcessID=188 then 1 else -1 end  EnterKind,D.DocRowNo,D.AcntCode,D.StoreID ,D.GoodsID,D.SubUnitID,'' BatchNo, 
	--	   SS.ProductSerialID,SS.PSerialNo,SS.ContainerID,SS.NumberPerContainer,
	--	   D.UserPriceID,cast (D.GoodsQuantity as float )GoodsQuantity,cast (D.SubUnitQuantity  as float )SubUnitQuantity,
	--	   D.GoodsPrice GoodsAmount,D.GoodsPrice,cast (0.0 as float ) VolumeRowNo,
	--	   '' BatchName,
	--	   '' BatchExtraField1,'' BatchExtraField2,'' BatchExtraField3,'' BatchExtraField4, 
	--	   cast (0.0 as float ) BatchCount,'' ExpireDate, 
	--	   ISNULL(A.AcntName,'') AcntName,ISNULL(S.StoreName,'')StoreName,ISNULL(pub.funGetProcessName(H.ProcessID,H.ProcessNo,1),'')ProcessName, 
	--	   ISNULL(G.GoodsName,'') GoodsName,ISNULL(U.UnitName,'')UnitName
	--FROM sal.tblSaleOrderHdr H 
	--inner join sal.tblSaleOrderDtl D ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	--inner join inv.tblStorageDocsSerials SS ON  SS.ProcessID=D.ProcessID AND SS.ProcessNo=D.ProcessNo AND SS.FiscalYear=D.FiscalYear AND SS.SerialNo=D.SerialNo AND SS.DocRowNo=D.DocRowNo
	--Left Join acc.tblAcntDtl A ON SUBSTRING(D.AcntCode,@AcntStart,@AcntLen)=A.AcntCode and A.LanguageID=@LanguageID and A.PartNumber=@AcntPart 
	--Left Join inv.tblStoresDtl S ON D.StoreID=S.StoreID and S.LanguageID=@LanguageID
	----Left Join pub.tblProcess P ON H.ProcessID=P.ProcessID and H.ProcessNo=P.ProcessNo 
	--Left Join inv.tblGoodsDtl G ON SUBSTRING(D.GoodsID,@GoodsStart,@GoodsLen)=G.GoodsID and G.LanguageID=@LanguageID and G.PartNumber=@GoodsPart 
	--Left Join inv.tblUnitsDtl U ON D.SubUnitID=U.UnitID  and A.LanguageID=@LanguageID
	--WHERE  H.ProcessID in (188,189) AND (@StoreID='' OR D.StoreID=@StoreID) AND 
	--	(@GoodsID='' OR D.GoodsID=@GoodsID) AND 
	--	(@AcntCode='' OR D.AcntCode=@AcntCode) AND 
	--	(@UserPriceID=0 OR D.UserPriceID=@UserPriceID) AND 
	--	(@SerialNo=0 OR D.SerialNo=@SerialNo) AND 		
	--	(@FromDate='' OR D.DocDate>=@FromDate) AND 
	--	(@ToDate='' OR D.DocDate<=@ToDate) AND 
	--	(@UserIsAdmin = 'True' OR ( 
	--		(SELECT	 IsNull(COUNT(*), 0)
	--	 	 FROM inv.tblGoodsRng
	--		 WHERE	(UserID = @UserID) AND (PartNumber = @GoodsPart) AND (AccessAllCode=1 OR ((AllowCodeView = 1) AND
	--			(LEFT(ISNULL(D.GoodsID,''), LEN(ToCode)) >= FromCode) AND 
	--			(LEFT(ISNULL(D.GoodsID,''), LEN(ToCode)) <= ToCode))))>0 AND
	--		(SELECT	 IsNull(COUNT(*), 0)
	--	 	 FROM inv.tblStoresRng
	--		 WHERE	(UserID = @UserID) AND (AccessAllCode=1 OR ((AllowCodeView = 1) AND
	--			(LEFT(ISNULL(D.StoreID,''), LEN(ToCode)) >= FromCode) AND 
	--			(LEFT(ISNULL(D.StoreID,''), LEN(ToCode)) <= ToCode))))>0))				
			
)
GO
