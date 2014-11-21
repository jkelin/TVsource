/*=============================================================================
	WebServer is responsible for listening to requests on the selected http
	port and will guide requests to the correct application.
=============================================================================*/

class WebServer extends IpDrv.TcpLink;

var config string Applications[10];
var config string ApplicationPaths[10];
var config int ListenPort;
var config int MaxConnections;
var config string ServerName;
var config bool bEnabled;
var config int DefaultApplication;
#if IG_TRIBES3_ADMIN   // glenn: admin support
var config int ExpirationSeconds;		// How long images can be cached .. default is 24 hours
#endif

var string ServerURL;
var WebApplication ApplicationObjects[10];

var int ConnectionCount;
#if IG_TRIBES3_ADMIN   // glenn: admin support
// var int ConnId;
#endif

function BeginPlay()
{
	local int i;
	local class<WebApplication> ApplicationClass;
	local IpAddr l;
	local string s;

    Log("WebServer.BeginPlay");

	if(!bEnabled)
	{
		Log("Webserver is not enabled.  Set bEnabled to True in Advanced Options.");
		Destroy();
		return;
	}

	Super.BeginPlay();
	
	for(i=0;i<10;i++)
	{
		if(Applications[i] == "")
			break;

		ApplicationClass = class<WebApplication>(DynamicLoadObject(Applications[i], class'Class'));
		if(ApplicationClass != None)
		{
		    log("WebServer: initializing "$ApplicationClass);
		
			ApplicationObjects[i] = New(None) ApplicationClass;
			ApplicationObjects[i].Level = Level;
			ApplicationObjects[i].WebServer = Self;
			ApplicationObjects[i].Path = ApplicationPaths[i];
			ApplicationObjects[i].Init();
		}
	}

	if(ServerName == "")
	{
		GetLocalIP(l);
		s = IpAddrToString(l);
		i = InStr(s, ":");
		if(i != -1)
			s = Left(s, i);
		ServerURL = "http://"$s;
	}
	else
		ServerURL = "http://"$ServerName;

	if(ListenPort != 80)
		ServerURL = ServerURL $ ":"$string(ListenPort);

    Log("WebServer: url="$ServerURL);

	BindPort( ListenPort );

	Listen();
}

event Destroyed()
{
	local int i;

    Log("WebServer.Destroyed");

	for(i=0;i<10;i++)
		if(ApplicationObjects[i] != None)
		{
			ApplicationObjects[i].Cleanup();
			ApplicationObjects[i].Level = None;
			ApplicationObjects[i].WebServer = None;
			ApplicationObjects[i] = None;
		}

	Super.Destroyed();
}

event GainedChild( Actor C )
{
    Log("WebServer.GainedChild: "$C.Name);

	Super.GainedChild(C);
	ConnectionCount++;

	// if too many connections, close down listen.
	if(MaxConnections > 0 && ConnectionCount > MaxConnections && LinkState == STATE_Listening)
	{
		Log("WebServer: Too many connections - closing down Listen.");
		Close();
	}
}

event LostChild( Actor C )
{
    Log("WebServer.LostChild: "$C.Name);

	Super.LostChild(C);
	ConnectionCount--;

	// if closed due to too many connections, start listening again.
	if(ConnectionCount <= MaxConnections && LinkState != STATE_Listening)
	{
		Log("WebServer: Listening again - connections have been closed.");
		Listen();
	}
}

function WebApplication GetApplication(string URI, out string SubURI)
{
	local int i, l;

    Log("WebServer.GetApplication: "$URI $", "$SubURI);

	SubURI = "";
	for(i=0;i<10;i++)
	{
		if(ApplicationPaths[i] != "")
		{
			l = Len(ApplicationPaths[i]);
			if(Left(URI, l) == ApplicationPaths[i] && (Len(URI) == l || Mid(URI, l, 1) == "/"))
			{
				SubURI = Mid(URI, l);
				return ApplicationObjects[i];
			}
		}
	}
	return None;
}

#if IG_TRIBES3_ADMIN   // glenn: admin support

defaultproperties
{
	ExpirationSeconds=86400
	ListenPort=80
	LinkMode=MODE_Text
	AcceptClass=class'WebConnection'
	MaxConnections=30
	DefaultApplication=-1
}

#else

// commented out because defaultproperties parser does not support #if/#else/#endif

//defaultproperties
//{
//	ListenPort=80
//	LinkMode=MODE_Text
//	AcceptClass=class'WebConnection'
//	MaxConnections=30
//	DefaultApplication=-1
//}

#endif