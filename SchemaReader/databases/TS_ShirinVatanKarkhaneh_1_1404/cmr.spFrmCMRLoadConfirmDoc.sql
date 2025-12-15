USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/10/15
-- Description:	Control Receipt 
-- Last Modifier: ZiA
-- Last Modified: 1393/06/27
-- =============================================
Create PROCEDURE [cmr].[spFrmCMRLoadConfirmDoc] 
	@ProcessID	tinyint,
	@ProcessNo	tinyint,
	@FiscalYear	smallint,
	@SerialNo	int,
	@DocDate	Char(10),
	@AcntCode	Varchar(20),
	@LanguageID	Tinyint

WITH ENCRYPTION
AS
Declare @strMsgText	 NVarChar(2044)
Declare @DocStep Tinyint
Declare @Counter Tinyint
BEGIN

	SET NOCOUNT ON;
	
--=================================		
	Declare	@DocStep1 Tinyint;
	Declare	@DocStep2 Tinyint;
	Declare @DocStep3 Tinyint;

	Set @DocStep1 = 1
	Set @DocStep2 = 2
	Set @DocStep3 = 2

--=================================		
	
	SELECT @DocStep=DocStep
	FROM cmr.tblCMRHdr 
	WHERE SerialNo=@SerialNo AND 
		  ProcessID=@ProcessID AND 
		  ProcessNo=@ProcessNo AND 
		  FiscalYear=@FiscalYear AND 
		  AcntCode=	@AcntCode AND	
		  DocDate<=@DocDate
		  
	IF @DocStep=1	 
	BEGIN
		--این شماره تایید نشده است
		SET @strMsgText='این شماره تایید نشده است'
		Raiserror (@strMsgText,16,1)
		Return
	END
	 IF @ProcessID=150
	
	select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed, DocDesc ,DescDtl,
				pub.funGetGoodsName(GoodsID,1) AS GoodsName
				, inv.funGetUnitName(SubUnitID,1) AS SubUnitName ,*
				,ConfirmQuantity SubUnitQuantity,				
				inv.funGetGoodsQuantityFromSubUnit(GoodsID,SubUnitID,ConfirmQuantity) GoodsQuantity
				from cmr.FunCmrGoodsQtyRemain(@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,0,0,0,0,0,0)
				where  (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					AND  DocDate<=@DocDate 
					AND ConfirmQuantity>0					
					AND DocStep=2
	else IF @ProcessID=230
	begin
	if @FiscalYear is null
	set @FiscalYear=0
if @SerialNo is null
	set @SerialNo=0

	Select *from (
		select a.*,[inv].[funGetUnitName] (a.SubUnitID,1)SubUnitName, DocDesc 
		 ,[pub].[funGetGoodsName] (a.GoodsID,1) GoodsName
		 , cast([inv].[funGetGoodsQuantityFromSubUnit](a.GoodsID,a.SubUnitID
						,(SELECT	isnull(sum(GoodsQuantity*EnterKind),0) FROM	inv.tblStorageDocsDtl d 
						WHERE	d.GoodsID = a.GoodsID AND d.StoreID = a.StoreID	and d.DocDate <=@DocDate
					)   )as float) Qty 
		From   inv.tblStoresRequestsHdr  Hdr 
		inner join  inv.tblStoresRequestsDtl a
		ON	Hdr.ProcessID = a.ProcessID 
		AND Hdr.ProcessNo = a.ProcessNo 
		AND Hdr.FiscalYear = a.FiscalYear 
		AND Hdr.SerialNo = a.SerialNo 		
		inner join (		
		SELECT ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
		FROM inv.tblStoresRequestsDtl 
		WHERE ProcessID=230	AND (@FiscalYear=0  or  @FiscalYear=FiscalYear)
		and (@SerialNo=0  or  @SerialNo=SerialNo)
		EXCEPT
		SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo
		FROM  inv.tblStorageDocsDtl
--		where BaseProcessID=230		and BaseProcessNo=1		and BaseFiscalYear=97		and BaseSerialNo=16
		except
		select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo  ,BaseDocRowNo
		FROM cmr.tblCMRDtl	
--		where BaseProcessID=230		and BaseProcessNo=1		and BaseFiscalYear=97		and BaseSerialNo=16
	) b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo =b.SerialNo and a.DocRowNo =b.DocRowNo 
	) a  Where --Qty<=SubUnitQuantity 	and 
	(@FiscalYear=0  or  @FiscalYear=FiscalYear)
	and (@SerialNo=0  or  @SerialNo=SerialNo)
			
	end 
	
	
END
GO
