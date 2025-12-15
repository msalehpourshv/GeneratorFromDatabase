USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1398/09/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < گردش حساب مشتریان برای CRM  رز>
-- ==============================================
Create PROCEDURE crm.SpAcntFlowForRozCRM
	@AcntCode			Varchar(20), 
	@FrDate				char(10),
	@ToDate				char(10)
WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect nVarchar(max)
	Declare @StrWhere nVarchar(max)
	declare @UserID				int;
	SELECT @UserID = isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'UserExternalCRM'	

	if @UserID=0
		set @UserID=-1

	declare @PartNumber				int;
	declare @PartStart				int;
	declare @PartLen				int;
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @PartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @PartLen=[acc].[FunGetAcntInfoForRemain](3)

	BEGIN TRY
			DROP TABLE #tblAcntCode
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)

	 Insert into  #tblAcntCode (AcntCode) 
	SELECT	Distinct a.AcntCode
		FROM	acc.tblVoucherDtl a
		inner join acc.tblAcnt b ON PartNumber= 1 and SUBSTRING(a.AcntCode,1,len(b.AcntCode)) =b.AcntCode
		WHERE AcntType NOT IN (91,92) AND VchKind <> 0  
		
	SET @StrWhere=''
	
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhere =  '   AND a.AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '
		
	SELECT		SerialNo,DocDate,AcntCode,Debit,Credit,RecDesc,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo
		into #tblRemain
	FROM	acc.tblVoucherDtl where 1=0
 
 declare @Layer1Lan				int;
select @Layer1Lan=Layer1 from pub.tblCodeLayer   where TableName='acc.tblAcnt' and PartNumber=1

	set @StrSelect='
	insert into #tblRemain
		SELECT		SerialNo,DocDate,a.AcntCode,Debit,Credit,RecDesc,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo
		FROM	acc.tblVoucherDtl a
		WHERE 1= 1 '
		if (@AcntCode<> '' and  not (@AcntCode is  null))		
			set @StrSelect= @StrSelect+ '	AND  SUBSTRING(a.AcntCode,'+str(@PartStart)+' ,'+str(@PartLen)+' ) = '''+@AcntCode+ ''''
		if (@FrDate<> '' and  not (@FrDate is  null))
				set @StrSelect= @StrSelect+ '	and ( DocDate>='''+@FrDate+''' )'
		if (@ToDate<> '' and  not (@ToDate is null))
			set @StrSelect= @StrSelect+ '	and ( DocDate<='''+@ToDate+''' )'
	 set @StrSelect= @StrSelect + @StrWhere
			
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	 
select  *   from #tblRemain			

END

GO
