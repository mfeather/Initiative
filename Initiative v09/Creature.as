package  {
	
	public class Creature {
		
		public var myName,otherStatus:String;
		public var initiative:Number;
		public var ac,fort,ref,will,pi,pp:int;
		public var isDelaying:Boolean = false;
		private var statusArray:Array = new Array();
		public var hasOtherStatus:Boolean = false;
		public var statIcons:Array = new Array();				//Array of the icons indicating each creature's statuses

		public function Creature(newName:String = "Enemy",newInit:Number = 0.0) {
			// constructor code
			myName = newName;
			initiative = newInit;
			for(var i:int=0;i<6;i++)
				statusArray.push(false);
			otherStatus = "";
		}
		
		public function getStatus():Array
		{
			return statusArray;
		}
		
		public function setStatus(bloodied:Boolean,dying:Boolean,marked:Boolean,
								  dazed:Boolean,slowed:Boolean,weakened:Boolean)
		{
			statusArray = new Array(bloodied,dying,marked,dazed,slowed,weakened);
		}
		
		public function setStatusTo(newStatus:Array)
		{
			if(newStatus.length == 6)
			{
				statusArray = newStatus;
			}
			else
				trace("Status array is not six elements long!");
		}

	}
	
}
