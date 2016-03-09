/*

List linked servers

http://jasonbrimhall.info/2012/03/01/linked-servers/

*/


select SRV_NAME = srv.name,
        SRV_PROVIDERNAME    = srv.provider,
        SRV_PRODUCT         = srv.product,
        SRV_DATASOURCE      = srv.data_source,
        SRV_PROVIDERSTRING  = srv.provider_string,
        SRV_LOCATION        = srv.location,
        SRV_CAT             = srv.catalog
	From sys.servers srv
	Where is_linked = 1
