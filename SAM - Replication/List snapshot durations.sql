SELECT mp.publisher_db
	,[repl type]=case mp.publication_type
	WHEN 0 THEN 'Trans'
	WHEN 1 THEN 'Snap'
	when 2 THEN 'Merge'
	END
	 , mp.publication
	 , article
	 ,b.name as [job name]
	 , start_time
	 , snaph.[time]
	 , duration
	 , comments
	 , delivered_transactions
FROM
	distribution.dbo.MSpublications mp
INNER JOIN distribution.dbo.MSarticles ma
	ON mp.publication_id = ma.publication_id
				INNER JOIN distribution.dbo.MSsnapshot_agents snapa
					ON mp.publication = snapa.publication
					INNER JOIN distribution.dbo.MSsnapshot_history snaph
						ON snapa.id = snaph.agent_id
						inner JOIN msdb.dbo.sysjobs b
						on snapa.job_id=b.job_id
						where comments like '%generated%'
						and start_time=(
  SELECT 
	 max(start_time)
FROM
	distribution.dbo.MSpublications mp2
INNER JOIN distribution.dbo.MSarticles ma2
	ON mp2.publication_id = ma2.publication_id
				INNER JOIN distribution.dbo.MSsnapshot_agents snapa2
					ON mp2.publication = snapa2.publication
					INNER JOIN distribution.dbo.MSsnapshot_history snaph2
						ON snapa2.id = snaph2.agent_id
						where mp2.publication=mp.publication)
