-- Show Transactional Publications and Subscriptions to articles at Distributor
-- Run this on the DISTRIBUTOR
-- Add a WHERE clause to limit results to one publisher\subscriber\publication\etc
SELECT  publishers.srvname AS [Publisher] ,
        publications.publisher_db AS [Publisher DB] ,
        publications.publication AS [Publication] ,
        subscribers.srvname AS [Subscriber] ,
        subscriptions.subscriber_db AS [Subscriber DB] ,
        articles.article AS [Article]
FROM    sys.sysservers AS publishers
        INNER JOIN distribution.dbo.MSarticles AS articles ON publishers.srvid = articles.publisher_id
        INNER JOIN distribution.dbo.MSpublications AS publications ON articles.publisher_id = publications.publisher_id
                                                              AND articles.publication_id = publications.publication_id
        INNER JOIN distribution.dbo.MSsubscriptions AS subscriptions ON articles.publisher_id = subscriptions.publisher_id
                                                              AND articles.publication_id = subscriptions.publication_id
                                                              AND articles.article_id = subscriptions.article_id
        INNER JOIN sys.sysservers AS subscribers ON subscriptions.subscriber_id = subscribers.srvid

-- Limit results to subscriber 
--WHERE   subscribers.srvname = '[Subscriber Server Name]'

---- Limit results to publisher and publication
--WHERE   publishers.srvname = '[Publisher Server Name]'
--        AND MSpublications.publication = '[Publication Name]'

ORDER BY publishers.srvname ,
        subscribers.srvname ,
        publications.publication ,
        articles.article 