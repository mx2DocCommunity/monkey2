
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-assimp>"

#Import "../mojo3d"

#Import "assets/"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _ground:Model
	
	Field _turtle:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-20 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( Pi/2,0,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create ground
		'
'		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green,0,.5 ) )
		
		'create turtle
		'		
		_turtle=Model.Load( "asset::turtle1.b3d" )
		
'		_turtle.Mesh.FitVertices( New Boxf( -1,1 ) )
'		_turtle.Move( 0,10,0 )
		
	End
		
	Method OnRender( canvas:Canvas ) Override
		
		Global time:=0.0
		
		RequestRender()
		
		util.Fly( _camera,Self )
		
		If Keyboard.KeyDown( Key.Space ) time+=12.0/60.0
			
		_turtle.Animator.Animate( 0,time )
		
		_scene.Render( canvas,_camera )

		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End