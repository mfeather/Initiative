package  {
	
	public class Creature {
		
		public var myName:String;
		public var initiative,ac,fort,ref,will,pi,pp:int;

		public function Creature(newName:String = "Enemy",newInit:int = 0) {
			// constructor code
			myName = newName;
			initiative = newInit;
		}

	}
	
}
