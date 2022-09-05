package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class CongratsState extends MusicBeatState
{
	public static var congratsPic:String;

	override function create()
	{
		super.create();
		var congrats:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(congratsPic, 'shared'));
		congrats.antialiasing = ClientPrefs.globalAntialiasing;
		add(congrats);
		//FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			MusicBeatState.switchState(new StoryMenuState());
		}
		super.update(elapsed);
	}
}
