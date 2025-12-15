USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 99/12/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE acc.SPVisitPathChange
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @Str1111	NVarChar(2000)
Declare @PartNo		Tinyint
	
	set @StrWhere = ' 1=1 '
	SET @PartNo = 0
	
	SELECT @PartNo = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'	
	select @Str1111= REPLACE( SPACE(acc.funGetAcntLayerStartandLen(@PartNo,1)-1),' ', '1')
	set @StrWhere =@StrWhere+	  LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 

if @CallType=1
	begin
	
	set @StrSelect = ' 
			select   a.AcntCode, AcntName,cast (0 as bit ) AllowChange  
				,a.VisitPathID1, acc.funVisitPathName(a.VisitPathID1,1,1) VisitPathName1
				,a.VisitPathID2	, acc.funVisitPathName(a.VisitPathID2,2,1) VisitPathName2
				,a.VisitPathID3	, acc.funVisitPathName(a.VisitPathID3,3,1) VisitPathName3
				,a.VisitPathID4	, acc.funVisitPathName(a.VisitPathID4,4,1) VisitPathName4
			from (select *, ltrim(rtrim('+@Str1111+') )+AcntCode AcntCode2  from acc.tblAcnt) a
			inner join acc.tblAcntDtl b on a.AcntCode=b.AcntCode and a.PartNumber=b.PartNumber 
			where  ' + @StrWhere +' '
	print @StrSelect
	Exec sp_executesql @StrSelect;
	
	end 

if @CallType=2
	begin
	 
	set @StrSelect = ' 
		 select  a.AcntCode, AcntName, DocDate , DocTime
			,a.VisitPathID1, acc.funVisitPathName(a.VisitPathID1,1,1) VisitPathName1
			,a.VisitPathID2	, acc.funVisitPathName(a.VisitPathID2,2,1) VisitPathName2
			,a.VisitPathID3	, acc.funVisitPathName(a.VisitPathID3,3,1) VisitPathName3
			,a.VisitPathID4	, acc.funVisitPathName(a.VisitPathID4,4,1) VisitPathName4
			
		from (select *, ltrim(rtrim('+@Str1111+') )+AcntCode AcntCode2 ,[pub].[funChangeDate_GergorianToPersian](LastUpdate) DocDate
			, convert(VarChar(5), LastUpdate, 108) DocTime from acc.tblAcntVisitPathHistory ) a
		inner join acc.tblAcntDtl b on a.AcntCode=b.AcntCode and a.PartNumber=b.PartNumber 
		where  ' + @StrWhere +' 
		order by   DocDate Desc, DocTime Desc'

	print @StrSelect
	Exec sp_executesql @StrSelect;
	
end 

end 
GO
