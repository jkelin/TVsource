class TerrainInfo extends Info
	noexport
	showcategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native
	placeable;

struct NormalPair
{
	var vector Normal1;
	var vector Normal2;
};

enum ETexMapAxis
{
	TEXMAPAXIS_XY,
	TEXMAPAXIS_XZ,
	TEXMAPAXIS_YZ,
};

enum ESortOrder
{
	SORT_NoSort,
	SORT_BackToFront,
	SORT_FrontToBack
};

#if IG_SHARED // rowan: aniamtion types for procedurally animated decolayers
enum EAnimationType
{
	AT_None,
	AT_Wind,
};
#endif // IG

struct TerrainLayer
{
	var() Material	Texture;
	var() Texture	AlphaMap;
	var() float		UScale;
	var() float		VScale;
	var() float		UPan;
	var() float		VPan;
	var() ETexMapAxis TextureMapAxis;
	var() float		TextureRotation;
	var() Rotator	LayerRotation;
	var   Matrix	TerrainMatrix;
	var() float		KFriction;
	var() float		KRestitution;
	var   transient Texture	LayerWeightMap;
};

struct DecorationLayer
{
	var() int			ShowOnTerrain;
	var() Texture		ScaleMap;
	var() Texture		DensityMap;
	var() Texture		ColorMap;
	var() StaticMesh	StaticMesh;
	var() RangeVector	ScaleMultiplier;
	var() Range			FadeoutRadius;
	var() Range			DensityMultiplier;
	var() int			MaxPerQuad;
	var() int			Seed;
	var() int			AlignToTerrain;
	var() ESortOrder	DrawOrder;
	var() int			ShowOnInvisibleTerrain;
	var() int			LitDirectional;
	var() int			DisregardTerrainLighting;
	var() int			RandomYaw;

#if IG_SHARED // rowan: animation control
	var() EAnimationType	AnimationType;
	var() float				AnimationSpeed;
	var() float				AnimationAmplitude;
	var() float				AnimationWorldPeriod;
#endif

#if IG_TRIBES3	// michaelj: uniform deco layer scaling
	var() Range			ScaleMultiplier3D;
	var() int			GetLightingFromFinalisedMacro;
#endif
};


struct DecoInfo
{
	var vector	Location;
	var rotator	Rotation;
	var vector	Scale;
	var vector	TempScale;
	var color	Color;
	var int		Distance;

#if IG_R // rowan: UniqueID for vertex shaders
	var int		UniqueID;
#endif
}; 

struct DecoSectorInfo
{
	var array<DecoInfo>	DecoInfo;
	var vector			Location;
	var float			Radius;
};

struct DecorationLayerData
{
	var array<DecoSectorInfo> Sectors;
};

var() int						TerrainSectorSize;
var() Texture					TerrainMap;
var() vector					TerrainScale;
#if IG_MACROTEX // rowan: 
var const Texture				MacroTexture;
var const Texture				FinalisedMacroTexture;
var const Texture				RenderMacroTexture;
var native const Matrix			MacroTextureTransform;
#endif
#if IG_TRIBES3	// rowan: lightmap
var const Texture				LightmapTexture;
var const int					BuiltCurrentLightmap;
#endif
var() TerrainLayer				Layers[32];
var() array<DecorationLayer>	DecoLayers;
var() float						DecoLayerOffset;
var() bool						Inverted;
#if IG_TRIBES3	// rowan: can flag terrains as always visible
var() bool						AlwaysVisible;
var() bool						TileTerrain;
#endif
#if IG_SHARED	// rowan: new editable vars
var() transient bool			bDisableRebuildOnEdit;
#endif

// This option means use half the graphics res for Karma collision.
// Note - Karma ignores per-quad info (eg. 'invisible' and 'edge-turned') with this set to true.
var() bool						bKCollisionHalfRes;

//
// Internal data
//
var transient int							JustLoaded;
var	native const array<DecorationLayerData> DecoLayerData;
var native const array<TerrainSector>		Sectors;
var native const array<vector>				Vertices;
var native const int						HeightmapX;
var native const int 						HeightmapY;
var native const int 						SectorsX;
var native const int 						SectorsY;
var native const TerrainPrimitive 			Primitive;
var native const array<NormalPair>			FaceNormals;
var native const vector						ToWorld[4];
var native const vector						ToHeightmap[4];
#if IG_MACROTEX
var native const vector						ToMacro[4];
#endif // IG
var native const array<int>					SelectedVertices;
var native const int						ShowGrid;
var const array<int>						QuadVisibilityBitmap;
var const array<int>						EdgeTurnBitmap;
var const array<material> QuadDomMaterialBitmap;
var native const array<int>					RenderCombinations;
var native const array<int>					VertexStreams;
#if IG_R // rowan: TERRAIN_COLOR
var native const array<int>					ColorStreams;
#endif
var native const array<color>				VertexColors;
var native const array<color>				PaintedColor;		// editor only
var native const Texture CollapsedLayers;

// OLD
var native const Texture OldTerrainMap;
var native const array<byte> OldHeightmap;

#if IG_SHARED // rowan: New vars
var native const int DecolayerRenderer;
#endif

#if IG_TRIBES3 // rowan: space for quadtree and finalised data ptr
var native const int QuadTree;
var native const object FinalisedData;
var native const int ActiveHardwareData;

var native const array<int> HardwareIndexBuffers;
#endif

#if IG_R // rowan: Temporary Visibility Data
var native const int VisibleSectorsCount;
var native const int RenderThingsCount;
var native const int VisibleSectors;
var native const int SectorProjectors;
var native const int RenderThings;
#endif

#if IG_TRIBES3 // dbeswick: this function is called to determine whether a projectile can hit this actor
simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	return true;
}
#endif

defaultproperties
{
	Texture=Texture'Engine_res.S_TerrainInfo'
	TerrainScale=(X=64,Y=64,Z=64)
	bStatic=True
	bStaticLighting=True
	bWorldGeometry=true
    bHidden=true
	TerrainSectorSize=16
	bKCollisionHalfRes=False

#if IG_SHARED // Alex:
	bBlockHavok=true
#endif
}
