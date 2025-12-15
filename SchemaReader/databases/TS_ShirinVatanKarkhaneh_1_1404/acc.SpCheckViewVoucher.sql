USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/11/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE  acc.SpCheckViewVoucher
	@ExtraParams		NVarChar(Max) = '' 
WITH ENCRYPTION
AS
BEGIN

 	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;
	DECLARE	@ProcessID		Int;
	DECLARE	@ProcessNo		Int;
	DECLARE	@FiscalYear		Int;
	DECLARE	@SerialNo		Int;
	DECLARE	@SerialNo2		Int;
	DECLARE	@CallType		Int;
	DECLARE	@C1				Int;
	DECLARE	@C2				Int;
	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrWhere		NVarChar(Max);

	SET @LangID				 = pub.funSplitString(@ExtraParams, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @ReportID			 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @UserID				 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @CallType		 = pub.funSplitString(@ExtraParams, '@', 6);
	
		BEGIN TRY
			DROP TABLE #tblAcntCode
		END TRY
		BEGIN CATCH
		END CATCH

	SELECT   AcntCode	into #tblAcntCode FROM   acc.tblVoucherDtl where 1=0

	if @CallType=1
	begin
		SET @SerialNo		 = pub.funSplitString(@ExtraParams, '@', 7);
		Insert into  #tblAcntCode (AcntCode) SELECT  Distinct AcntCode	FROM   acc.tblVoucherDtl where SerialNo=@SerialNo
	end

	if @CallType=2
	begin
		SET @ProcessID		 = pub.funSplitString(@ExtraParams, '@',7);
		SET @ProcessNo		 = pub.funSplitString(@ExtraParams, '@', 8);
		SET @FiscalYear		 = pub.funSplitString(@ExtraParams, '@', 9);
		SET @SerialNo		 = pub.funSplitString(@ExtraParams, '@', 10);

		 Insert into  #tblAcntCode (AcntCode) 
		 SELECT  Distinct AcntCode	FROM acc.tblDebitCreditDeclarationDtl where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear			and SerialNo=@SerialNo
	end 
	if @CallType=3
	begin
		SET @SerialNo2		 = pub.funSplitString(@ExtraParams, '@', 7);
		SET @ProcessID		 = pub.funSplitString(@ExtraParams, '@', 8);
		SET @ProcessNo		 = pub.funSplitString(@ExtraParams, '@', 9);
		SET @FiscalYear		 = pub.funSplitString(@ExtraParams, '@', 10);
		SET @SerialNo		 = pub.funSplitString(@ExtraParams, '@', 11);

		 Insert into  #tblAcntCode (AcntCode) 
		 SELECT  Distinct AcntCode	FROM  acc.tblVoucherDtl where SerialNo=@SerialNo2 and SourceProcessID=@ProcessID and SourceProcessNo=@ProcessNo and SourceFiscalYear=@FiscalYear and SourceSerialNo=@SerialNo
	end 

	SELECT  @C1=Count(*)	FROM  #tblAcntCode

	if @UserIsAdmin=0
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
		
	 SELECT  @C2=Count(*)	FROM  #tblAcntCode

	 if @C2<@C1
		  select 0
	  else 
		  select 1

end
GO
