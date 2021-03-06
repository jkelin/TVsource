class DegrappleProjectile extends Gameplay.GrapplerProjectile;

var float Health;

function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	Health -= Damage;
	
	if(Health <= 0)
		Destroy();
		
	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}

simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
	Super.simulatedAttach(Other, TouchLocation);

	SetCollision(true, true, true);
}

defaultproperties
{
     Health=25.000000
     bCanBeDamaged=True
}
