//=============================================================================
// Fragment.
//=============================================================================
class Fragment extends Effects;

var() MESH Fragments[11];
var int numFragmentTypes;
var bool bFirstHit;
var() sound    ImpactSound, AltImpactSound;		
var()	float  SplashTime;

function bool CanSplash()
{
	if ( (Level.TimeSeconds - SplashTime > 0.25)
		&& (Physics == PHYS_Falling)
		&& (Abs(Velocity.Z) > 100) )
	{
		SplashTime = Level.TimeSeconds;
		return true;
	}
	return false;
}


simulated function CalcVelocity(vector Momentum)
{
	local float ExplosionSize;

	ExplosionSize = 0.011 * VSize(Momentum);
	Velocity = 0.0033 * Momentum + 0.7 * VRand()*(ExplosionSize+FRand()*100.0+100.0); 
	Velocity.Z += 0.5 * ExplosionSize;
}

simulated function HitWall (vector HitNormal, actor HitWall)
{
	local float speed;

	Velocity = 0.5*(( Velocity Dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);	
	if (bFirstHit && speed<400) 
	{
		bFirstHit=False;
		bRotateToDesired=True;
		bFixedRotationDir=False;
		DesiredRotation.Pitch=0;	
		DesiredRotation.Yaw=FRand()*65536;
		DesiredRotation.Roll=0;
	}
	RotationRate.Yaw = RotationRate.Yaw*0.75;
	RotationRate.Roll = RotationRate.Roll*0.75;
	RotationRate.Pitch = RotationRate.Pitch*0.75;
	if ( (speed < 60) && (HitNormal.Z > 0.7) )
	{
		SetPhysics(PHYS_None);
		bBounce = false;
		GotoState('Dying');
	}
	else if (speed > 80) 
	{
#if IG_EFFECTS
		if (FRand()<0.5) 
			PlaySound(ImpactSound, , , 300, 300, 0.85+FRand()*0.3, 0, , true);
		else 
			PlaySound(AltImpactSound, , , 300, 300, 0.85+FRand()*0.3, 0, , true);
#else
		if (FRand()<0.5) 
			PlaySound(ImpactSound, SLOT_None,,, 300, 0.85+FRand()*0.3,true);
		else 
			PlaySound(AltImpactSound, SLOT_None,,, 300, 0.85+FRand()*0.3,true);
#endif
	}
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;	
}

auto state Flying
{
	simulated function timer()
	{
		GotoState('Dying');
	}

	simulated singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
		{
			Velocity = 0.2 * Velocity;
			if (bFirstHit) 
			{
				bFirstHit=False;
				bRotateToDesired=True;
				bFixedRotationDir=False;
				DesiredRotation.Pitch=0;	
				DesiredRotation.Yaw=FRand()*65536;
				DesiredRotation.Roll=0;
			}
			
			RotationRate = 0.2 * RotationRate;
			GotoState('Dying');
		}
	}

	simulated function BeginState()
	{
		RandSpin(125000);
		if (Abs(RotationRate.Pitch)<10000) 
			RotationRate.Pitch=10000;
		if (Abs(RotationRate.Roll)<10000) 
			RotationRate.Roll=10000;			
		LinkMesh(Fragments[int(FRand()*numFragmentTypes)]);
		if ( Level.NetMode == NM_Standalone )
			LifeSpan = 20 + 40 * FRand();
		SetTimer(5.0,True);			
	}
}

state Dying
{
#if IG_SHARED  //tcohen: hooked TakeDamage(), used by effects system and reactive world objects
	function PostTakeDamage( float Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional float projectileFactor)
#else
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
#endif
	{
		Destroy();
	}

	simulated function timer()
	{
		if ( !PlayerCanSeeMe() ) 
			Destroy();
	}

	simulated function BeginState()
	{
		SetTimer(1 + FRand(),True);
		SetCollision(true, false, false);
	}
}

defaultproperties
{
     bFirstHit=True
     Physics=PHYS_Falling
     DrawType=DT_Mesh
     LifeSpan=20.000000
     bDestroyInPainVolume=True
     CollisionRadius=18.000000
     CollisionHeight=4.000000
     bCollideWorld=True
     bBounce=True
     bFixedRotationDir=True
}
