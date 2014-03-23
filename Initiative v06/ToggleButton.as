package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	

	
	public class ToggleButton extends MovieClip {
		

		public var isOn:Boolean = false;
		
		public function ToggleButton(newX:int, newY:int) {
			// constructor code
			x = newX;
			y = newY;
			setState();
			addEventListener(MouseEvent.CLICK,clicked);
		}
		
		private function clicked(event:MouseEvent)
		{
			isOn = !isOn;
			setState();
		}
		
		public function setState()
		{
			if(isOn)
				gotoAndStop("On");
			else
				gotoAndStop("Off");
		}
		
		public function setStateTo(newState:Boolean)
		{
			isOn = newState;
			setState();
		}
		
		public function remove()
		{
			removeEventListener(MouseEvent.CLICK,clicked);
		}
	}
	
}
