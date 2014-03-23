package mylibrary
{

	import flash.text.TextField;
	import flash.text.TextFormat;

	public class TextField2 extends TextField
	{

		public function TextField2(format:TextFormat,txt:String="",newX:int=0,newY:int=0,
								   newWidth:int=500,select:Boolean=false)
		{
			defaultTextFormat = format;
			text = txt;
			x = newX;
			y = newY;
			width = newWidth;
			selectable = select;
			height = this.textHeight+5;
		}
	}
}