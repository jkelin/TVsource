class ActionVariableMultiply extends Action;

var() actionnoresolve Name lhs;
var() String rhs;


// execute
latent function Variable execute()
{
	local Variable vLhs, result;

	Super.execute();

	vLhs = findVariable(lhs);
	if (vLhs == None)
	{
		logError("lhs of an arithmetic operation must be a variable");
		return None;
	}

	result = newTemporaryVariable(vLhs.class, vLhs.GetPropertyText("value"));
	result.multiply(rhs);

	return result;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = propertyDisplayString('lhs') $ " * " $ propertyDisplayString('rhs');
}

defaultproperties
{
	returnType			= class'Variable'
	actionDisplayName	= "Multiplication"
	actionHelp			= "Returns the result of the multiplication of one variable with another"
	category			= "Variable"
}