
module Graphics.Gloss.Internals.Interface.Simulate
	(simulateInWindow)
where
import Graphics.Gloss.Color
import Graphics.Gloss.Picture
import Graphics.Gloss.ViewPort
import Graphics.Gloss.Internals.Render.Picture
import Graphics.Gloss.Internals.Render.ViewPort
import Graphics.Gloss.Internals.Interface.Window
import Graphics.Gloss.Internals.Interface.Common.Exit
import Graphics.Gloss.Internals.Interface.ViewPort.KeyMouse
import Graphics.Gloss.Internals.Interface.ViewPort.Motion
import Graphics.Gloss.Internals.Interface.ViewPort.Reshape
import Graphics.Gloss.Internals.Interface.Animate.Timing
import Graphics.Gloss.Internals.Interface.Simulate.Idle
import qualified Graphics.Gloss.Internals.Interface.Callback			as Callback
import qualified Graphics.Gloss.Internals.Interface.ViewPort.ControlState	as VPC
import qualified Graphics.Gloss.Internals.Interface.Simulate.State		as SM
import qualified Graphics.Gloss.Internals.Interface.Animate.State		as AN
import qualified Graphics.Gloss.Internals.Render.Options			as RO
import qualified Graphics.UI.GLUT						as GLUT
import Data.IORef
import System.Mem

-- | Run a simulation in a window
simulateInWindow
	:: String			-- ^ The name of the window.
	-> (Int, Int)			-- ^ Initial size of the window, in pixels.
	-> (Int, Int)			-- ^ Initial position of the window, in pixels.
	-> Color			-- ^ Background color.
	-> Int				-- ^ Number of steps to take for each second of real time.
	-> world 			-- ^ The initial world.
	-> (world -> Picture)	 	-- ^ A function to convert the world a picture.

	-> (ViewPort -> Float -> world -> world) 	
					-- ^ A function to step the world one iteration.
					--	The float gives the simulation period (time step).
	-> Float			-- ^ How much time to advance the world by in single step mode.
	-> IO ()

simulateInWindow
	windowName
	windowSize
	windowPos
	backgroundColor
	simResolution
	worldStart
	worldToPicture
	worldAdvance
	singleStepTime
 = do
	-- make the simulation state
	stateSR		<- newIORef $ SM.stateInit simResolution

	-- make a reference to the initial world
	worldSR		<- newIORef worldStart

	-- make the initial GL view and render states
	viewSR		<- newIORef viewPortInit
	viewControlSR	<- newIORef VPC.stateInit
	renderSR	<- newIORef RO.optionsInit
	animateSR	<- newIORef AN.stateInit

	let displayFun
	     = do
		-- convert the world to a picture
		world		<- readIORef worldSR
		let picture	= worldToPicture world
	
		-- display the picture in the current view
		renderS		<- readIORef renderSR
		viewS		<- readIORef viewSR

		-- render the frame
		withViewPort 
			viewS
	 	 	(renderPicture renderS viewS picture)
 
		-- perform garbage collection
		performGC

	let callbacks
	     = 	[ Callback.Display	(animateBegin animateSR)
		, Callback.Display 	displayFun
		, Callback.Display	(animateEnd   animateSR)
		, Callback.Idle		(callback_simulate_idle 
						stateSR animateSR viewSR 
						worldSR worldStart worldAdvance
						singleStepTime)
		, callback_exit () 
		, callback_viewPort_keyMouse viewSR viewControlSR 
		, callback_viewPort_motion   viewSR viewControlSR 
		, callback_viewPort_reshape ]

	createWindow windowName windowSize windowPos backgroundColor callbacks
