USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ====================
-- Author		 : jafari
-- Create date   : 1397/01/29
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================

Create PROCEDURE [trs].[SpFrmRetChequeFlow]
	@ExtraParams		NVarChar(Max) 
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE	@CallType	Int;
DECLARE	@LangID		Char(1);
DECLARE	@VolumeFiscalYear	Int;
DECLARE	@VolumeRowNo	Int;


--Select @ExtraParams

SET @CallType = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @LangID = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 


if @CallType=4
begin


SET @VolumeFiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
SET @VolumeRowNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 4));



SELECT     a.HistoryID, a.FieldID,FieldName,FieldText, OldValue, NewValue, b.HistoryDate,b.HistoryTime  
into #tblHistorytemp 
FROM         hst.tblHistoryFields a   
inner join   hst.tblHistoryRecords b on a.HistoryID=b.HistoryID   
inner join   hst.tblFields  c on a.FieldID=c.FieldID 
and  c.FieldName in ('FollowAcntCode','FollowAcntCodeName','ReceiptAcntCode','ReceiptAcntCodeName') 
    where   b.SerialNo=@VolumeRowNo and b.FiscalYear=@VolumeFiscalYear
     order by a.HistoryID Desc, a.FieldID Desc
     
select NewValue ReceiptAcntCode ,NewValue ReceiptAcntCodeName ,NewValue FollowAcntCode ,NewValue FollowAcntCodeName  ,HistoryDate , HistoryTime  
into #tblHistorytemp2   from #tblHistorytemp  where 1=0

        
insert into #tblHistorytemp2(ReceiptAcntCode,ReceiptAcntCodeName,FollowAcntCode,FollowAcntCodeName,HistoryDate, HistoryTime )        
select Distinct '','','','', HistoryDate , HistoryTime 
from #tblHistorytemp           
                         
update #tblHistorytemp2  Set ReceiptAcntCode= NewValue  
from #tblHistorytemp2 b inner join  #tblHistorytemp  a  
on  a.FieldName='ReceiptAcntCode' and a.HistoryDate=b.HistoryDate and a.HistoryTime=b.HistoryTime
        
update #tblHistorytemp2 Set ReceiptAcntCodeName= NewValue  
from #tblHistorytemp2 b inner join  #tblHistorytemp  a  
on  a.FieldName='ReceiptAcntCodeName' and a.HistoryDate=b.HistoryDate and a.HistoryTime=b.HistoryTime
 
         
update #tblHistorytemp2 Set FollowAcntCode= NewValue  
from #tblHistorytemp2 b inner join  #tblHistorytemp  a  
on  a.FieldName='FollowAcntCode' and a.HistoryDate=b.HistoryDate and a.HistoryTime=b.HistoryTime 
         
update #tblHistorytemp2  Set FollowAcntCodeName= NewValue  
from #tblHistorytemp2 b inner join  #tblHistorytemp  a  
on  a.FieldName='FollowAcntCodeName' and a.HistoryDate=b.HistoryDate and a.HistoryTime=b.HistoryTime

Select * from #tblHistorytemp2    

end
-------------------------------------------------------------------------------------------- 
if @CallType=5
begin

	SET @VolumeFiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @VolumeRowNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 4));

	DECLARE @StrSelect NVarChar(4000);
	DECLARE @StrSelect1 NVarChar(4000);
	DECLARE @StrSelect2 NVarChar(4000);
	DECLARE @StrSelect3 NVarChar(4000);

	Declare @OldDbName1 Varchar(50)
	Declare @OldDbName2 Varchar(50)
	Declare @OldDbName3 Varchar(50)
	Declare @OldTask NVarChar(Max)

	set @OldDbName1=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -1)) 
	set @OldDbName2=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -2)) 
	set @OldDbName3=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -3)) 
	 
	set @StrSelect1=''
	set @StrSelect2=''
	set @StrSelect3=''
	if (select Count(*) from sys.databases where name =@OldDbName1)>0
		set @StrSelect1='
			select isnull((SELECT      TypeText FROM         pub.tblTypeValues where TypeID=2 and TypeValue=a.PayTypeID and LanguageID='+@LangID+' ) ,'''') TypeName, pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankCity		
				,pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankAddress,pub.funGetBankTypeName(a.BankTypeID,'+@LangID+') AS BankName,b.AtomAmount,a.*	
			from '+ @OldDbName1 +'.trs.tblPayDtl a 
			inner join '+ @OldDbName1 +'.trs.tblPayAtm b
				on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
			where VolumeFiscalYearAtm='+ str(@VolumeFiscalYear) +' and VolumeRowNoAtm='+ str(@VolumeRowNo)  

	if (select Count(*) from sys.databases where name =@OldDbName2)>0
			set @StrSelect2='
				select isnull((SELECT      TypeText FROM         pub.tblTypeValues where TypeID=2 and TypeValue=a.PayTypeID and LanguageID='+@LangID+' ) ,'''') TypeName, pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankCity		
					,pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankAddress,pub.funGetBankTypeName(a.BankTypeID,'+@LangID+') AS BankName,b.AtomAmount,a.*	
				from '+ @OldDbName2 +'.trs.tblPayDtl a 
				inner join '+ @OldDbName2 +'.trs.tblPayAtm b
					on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
				where VolumeFiscalYearAtm='+ str(@VolumeFiscalYear) +' and VolumeRowNoAtm='+ str(@VolumeRowNo)  
	
	if (select Count(*) from sys.databases where name =@OldDbName3)>0
			set @StrSelect3='
				select isnull((SELECT      TypeText FROM         pub.tblTypeValues where TypeID=2 and TypeValue=a.PayTypeID and LanguageID='+@LangID+' ) ,'''') TypeName, pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankCity		
					,pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankAddress,pub.funGetBankTypeName(a.BankTypeID,'+@LangID+') AS BankName,b.AtomAmount,a.*	
				from '+ @OldDbName3 +'.trs.tblPayDtl a 
				inner join '+ @OldDbName3 +'.trs.tblPayAtm b
					on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
				where VolumeFiscalYearAtm='+ str(@VolumeFiscalYear) +' and VolumeRowNoAtm='+ str(@VolumeRowNo)  
	 
	set @StrSelect='
		select isnull((SELECT      TypeText FROM         pub.tblTypeValues where TypeID=2 and TypeValue=a.PayTypeID and LanguageID='+@LangID+' ) ,'''') TypeName, pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankCity		
			,pub.funGetLocationName(a.LocationID,'+@LangID+') AS BankAddress,pub.funGetBankTypeName(a.BankTypeID,'+@LangID+') AS BankName,b.AtomAmount,a.*	
		from trs.tblPayDtl a 
		inner join trs.tblPayAtm b
			on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
		where VolumeFiscalYearAtm='+ str(@VolumeFiscalYear) +' and VolumeRowNoAtm='+ str(@VolumeRowNo)  

	if @StrSelect1<>''
			SET @StrSelect += '	Union  all 	 '+@StrSelect1
	if @StrSelect2<>''
			SET @StrSelect += '	Union  all 	 '+@StrSelect2
	if @StrSelect3<>''
			SET @StrSelect += '	Union  all 	 '+@StrSelect3

	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
end


END
GO
