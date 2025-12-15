USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 97/10/27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--drop  FUNCTION cmr.FunCmrGoodsQty
Create FUNCTION cmr.FunCmrGoodsQty
(
	@ProcessID int
	,@ProcessNo  int
	,@FiscalYear  int
	,@SerialNo  int
	,@DocRowNo int	
	,@BaseProcessID int 	
	,@BaseProcessNo	 int 
	,@BaseFiscalYear	 int 
	,@BaseSerialNo	 int 
	,@BaseDocRowNo int 
)
RETURNS	@tbl Table 
(ProcessID  int 
,ProcessNo int 
,FiscalYear  int 
,SerialNo  int 
,DocRowNo int 
,RowNo int 
,GoodsID varchar(20)
,SubUnitID varchar(20)
,DocStep int
,Qty float
,CancelQty float
,ConfirmQuantity float
,DocDate char(10)
,AcntCode varchar(20)
,BaseProcessID int 	
,BaseProcessNo	 int 
,BaseFiscalYear	 int 
,BaseSerialNo	 int 
,BaseDocRowNo int  
,AcntName NVarChar(200) 
,DocDesc NVarChar(2000) 
,DescDtl NVarChar(2000) 
,Recognition int
,PenaltyPercent int
,ExtraField1 NVarChar(2000)
,ExtraField2 NVarChar(2000)
,ExtraField3 NVarChar(2000)
,ExtraField4 NVarChar(2000)
,ExtraField5 NVarChar(2000)
,GoodsPrice float
,OrderDate char(10)
,SgnSN1 int
,SgnSN2 int
,SgnSN3 int
,SgnSN4 int
,SgnSN5 int
)
WITH ENCRYPTION            
as
begin

if @ProcessID  is null  set @ProcessID  =0
if @ProcessNo  is null  set @ProcessNo  =0
if @FiscalYear  is null  set @FiscalYear  =0
if @SerialNo  is null  set @SerialNo  =0
if @DocRowNo  is null  set @DocRowNo  =0
if @BaseProcessID  is null  set @BaseProcessID  =0
if @BaseProcessNo  is null  set @BaseProcessNo  =0
if @BaseFiscalYear  is null  set @BaseFiscalYear  =0
if @BaseSerialNo  is null  set @BaseSerialNo  =0
if @BaseDocRowNo  is null  set @BaseDocRowNo  =0

DECLARE @UnitPart TINYINT,
		@str_Goods  tinyint,
		@str_GoodsSum tinyint

	SET @UnitPart  = 1
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1


	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart


------------ درخواست خرید----------------
if @ProcessID=150
begin
	insert into @tbl(ProcessID ,ProcessNo ,FiscalYear ,SerialNo ,DocRowNo,RowNo
					,GoodsID,SubUnitID,DocStep, Qty ,CancelQty ,ConfirmQuantity ,DocDate ,AcntCode
					,BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo,AcntName,DocDesc,DescDtl
					,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,OrderDate,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5)		
	Select cmr.ProcessID ,cmr.ProcessNo ,cmr.FiscalYear ,cmr.SerialNo ,cmr.DocRowNo,cmr.RowNo
		 ,cmr.GoodsID,cmr.SubUnitID,cmr.DocStep
		 , isnull( cmr.ConfirmQuantity,0)Qty ,isnull( Rtn.ConfirmQuantity ,0) CancelQty 
		 , isnull( cmr.ConfirmQuantity,0) -isnull( Rtn.ConfirmQuantity ,0) ConfirmQuantity  
		 ,cmr.DocDate ,cmr.AcntCode
		 ,cmr.BaseProcessID	,cmr.BaseProcessNo	,cmr.BaseFiscalYear	,cmr.BaseSerialNo	,cmr.BaseDocRowNo
		 , pub.GetCodeName(cmr.AcntCode, 1) AS AcntName, DocDesc,DescDtl
		 ,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,cmr.OrderDate
		 ,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
	From cmr.tblCMRHdr Hdr 
	inner join 
	(  select * from cmr.tblCMRDtl cmr Where cmr.ProcessID = 150 
		AND (@ProcessNo =0 OR cmr.ProcessNo= @ProcessNo) 
		AND (@FiscalYear =0 OR cmr.FiscalYear= @FiscalYear) 
		AND (@SerialNo =0 OR cmr.SerialNo= @SerialNo) 
		AND (@DocRowNo =0 OR cmr.DocRowNo= @DocRowNo) 
		AND (@BaseProcessID =0 OR cmr.BaseProcessID= @BaseProcessID) 
		AND (@BaseProcessNo =0 OR cmr.BaseProcessNo= @BaseProcessNo) 
		AND (@BaseFiscalYear =0 OR cmr.BaseFiscalYear= @BaseFiscalYear) 
		AND (@BaseSerialNo =0 OR cmr.BaseSerialNo= @BaseSerialNo) 
		AND (@BaseDocRowNo =0 OR cmr.BaseDocRowNo= @BaseDocRowNo) )
	cmr
		ON	Hdr.ProcessID = cmr.ProcessID 
		AND Hdr.ProcessNo = cmr.ProcessNo 
		AND Hdr.FiscalYear = cmr.FiscalYear 
		AND Hdr.SerialNo = cmr.SerialNo 
	INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE PartNumber=@UnitPart AND CodeClosed = 'False' ) G
		ON SUBSTRING(cmr.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID		
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
		,isnull( SUM( ConfirmQuantity  ),0)  ConfirmQuantity
		From cmr.tblCMRDtl 
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo, BaseDocRowNo
	) Rtn
	ON	cmr.ProcessID = Rtn.BaseProcessID 
		AND cmr.ProcessNo = Rtn.BaseProcessNo 
		AND cmr.FiscalYear = Rtn.BaseFiscalYear 
		AND cmr.SerialNo = Rtn.BaseSerialNo 
		AND cmr.DocRowNo = Rtn.BaseDocRowNo

end

------------ سفارش خرید----------------
else if @ProcessID=160
begin
	insert into @tbl(ProcessID ,ProcessNo ,FiscalYear ,SerialNo ,DocRowNo,RowNo
					,GoodsID,SubUnitID,DocStep,Qty ,CancelQty , ConfirmQuantity ,DocDate ,AcntCode
					,BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo,AcntName,DocDesc,DescDtl
					,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,GoodsPrice,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5)		
	Select cmr.ProcessID ,cmr.ProcessNo ,cmr.FiscalYear ,cmr.SerialNo ,cmr.DocRowNo,cmr.RowNo
		 ,cmr.GoodsID,cmr.SubUnitID,cmr.DocStep
		 , isnull( cmr.ConfirmQuantity,0)Qty,isnull( Rtn.ConfirmQuantity ,0) CancelQuantity 
		 , isnull( cmr.ConfirmQuantity,0)-isnull( Rtn.ConfirmQuantity ,0) ConfirmQuantity 
		 ,cmr.DocDate ,cmr.AcntCode
		 ,cmr.BaseProcessID	,cmr.BaseProcessNo	,cmr.BaseFiscalYear	,cmr.BaseSerialNo	,cmr.BaseDocRowNo
		  , pub.GetCodeName(cmr.AcntCode, 1) AS AcntName, DocDesc,DescDtl
		  ,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,GoodsPrice
		  ,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
	From  cmr.tblOrderHdr  Hdr 
	inner join
	(select * from cmr.tblOrderDtl cmr Where cmr.ProcessID = 160 
		AND (@ProcessNo =0 OR cmr.ProcessNo= @ProcessNo) 
		AND (@FiscalYear =0 OR cmr.FiscalYear= @FiscalYear) 
		AND (@SerialNo =0 OR cmr.SerialNo= @SerialNo) 
		AND (@DocRowNo =0 OR cmr.DocRowNo= @DocRowNo) 
		AND (@BaseProcessID =0 OR cmr.BaseProcessID= @BaseProcessID) 
		AND (@BaseProcessNo =0 OR cmr.BaseProcessNo= @BaseProcessNo) 
		AND (@BaseFiscalYear =0 OR cmr.BaseFiscalYear= @BaseFiscalYear) 
		AND (@BaseSerialNo =0 OR cmr.BaseSerialNo= @BaseSerialNo) 
		AND (@BaseDocRowNo =0 OR cmr.BaseDocRowNo= @BaseDocRowNo) )
		cmr	
		ON	Hdr.ProcessID = cmr.ProcessID 
		AND Hdr.ProcessNo = cmr.ProcessNo 
		AND Hdr.FiscalYear = cmr.FiscalYear 
		AND Hdr.SerialNo = cmr.SerialNo 
	INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE PartNumber=@UnitPart AND CodeClosed = 'False' ) G
		ON SUBSTRING(cmr.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID		
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
		,isnull( SUM( ConfirmQuantity  ),0)  ConfirmQuantity
		From cmr.tblOrderDtl  cmr		
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo, BaseDocRowNo
	) Rtn
	ON	cmr.ProcessID = Rtn.BaseProcessID 
		AND cmr.ProcessNo = Rtn.BaseProcessNo 
		AND cmr.FiscalYear = Rtn.BaseFiscalYear 
		AND cmr.SerialNo = Rtn.BaseSerialNo 
		AND cmr.DocRowNo = Rtn.BaseDocRowNo
	
end

------------ رسید موقت خرید----------------
else if @ProcessID=170 or  @ProcessID=171
begin
	insert into @tbl(ProcessID ,ProcessNo ,FiscalYear ,SerialNo ,DocRowNo,RowNo
					,GoodsID,SubUnitID,DocStep, Qty ,CancelQty ,ConfirmQuantity ,DocDate ,AcntCode
					,BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo,AcntName,DocDesc,DescDtl,Recognition,PenaltyPercent
					,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5)		
	Select cmr.ProcessID ,cmr.ProcessNo ,cmr.FiscalYear ,cmr.SerialNo ,cmr.DocRowNo,cmr.RowNo
		 ,cmr.GoodsID,cmr.SubUnitID,cmr.DocStep
		 , isnull( cmr.ConfirmQuantity,0)Qty,isnull( Rtn.ConfirmQuantity ,0) CancelQuantity 
		 , isnull( cmr.ConfirmQuantity,0)-isnull( Rtn.ConfirmQuantity ,0) ConfirmQuantity ,cmr.DocDate ,cmr.AcntCode
		 ,cmr.BaseProcessID	,cmr.BaseProcessNo	,cmr.BaseFiscalYear	,cmr.BaseSerialNo	,cmr.BaseDocRowNo
		  , pub.GetCodeName(cmr.AcntCode, 1) AS AcntName, DocDesc,DescDtl,Recognition,PenaltyPercent
		  ,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5
		  ,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
	From inv.tblInvTempReceiptHdr  Hdr 
	inner join
	(select * from inv.tblInvTempReceiptDtl  cmr 
	Where cmr.ProcessID = @ProcessID 
		AND (@ProcessNo =0 OR cmr.ProcessNo= @ProcessNo) 
		AND (@FiscalYear =0 OR cmr.FiscalYear= @FiscalYear) 
		AND (@SerialNo =0 OR cmr.SerialNo= @SerialNo) 
		AND (@DocRowNo =0 OR cmr.DocRowNo= @DocRowNo) 
		AND (@BaseProcessID =0 OR cmr.BaseProcessID= @BaseProcessID) 
		AND (@BaseProcessNo =0 OR cmr.BaseProcessNo= @BaseProcessNo) 
		AND (@BaseFiscalYear =0 OR cmr.BaseFiscalYear= @BaseFiscalYear) 
		AND (@BaseSerialNo =0 OR cmr.BaseSerialNo= @BaseSerialNo) 
		AND (@BaseDocRowNo =0 OR cmr.BaseDocRowNo= @BaseDocRowNo) )
		cmr
		ON	Hdr.ProcessID = cmr.ProcessID 
		AND Hdr.ProcessNo = cmr.ProcessNo 
		AND Hdr.FiscalYear = cmr.FiscalYear 
		AND Hdr.SerialNo = cmr.SerialNo   
	INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE PartNumber=@UnitPart AND CodeClosed = 'False' ) G
		ON SUBSTRING(cmr.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID	
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
		,isnull( SUM( ConfirmQuantity  ),0)  ConfirmQuantity
		From inv.tblInvTempReceiptDtl cmr		
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo, BaseDocRowNo
	) Rtn
	ON	cmr.ProcessID = Rtn.BaseProcessID 
		AND cmr.ProcessNo = Rtn.BaseProcessNo 
		AND cmr.FiscalYear = Rtn.BaseFiscalYear 
		AND cmr.SerialNo = Rtn.BaseSerialNo 
		AND cmr.DocRowNo = Rtn.BaseDocRowNo
	
end

------------  قبض خرید----------------
else if @ProcessID=55
begin
	insert into @tbl(ProcessID ,ProcessNo ,FiscalYear ,SerialNo ,DocRowNo,RowNo
					,GoodsID,SubUnitID,DocStep,Qty ,CancelQty , ConfirmQuantity ,DocDate ,AcntCode
					,BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo,AcntName,DocDesc,DescDtl
					,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5)		
	Select cmr.ProcessID ,cmr.ProcessNo ,cmr.FiscalYear ,cmr.SerialNo ,cmr.DocRowNo,cmr.RowNo
		 ,cmr.GoodsID,cmr.SubUnitID,cmr.DocStep
		 , isnull( cmr.SubUnitQuantity,0)Qty,isnull( Rtn.ConfirmQuantity ,0) CancelQuantity 
		 , isnull( cmr.SubUnitQuantity,0)-isnull( Rtn.ConfirmQuantity ,0) ConfirmQuantity ,cmr.DocDate ,cmr.AcntCode
		 ,cmr.BaseProcessID	,cmr.BaseProcessNo	,cmr.BaseFiscalYear	,cmr.BaseSerialNo	,cmr.BaseDocRowNo
		  , pub.GetCodeName(cmr.AcntCode, 1) AS AcntName, DocDesc,DescDtl
		  , G.ExtraField1, G.ExtraField2, G.ExtraField3, G.ExtraField4, G.ExtraField5
		  ,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
	From inv.tblStorageDocsHdr Hdr 
	inner join 
	(select * from inv.tblStorageDocsDtl cmr
	 Where cmr.ProcessID = 55 
		AND (@ProcessNo =0 OR cmr.ProcessNo= @ProcessNo) 
		AND (@FiscalYear =0 OR cmr.FiscalYear= @FiscalYear) 
		AND (@SerialNo =0 OR cmr.SerialNo= @SerialNo) 
		AND (@DocRowNo =0 OR cmr.DocRowNo= @DocRowNo)
		AND (@BaseProcessID =0 OR cmr.BaseProcessID= @BaseProcessID) 
		AND (@BaseProcessNo =0 OR cmr.BaseProcessNo= @BaseProcessNo) 
		AND (@BaseFiscalYear =0 OR cmr.BaseFiscalYear= @BaseFiscalYear) 
		AND (@BaseSerialNo =0 OR cmr.BaseSerialNo= @BaseSerialNo) 
		AND (@BaseDocRowNo =0 OR cmr.BaseDocRowNo= @BaseDocRowNo) 	)
		cmr
		ON	Hdr.ProcessID = cmr.ProcessID 
		AND Hdr.ProcessNo = cmr.ProcessNo 
		AND Hdr.FiscalYear = cmr.FiscalYear 
		AND Hdr.SerialNo = cmr.SerialNo 
	INNER JOIN
		(SELECT GoodsID,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5 FROM inv.tblGoods WHERE PartNumber=@UnitPart AND CodeClosed = 'False' ) G
		ON SUBSTRING(cmr.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID	
	LEFT JOIN 
	(
		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
		,isnull( SUM( SubUnitQuantity  ),0)  ConfirmQuantity
		From inv.tblStorageDocsDtl cmr		
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo, BaseDocRowNo
	) Rtn
	ON	cmr.ProcessID = Rtn.BaseProcessID 
		AND cmr.ProcessNo = Rtn.BaseProcessNo 
		AND cmr.FiscalYear = Rtn.BaseFiscalYear 
		AND cmr.SerialNo = Rtn.BaseSerialNo 
		AND cmr.DocRowNo = Rtn.BaseDocRowNo
		 		
end

update @tbl set Recognition=0 where Recognition is null
update @tbl set PenaltyPercent=0 where PenaltyPercent is null
update @tbl set GoodsPrice=0 where GoodsPrice is null
update @tbl set OrderDate='' where OrderDate is null

return 
end
GO
