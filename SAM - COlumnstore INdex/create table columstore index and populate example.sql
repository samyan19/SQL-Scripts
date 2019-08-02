create table t_colstor(
accountkey int not null,
accountdescription nvarchar(50),
accounttype nvarchar(50),
unitsold int)

create unique clustered index t_colstor_ci on t_colstor(accountkey)

create nonclustered columnstore index t_colstor_NCCI on t_colstor (accountdescription, unitsold)

declare @outerloop int=0
declare @i int=0
while (@outerloop < 1000000)
begin
	select @i=0

	begin tran
	while (@i<2000)
	begin
		insert t_colstor values (@i + @outerloop, 'test1', 'test2', @i*4)
		set @i +=1;
	end
	commit

	set @outerloop = @outerloop + 2000
	set @i =0 
end
go

