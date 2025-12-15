USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--exec "TS_Mishab_1_1396"."sal"."RptSal_DistributeDiscounts";1 '111302 0403201010028@@90@10@96@117214', 62963717, '1396/11/01', 1
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/01/14
-- Viewed By	 : 
-- Last Modified : 1396/11/02
-- Last Modifier : TakroSystem\Hadi Sadeghi
-- Description	 : 
-- ==============================================
Create PROCEDURE [sal].[RptSal_DistributeDiscounts]
	@AcntCode			VarChar(50)='',
	@Amount				float = Null,
	@DocDate			Char(10)='',
	@LangID				int = 1
WITH ENCRYPTION
AS
Begin

	SET NOCOUNT ON;
	declare @ACC			varchar(20)
	declare @PayOffTypeID	varchar(20)
	declare @GoodsID		varchar(20)
	declare @GoodsGroupID	varchar(20)	
	declare @Price			float
	declare	@ProcessID		INT,
			@ProcessNo		INT,
			@FiscalYear		INT,
			@SerialNo		INT
	DECLARE @PayPayOffDiscountsWithGoods   BIT
	DECLARE @sal_CalcPayOffDiscountsWithGroup   BIT
	
	set @ACC=LTrim(pub.funSplitString(@AcntCode, '@', 1))
	set @PayOffTypeID=LTrim(pub.funSplitString(@AcntCode, '@', 2))
	set @ProcessID=LTrim(pub.funSplitString(@AcntCode, '@', 3))
	set @ProcessNo=LTrim(pub.funSplitString(@AcntCode, '@', 4))
	set @FiscalYear=LTrim(pub.funSplitString(@AcntCode, '@', 5))
	set @SerialNo=LTrim(pub.funSplitString(@AcntCode, '@', 6))
	set @PayOffTypeID=isnull(@PayOffTypeID,'')

	SELECT @PayPayOffDiscountsWithGoods = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'PayPayOffDiscountsWithGoods' 
	SET @PayPayOffDiscountsWithGoods = isnull(@PayPayOffDiscountsWithGoods,'False')
	
	SELECT @sal_CalcPayOffDiscountsWithGroup= SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_CalcPayOffDiscountsWithGroup' 
	SET @sal_CalcPayOffDiscountsWithGroup = isnull(@sal_CalcPayOffDiscountsWithGroup,'False')	

	declare @CustomerKindID varchar(20)
	select @CustomerKindID = [pub].[funGetCustomerKindID](@ACC)

	IF @PayPayOffDiscountsWithGoods = 'False'
	BEGIN

		SELECT PD.*, PT.PayOffTypeName, pub.funFarsiDateAddDays('Day', @DocDate, PD.DaysNo) FinishDate,N'' Name,0 Price
		FROM sal.tblPayOffDiscountsDtl PD
				inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
		WHERE (CustomerKindID = @CustomerKindID) And 
			  (@Amount <= 0 or (@Amount > 0 AND @Amount >= FromPrice AND @Amount <= ToPrice)) And
			   (@PayOffTypeID Is Null OR @PayOffTypeID = '' OR (PD.DaysNo <= ISNULL((SELECT TOP 1 DaysNo from sal.tblPayOffDiscountsDtl WHERE PayOffTypeID = @PayOffTypeID),0)))
		order by DocRowNo

	END	
	ELSE
	BEGIN

		SELECT TOP 0 * ,0 RW, CAST('' as Nvarchar(100)) PayOffTypeName ,
			CAST('' as varchar(10)) FinishDate,CAST('' as Nvarchar(1000)) Name,
			CAST(0.0 as FLOAT) Price
				INTO #PayOffDiscounts
		FROM sal.tblPayOffDiscountsDtl 
	if @sal_CalcPayOffDiscountsWithGroup='True'
	begin
		Declare	curSale CURSOR For 
		select case When  GoodsGroupID='' then GoodsID else '' end GoodsID,  case When  GoodsGroupID='' then  '' else GoodsGroupID end GoodsGroupID, Sum(Price) Price
		from (
				SELECT  isnull(GoodsGroupID ,'') GoodsGroupID ,  a.GoodsID,(GoodsPrice*GoodsQuantity)-DiscountDtl+TaxOverWorthCostDtl+TollOverWorthCostDtl Price
					FROM inv.tblStorageDocsDtl  a
					left join  inv.tblGoodsGroupsGoodsListDtl b 
					on a.GoodsID=b.GoodsID and GoodsGroupID in (Select GoodsGroupID from sal.tblPayOffDiscountsDtl where CustomerKindID=@CustomerKindID)					
						WHERE ProcessID=@ProcessID AND 
						  ProcessNo=@ProcessNo AND 
						  FiscalYear=@FiscalYear AND 
						  SerialNo=@SerialNo ) a
		Group by GoodsGroupID,case When  GoodsGroupID='' then GoodsID else '' end 
		
		Open  curSale; 

		Fetch NEXT From curSale Into @GoodsID,@GoodsGroupID,@Price

		While (@@Fetch_Status = 0)
			BEGIN
			
				INSERT INTO #PayOffDiscounts		
				SELECT CustomerKindID, 0 RowNo,0 DocRowNo, PD.PayOffTypeID,0 DiscountPercent,0 IsDefault,0 FromPrice,0 ToPrice, DaysNo,'' GoodsID, GoodsGroupID,0 RW,
					   PT.PayOffTypeName, pub.funFarsiDateAddDays('Day', @DocDate, PD.DaysNo) FinishDate,CASE WHEN GoodsID='' THEN N'کل فاکتور ' ELSE pub.funGetGoodsName(GoodsID,1) END + LTRIM(RTRIM(STR(DiscountPercent))) + N' درصد'  Name,
					   @Price *(100+DiscountPercent)/100 Price
				FROM (
						SELECT * 
						from (
							SELECT *,row_number()over(partition by CustomerKindID,PayOffTypeID order by LEN(GoodsID) desc,LEN(GoodsGroupID) desc ,GoodsGroupID desc) RW 
							FROM sal.tblPayOffDiscountsDtl P
							WHERE CustomerKindID = @CustomerKindID  
								AND (LEN(@GoodsID)=0 OR (len (GoodsID)>0 and  SUBSTRING(@GoodsID,1,LEN(GoodsID))=GoodsID ) )
								AND ( LEN(@GoodsGroupID)=0 OR (len (GoodsGroupID)>0 and  @GoodsGroupID=P.GoodsGroupID)	)
								AND FromPrice<=@Price 
								and @Price<=ToPrice 
						  	 ) a
					) PD
				inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
				WHERE  (@Price <= 0 or (@Price > 0 AND @Price >= FromPrice AND @Price <= ToPrice)) And
					   (@PayOffTypeID Is Null OR @PayOffTypeID = '' OR (PD.DaysNo <= ISNULL((SELECT TOP 1 DaysNo from sal.tblPayOffDiscountsDtl WHERE PayOffTypeID = @PayOffTypeID),0)))
				
				UNION ALL

				SELECT DISTINCT @CustomerKindID CustomerKindID, 0 RowNo,0 DocRowNo, PD.PayOffTypeID,0 DiscountPercent,0 IsDefault,0 FromPrice,0 ToPrice, DaysNo,'' GoodsID,'' GoodsGroupID,0 RW,
					PT.PayOffTypeName , pub.funFarsiDateAddDays('Day', @DocDate, PD.DaysNo) FinishDate,''  Name,@Price Price
				from (
					SELECT CustomerKindID,PayOffTypeID,DaysNo FROM sal.tblPayOffDiscountsDtl
				except
					select CustomerKindID,PD.PayOffTypeID,DaysNo
					FROM (
						SELECT * 
						from (
							SELECT *,row_number()over(partition by CustomerKindID,PayOffTypeID order by LEN(GoodsID) desc,LEN(GoodsGroupID) desc ,GoodsGroupID desc) RW 
							FROM sal.tblPayOffDiscountsDtl P
							WHERE CustomerKindID = @CustomerKindID  
								AND (LEN(@GoodsID)=0 OR (len (GoodsID)>0 and  SUBSTRING(@GoodsID,1,LEN(GoodsID))=GoodsID ) )
								AND ( LEN(@GoodsGroupID)=0 OR (len (GoodsGroupID)>0 and  @GoodsGroupID=P.GoodsGroupID)	)
								AND FromPrice<=@Price 
								and @Price<=ToPrice
						  		) a
						) PD
					inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
					WHERE  (@Price <= 0 or (@Price > 0 AND @Price >= FromPrice AND @Price <= ToPrice)) And
							(@PayOffTypeID Is Null OR @PayOffTypeID = '' OR (PD.DaysNo <= ISNULL((SELECT TOP 1 DaysNo from sal.tblPayOffDiscountsDtl WHERE PayOffTypeID = @PayOffTypeID),0)))
					
					)  PD   
				inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
				WHERE PD.CustomerKindID=@CustomerKindID
				order by DocRowNo

				Fetch NEXT From curSale Into @GoodsID,@GoodsGroupID,@Price
			END
		
			Close curSale;
			Deallocate curSale; 
		END
		else
		begin

		Declare	curSale CURSOR For 
		SELECT GoodsID,(GoodsPrice*GoodsQuantity)-DiscountDtl+TaxOverWorthCostDtl+TollOverWorthCostDtl Price
		FROM inv.tblStorageDocsDtl 
		WHERE ProcessID=@ProcessID AND 
			  ProcessNo=@ProcessNo AND 
			  FiscalYear=@FiscalYear AND 
			  SerialNo=@SerialNo 
		Open  curSale; 

		Fetch NEXT From curSale Into @GoodsID,@Price

		While (@@Fetch_Status = 0)
			BEGIN
			
				INSERT INTO #PayOffDiscounts		
				SELECT CustomerKindID, 0 RowNo,0 DocRowNo, PD.PayOffTypeID,0 DiscountPercent,0 IsDefault,0 FromPrice,0 ToPrice, DaysNo,'' GoodsID,'' GoodsGroupID,0 RW,
					   PT.PayOffTypeName, pub.funFarsiDateAddDays('Day', @DocDate, PD.DaysNo) FinishDate,CASE WHEN GoodsID='' THEN N'کل فاکتور ' ELSE pub.funGetGoodsName(GoodsID,@LangID) END + LTRIM(RTRIM(STR(DiscountPercent))) + N' درصد'  Name,
					   @Price *(100+DiscountPercent)/100 Price
				FROM (
						SELECT * 
						from (
							SELECT *,row_number()over(partition by CustomerKindID,PayOffTypeID order by LEN(GoodsID) desc,LEN(GoodsGroupID) desc ,GoodsGroupID desc) RW 
							FROM sal.tblPayOffDiscountsDtl P
							WHERE CustomerKindID = @CustomerKindID  AND 
							      (SUBSTRING(@GoodsID,1,LEN(GoodsID))=GoodsID AND
								   (LEN(GoodsGroupID)=0 OR (SELECT COUNT(*) FROM inv.tblGoodsGroupsGoodsListDtl G WHERE G.GoodsGroupID=P.GoodsGroupID AND G.GoodsID =@GoodsID )>0)
								  )
						  	 ) a
						--WHERE RW = 1
					) PD
				inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
				WHERE  (@Price <= 0 or (@Price > 0 AND @Price >= FromPrice AND @Price <= ToPrice)) And
					   (@PayOffTypeID Is Null OR @PayOffTypeID = '' OR (PD.DaysNo <= ISNULL((SELECT TOP 1 DaysNo from sal.tblPayOffDiscountsDtl WHERE PayOffTypeID = @PayOffTypeID),0)))
				
				UNION ALL

					SELECT DISTINCT @CustomerKindID CustomerKindID, 0 RowNo,0 DocRowNo, PD.PayOffTypeID,0 DiscountPercent,0 IsDefault,0 FromPrice,0 ToPrice, DaysNo,'' GoodsID,'' GoodsGroupID,0 RW,
					   PT.PayOffTypeName , pub.funFarsiDateAddDays('Day', @DocDate, PD.DaysNo) FinishDate,N''  Name,@Price Price
					from (
						SELECT CustomerKindID,PayOffTypeID,DaysNo FROM sal.tblPayOffDiscountsDtl
					except
						select CustomerKindID,PD.PayOffTypeID,DaysNo
						FROM (
							SELECT * 
							from (
								SELECT *,row_number()over(partition by CustomerKindID,PayOffTypeID order by LEN(GoodsID) desc ) RW 
								FROM sal.tblPayOffDiscountsDtl P
								WHERE (CustomerKindID = @CustomerKindID)  AND 
								      (SUBSTRING(@GoodsID,1,LEN(GoodsID))=GoodsID AND
									   (LEN(GoodsGroupID)=0 OR (SELECT COUNT(*) FROM inv.tblGoodsGroupsGoodsListDtl G WHERE G.GoodsGroupID=P.GoodsGroupID AND G.GoodsID =@GoodsID )>0)
									  )
						  		 ) a
							--WHERE RW = 1
						) PD
						inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
						WHERE  (@Price <= 0 or (@Price > 0 AND @Price >= FromPrice AND @Price <= ToPrice)) And
							   (@PayOffTypeID Is Null OR @PayOffTypeID = '' OR (PD.DaysNo <= ISNULL((SELECT TOP 1 DaysNo from sal.tblPayOffDiscountsDtl WHERE PayOffTypeID = @PayOffTypeID),0)))
					
						 )  PD   
				   inner join sal.tblPayOffTypesDtl PT on PD.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = @LangID
						WHERE PD.CustomerKindID=@CustomerKindID
				order by DocRowNo

				Fetch NEXT From curSale Into @GoodsID,@Price
			END
		
			Close curSale;
			Deallocate curSale; 
			
		end

		SELECT CustomerKindID, RowNo, DocRowNo, PayOffTypeID, DiscountPercent,IsDefault, 
				1 FromPrice,1000000000000 ToPrice, DaysNo,GoodsID, PayOffTypeName,FinishDate,
				(select DISTINCT  Name + '' from #PayOffDiscounts b WHERE a.PayOffTypeID=b.PayOffTypeID  for xml path('') ) Name
				,SUM(Price) Price
		FROM #PayOffDiscounts a
		group by 
			CustomerKindID, RowNo, DocRowNo, PayOffTypeID, DiscountPercent, 
			IsDefault, FromPrice, ToPrice, DaysNo, GoodsID,RW, PayOffTypeName,FinishDate
				
	END
End
GO
