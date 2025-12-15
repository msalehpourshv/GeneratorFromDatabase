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
--[cmr].[spFrmCMRHdrListSelect] @ProcessID=155,@DocDate='1394/06/21',@AcntCode=NULL
Create PROCEDURE [cmr].[spFrmCMRHdrListSelect] 
	@ProcessID		tinyint,
	@DocDate		Char(10),
	@AcntCode		Varchar(20),
	@ShowAll		int,
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

--==========================================
	Declare	@DocStep1  Tinyint;
	Declare @DocStep2  Tinyint;
	Declare @ProcessNo Tinyint
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;
	DECLARE @OnlyHdrList	BIT;
	SET @OnlyHdrList ='False'

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	SET @OnlyHdrList		= pub.funSplitString(@ExtraParams, '@', 9);
	
		
	if @ProcessNo is null 	
		set @ProcessNo=0
	Set @DocStep1 = 2
	Set @DocStep2 = 2
	if @ShowAll is null  
		set @ShowAll=0
	
-------------------------------------------------------------------------------------------------------------------
	IF @ProcessID=150
	begin
	
		SELECT Distinct ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate ,DocStep,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
		FROM cmr.tblCMRHdr 
		WHERE ProcessID= @ProcessID    and (@ProcessNo=0 or ProcessNo=@ProcessNo)
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
	end 		
-------------------------------------------------------------------------------------------------------------------
	ELSE IF @ProcessID=155
		select DISTINCT IsCodeClosed, ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode, DocDate
		from (
			select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed,
				pub.funGetGoodsName(GoodsID,1) AS GoodsName
				, inv.funGetUnitName(SubUnitID,1) AS SubUnitName ,*	
				from cmr.FunCmrGoodsQtyRemain(150,@ProcessNo,0,0,0,0,0,0,0,0)
				where 
				 	 (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					AND  DocDate<=@DocDate 
					AND ConfirmQuantity>0
					AND   DocStep = 2
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
			) A WHERE IsCodeClosed = 0 and ConfirmQuantity>0
			order by FiscalYear,SerialNo
-------------------------------------------------------------------------------------------------------------------

	ELSE IF @ProcessID=230
	BEGIN
		Select * INTO #TT1 from (
			select a.*,[inv].[funGetUnitName] (a.SubUnitID,1)SubUnitName
			 ,[pub].[funGetGoodsName] (a.GoodsID,1) GoodsName
			 , cast([inv].[funGetGoodsQuantityFromSubUnit](a.GoodsID,a.SubUnitID
							,(SELECT	isnull(sum(GoodsQuantity*EnterKind),0) FROM	inv.tblStorageDocsDtl WHERE	GoodsID = a.GoodsID AND StoreID = a.StoreID	and DocDate <=a.DocDate
						)   )as float) Qty 
			FROM inv.tblStoresRequestsDtl a
			inner join (
		
			SELECT ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
			FROM inv.tblStoresRequestsDtl 
			WHERE ProcessID=230	
			except
			select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo
			FROM  inv.tblStorageDocsDtl
	--		where BaseProcessID=230		and BaseProcessNo=1		and BaseFiscalYear=97		and BaseSerialNo=16
			except
			select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo  ,BaseDocRowNo
			FROM cmr.tblCMRDtl	
	--		where BaseProcessID=230		and BaseProcessNo=1		and BaseFiscalYear=97		and BaseSerialNo=16

		) b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo =b.SerialNo and a.DocRowNo =b.DocRowNo 

		) a  Where  (@ShowAll=1 or Qty<=SubUnitQuantity ) and (@ProcessNo=0 or ProcessNo=@ProcessNo)

		if @OnlyHdrList = 'False'
			select * from #TT1
		else
			select Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate from #TT1

	END
	
END
GO
