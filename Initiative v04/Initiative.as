﻿package  {
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
		
		var creatures:Array = new Array();				//Array of the creature objects in the battle
		var playerCharacters:Array = new Array();		//Array of the player character's creature objects
		var initiativeOrder:Array = new Array();		//Array of the text fields in the initiative list
		var delayingCreatures:Array = new Array();		//Array of the creature objects that are delaying
		var charStats:Array = new Array();				//Array of the text fields in the char stat list
		var buttons:Array = new Array();				//Array of temporary buttons
		var buttonLabels:Array = new Array();			//Array of labels matching temporary buttons
		var textFields:Array = new Array();				//Array of temporary text fields
		var statusLabels:Array = new Array("Bloodied","Dying","Marked","Dazed","Slowed","Weakened");  //Array of status label strings
		var initOrderFormat:TextFormat = new TextFormat("Times New Roman",50,0x00FF00);		//Format of non-active initiative fields
		var initActiveFormat:TextFormat = new TextFormat("Times New Roman",50,0x00BFFF);	//Format of the active initiative field
		var initDelayFormat:TextFormat = new TextFormat("Times New Roman",50,0x00BFBF);		//Format of the delaying initiative fields
		var charStatFormat:TextFormat = new TextFormat("Times New Roman",30,0x00BF00);		//Format of the char stat list
		var labelFormat:TextFormat = new TextFormat("Times New Roman",26,0xBFBFBF);			//Format of information labels
		var inputFormat:TextFormat = new TextFormat("Arial",25,0x00BF00);					//Generic format
		var activeCreatureNum:int = 0;					//Index of the active creature in the initiative list
		var selectedCreatureNum:int = 0;				//Index of the selected creature to view
		var encounterState:String = "Begin";			//Tracks the current state of the program

		public function Initiative() {
			//Right-justify some text formats
			charStatFormat.align = TextFormatAlign.RIGHT;
			labelFormat.align = TextFormatAlign.RIGHT;
			initDelayFormat.align = TextFormatAlign.RIGHT;
			initActiveFormat.italic = true;
			//Load the player characters from the text file
			var pcLoader:URLLoader = new URLLoader(new URLRequest("PlayerCharacters.txt"));
			pcLoader.addEventListener(Event.COMPLETE,pcLoaded);
		}
		
		//Called once at the start of the program
		public function initializeEncounter()
		{
			//Create the background and add it
			var bgd:Background = new Background();
			addChild(bgd);	
			
			//Create the label for the char stat list
			var statText:TextField = new TextField();
			statText.defaultTextFormat = labelFormat;
			statText.width = 360;
			statText.text = "AC FT RF WL PI PP";
			statText.x = 620;
			statText.y = 115;
			statText.selectable = false;
			addChild(statText);
			
			//Create prompt for inputing additional creatures
			createCreatureInput();
		}
		
		//Called after all creatures have been loaded in to the battle
		private function beginEncounter()
		{
			activeCreatureNum = 0;
			//Create the main button prompts and start the battle
			createMainPrompts();			
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
		
		//Called once to create the player characters from the stats 
		private function createPCs(stats:Array)
		{	
			encounterState = "loading";
			//While there are more creatures, make a new creature
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
			//Add all of the player characters to the main creature list
			playerCharacters.forEach(addToCharStats);
			encounterState = "Input";
		}
		
		//Called anytime the initiative list needs to be updated
		private function refreshInitiative(sort:Boolean = true)
		{
			//Clear the current list
			for(var i:int=0;i<initiativeOrder.length;i++)
				removeChild(initiativeOrder[i]);
			initiativeOrder = new Array();
			//Sort the creature list by initiative in descending order
			if(sort)
				creatures.sortOn("initiative",Array.NUMERIC|Array.DESCENDING);
			//If the list gets too long, resize the font
			if(creatures.length > 17)
			{
				initOrderFormat.size = 20;
				initActiveFormat.size = 20;
			}
			else if(creatures.length > 10)
			{
				initOrderFormat.size = 30;
				initActiveFormat.size = 30;
			}
			else
			{
				initOrderFormat.size = 50;
				initActiveFormat.size = 50;
			}
			//Add all of the creatures to the new initiative list
			creatures.forEach(addToInitiativeOrder);
		}
		
		//Called to add a creature's name to the initiative list
		private function addToInitiativeOrder(e:*,index:int,array:Array)
		{
			var name1:TextField = new TextField();
			//If the battle has started, change the format of the active creature
			if(encounterState=="Battle")
			{
				if(index==activeCreatureNum)
					name1.defaultTextFormat = initActiveFormat;
				else if(e.isDelaying)
					name1.defaultTextFormat = initDelayFormat;
				else
					name1.defaultTextFormat = initOrderFormat;
			}
			else
				name1.defaultTextFormat = initOrderFormat;
			name1.width = 450;
			name1.text = e.myName;
			name1.x = 50;
			name1.y = 75 + index * name1.textHeight;
			name1.selectable = false;
			initiativeOrder.push(name1);
			addChild(name1);
		}
		
		//Called to add a creature's stats to the stat list
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
		
		//Called to create the new creature prompts
		private function createCreatureInput()
		{
			//Input field for creature name
			var inputName:TextField = new TextField();
			inputName.defaultTextFormat = inputFormat;
			inputName.type = TextFieldType.INPUT;
			inputName.border = true;
			inputName.x = 620;
			inputName.y = 570;
			inputName.height = inputName.textHeight+5;
			inputName.width = 240;
			inputName.maxChars = 15;
			inputName.borderColor = 0x003300;
			textFields.push(inputName);
			addChild(inputName);
			
			//Input field for creature initiative
			var inputInit:TextField = new TextField();
			inputInit.defaultTextFormat = inputFormat;
			inputInit.type = TextFieldType.INPUT;
			inputInit.border = true;
			inputInit.x = inputName.x + inputName.width + 10;
			inputInit.y = inputName.y;
			inputInit.height = inputInit.textHeight+5;
			inputInit.width = 50;
			inputInit.maxChars = 2;
			inputInit.borderColor = 0x003300;
			textFields.push(inputInit);
			addChild(inputInit);
			
			//Label for name field
			var nameText:TextField = new TextField();
			nameText.defaultTextFormat = inputFormat;
			nameText.text = "Creature Name";
			nameText.x = inputName.x;
			nameText.y = inputName.y - nameText.textHeight - 5;
			nameText.width = inputName.width;
			nameText.mouseEnabled = false;
			textFields.push(nameText);
			addChild(nameText);
			
			//Label for initiative field
			var initText:TextField = new TextField();
			initText.defaultTextFormat = inputFormat;
			initText.text = "Init";
			initText.x = inputInit.x;
			initText.y = inputInit.y - initText.textHeight - 5;
			initText.width = inputInit.width;
			initText.mouseEnabled = false;
			textFields.push(initText);
			addChild(initText);
			
			//Button to add creature
			var addButton:BasicButton = new BasicButton();
			addButton.x = inputInit.x + inputInit.width + 10;
			addButton.y = inputName.y - 5;
			addButton.width = 60;
			addButton.addEventListener(MouseEvent.CLICK,addCreature);
			buttons.push(addButton);
			addChild(addButton);
			
			//Label for the button to add creature
			var buttonText1:TextField = new TextField();
			buttonText1.mouseEnabled = false;
			buttonText1.defaultTextFormat = inputFormat;
			buttonText1.text = "Add";
			buttonText1.x = addButton.x + 4;
			buttonText1.y = addButton.y + 5;
			buttonText1.height = buttonText1.textHeight;
			buttonLabels.push(buttonText1);
			addChild(buttonText1);
			
			//Button to signal that no more creature are to be added
			var doneButton:BasicButton = new BasicButton();
			doneButton.x = 630;
			doneButton.y = 620;
			doneButton.width = 360;
			doneButton.addEventListener(MouseEvent.CLICK,charInit);
			buttons.push(doneButton);
			addChild(doneButton);
			
			//Label for done button
			var buttonText2:TextField = new TextField();
			buttonText2.mouseEnabled = false;
			buttonText2.defaultTextFormat = inputFormat;
			buttonText2.text = "Done";
			buttonText2.x = doneButton.x + 150;
			buttonText2.y = doneButton.y + 5;
			buttonText2.height = buttonText2.textHeight;
			buttonLabels.push(buttonText2);
			addChild(buttonText2);
			stage.focus = inputName;
		}
		
		//Called to create a creature when the add button is pressed
		private function addCreature(event:MouseEvent)
		{
			//Don't create a creature if either field is blank
			if(textFields[0].text.length<1||textFields[1].text.length<1)
				return;
			//Create a creature and clear the input fields
			creatures.push(new Creature(textFields[0].text,int(textFields[1].text)));
			textFields[0].text = "";
			textFields[1].text = "";
			//Shift focus back to the name input field and refress the initiative order
			stage.focus = textFields[0];
			refreshInitiative();
		}
		
		//Called after all creatures have been added. Sets the initiatives of the player characters
		private function charInit(event:MouseEvent)
		{
			//Clear the prompts
			buttons[0].removeEventListener(MouseEvent.CLICK,addCreature);
			buttons[1].removeEventListener(MouseEvent.CLICK,beginEncounter);
			clearTextFields();
			clearButtons();
			//Create a new prompt for each player character
			playerCharacters.forEach(createInitPrompt);
		}
		
		//Called for each player character. Creates a prompt for initiative
		private function createInitPrompt(e:*,index:int,array:Array)
		{
			//Label for the initiative input field
			var text1:TextField = new TextField();
			text1.defaultTextFormat = charStatFormat;
			text1.text = e.myName + "'s initiative:";
			text1.x = 615;
			text1.y = 410 + index * 50;
			text1.width = 250;
			text1.mouseEnabled = false;
			textFields.push(text1);
			addChild(text1);
			
			//Input field for the character's initiative
			var inputText:TextField = new TextField();
			inputText.defaultTextFormat = inputFormat;
			inputText.type = TextFieldType.INPUT;
			inputText.border = true;
			inputText.x = text1.x + text1.width;
			inputText.y = text1.y;
			inputText.height = inputText.textHeight+5;
			inputText.width = 40;
			inputText.maxChars = 2;
			inputText.borderColor = 0x003300;
			textFields.push(inputText);
			addChild(inputText);
			
			//Button to store the initiative
			var button:BasicButton = new BasicButton();
			button.x = inputText.x + inputText.width + 7;
			button.y = text1.y;
			button.width = 70;
			button.addEventListener(MouseEvent.CLICK,editCharInit);
			buttons.push(button);
			addChild(button);
			
			//Label for the initiative button
			var buttonLabel:TextField = new TextField();
			buttonLabel.mouseEnabled = false;
			buttonLabel.defaultTextFormat = inputFormat;
			buttonLabel.text = "Done";
			buttonLabel.x = button.x + 2;
			buttonLabel.y = button.y + 5;
			buttonLabel.height = buttonLabel.textHeight;
			buttonLabels.push(buttonLabel);
			addChild(buttonLabel);
			
		}
		
		//Called by the initiative prompt for each player. Stores the input initiative
		private function editCharInit(event:MouseEvent)
		{
			var buttonNum:int = buttons.indexOf(event.target);
			//Return if the field is blank
			if(textFields[buttonNum*2+1].text.length==0)
				return;
			buttons[buttonNum].removeEventListener(MouseEvent.CLICK,editCharInit);
			playerCharacters[buttonNum].initiative = textFields[buttonNum*2+1].text;
			//Hide the button and its label
			buttons[buttonNum].visible = false;
			buttonLabels[buttonNum].visible = false;
			//If all of the buttons are hidden, then the encounter can begin
			if(buttons.every(function isVis(e:*,i:int,a:Array):Boolean{return !e.visible;}))
				beginEncounter();
		}
		
		//Called any time the main prompts need to be recreated
		private function createMainPrompts()
		{
			//Clear the interface
			clearTextFields();
			clearButtons();
			
			//The button that moves to the next creature in the initiative list
			var nextButton:BasicButton = new BasicButton();
			nextButton.x = 630;
			nextButton.y = 615;
			nextButton.width = 360;
			nextButton.addEventListener(MouseEvent.CLICK,function doNextCreature(event:MouseEvent){nextCreature();});
			buttons.push(nextButton);
			addChild(nextButton);
			
			//The label for the next button
			var nextLabel:TextField = new TextField();
			nextLabel.mouseEnabled = false;
			nextLabel.defaultTextFormat = inputFormat;
			nextLabel.text = "Next";
			nextLabel.x = nextButton.x + 150;
			nextLabel.y = nextButton.y + 5;
			nextLabel.height = nextLabel.textHeight;
			buttonLabels.push(nextLabel);
			addChild(nextLabel);
			
			//The button that delays the creature
			var delayButton:BasicButton = new BasicButton();
			delayButton.x = 630;
			delayButton.y = 560;
			delayButton.width = 170;
			delayButton.addEventListener(MouseEvent.CLICK,function delayCreature(event:MouseEvent){nextCreature(true);});
			buttons.push(delayButton);
			addChild(delayButton);
			
			//The label for the delay button
			var delayLabel:TextField = new TextField();
			delayLabel.mouseEnabled = false;
			delayLabel.defaultTextFormat = inputFormat;
			delayLabel.text = "Delay";
			delayLabel.x = delayButton.x + 40;
			delayLabel.y = delayButton.y + 5;
			delayLabel.height = delayLabel.textHeight + 5;
			buttonLabels.push(delayLabel);
			addChild(delayLabel);
			
			//The button that inserts a delayed creature
			var insertButton:BasicButton = new BasicButton();
			insertButton.x = delayButton.x + delayButton.width + 5;
			insertButton.y = delayButton.y;
			insertButton.width = 170;
			insertButton.addEventListener(MouseEvent.CLICK,chooseInsertCreature);
			buttons.push(insertButton);
			addChild(insertButton);
			
			//The label for the insert button
			var insertLabel:TextField = new TextField();
			insertLabel.mouseEnabled = false;
			insertLabel.defaultTextFormat = inputFormat;
			insertLabel.text = "Insert";
			insertLabel.x = insertButton.x + 40;
			insertLabel.y = insertButton.y + 5;
			insertLabel.height = insertLabel.textHeight + 5;
			buttonLabels.push(insertLabel);
			addChild(insertLabel);
			
			//The button that drops the creature
			var dropButton:BasicButton = new BasicButton();
			dropButton.x = 630;
			dropButton.y = 505;
			dropButton.width = 170;
			dropButton.addEventListener(MouseEvent.CLICK,chooseDropCreature);
			buttons.push(dropButton);
			addChild(dropButton);
			
			//The label for the drop button
			var dropLabel:TextField = new TextField();
			dropLabel.mouseEnabled = false;
			dropLabel.defaultTextFormat = inputFormat;
			dropLabel.text = "Drop";
			dropLabel.x = dropButton.x + 40;
			dropLabel.y = dropButton.y + 5;
			dropLabel.height = dropLabel.textHeight + 5;
			buttonLabels.push(dropLabel);
			addChild(dropLabel);
			
			//The button that sets the status for a creature
			var statusButton:BasicButton = new BasicButton();
			statusButton.x = dropButton.x + dropButton.width + 5;
			statusButton.y = dropButton.y;
			statusButton.width = 170;
			statusButton.addEventListener(MouseEvent.CLICK,chooseStatusCreature);
			buttons.push(statusButton);
			addChild(statusButton);
			
			//The label for the status button
			var statusLabel:TextField = new TextField();
			statusLabel.mouseEnabled = false;
			statusLabel.defaultTextFormat = inputFormat;
			statusLabel.text = "Status";
			statusLabel.x = statusButton.x + 40;
			statusLabel.y = statusButton.y + 5;
			statusLabel.height = statusLabel.textHeight + 5;
			buttonLabels.push(statusLabel);
			addChild(statusLabel);
		}
		
		//Called by the next button. Moves down the initiative list
		private function nextCreature(delay:Boolean = false)
		{
			//Return if there are no creatures
			if(creatures.length < 1)
				return;
			creatures[activeCreatureNum].isDelaying = delay;
			activeCreatureNum++;
			//If you reach the bottom of the list, go back to the top
			if(activeCreatureNum == initiativeOrder.length)
				activeCreatureNum = 0;
			//Redraw the initiative list without resorting it
			refreshInitiative(false);
		}
		
		//Called by the insert button. Inserts a delayed creature into the initiative list
		private function chooseInsertCreature(event:MouseEvent)
		{
			//Return if there are no delayed creatures
			if(creatures.every(function noneDelaying(e:*,i:int,a:Array):Boolean{return !e.isDelaying;}))
				return;
			//Clear the interface
			clearTextFields();
			clearButtons();
			
			//Text that directs the user to select a delayed creature
			var text1:TextField = new TextField();
			text1.defaultTextFormat = charStatFormat;
			text1.text = "Select a delayed creature";
			text1.x = 615;
			text1.y = 410;
			text1.width = 350;
			text1.mouseEnabled = false;
			textFields.push(text1);
			addChild(text1);

			//Add a listener to each delayed creature
			for(var i:int=0;i<creatures.length;i++)
			{
				if(creatures[i].isDelaying)
				{
					var num:int = getTurnNumber(creatures[i].myName);
					initiativeOrder[num].addEventListener(MouseEvent.CLICK,insertCreature);
					initiativeOrder[num].mouseEnabled = true;
				}
			}
		}
		
		//Called when a creature is selected to be reinserted into the initiative list
		private function insertCreature(event:MouseEvent)
		{
			var creatureNum = initiativeOrder.indexOf(event.target);
			var delayed:Array = creatures.splice(creatureNum,1);
			if(activeCreatureNum > creatureNum)
			{
				activeCreatureNum--;
				creatures.splice(activeCreatureNum,0,delayed.pop());
			}
			else
				creatures.splice(activeCreatureNum,0,delayed.pop());
			creatures[activeCreatureNum].isDelaying = false;
			initiativeOrder.forEach(function noMouseList(e:*,i:int,a:Array)
									{e.mouseEnabled = false; e.removeEventListener(MouseEvent.CLICK,insertCreature);});
			createMainPrompts();
			refreshInitiative(false);
		}
		
		//Called by the drop button. Drops a creature from the initiative list
		private function chooseDropCreature(event:MouseEvent)
		{
			//Return if there are no creatures
			if(creatures.length < 1)
				return;
			//Clear the interface
			clearTextFields();
			clearButtons();
			
			//Text that directs the user to select a creature
			var text1:TextField = new TextField();
			text1.defaultTextFormat = charStatFormat;
			text1.text = "Select a creature to drop";
			text1.x = 615;
			text1.y = 410;
			text1.width = 350;
			text1.mouseEnabled = false;
			textFields.push(text1);
			addChild(text1);

			//Add a listener to each creature
			for(var i:int=0;i<initiativeOrder.length;i++)
			{
				initiativeOrder[i].addEventListener(MouseEvent.CLICK,dropCreature);
				initiativeOrder[i].mouseEnabled = true;
			}
		}
		
		//Called when a creature is selected to be dropped from the initiative list
		private function dropCreature(event:MouseEvent)
		{
			//Get the number of the creature that was clicked
			var creatureNum:int = initiativeOrder.indexOf(event.target);
			if(activeCreatureNum > creatureNum)	//Compensate for the dropped creature
				activeCreatureNum--;
			creatures.splice(creatureNum,1);	//Drop that creature from the list
			for(var i:int=0;i<initiativeOrder.length;i++)
			{
				initiativeOrder[i].removeEventListener(MouseEvent.CLICK,dropCreature);
				initiativeOrder[i].mouseEnabled = false;
			}
			createMainPrompts();
			refreshInitiative(false);		//Refresh the initiative list without sorting
		}
		
		//Called by the status button. Sets the status for a creature in the initiative list
		private function chooseStatusCreature(event:MouseEvent)
		{
			//Return if there are no creatures
			if(creatures.length < 1)
				return;
			//Clear the interface
			clearTextFields();
			clearButtons();
			
			//Text that directs the user to select a creature
			var text1:TextField = new TextField();
			text1.defaultTextFormat = charStatFormat;
			text1.text = "Select a creature";
			text1.x = 615;
			text1.y = 410;
			text1.width = 350;
			text1.mouseEnabled = false;
			textFields.push(text1);
			addChild(text1);

			//Add a listener to each creature
			for(var i:int=0;i<initiativeOrder.length;i++)
			{
				initiativeOrder[i].addEventListener(MouseEvent.CLICK,statusCreature);
				initiativeOrder[i].mouseEnabled = true;
			}
		}
		
		//Called when a creature is selected to have its status set from the initiative list
		private function statusCreature(event:MouseEvent)
		{
			//Clear the interface
			clearTextFields();
			clearButtons();
			
			//Remove the mouse listeners from the initiative list
			for(var i:int=0;i<initiativeOrder.length;i++)
			{
				initiativeOrder[i].removeEventListener(MouseEvent.CLICK,statusCreature);
				initiativeOrder[i].mouseEnabled = false;
			}
			
			//Get the number of the creature that was clicked
			var creatureNum:int = initiativeOrder.indexOf(event.target);
			drawStatusPrompts(creatureNum);
		}
		
		private function drawStatusPrompts(creatureNum:int)
		{
			selectedCreatureNum = creatureNum;
			var statArray:Array = creatures[creatureNum].getStatus();
			
			//The button that saves the creature's statuses
			var saveButton:BasicButton = new BasicButton();
			saveButton.x = 630;
			saveButton.y = 615;
			saveButton.width = 360;
			saveButton.addEventListener(MouseEvent.CLICK,saveStatus);
			buttons.push(saveButton);
			addChild(saveButton);
			
			//The label for the save button
			var saveLabel:TextField = new TextField();
			saveLabel.mouseEnabled = false;
			saveLabel.defaultTextFormat = inputFormat;
			saveLabel.text = "Save " + creatures[creatureNum].myName + "'s Status";
			saveLabel.x = saveButton.x + 20;
			saveLabel.y = saveButton.y + 5;
			saveLabel.height = saveLabel.textHeight + 5;
			saveLabel.width = 340;
			buttonLabels.push(saveLabel);
			addChild(saveLabel);
			
			//The button and label for each status
			for(var column:int=0;column<2;column++)
			{
				for(var row:int=0;row<statArray.length/2;row++)
				{
					var tButton:ToggleButton = new ToggleButton(630+column*180,400+row*50);
					tButton.setStateTo(statArray[row+column*statArray.length/2]);
					buttons.push(tButton);
					addChild(tButton);
					
					var tText:TextField = new TextField();
					tText.defaultTextFormat = inputFormat;
					tText.text = statusLabels[row+column*statArray.length/2];
					tText.x = tButton.x + tButton.width + 5;
					tText.y = tButton.y;
					tText.width = 175;
					tText.height = tText.textHeight + 5;
					tText.mouseEnabled = false;
					buttonLabels.push(tText);
					addChild(tText);
				}
			}
			var oButton:ToggleButton = new ToggleButton(630,400+statArray.length/2*50);
			oButton.setStateTo(creatures[creatureNum].hasOtherStatus);
			buttons.push(oButton);
			addChild(oButton);
			
			var oText:TextField = new TextField();
			oText.defaultTextFormat = inputFormat;
			oText.text = "Other Status:";
			oText.x = oButton.x + oButton.width + 5;
			oText.y = oButton.y;
			oText.width = 155;
			oText.height = oText.textHeight + 5;
			oText.mouseEnabled = false;
			buttonLabels.push(oText);
			addChild(oText);
			
			var otherStatText:TextField = new TextField();
			otherStatText.defaultTextFormat = labelFormat;
			otherStatText.type = TextFieldType.INPUT;
			otherStatText.mouseEnabled = true;
			otherStatText.mouseWheelEnabled = true;
			otherStatText.multiline = true;
			otherStatText.wordWrap = true;
			otherStatText.border = true;
			otherStatText.borderColor = 0x003300;
			otherStatText.text = creatures[creatureNum].otherStatus;
			otherStatText.x = oText.x + oText.width + 5;
			otherStatText.y = oButton.y - 5;
			otherStatText.width = 130;
			otherStatText.height = otherStatText.textHeight * 2 + 5;
			textFields.push(otherStatText);
			addChild(otherStatText)
		}
		
		private function saveStatus(event:MouseEvent)
		{
			var statArray:Array = new Array();
			for(var i:int=1;i<7;i++)
				statArray.push(buttons[i].isOn);
			creatures[selectedCreatureNum].setStatusTo(statArray);
			creatures[selectedCreatureNum].hasOtherStatus = buttons[7].isOn;
			if(buttons[7].isOn)
				creatures[selectedCreatureNum].otherStatus = textFields[0].text;
			else
				creatures[selectedCreatureNum].otherStatus = "";

			createMainPrompts();
		}
		
		private function getTurnNumber(c:String):int
		{
			for(var i:int = 0; i<initiativeOrder.length; i++)
			{
				if(initiativeOrder[i].text == c)
					return i;
			}
			trace("Name not found!");
			return -1;
		}
		
		//Called any time the interface changes. Clears the temporary text fields
		private function clearTextFields()
		{
			for(var i:int=0;i<textFields.length;i++)
				removeChild(textFields[i]);
			textFields = new Array();
		}
		
		//Called any time the interface changes. Clears the temporary buttons
		private function clearButtons()
		{
			for(var i:int=0;i<buttons.length;i++)
			{
				if(buttons[i] is ToggleButton)
					buttons[i].remove();
				removeChild(buttons[i]);
				removeChild(buttonLabels[i]);
			}
			buttons = new Array();
			buttonLabels = new Array();
		}
	}
	
}
