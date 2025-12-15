USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation Date : 1396/07/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE acc.SpCreateAcntFromAcnt
	@Acnt1  Varchar(20),
	@Acnt2  Varchar(20),
	@PartNumber int

WITH ENCRYPTION
AS 

Begin --============== S T A R T  C O D E ===================================================

	set NOCOUNT ON;

--SELECT     AcntCode, @PartNumber FROM         acc.tblAcnt WHERE     (AcntCode LIKE '3%') AND (@PartNumber = 2)
declare @Result1 as varchar(max)
Declare @StrSelect  nVarchar(max)
Declare @Acnt3  Varchar(20)
Declare @L as int=1
Declare @LenPart  as int=0
Declare @LenLayer  as int=0

while @L<10
begin
	if @L=1 Select @LenLayer  =Layer1,@LenPart  =Layer1 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=2 Select @LenLayer  =Layer2, @LenPart  =Layer1+Layer2 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=3 Select @LenLayer  =Layer3, @LenPart  =Layer1+Layer2+Layer3 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=4 Select @LenLayer  =Layer4, @LenPart  =Layer1+Layer2+Layer3+Layer4 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=5 Select @LenLayer  =Layer5,@LenPart  =Layer1+Layer2+Layer3+Layer4+Layer5 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=6 Select @LenLayer  =Layer6, @LenPart  =Layer1+Layer2+Layer3+Layer4+Layer5+Layer6 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=7 Select @LenLayer  =Layer7, @LenPart  =Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=8 Select @LenLayer  =Layer8, @LenPart  =Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber
	if @L=9 Select @LenLayer  =Layer9,@LenPart  =Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=@PartNumber

	--Select @LenPart,LEN(@Acnt2)
	
	if @LenPart>LEN(@Acnt2)
	begin
		set @Acnt3=SUBSTRING(@Acnt1,len(@Acnt2)+1,@LenLayer)
		--select @L,@Acnt3,@Acnt2,@Acnt2+@Acnt3
		--set @Acnt2=@Acnt2+@Acnt3

		 if ((Select COUNT(*) FROM         acc.tblAcnt WHERE     AcntCode =@Acnt2+@Acnt3 AND PartNumber =@PartNumber  )>0)
		 begin
			
			Select @Acnt3= RIGHT( max(AcntCode),LEN(@Acnt3))--,@LenPart,LEN(@Acnt2),* 
					FROM         acc.tblAcnt WHERE     AcntCode like ''+@Acnt2+'%'  and len(AcntCode)= len(@Acnt2)+len(@Acnt3) AND (PartNumber =@PartNumber  )
			 if RIGHT(@Acnt3,1)=9
			  set @Acnt3= SUBSTRING(@Acnt3,1,LEN(@Acnt3)-2)+ltrim(str( RIGHT(@Acnt3,2)+1 ))
			else
  				set @Acnt3= SUBSTRING(@Acnt3,1,LEN(@Acnt3)-1)+ltrim(str( RIGHT(@Acnt3,1)+1 ))
  		
			--set @Acnt2=@Acnt2+@Acnt3
		 end
		 
			set @Acnt2=@Acnt2+@Acnt3
			SET @Result1= ''
			exec [pub].[funGetColumnsWithoutXColumns] @SchemaName='acc',@tableName='tblAcnt',
			@ColumnsName='AcntCode',@CompressTableName='H',@Result=@Result1 output

			Set @StrSelect  =' insert into acc.tblAcnt
			Select '''+@Acnt2+''','+@Result1+' FROM         acc.tblAcnt H 
			WHERE     (AcntCode ='''+ substring(@Acnt1,1,len(@Acnt2))+''') AND PartNumber ='+str(@PartNumber  )+' '

			print @StrSelect
			exec sp_executesql @StrSelect

			SET @Result1= ''
			exec [pub].[funGetColumnsWithoutXColumns] @SchemaName='acc',@tableName='tblAcntDtl',
			@ColumnsName='AcntCode',@CompressTableName='H',@Result=@Result1 output

			Set @StrSelect  =' insert into acc.tblAcntDtl
			Select '''+@Acnt2+''','+@Result1+' FROM         acc.tblAcntDtl H 
			WHERE     (AcntCode ='''+substring(@Acnt1,1,len(@Acnt2))+''') AND PartNumber ='+str(@PartNumber  )+' '

			print @StrSelect
			exec sp_executesql @StrSelect
		 

	end

	Set @L+=1
end
select @Acnt2
end







GO
