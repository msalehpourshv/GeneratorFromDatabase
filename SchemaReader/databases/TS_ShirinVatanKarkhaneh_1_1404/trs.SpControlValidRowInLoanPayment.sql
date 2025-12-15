USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/07/12
-- Description:	
-- =============================================
Create PROCEDURE trs.SpControlValidRowInLoanPayment  
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo      int,
 @InstallmentNo tinyint,
 @LanguageID	TinyInt,
 @BaseFiscalYear	smallint,
 @BaseSerialNo      int
 
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

Declare @BaseProcessID		tinyint
IF @ProcessID = 8
	SET @BaseProcessID=7
IF @ProcessID = 48
	SET @BaseProcessID=47
 
Declare @strMsgText	    NVarchar(2044)
Declare @intSerialNo  int

if (SELECT COUNT(SerialNo)
	FROM trs.tblLoanHdr 
	WHERE ProcessID=@BaseProcessID AND ProcessNo=@ProcessNo AND 
		  FiscalYear=@BaseFiscalYear AND SerialNo=@BaseSerialNo AND
		Cancel = 'True') >0
BEGIN

	SET @strMsgText='این وام ابطال شده است'
	Raiserror (@strMsgText,16,1)
	Return
END


SELECT top 1 @intSerialNo = isnull(SerialNo,0)
FROM trs.tblLoanDtl 
WHERE ProcessID=@ProcessID AND BaseProcessNo=@ProcessNo AND BaseFiscalYear=@BaseFiscalYear AND BaseSerialNo=@BaseSerialNo AND InstallmentNo=@InstallmentNo
	  AND not (ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo AND InstallmentNo=@InstallmentNo)

	  
declare @trs_InloanRegAnyInstallment as bit
select @trs_InloanRegAnyInstallment = isnull(SettingValue, 'False')	from pub.tblSettings	where SettingKey = 'trs_InloanRegAnyInstallment'
set @trs_InloanRegAnyInstallment=isnull(@trs_InloanRegAnyInstallment, 'False')

if @trs_InloanRegAnyInstallment ='False' and @intSerialNo>0
begin
	DECLARE @strSerialNo varchar(20)
	SET @strSerialNo = ltrim(str(@intSerialNo))
		-- این قسط در سند %s  پرداخت شده است
	SET @strMsgText=TS.pub.funGetMessages(12074,@LanguageID)
	Raiserror (@strMsgText,16,1,@strSerialNo)
	Return
end

	select a.ProcessID	,a.ProcessNo	,a.FiscalYear	,a.SerialNo	,a.RowNo	,a.InstallmentNo	,a.BaseProcessID	,a.BaseProcessNo	,a.BaseFiscalYear	,a.BaseSerialNo	,a.InstallmentDate	,a.CurrencyTypeID	,a.CurrencyRate	
	,a.InstallmentAmount-isnull(b.InstallmentAmount,0) InstallmentAmount		,a.InstallmentCost-isnull(b.InstallmentCost,0) InstallmentCost	
	,a.InstallmentFine-isnull(b.InstallmentFine,0) InstallmentFine		,a.DocRowNo	,a.SourceSerialNo	,a.SourceProcessNo	
	into #t1 
	from 
	(SELECT * FROM trs.tblLoanDtl 
		WHERE ProcessID = @BaseProcessID  and ProcessNo=@ProcessNo AND	FiscalYear=@BaseFiscalYear AND SerialNo=@BaseSerialNo AND InstallmentNo=@InstallmentNo ) a
	left join 
	(SELECT isnull(sum(InstallmentAmount),0) InstallmentAmount ,isnull(sum(InstallmentCost),0) InstallmentCost ,isnull(sum(InstallmentFine),0) InstallmentFine ,
			BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo       FROM trs.tblLoanDtl 
			WHERE ProcessID =@ProcessID    and ProcessNo=@ProcessNo and InstallmentNo=@InstallmentNo
			 AND not (ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo AND InstallmentNo=@InstallmentNo)
				Group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,InstallmentNo      ) b
	on  a.ProcessID = b.BaseProcessID AND a.ProcessNo = b.BaseProcessNo AND a.FiscalYear = b.BaseFiscalYear AND a.SerialNo = b.BaseSerialNo AND a.InstallmentNo = b.InstallmentNo 
	where  (a.InstallmentAmount-isnull(b.InstallmentAmount,0)>0 or a.InstallmentCost-isnull(b.InstallmentCost,0)>0 )	
	
	select * from  #t1

	

--if (@@rowcount=0)
--	BEGIN
--		 چنین شماره ای وجود ندارد 
--		SET @strMsgText=TS.pub.funGetMessages(12034,@LanguageID)
--		Raiserror (@strMsgText,16,1)
--		Return

--	END

END
GO
