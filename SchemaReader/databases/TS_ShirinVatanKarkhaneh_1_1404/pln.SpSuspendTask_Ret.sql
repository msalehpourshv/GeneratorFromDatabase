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
Create PROCEDURE pln.SpSuspendTask_Ret
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE	@BaseFiscalYearFr	Int
DECLARE	@BaseSerialNoFr		Int
DECLARE	@BaseFiscalYearTo	Int 
DECLARE	@BaseSerialNoTo		Int
DECLARE	@FiscalYearFr		Int
DECLARE	@SerialNoFr			Int
DECLARE	@FiscalYearTo		Int 
DECLARE	@SerialNoTo			Int
DECLARE	@ProcessNo			Int
DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrWhere 		NVarChar(Max);

SET @BaseFiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 1);
SET @BaseSerialNoFr		= pub.funSplitString(@ExtraParams, '@', 2);
SET @BaseFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 3);
SET @BaseSerialNoTo		= pub.funSplitString(@ExtraParams, '@', 4);
SET @FiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 5);
SET @SerialNoFr		= pub.funSplitString(@ExtraParams, '@', 6);
SET @FiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 7);
SET @SerialNoTo		= pub.funSplitString(@ExtraParams, '@', 8);
SET @ProcessNo		= pub.funSplitString(@ExtraParams, '@', 9);


	
 set @StrWhere='  ProcessNo= '+ str(@ProcessNo)
 
	if @BaseFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear>= ' + str(@BaseFiscalYearFr)  +''
	if @BaseSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo>= ' + str(@BaseSerialNoFr)  +''
	if @BaseFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear<= ' + str(@BaseFiscalYearTo)  +''
	if @BaseSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo<= ' + str(@BaseSerialNoTo)  +''
			
	if @FiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear>= ' + str(@FiscalYearFr)  +''
	if @SerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo>= ' + str(@SerialNoFr)  +''
	if @FiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear<= ' + str(@FiscalYearTo)  +''
	if @SerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo<= ' + str(@SerialNoTo)  +''
	
	
		set @StrSelect = ' select  a.ProcessID ,a.ProcessNo, a.FiscalYear,a.SerialNo,ltrim(rtrim(str(a.FiscalYear)))+''/''+ltrim(rtrim(str(a.SerialNo))) SerialNo1
	,a.BaseProcessID ,a.BaseProcessNo,a.BaseFiscalYear,a.BaseSerialNo,ltrim(rtrim(str(a.BaseFiscalYear)))+''/''+ltrim(rtrim(str(a.BaseSerialNo))) SerialNo2,a.BaseDocRowNo,Suspend
	 from  pln.tblTaskOrderHdr a
		where   Suspend = 1 and  ' + @StrWhere
	 		print @StrSelect
		Exec sp_executesql @StrSelect;
 
     	 
end
GO
