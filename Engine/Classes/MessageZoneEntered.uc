class MessageZoneEntered extends MessageZone
	editinlinenew;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Zone "$triggeredBy$" is entered";
}

defaultproperties
{
}
