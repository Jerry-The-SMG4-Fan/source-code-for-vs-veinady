package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

class StorySelectState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	// [Story Name, Story Character, BF Color]
	var stories:Array<Dynamic> = [
		["baseGame", "baseGame", 'FFFF00'],
		["veinadyOnTheRun", "veinadyOnTheRun", 'FF0000'],
		["legacy", "BFBoomer", '999999']
	];

	var bgSprite:FlxSprite;

	private static var curStory:Int = 0;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var storymodeLogo:FlxSprite;
	var sprStoryName:FlxSprite;
	var sprStoryCharacters:FlxSprite;
	var sprStoryCharactersDisappear:FlxSprite;
	var backgrounde:FlxSprite;

	var intendedColor:Int;
	var colorTween:FlxTween;

	var permissionToMove:Bool;

	override function create()
	{
		var grpWeekText:FlxTypedGroup<FlxSprite>;
		var grpWeekSprites:FlxTypedGroup<FlxSprite>;
		
		grpWeekSprites = new FlxTypedGroup<FlxSprite>();
		add(grpWeekSprites);

		grpWeekText = new FlxTypedGroup<FlxSprite>();
		add(grpWeekText);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		backgrounde = new FlxSprite().loadGraphic(Paths.image('stageBG'));
		//backgrounde.updateHitbox();
		//backgrounde.screenCenter();
		//backgrounde.antialiasing = ClientPrefs.globalAntialiasing;
		add(backgrounde);

		var daStageeee:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stageNoBG'));
		daStageeee.updateHitbox();
		daStageeee.screenCenter();
		daStageeee.antialiasing = ClientPrefs.globalAntialiasing;
		add(daStageeee);

		PlayState.isStoryMode = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var storySelectors = new FlxGroup();
		add(storySelectors);

		leftArrow = new FlxSprite(10, 325);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		storySelectors.add(leftArrow);

		rightArrow = new FlxSprite(1225, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		storySelectors.add(rightArrow);

		sprStoryCharacters = new FlxSprite(0, 0);
		sprStoryCharacters.antialiasing = ClientPrefs.globalAntialiasing;
		add(sprStoryCharacters);

		sprStoryCharactersDisappear = new FlxSprite(0, 0);
		sprStoryCharactersDisappear.antialiasing = ClientPrefs.globalAntialiasing;
		add(sprStoryCharactersDisappear);

		sprStoryName = new FlxSprite(100, leftArrow.y - 100);
		sprStoryName.antialiasing = ClientPrefs.globalAntialiasing;
		add(sprStoryName);

		storymodeLogo = new FlxSprite(325, 10);
		storymodeLogo.frames = Paths.getSparrowAtlas('mainmenu/menu_story_mode');
		storymodeLogo.antialiasing = ClientPrefs.globalAntialiasing;
		storymodeLogo.animation.addByPrefix('bump', 'story_mode basic', 24, true);
		storymodeLogo.animation.play('bump');
		add(storymodeLogo);

		backgrounde.color = getCurrentBGColor();
		intendedColor = backgrounde.color;
		changeStory(0, 0);

		super.create();
	}

	override function update(elapsed:Float)
	{

		if (!movedBack && !selectedStory)
		{
			var upP = controls.UI_LEFT_P;
			var downP = controls.UI_RIGHT_P;
			if (upP && permissionToMove)
			{
				changeStory(-1, 1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP && permissionToMove)
			{
				changeStory(1, 2);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedStory)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		//grpLocks.forEach(function(lock:FlxSprite)
		//{
		//	lock.y = grpWeekText.members[lock.ID].y;
		//});
	}

	var movedBack:Bool = false;
	var selectedStory:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxFlicker.flicker(sprStoryName, 1, 0.06, false);
			stopspamming = true;
		}

		selectedStory = true;
		if (curStory == 0) {
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				WeekData.storyType = "baseGame";
				MusicBeatState.switchState(new StoryMenuState());
			});
		} else if (curStory == 1) {
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				WeekData.storyType = "veinadyOnTheRun";
				MusicBeatState.switchState(new StoryMenuState());
			});
		} else if (curStory == 2) {
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				WeekData.storyType = "legacy";
				MusicBeatState.switchState(new StoryMenuState());
			});
		}
	}

	var tweenStoryTitle:FlxTween;
	var tweenStoryCharacters:FlxTween;
	var tweenStoryCharactersTwo:FlxTween;
	var lastImagePath:String;
	var lastImagePathTwo:String;
	var lastImagePathThree:String;

	// Sides...0 = None, 1 = Go Left, 2 = Go Right

	function changeStory(change:Int = 0, sides:Int = 0):Void
	{
		permissionToMove = false;

		curStory += change;

		if (curStory >= stories.length)
			curStory = 0;
		if (curStory < 0)
			curStory = stories.length - 1;

		//var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curStory]);

		// Tweening the main characters.

		var imagetwo:Dynamic = Paths.image('storySelectCharacters/' + stories[curStory][1]);
		var newImagePathTwo:String = ''; // And two is spelled wrong because wrong spelling = comedy hahahahaha why aren't you laughing
		if(Std.isOfType(imagetwo, FlxGraphic))
		{
			var graphiclol:FlxGraphic = imagetwo;
			newImagePathTwo = graphiclol.assetsKey;
		}
		else
			newImagePathTwo = imagetwo;

		if(newImagePathTwo != lastImagePathTwo)
			{
				if (sides == 1) {
					sprStoryCharacters.loadGraphic(imagetwo);
					sprStoryCharacters.x = -1280;
		
					if(tweenStoryCharacters != null) tweenStoryCharacters.cancel();
					tweenStoryCharacters = FlxTween.tween(sprStoryCharacters, {x: 0}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					{
						permissionToMove = true;
						tweenStoryCharacters = null;
					}});
				} else if (sides == 2 || sides == 0) {
					sprStoryCharacters.loadGraphic(imagetwo);
					sprStoryCharacters.x = 1280;
		
					if(tweenStoryCharacters != null) tweenStoryCharacters.cancel();
					tweenStoryCharacters = FlxTween.tween(sprStoryCharacters, {x: 0}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					{
						permissionToMove = true;
						tweenStoryCharacters = null;
					}});
				}
			}
			lastImagePathTwo = newImagePathTwo; 

		// Tweening the character that is gonna go off-stage.
		// Coding this took WAY longer than it should have taken. AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!!
		
		var imagethree:Dynamic = Paths.image('storySelectCharacters/' + stories[curStory][1]);
		if (curStory - 1 < 0 && sides == 2) {
			imagethree = Paths.image('storySelectCharacters/' + stories[stories.length - 1][1]);
		} else if (curStory + 1 >= stories.length && sides == 1) {
			imagethree = Paths.image('storySelectCharacters/' + stories[0][1]);
		} else {
			if (sides == 2) {
				imagethree = Paths.image('storySelectCharacters/' + stories[curStory - 1][1]);
			} else if (sides == 1) {
				imagethree = Paths.image('storySelectCharacters/' + stories[curStory + 1][1]);
			} else {
				imagethree = Paths.image('storySelectCharacters/' + stories[curStory][1]);
			}
		}

		if (sides == 2) {
			sprStoryCharactersDisappear.loadGraphic(imagethree);
			sprStoryCharactersDisappear.x = 0;

			if(tweenStoryCharactersTwo != null) tweenStoryCharactersTwo.cancel();
			tweenStoryCharactersTwo = FlxTween.tween(sprStoryCharactersDisappear, {x: -1280}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
			{
				tweenStoryCharactersTwo = null;
			}});
		} else if (sides == 1) {
			sprStoryCharactersDisappear.loadGraphic(imagethree);
			sprStoryCharactersDisappear.x = 0;

			if(tweenStoryCharactersTwo != null) tweenStoryCharactersTwo.cancel();
			tweenStoryCharactersTwo = FlxTween.tween(sprStoryCharactersDisappear, {x: 1280}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
			{
				tweenStoryCharactersTwo = null;
			}});
		} else if (sides == 0) {
			sprStoryCharactersDisappear.loadGraphic(imagethree);
			sprStoryCharactersDisappear.x = -10000;

			if(tweenStoryCharactersTwo != null) tweenStoryCharactersTwo.cancel();
			tweenStoryCharactersTwo = FlxTween.tween(sprStoryCharactersDisappear, {x: -9999}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
			{
				tweenStoryCharactersTwo = null;
			}});
		}

		// Tweening the story icon.

		var image:Dynamic = Paths.image('storyselect/' + stories[curStory][0]);
		var newImagePath:String = '';
		if(Std.isOfType(image, FlxGraphic))
		{
			var graphic:FlxGraphic = image;
			newImagePath = graphic.assetsKey;
		}
		else
			newImagePath = image;

		if(newImagePath != lastImagePath)
			{
				sprStoryName.loadGraphic(image);
				sprStoryName.x = leftArrow.x + 160;
				sprStoryName.x += (308 - sprStoryName.width) / 2;
				sprStoryName.alpha = 0;
				sprStoryName.y = leftArrow.y - 150;
	
				if(tweenStoryTitle != null) tweenStoryTitle.cancel();
				tweenStoryTitle = FlxTween.tween(sprStoryName, {y: leftArrow.y - 100, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
				{
					tweenStoryTitle = null;
				}});
			}
			lastImagePath = newImagePath;

		/* var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curStory;
			if (item.targetY == Std.int(0) && !weekIsLocked(curStory))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		} */
		
		// updateText();

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(backgrounde, 1, backgrounde.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
	}

	function getCurrentBGColor() {
		var bgColor:String = stories[curStory][2];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}
}
