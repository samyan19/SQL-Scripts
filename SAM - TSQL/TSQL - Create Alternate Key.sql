ALTER table dbo.DimCapacityType add constraint AK_DimCapacityType unique NONCLUSTERED 
(
	[CapacityTypeID] ASC
)