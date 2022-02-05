-- кількість клієнтів в кожному із станів
select cs.Name as ClientStatus, 
	   count(*) as NumOfClients
from dbo.tb_clients c
join dbo.tb_Client_Status cs
	on cs.id = c."Status"
group by cs.Name
order by NumOfClients desc;

-- розподіл клієнтів залежно від рівня ризику - лише активні клієнти та клієнти, які потребують переідентифікації
with cte as (
select id as ClientId,
	   case when RiskLevel <= 40 then 'Низький рівень ризику'
			when RiskLevel <= 60 then 'Середній рівень ризику'
			when RiskLevel <= 95 then 'Високий рівень ризику'
			when RiskLevel > 95 then 'Захмарний рівень ризику'
	   end as RiskLevelDescr	
from dbo.tb_Clients
where "Status" = 0 or "Status" = 2
)
select RiskLevelDescr,
	   count(*) as NumOfClients
from cte
group by RiskLevelDescr
order by NumOfClients;

-- кількість договорів в розрізі клієнта та валют - табличка, лише активні клієнти та клієнти, які потребують переідентифікації, при цьому клієнт має мати більш ніж один договір
select c.id as CLientId,
	   c.lname,
	   c.fname,
	   c.mname,
	   c.RiskLevel,
	   c.Date_from,
	   c.Date_birth,
	   case	when tr.CCY is null 
			then 'UAH' else tr.CCY
		end as Curr,
		case when ts.Id in (1001, 1002) 
			then 'Кредит' else 'Депозит'
		end as TreatyType,
		count(*) as NumOfAgr
from dbo.tb_Clients c
join tb_Treaty tr
	on tr.ClientId = c.id
join dbo.tb_Treaty_Systems ts
	on ts.id = tr.SystemId
where c."Status" in (0, 2)
group by c.id, 
	   c.lname,
	   c.fname,
	   c.mname,
	   c.RiskLevel,
	   c.Date_from,
	   c.Date_birth,
	   tr.CCY, 
	   ts.Id
having count(*) > 1
order by NumOfAgr desc;

-- кількість договорів по кожному з продуктів, разом із середньою сумою договору, лише активні клієнти та клієнти, які потребують переідентифікації
with cte as (
select ts.Name as TreatyType,
		case when tr.CCY is not null
			then tr.Amount * tr.ExRate
			else tr.Amount
		end as TreatyAmount
from dbo.tb_Treaty tr
join dbo.tb_Treaty_Systems ts
	on ts.id = tr.SystemId
join dbo.tb_Clients c
	on c.id = tr.CLientId
	and c.Status in (2, 0)
)
select TreatyType, 
		count(*) as NumOfAgr,
		avg(TreatyAmount) as AvgAmount
from cte
group by TreatyType
order by AvgAmount desc;