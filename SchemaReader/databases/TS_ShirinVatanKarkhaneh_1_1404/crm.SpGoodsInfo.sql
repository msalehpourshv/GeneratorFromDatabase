USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1401/08/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < لیست کالا ها برای CRM  رز>
-- ==============================================
Create PROCEDURE crm.SpGoodsInfo
	@GoodsID			Varchar(20)	
WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect nVarchar(max)
	Declare @StrWhere nVarchar(max)
	declare @UserID				int;

	SELECT @UserID = isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'UserExternalCRM'	

	if @UserID=0
		set @UserID=-1
		 
	declare @PartNumber		int;
	select @PartNumber=1

	BEGIN TRY
			DROP TABLE #tblGoods
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblGoods
	(
	GoodsID 			Varchar(20)collate arabic_cs_as null
	)

	 Insert into  #tblGoods (GoodsID) 
	 SELECT	Distinct a.GoodsID	
		FROM	inv.tblGoods  a
			where PartNumber =@PartNumber 

 	DELETE 
	from  #tblGoods 
		where   GoodsID not in (
		    select GoodsID		 from  #tblGoods A
				where 1=1  AND(
							(Select COUNT(*) from inv.tblGoodsRng
								where inv.tblGoodsRng.UserID=@UserID AND AllowCodeView=1 AND inv.tblGoodsRng.PartNumber=@PartNumber  AND
								(LEFT(A.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(A.GoodsID))
							AND LEFT(A.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(A.GoodsID)))
							)>0 
							
							OR 
								(Select COUNT(*) from inv.tblGoodsRng
								where  inv.tblGoodsRng.UserID=@UserID AND inv.tblGoodsRng.PartNumber=@PartNumber  AND AccessAllCode=1)>0
							)
							
						  AND(
							(Select COUNT(*) from inv.tblGoodsRng
								where inv.tblGoodsRng.UserID=@UserID AND AllowCodeView=0 AND inv.tblGoodsRng.PartNumber=@PartNumber  AND
								(LEFT(A.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(A.GoodsID))
							AND LEFT(A.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(A.GoodsID)))
							)=0 
							OR
							(Select COUNT(*) from inv.tblGoodsRng
								where inv.tblGoodsRng.UserID=-1 AND AllowCodeView=0 AND inv.tblGoodsRng.PartNumber=@PartNumber  AND
								(LEFT(A.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(A.GoodsID))
							AND LEFT(A.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(A.GoodsID)))
							)=0 
							)
							
					)
					
	
	--select GoodsID		 from  #tblGoods
	SET @StrWhere =  ' Where 1=1 '
		SET @StrWhere +=  '   AND a.GoodsID in (SELECT  GoodsID FROM  #tblGoods    ) '
		
	set @StrSelect='
		SELECT	a.GoodsID,GoodsName,a.UnitID, U1.UnitName,isnull(SubUnitID,'''') SubUnitID,isnull(U2.UnitName,'''') UnitName2
		,CodeClosed	,TechnicalSpecifications,TechnicalNo,BarCode,ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,isnull(MainUnitValue,0) MainUnitValue ,isnull(UnitValue,0)  UnitValue	, LastUpdate 	
		FROM	inv.tblGoods a
		INNER join inv.tblGoodsDtl b
			ON a.PartNumber= b.PartNumber
				 and a.GoodsID= b.GoodsID AND a.PartNumber='+str(@PartNumber) +' AND b.LanguageID=1
		left join inv.tblUnitsDtl U1 on a.UnitID= U1.UnitID  AND U1.LanguageID=1
		left join inv.tblSubUnitsDtl SU on a.GoodsID= SU.GoodsID and ShowInInvoice=1
		left join inv.tblUnitsDtl U2 on SU.SubUnitID= U2.UnitID  AND U2.LanguageID=1	
		'		 
	 set @StrSelect= @StrSelect + @StrWhere
	set @StrSelect= @StrSelect + ' and ('''+ @GoodsID+'''='''' or a.GoodsID='''+ @GoodsID+''')  '
			
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
END



GO
