-- ������� �볺��� � ������� �� �����
select cs.Name as ClientStatus, 
	   count(*) as NumOfClients
from dbo.tb_clients c
join dbo.tb_Client_Status cs
	on cs.id = c."Status"
group by cs.Name
order by NumOfClients desc;

-- ������� �볺��� ������� �� ���� ������ - ���� ������ �볺��� �� �볺���, �� ���������� ����������������
with cte as (
select id as ClientId,
	   case when RiskLevel <= 40 then '������� ����� ������'
			when RiskLevel <= 60 then '������� ����� ������'
			when RiskLevel <= 95 then '������� ����� ������'
			when RiskLevel > 95 then '��������� ����� ������'
	   end as RiskLevelDescr	
from dbo.tb_Clients
where "Status" = 0 or "Status" = 2
)
select RiskLevelDescr,
	   count(*) as NumOfClients
from cte
group by RiskLevelDescr
order by NumOfClients;

-- ������� �������� � ����� �볺��� �� ����� - ��������, ���� ������ �볺��� �� �볺���, �� ���������� ����������������, ��� ����� �볺�� �� ���� ���� �� ���� ������
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
			then '������' else '�������'
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

-- ������� �������� �� ������� � ��������, ����� �� ��������� ����� ��������, ���� ������ �볺��� �� �볺���, �� ���������� ����������������
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