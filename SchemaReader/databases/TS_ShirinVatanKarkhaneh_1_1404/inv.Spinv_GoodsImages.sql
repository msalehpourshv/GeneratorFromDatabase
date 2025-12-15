USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reza Moayed,NP
-- Create date: 93/06/06
-- Description:	
-- =============================================
create PROCEDURE  [inv].[Spinv_GoodsImages]  --6,'210202 0908',0

@UserID as int=0,
@VisitorID as varchar(20)='',
@IsSayman as bit=1

WITH ENCRYPTION
AS
Begin

if @IsSayman=0
begin


SELECT  D.* FROM inv.tblGoodsImages D

inner join (SELECT * from inv.tblGoods where  NotShowInTablet = 'False')  G
on D.GoodsID=G.GoodsID

where D.GoodsImage is not null and



 ( -- حیطه
		(Select COUNT(*) from inv.tblGoodsRng
			where D.GoodsImage is not null and UserID=@UserID AND AllowCodeView=1 AND 
			      LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(G.GoodsID))
			  and LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(G.GoodsID)))>0  
		OR 
			(Select COUNT(*) from inv.tblGoodsRng
			where UserID=@UserID and AccessAllCode=1
			and D.GoodsImage is not null)>0
		)
	 OR 
	LEFT(G.GoodsID,LEN(G.GoodsID)) in (select LEFT(g.GoodsID,LEN(G.GoodsID))
				  FROM inv.tblVisitorCoddingRangDtl a 
				  INNER JOIN inv.tblGoodsGroupsGoodsListDtl g 
				  ON a.GoodsGroupID=g.GoodsGroupID 
				  WHERE a.VisitorID = @VisitorID AND 
				  FromGoodsID = '' AND ToGoodsID = ''
				  and D.GoodsImage is not null)	  
	  
	 OR
	 
	 ( 
		(Select COUNT(*) from inv.tblVisitorCoddingRangDtl
		where VisitorID = @VisitorID AND LEFT(G.GoodsID,LEN(G.GoodsID))>=
		LEFT(inv.tblVisitorCoddingRangDtl.FromGoodsID,LEN(G.GoodsID))
		and LEFT(G.GoodsID,LEN(G.GoodsID))<=
		LEFT(inv.tblVisitorCoddingRangDtl.ToGoodsID,LEN(G.GoodsID))
		)>0 and D.GoodsImage is not null
		 
	)

		 
end

if @IsSayman=1

begin


	SELECT  D.* FROM inv.tblGoodsImages D

	inner join inv.tblGoods G
	on D.GoodsID=G.GoodsID

	where NotShowInTablet = 'False' AND D.GoodsImage is not null 
 end
 
 
 
End
GO
