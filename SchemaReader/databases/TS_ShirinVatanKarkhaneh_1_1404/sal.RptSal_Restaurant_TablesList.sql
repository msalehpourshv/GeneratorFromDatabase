USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ 
-- Create date   : 1394/02/17
-- Viewed By	 : 
-- Last Modified : 1394/02/17
-- Last Modifier : TakroSystem\ 
-- Description	 : برای تولید مواد اولیه جهت انتقال کالا
-- ==============================================r
create PROCEDURE [sal].[RptSal_Restaurant_TablesList]
	@SalonIDTo		varchar(20) = NULL,
	@SalonIDFrom	varchar(20) = NULL,
	@RepOptions		varchar(100) = '101',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS

declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@strSelect		nvarchar(max); 
declare	@strWhere		nvarchar(4000); 

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

set @strWhere= ' 1=1   '
 

If @SalonIDFrom is not null
		SET @strWhere = @strWhere + ' AND h.TableID >=''' + @SalonIDFrom + ''''

If @SalonIDTo is not null
		SET @strWhere = @strWhere + ' AND  h.TableID <=''' + @SalonIDTo + ''''
	---------------------------------------------------------------------------
	
 set @strSelect='SELECT * from sal.tblTables h 
		 inner join sal.tblTablesDtl d
		 on h.TableID=d.TableID
  WHERE ' + @strWhere


	-- RUN -------------------------------------------------------
	PRINT @strSelect;
	EXEC sp_executesql @strSelect;
	--------------------------------------------------------------

 
	 
End
GO
