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
-- Description	 : < لیست شعبات  >
-- ==============================================
Create PROCEDURE iw.SpStationList
	@UserID		int	,
	@StrWhare	NVarChar(MAX),
	@Skip		int,
	@Take		int
WITH ENCRYPTION
AS
BEGIN	

	Declare @DbName0000	NVarChar(100);
	Declare @DbName 	NVarChar(100);
	Declare @StrSelect	NVarChar(max);
	
	select @DbName=DB_name()
	set @DbName0000	=SUBSTRING(@DbName,1, len(@DbName)-4)+'0000'
	
	if isnull(@Take,0)=0
		set @Take=1
	
	set @StrSelect='select   Count(*)over () TotalCount, D.StationID,isnull(D.StationName,'''') StationName 
			from   pub.tblStationDtl D
			inner join '+@DbName0000+'.usr.tblBranchUsersDtl B on D.StationID=B.BranchID
			where B.UserID='+str(@UserID)

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare

	set @StrSelect += ' Order by  D.StationID
						OFFSET ' +str(@Skip) +' Rows 
						FETCH NEXT ' +Str(@Take) +' Rows ONLY '
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	   	 
END
GO
