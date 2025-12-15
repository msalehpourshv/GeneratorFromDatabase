USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Creation date : 1404/02/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : بررسی وجود حلقه در سیستم زیر دست بالا دست
-- =======================================
Create PROCEDURE pub.spCheckLoopHasSubUser 
(
	@UserID		Int	
)
WITH ENCRYPTION
As 
begin

declare @R Varchar(50)
declare @R2 Varchar(200)
declare @Counter int
declare @Loop int
declare @BaseSupUserID int
declare @SupUserID int
declare @SubUserID int


SELECT Cast('' as Varchar(Max)) R, SupUserID	,SubUserID	 , Cast('' as Varchar(Max)) R2
	into #tblTaskAssignRules
from pub.tblTaskAssignRules
where 1=0

set @BaseSupUserID =@UserID

insert into #tblTaskAssignRules
	SELECT ROW_NUMBER()over(partition by SupUserID  order by SupUserID	 ) R2,
		SupUserID	,SubUserID	 ,ltrim(str(SupUserID))+'-'+ltrim(str(SubUserID))
	from pub.tblTaskAssignRules
	where SupUserID=@UserID

set  @Counter=1
set	@Loop=0

--select * from #tblTaskAssignRules

while ((select count(*) from #tblTaskAssignRules)>0 and @Counter<500 and @Loop=0)
begin
	SELECT top 1  @SupUserID=SupUserID	,@SubUserID=SubUserID	, @R=R, @R2=R2
	from #tblTaskAssignRules
	order by len(R),R
	  
	if @SubUserID=@BaseSupUserID
		set @Loop=1

	insert into #tblTaskAssignRules
	SELECT @R +'-'+ltrim(str( ROW_NUMBER()over(partition by SupUserID order by SupUserID))) R
	,SupUserID	,SubUserID	,@R2 +'<=>'+ltrim(str(SupUserID))+'->'+ltrim(str(SubUserID)) 
	from pub.tblTaskAssignRules
	where SupUserID=@SubUserID
	
	delete 
	from #tblTaskAssignRules
	where   R=@R
	
	set  @Counter+=1
	
end

if @Loop=1
	select   @R2  LoopUser
else
	select  '' LoopUser

END
GO
