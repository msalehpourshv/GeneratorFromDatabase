USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Seyyed Mahdi Mostafavi
-- Create date   : 1403/06/
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [inv].[funGetGoodsPosInStoreReview]
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
@FromExpireDate as varchar(10),
@ToExpireDate as varchar(10),
@AcntCode as varchar(20),
@UserPriceID as bigint,
@SerialNo as bigint
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	SELECT H.ProcessID,
		ISNULL( pub.funGetProcessName(H.ProcessID,H.ProcessNo,@LanguageID),'')ProcessName,
		H.ProcessNo,
		--P.ProcessName,
		H.FiscalYear,
		H.SerialNo,
		H.DocDate,
		D.StoreID,
		D.GoodsID,
		D.SubUnitID,
		Cast(CASE WHEN H.ProcessID= 188 THEN 1 WHEN H.ProcessID= 189 THEN -1  ELSE D.EnterKind END AS SmallInt) EnterKind,
		SS.ContainerID,
		inv.funGetContainerName(SS.ContainerID, @LanguageID) ContainerName,
		SS.NumberPerContainer,
		CAST (D.GoodsQuantity as float )GoodsQuantity,
		CAST (D.SubUnitQuantity  as float )SubUnitQuantity,
		D.GoodsAmount,
		ISNULL(S.StoreName,'')StoreName,
		ISNULL(G.GoodsName,'') GoodsName,
		GG.TechnicalNo,
		ISNULL(U.UnitName,'')UnitName, 
		SS.ContainerStoresID, 
		inv.funGetContainerStoresName(SS.ContainerStoresID,@LanguageID) ContainerStoresName, 
		SS.ContainerStoresID2, 
		inv.funGetContainerStoresName(SS.ContainerStoresID2,@LanguageID) ContainerStoresName2, 
		SS.ExpireDate, 
		SS.ProductionDate, 
		GG.ExpirationPeriod
		
	FROM inv.tblStorageDocsHdr H 
	inner join inv.tblStorageDocsDtl D 			ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	inner join inv.tblStorageDocsSerials SS		ON SS.ProcessID=D.ProcessID AND SS.ProcessNo=D.ProcessNo AND SS.FiscalYear=D.FiscalYear AND SS.SerialNo=D.SerialNo AND SS.DocRowNo=D.DocRowNo
	Left Join pub.tblProcess P		ON H.ProcessID=P.ProcessID and H.ProcessNo=P.ProcessNo 
	Left Join acc.tblAcntDtl A		ON SUBSTRING(D.AcntCode,@AcntStart,@AcntLen)=A.AcntCode and A.LanguageID=@LanguageID and A.PartNumber=@AcntPart 
	Left Join inv.tblStoresDtl S	ON D.StoreID=S.StoreID and S.LanguageID=@LanguageID
	Left Join inv.tblGoodsDtl G		ON SUBSTRING(D.GoodsID,@GoodsStart,@GoodsLen)=G.GoodsID and G.LanguageID=@LanguageID and G.PartNumber=@GoodsPart 
	Left Join inv.tblGoods GG		ON SUBSTRING(D.GoodsID,@GoodsStart,@GoodsLen)=GG.GoodsID and GG.PartNumber=@GoodsPart 
	Left Join inv.tblUnitsDtl U		ON D.SubUnitID=U.UnitID  and U.LanguageID=@LanguageID
	Left Join inv.tblBatch B		ON D.BatchNo=B.BatchNo 
	Left Join inv.tblBatchDtl BD	ON D.BatchNo=BD.BatchNo and BD.LanguageID=@LanguageID 
	WHERE ((@StoreID = '' OR D.StoreID = @StoreID) AND 
		(@GoodsID = '' OR D.GoodsID = @GoodsID) AND 
		(@AcntCode = '' OR D.AcntCode = @AcntCode) AND 
		(@UserPriceID = 0 OR D.UserPriceID = @UserPriceID) AND 
		(@SerialNo = 0 OR D.SerialNo = @SerialNo) AND 		
		(@FromDate = '' OR D.DocDate >= @FromDate) AND 
		(@ToDate = '' OR D.DocDate <= @ToDate) AND 
		(@FromExpireDate = '' OR D.ExpireDate >= @FromExpireDate) AND 
		(@ToExpireDate = '' OR D.ExpireDate <= @ToExpireDate) AND 
		(D.EnterKind <> 0 or H.ProcessID in(188,189) ) AND 
		(@UserIsAdmin = 'True' OR ((SELECT	 IsNull(COUNT(*), 0) 
									FROM inv.tblGoodsRng 
									WHERE	(UserID = @UserID) 
									AND (PartNumber = @GoodsPart) 
									AND (AccessAllCode=1 OR ((AllowCodeView = 1) 
									AND (LEFT(ISNULL(D.GoodsID,''), LEN(ToCode)) >= FromCode) 
									AND (LEFT(ISNULL(D.GoodsID,''), LEN(ToCode)) <= ToCode))))>0 AND
									(SELECT	 IsNull(COUNT(*), 0)
									FROM inv.tblStoresRng
									WHERE	(UserID = @UserID) 
									AND (AccessAllCode=1 OR ((AllowCodeView = 1) 
									AND (LEFT(ISNULL(D.StoreID,''), LEN(ToCode)) >= FromCode) 
									AND (LEFT(ISNULL(D.StoreID,''), LEN(ToCode)) <= ToCode))))>0)))
)
GO
