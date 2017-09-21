select * 
from sys.server_event_sessions ses
join sys.server_event_session_fields sesf on ses.event_session_id=sesf.event_session_id
