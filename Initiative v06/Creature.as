package  {
	
	public class Creature {
		
		public var myName,otherStatus:String;
		public var initiative,ac,fort,ref,will,pi,pp:int;
		public var isDelaying:Boolean = false;
		private var statusArray:Array = new Array();
		public var hasOtherStatus:Boolean = false;

		public function Creature(newName:String = "Enemy",newInit:int = 0) {
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
				//if(newStatus.every(function allBool(e:*,i:int,a:Array){return e is Boolean;}))
				   statusArray = newStatus;
				//else
					//trace("Status array does not contain only Boolean values!");
			}
			else
				trace("Status array is not six elements long!");
		}

	}
	
}
