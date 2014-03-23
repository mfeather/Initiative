package  {
	import flash.text.TextField;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldType;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	public class Initiative extends MovieClip{
		
		var creatures:Array = new Array();
		var playerCharacters:Array = new Array();
		var initiativeOrder:Array = new Array();
		var charStats:Array = new Array();
		var initOrderFormat:TextFormat = new TextFormat("Times New Roman",50,0x00FF00);
		var initActiveFormat:TextFormat = new TextFormat("Times New Roman",50,0x00BFFF);
		var charStatFormat:TextFormat = new TextFormat("Times New Roman",30,0x00BF00);
		var labelFormat:TextFormat = new TextFormat("Times New Roman",26,0xBFBFBF);
		var inputFormat:TextFormat = new TextFormat("Arial",25,0x00BF00);
		var inputName:TextField = new TextField();
		var inputInit:TextField = new TextField();
		var buttonText1:TextField = new TextField();
		var buttonText2:TextField = new TextField();
		var addButton:BasicButton = new BasicButton();
		var doneButton:BasicButton = new BasicButton();
		var activeCreatureNum:int = 0;
		var encounterState:String = "Begin";

		public function Initiative() {
			charStatFormat.align = TextFormatAlign.RIGHT;
			labelFormat.align = TextFormatAlign.RIGHT;
			//Load the player characters from the text file
			var pcLoader:URLLoader = new URLLoader(new URLRequest("PlayerCharacters.txt"));
			pcLoader.addEventListener(Event.COMPLETE,pcLoaded);
			creatures.push(new Creature());
		}
		
		public function startEncounter()
		{
			// constructor code
			var bgd:Background = new Background();
			addChild(bgd);	
			
			var statText:TextField = new TextField();
			statText.defaultTextFormat = labelFormat;
			statText.width = 360;
			statText.text = "AC FT RF WL PI PP";
			statText.x = 620;
			statText.y = 115;
			statText.selectable = false;
			addChild(statText);
			
			createCreatureInput();
		}
		
		private function beginEncounter()
		{
			removeChild(buttonText2);
			removeChild(inputInit);
			activeCreatureNum = 0;
			addButton.x = 630;
			addButton.y = 615;
			addButton.width = 360;
			addButton.addEventListener(MouseEvent.CLICK,nextCreature);
			buttonText1.text = "Next";
			buttonText1.x = 780;
			buttonText1.y = 620;
			encounterState = "Battle";
			refreshInitiative();
		}
		
		//Called once when the pc text file has finished loading
		private function pcLoaded(event:Event)
		{
			var loadedCreatures:URLLoader = URLLoader(event.target);
			//Split up the stats and create the pcs from the stats
			createPCs(loadedCreatures.data.split(" "));	
		}
		
		private function createPCs(stats:Array)
		{	
			encounterState = "loading";
			while(stats.length>0)
			{
				var creature:Creature = new Creature(stats.shift());
				creature.ac = stats.shift();
				creature.fort = stats.shift();
				creature.ref = stats.shift();
				creature.will = stats.shift();
				creature.pi = stats.shift();
				creature.pp = stats.shift();
				playerCharacters.push(creature);
				creatures.push(creature);
			}
			refreshInitiative();
			playerCharacters.forEach(addToCharStats);
			encounterState = "Input";
		}
		
		private function refreshInitiative()
		{
			for(var i:int=0;i<initiativeOrder.length;i++)
				removeChild(initiativeOrder[i]);
			initiativeOrder = new Array();
			creatures.sortOn("initiative",Array.NUMERIC|Array.DESCENDING);
			if(creatures.length > 17)
				initOrderFormat.size = 20;
			else if(creatures.length > 10)
				initOrderFormat.size = 30;
			creatures.forEach(addToInitiativeOrder);
		}
		
		private function addToInitiativeOrder(e:*,index:int,array:Array)
		{
			var name1:TextField = new TextField();
			if(encounterState=="Battle" && index==activeCreatureNum)
				name1.defaultTextFormat = initActiveFormat;
			else
				name1.defaultTextFormat = initOrderFormat;
			name1.width = 500;
			name1.text = e.myName;
			name1.x = 50;
			name1.y = 75 + index * name1.textHeight;
			name1.selectable = false;
			initiativeOrder.push(name1);
			addChild(name1);
		}
		
		private function addToCharStats(e:*,index:int,array:Array)
		{
			var name1:TextField = new TextField();
			name1.defaultTextFormat = charStatFormat;
			name1.width = 360;
			name1.text = e.myName + " " + e.ac + " " + e.fort + " " + e.ref + " " + e.will
						+ " " + e.pi + " " + e.pp;
			name1.x = 620;
			name1.y = 150 + index * name1.textHeight;
			name1.selectable = false;
			charStats.push(name1);
			addChild(name1);
			
		}
		
		private function addCreature(event:MouseEvent)
		{
			if(inputName.text.length<1||inputInit.text.length<1)
				return;
				
			creatures.push(new Creature(inputName.text,int(inputInit.text)));
			inputName.text = "";
			inputInit.text = "";
			stage.focus = inputName;
			refreshInitiative();
		}
		
		private function charInit(event:MouseEvent)
		{
			removeChild(inputName);
			addButton.removeEventListener(MouseEvent.CLICK,addCreature);
			doneButton.removeEventListener(MouseEvent.CLICK,beginEncounter);
			removeChild(doneButton);
			buttonText2.x = 620;
			buttonText2.y = 400;
			buttonText2.width = 250;
			buttonText2.height = buttonText2.textHeight + 5;
			buttonText1.text = "Enter";
			addButton.width = 80;
			nextCharInit();
		}
		
		private function nextCharInit()
		{
			if(activeCreatureNum >= playerCharacters.length)
				beginEncounter();
			stage.focus = inputInit;
			buttonText2.text = playerCharacters[activeCreatureNum].myName + "'s initiative:";
			
			inputInit.text = "";
			addButton.addEventListener(MouseEvent.CLICK,editCharInit);
		}
		
		private function editCharInit(event:MouseEvent)
		{
			if(inputInit.text.length<1)
				return;
			addButton.removeEventListener(MouseEvent.CLICK,editCharInit);
			playerCharacters[activeCreatureNum].initiative = inputInit.text;
			activeCreatureNum++;
			nextCharInit();			
		}
		
		private function createCreatureInput()
		{
			
			inputName.defaultTextFormat = inputFormat;
			inputName.type = TextFieldType.INPUT;
			inputName.border = true;
			inputName.x = 620;
			inputName.y = 400;
			inputName.height = inputName.textHeight+5;
			inputName.width = 250;
			inputName.maxChars = 15;
			inputName.borderColor = 0x003300;
			addChild(inputName);
			
			inputInit.defaultTextFormat = inputFormat;
			inputInit.type = TextFieldType.INPUT;
			inputInit.border = true;
			inputInit.x = 880;
			inputInit.y = 400;
			inputInit.height = inputInit.textHeight+5;
			inputInit.width = 50;
			inputInit.maxChars = 2;
			inputInit.borderColor = 0x003300;
			addChild(inputInit);
			
			addButton.x = 875;
			addButton.y = 450;
			addButton.width = 65;
			addButton.addEventListener(MouseEvent.CLICK,addCreature);
			addChild(addButton);
			
			buttonText1.mouseEnabled = false;
			buttonText1.defaultTextFormat = inputFormat;
			buttonText1.text = "Add";
			buttonText1.x = addButton.x + 7;
			buttonText1.y = addButton.y + 5;
			buttonText1.height = buttonText1.textHeight;
			addChild(buttonText1);
			
			doneButton.x = 775;
			doneButton.y = 450;
			doneButton.width = 80;
			doneButton.addEventListener(MouseEvent.CLICK,charInit);
			addChild(doneButton);
			
			buttonText2.mouseEnabled = false;
			buttonText2.defaultTextFormat = inputFormat;
			buttonText2.text = "Done";
			buttonText2.x = doneButton.x + 7;
			buttonText2.y = doneButton.y + 5;
			buttonText2.height = buttonText2.textHeight;
			addChild(buttonText2);
			stage.focus = inputName;
		}
		
		private function nextCreature(event:MouseEvent)
		{
			activeCreatureNum++;
			if(activeCreatureNum == initiativeOrder.length)
				activeCreatureNum = 0;
			refreshInitiative();
		}

	}
	
}
