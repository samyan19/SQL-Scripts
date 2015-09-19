--Add Column
ALTER table dbo.GuideRequests add utm_source varchar(100) NULL;

--Drop Column
alter table dbo.GuideRequests drop column utm_source;

