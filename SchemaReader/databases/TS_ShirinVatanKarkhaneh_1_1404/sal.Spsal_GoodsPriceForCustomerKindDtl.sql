USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : REZA Moayed,Reza NP
-- Create date   : 93/06/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
 -- [sal].[Spsal_GoodsPriceForCustomerKindDtl] 5,'211001 3104',0
create PROCEDURE  [sal].[Spsal_GoodsPriceForCustomerKindDtl]

	@UserID as int=0,
	@VisitorID as varchar(20)='',
	@IsSayman as bit=1
	
WITH ENCRYPTION
AS
Begin


if @IsSayman=0
begin

SELECT  D.*,H.* FROM sal.tblGoodsPriceForCustomerKindDtl D
inner join sal.tblGoodsPriceForCustomerKindHdr H
on D.SerialNo=H.SerialNo
inner join inv.tblGoods G
on D.GoodsID=G.GoodsID

where H.CurrencyTypeID = '' and  NotShowInTablet = 'False' AND 1=1 and
	
( -- حیطه
	(Select COUNT(*) from inv.tblGoodsRng
		where  UserID=@UserID AND AllowCodeView=1 AND 
			    LEFT(G.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=inv.tblGoodsRng.FromCode
			and LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=inv.tblGoodsRng.ToCode)>0  
			and G.CodeClosed=0 
	OR 
		(Select COUNT(*) from inv.tblGoodsRng
		where UserID=@UserID and AccessAllCode=1)>0
)
		OR 
	LEFT(G.GoodsID,LEN(G.GoodsID)) in (select LEFT(g.GoodsID,LEN(G.GoodsID))
					FROM inv.tblVisitorCoddingRangDtl a 
					INNER JOIN inv.tblGoodsGroupsGoodsListDtl g 
					ON a.GoodsGroupID=g.GoodsGroupID 
					WHERE a.VisitorID = @VisitorID AND 
					FromGoodsID = '' AND ToGoodsID = ''
					and G.CodeClosed=0)	  
		  
		OR
		 
		( 
		(Select COUNT(*) from inv.tblVisitorCoddingRangDtl
		where VisitorID = @VisitorID AND LEFT(G.GoodsID,LEN(G.GoodsID))>=LEFT(inv.tblVisitorCoddingRangDtl.FromGoodsID,LEN(G.GoodsID))
		and LEFT(G.GoodsID,LEN(G.GoodsID))<=LEFT(inv.tblVisitorCoddingRangDtl.ToGoodsID,LEN(G.GoodsID)))>0
		and G.CodeClosed=0 
			 
		)		 
		 
end
	
if @IsSayman=1
begin

	SELECT  D.*,H.* FROM sal.tblGoodsPriceForCustomerKindDtl D
	inner join sal.tblGoodsPriceForCustomerKindHdr H
	on D.SerialNo=H.SerialNo
	inner join inv.tblGoods G
	on D.GoodsID=G.GoodsID
	where   H.CurrencyTypeID = '' and NotShowInTablet = 'False' 
			 
end
	
End
GO
