package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable Cutscenes',
			"If unchecked, cutscenes won\'t play on songs in Story Mode.\nIf you wanna play a week with long cutscenes again but\nyou just don\'t wanna see the cutscenes and just wanna\nplay the week, uncheck this.",
			'wantCutscene',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option('Menu Music:',
			"What song should be played when you're in\nthe Main Menu or the Title Screen?",
			'menuMusic',
			'string',
			'Gettin\' Freaky',
			['Gettin\' Freaky', 'G.F. Cryo Ver', 'Prev Song 102 BPM']);
		addOption(option);
		option.onChange = onChangeMenuMusic;
		
		var option:Option = new Option('Pause Music:',
			"What song should be played when you pause the game?",
			'pauseMusic',
			'string',
			'Tea Time',
			['...', 'Breakfast', 'Tea Time', 'Ruby Light']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'Breakfast') {
			FlxG.sound.playMusic(Paths.music('breakfast'));
		} else if (ClientPrefs.pauseMusic == 'Ruby Light') {
			FlxG.sound.playMusic(Paths.music('rubyLight'));
		} else if (ClientPrefs.pauseMusic == 'Tea Time') {
			FlxG.sound.playMusic(Paths.music('tea-time'));
		} else {
			FlxG.sound.music.volume = 0;
		}
		
		changedMusic = true;
	}

	function onChangeMenuMusic()
	{
		if (ClientPrefs.menuMusic == 'Gettin\' Freaky') {
			TitleState.mainMenuSong = TitleState.mainMenuSong;
		} else if (ClientPrefs.menuMusic == 'G.F. Cryo Ver') {
			TitleState.mainMenuSong = 'freakyMenuCryoVer';
		} else if (ClientPrefs.menuMusic == 'Prev Song 102 BPM') {
			TitleState.mainMenuSong = 'freakyMenuCryoVer102BPM';
		}
		FlxG.sound.playMusic(Paths.music(TitleState.mainMenuSong));

		changedMusic = false;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music(TitleState.mainMenuSong));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}