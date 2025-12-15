USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 98/04/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

Create PROCEDURE inv.SPAbattoirReview 
@ProcessID Int, 
@ProcessNo Int, 
@FiscalYear int , 
@SerialNo int,
@LanguageID as tinyint,
@AcntCode as varchar(20),
@AcntPart as varchar(1),
@FromDate as varchar(10),
@ToDate as varchar(10),
@DocStepFilter varchar(20)
WITH ENCRYPTION
AS
begin


DECLARE @StrSelect	NVarChar(max)
DECLARE @StrStep	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

  
Declare @Part as tinyint=1
select @Part=[acc].[FunGetAcntInfoForRemain](1)

set @StrWhere = ' 1=1 '
if @ProcessID>0
	set @StrWhere =@StrWhere+ ' AND ProcessID  =' +str(@ProcessID)
if @ProcessNo>0
	set @StrWhere =@StrWhere+ ' AND ProcessNo  =' +str(@ProcessNo)
if @FiscalYear>0
	set @StrWhere =@StrWhere+ ' AND FiscalYear  =' +str(@FiscalYear)
if @SerialNo>0
	set @StrWhere = @StrWhere+' AND SerialNo  =' +str(@SerialNo)
if @AcntCode<>'' 
	set @StrWhere = @StrWhere+' AND AcntCode  =''' + @AcntCode + ''''
if @FromDate<>'' 
	set @StrWhere =@StrWhere+ ' AND DocDate  >=''' + @FromDate + ''''
if @ToDate<>'' 
	set @StrWhere = @StrWhere+' AND DocDate  <=''' + @ToDate + ''''

if @DocStepFilter<>'' 
BEGIN
	set @StrWhere = @StrWhere+' AND DocStep   in (0' + @DocStepFilter + ') '
END

	SET @StrStep = ',GoodsQuantity Step1,
	                CASE WHEN BaharbandNo='''' THEN ''-'' ELSE BaharbandNo END BaharbandNo ,
	                ISNULL((SELECT SUM(Amount) FROM acc.tblServicesHdr S where H.ProcessID=S.BaseProcessID AND H.ProcessNo=S.BaseProcessNo AND H.FiscalYear=S.BaseFiscalYear AND H.SerialNo=S.BaseSerialNo AND S.BaseStep=1),0) Step2,
					ISNULL((select SUM(Amount) 
							from trs.tblPayDtl PD INNER JOIN trs.tblPayHdr PH 
							ON PD.ProcessID=PH.ProcessID AND PD.ProcessNo=PH.ProcessNo
							AND PD.FiscalYear=PH.FiscalYear AND PD.SerialNo=PH.SerialNo
							WHERE H.ProcessID=PH.BaseProcessID AND H.ProcessNo=PH.BaseProcessNo
							AND H.FiscalYear=PH.BaseFiscalYear AND H.SerialNo=PH.BaseSerialNo 
							AND BaseStep=1),0)  Step3,
					ISNULL((BaseDecompositionSerialNo),0)  Step4,
					ISNULL((SELECT SUM(Amount) FROM acc.tblServicesHdr S where H.ProcessID=S.BaseProcessID AND H.ProcessNo=S.BaseProcessNo AND H.FiscalYear=S.BaseFiscalYear AND H.SerialNo=S.BaseSerialNo AND S.BaseStep=2),0) Step5,
					ISNULL((select SUM(Amount) 
							from trs.tblPayDtl PD INNER JOIN trs.tblPayHdr PH 
							ON PD.ProcessID=PH.ProcessID AND PD.ProcessNo=PH.ProcessNo
							AND PD.FiscalYear=PH.FiscalYear AND PD.SerialNo=PH.SerialNo
							WHERE H.ProcessID=PH.BaseProcessID AND H.ProcessNo=PH.BaseProcessNo
							AND H.FiscalYear=PH.BaseFiscalYear AND H.SerialNo=PH.BaseSerialNo 
							AND BaseStep=2),0)  Step6,
					ISNULL((BaseOtherTrustSendSerialNo),0)  Step7'

set @StrSelect = '
 select ProcessID, ProcessNo, FiscalYear, SerialNo' + @StrStep + ', DocDate,StoreID, DocTime, DocStep, CustomerCode,[acc].[funGetAcntName](CustomerCode,' + @AcntPart + ',1) CustomerName, GoodsID,pub.GetGoodsName(GoodsID,1) GoodsName, GoodsQuantity,BaseService1ProcessID, BaseService1ProcessNo, BaseService1FiscalYear, BaseService1SerialNo, BaseService2ProcessID, BaseService2ProcessNo, BaseService2FiscalYear, BaseService2SerialNo, BaseDecompositionProcessID, BaseDecompositionProcessNo, BaseDecompositionFiscalYear, BaseDecompositionSerialNo, BaseOtherTrustSendProcessID, BaseOtherTrustSendProcessNo, BaseOtherTrustSendFiscalYear, BaseOtherTrustSendSerialNo, BasePay1ProcessID, BasePay1ProcessNo, BasePay1FiscalYear, BasePay1SerialNo, BasePay2ProcessID, BasePay2ProcessNo, BasePay2FiscalYear, BasePay2SerialNo
 ,[pub].[GetUserName](SessionNo) AS UserName 
 from  inv.tblAbattoirHdr H 
	where ' + @StrWhere
	 	print @StrSelect
	Exec sp_executesql @StrSelect;

end
GO
