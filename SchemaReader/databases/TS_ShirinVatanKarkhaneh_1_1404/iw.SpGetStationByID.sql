USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < مشخصات شعبه  >
-- ==============================================
Create PROCEDURE iw.SpGetStationByID
	@UserID		int	,
	@StrWhare	NVarChar(MAX),
	@StationID	varchar(20) 
WITH ENCRYPTION
AS
BEGIN	

	Declare @DbName0000	NVarChar(100);
	Declare @DbName 	NVarChar(100);
	Declare @StrSelect	NVarChar(max);
	Declare @StrWhareIn	NVarChar(MAX);


	set @StrWhareIn='  LTRIM(D.StationID) <> '''' '	
	if @StationID<>'' --AND  left(D.StationID,1 ) ='2' 
		set @StrWhareIn+=' and left(D.StationID,'+ str(len(@StationID)) +') ='''+@StationID+'''   '	
	
	select @DbName=DB_name()
	set @DbName0000	=SUBSTRING(@DbName,1, len(@DbName)-4)+'0000'
	
	set @StrSelect='select   Count(*)over () TotalCount, D.StationID,isnull(D.StationName,'''') StationName 
			from   pub.tblStationDtl D
			inner join '+@DbName0000+'.usr.tblBranchUsersDtl B on D.StationID=B.BranchID
			where B.UserID='+str(@UserID)

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	if isnull(@StrWhareIn,'')<>''
		set @StrSelect +=' and ' +@StrWhareIn

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	   	 
END


--لیست ورودی 
--1- کد کاربر
--2- کد شعبه
--3- شروط ورودی
--4- از سطر
--5- تعداد سطر
--6- قسمت اول كد

-- لیست خروجی
--0- تعداد سطر
--1- کد شعبه
--2- نام شعبه

GO
