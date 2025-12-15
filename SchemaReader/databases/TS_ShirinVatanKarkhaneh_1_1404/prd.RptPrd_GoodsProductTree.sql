USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/04/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_GoodsProductTree]
	@GoodsID		VarChar(20),
	@RepOptions		NVarChar(100) = '1', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1' 
WITH ENCRYPTION
AS
declare	@LangID		Char(1);
declare	@SessionNo	Int; 
declare	@ReportID	Int; 

declare	@ProductID	varchar(20); 
declare	@SerialNo	int; 
declare	@Quantity	float; 
declare	@IsDefault	bit; 
declare	@FirstLayer	bit; 
declare @Count		int;

DECLARE @UnitPart	TINYINT

Begin
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @FirstLayer = Substring(@RepOptions, 1, 1);
	--------------------------------------------------------------------

	--================================== UnitPart
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	--==================================
	
	create table #tblResult1
	(
		ProductID	varchar(20) not null,
		SerialNo	varchar(20) not null,
		IsDefault	bit,
		Quantity	float not null
	);

	insert into #tblResult1
	select	D.ProductID, D.SerialNo, H.IsDefault, cast(D.GoodsQuantity / H.ProductCount as float)
	from	prd.tblFormulasDtl D 
				inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
	where D.GoodsID = @GoodsID
		
	if (@FirstLayer = 0)
	begin
		-- last level is requested

		create table #tblResult2
		(
			ProductID	varchar(20) not null,
			SerialNo	varchar(20) not null,
			IsDefault	bit,
			Quantity	float not null
		);

		while (1=1)
		begin
			declare crs_Prods cursor for
				select	*
				from	#tblResult1

			select @Count = count(*)
			from prd.tblFormulasDtl
			where GoodsID in 
				(
					select ProductID
					from #tblResult1
				)
			
			if (@Count = 0)
				break;

			open crs_Prods 
			fetch next from crs_Prods into @ProductID, @SerialNo, @IsDefault, @Quantity

			while (@@fetch_status = 0)
			begin
				insert into #tblResult2
				select	D.ProductID, D.SerialNo, H.IsDefault, cast( cast(D.GoodsQuantity as float) * cast(@Quantity as float) / H.ProductCount as float)
				from	prd.tblFormulasDtl D 
							inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
				where D.GoodsID = @ProductID

				if (@@RowCount = 0)
					insert into #tblResult2
					values(@ProductID, @SerialNo, @IsDefault, @Quantity)

				fetch next from crs_Prods into @ProductID, @SerialNo, @IsDefault, @Quantity
			end

			close crs_Prods
			deallocate crs_Prods

			delete from #tblResult1
			
			insert into #tblResult1
			select *
			from #tblResult2

			delete from #tblResult2
		end -- while
	end -- if

	SELECT ProductID, GoodsName as ProductName, SerialNo, IsDefault, Sum(Quantity) GoodsQuantity
	FROM #tblResult1 R
	INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(R.ProductID, @str_Goods + 1, @str_GoodsSum) AND 
									G.PartNumber=@UnitPart AND G.LanguageID = @LangID

	GROUP BY ProductID, GoodsName, SerialNo, IsDefault
End
GO
