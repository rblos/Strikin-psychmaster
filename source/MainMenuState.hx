package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using flixel.util.FlxSpriteUtil;
using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var choosingDiff:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuItemsWhite:FlxTypedGroup<FlxSprite>;
	var daChoices:FlxTypedGroup<FlxSprite>;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', 'joe nuts club', 'options'];
	var difficultyItems:Array<String> = ['easy', 'normal', 'hard'];
	var sizeOffset:Int;
	
	var effect:BGSprite;
	var px:Int;
	var py:Int;

	var bf:BGSprite;
	var gf:BGSprite;
	var pico:BGSprite;

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var blackScr:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-3, -55).loadGraphic(Paths.image('mainmenu/Metameta'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 0.67));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		bf = new BGSprite('mainmenu/Metagang', 320, -170, 1, 1, ['BF'], true);
		bf.setGraphicSize(Std.int(bf.width * 0.67));
		bf.updateHitbox();
		bf.animation.addByPrefix('idle', 'BF', 30, true);
		bf.animation.play('idle');
		add(bf);

		gf = new BGSprite('mainmenu/Metagang', 122, -9, 1, 1, ['GF'], true);
		gf.setGraphicSize(Std.int(gf.width * 0.13));
		gf.updateHitbox();
		gf.animation.addByPrefix('idle', 'GF', 30, true);
		gf.animation.play('idle');
		add(gf);

		pico = new BGSprite('mainmenu/Metagang', 15, 150, 1, 1, ['P'], true);
		pico.setGraphicSize(Std.int(pico.width * 0.17));
		pico.updateHitbox();
		pico.animation.addByPrefix('idle', 'P', 30, true);
		pico.animation.play('idle');
		add(pico);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItemsWhite = new FlxTypedGroup<FlxSprite>();
		add(menuItemsWhite);

		effect = new BGSprite('mainmenu/select_effect', 1, 1, ['effect'], true);
		effect.animation.play('effect');
		effect.angle = -15;
		add(effect);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(50, (i * 100)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_buttons');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " alt", 24, false);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;

			var menuItemWhite:FlxSprite = new FlxSprite(50, (i * 100)  + offset);
			menuItemWhite.frames = Paths.getSparrowAtlas('mainmenu/menu_buttons');
			menuItemWhite.animation.addByPrefix('selected', optionShit[i] + "0", 24, false);
			menuItemWhite.animation.play('selected');
			menuItemWhite.ID = i;
			menuItemWhite.scrollFactor.set(0, scr);
			menuItemWhite.antialiasing = ClientPrefs.globalAntialiasing;

			switch (menuItem.ID) 
			{
				case 0: //story mode
					menuItem.y -= 30;
					menuItemWhite.y -= 30;
					sizeOffset = 35;
				case 1: //freeplay
					menuItem.y -= 10;
					menuItemWhite.y -= 10;
					sizeOffset = 45;
				case 2: //awards
					sizeOffset = 35;
				case 3: //credits
					menuItem.y -= 10;
					menuItemWhite.y -= 10;
					sizeOffset = 35;
				case 4: //joe nuts club
					menuItem.y -= 75;
					menuItemWhite.y -= 75;
					sizeOffset = 60;
				case 5: //options
					menuItem.y -= 25;
					menuItemWhite.y -= 25;
					sizeOffset = 45;
			}
			menuItem.setGraphicSize(Std.int(0.88 * (menuItem.width - 0.88 + sizeOffset)));
			menuItem.updateHitbox();
			menuItems.add(menuItem);

			menuItemWhite.setGraphicSize(Std.int(0.88 * (menuItem.width - 0.88 + sizeOffset)));
			menuItemWhite.updateHitbox();
			menuItemsWhite.add(menuItemWhite);
		}

		blackScr = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blackScr.screenCenter();
		blackScr.alpha = 0;
		add(blackScr);

		daChoices = new FlxTypedGroup<FlxSprite>();
		add(daChoices);

		for (i in 0...difficultyItems.length)
		{
			var addSize:Float = 0;
			var daChoice:FlxSprite = new FlxSprite(1500, 150 + (i * 140));
			daChoice.frames = Paths.getSparrowAtlas('mainmenu/difficulty buttons');
			daChoice.animation.addByPrefix('idle', difficultyItems[i] + "0", 24);
			daChoice.animation.addByPrefix('selected', difficultyItems[i] + " selected", 24);
			daChoice.animation.play('idle');
			daChoice.ID = i;
			switch (daChoice.ID)
			{
				case 1:
					addSize = 100;
			}
			daChoice.setGraphicSize(Std.int(daChoice.height - 0.5 + addSize));
			daChoice.updateHitbox();
			daChoices.add(daChoice);
			daChoice.scrollFactor.set();
			daChoice.antialiasing = ClientPrefs.globalAntialiasing;
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(FlxG.width - 195, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(FlxG.width - 275, FlxG.height - 24, 0, "Friday Night Strikin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		changeDifficulty();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('fns/dialogueselect'));
				if (!choosingDiff)
					changeItem(-1);
				else
					changeDifficulty(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('fns/dialogueselect'));
				if (!choosingDiff)
					changeItem(1);
				else
					changeDifficulty(1);
			}

			if (controls.BACK)
			{
				if (!choosingDiff)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					choosingDiff = false;
					FlxTween.tween(blackScr, {alpha: 0}, 0.3, {ease: FlxEase.quadOut});
					//get rid of diff stuff method
					difficultyChoice('close');
				}
			}

			if (controls.ACCEPT)
			{
				if (!choosingDiff)
				{
					if (optionShit[curSelected] == 'joe nuts club')
					{
						CoolUtil.browserLoad('https://discord.gg/Yhubw3KVvA');
					}
					else if (optionShit[curSelected] == 'story mode')
					{
						FlxG.sound.play(Paths.sound('fns/dialogueopen'));
						choosingDiff = true;
						FlxTween.tween(blackScr, {alpha: 0.3}, 0.3, {ease: FlxEase.quadOut});
						//add diff stuff method
						difficultyChoice('open');
					}
					else
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('fns/dialogueclose'));

						//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								FlxFlicker.flicker(effect, 1, 0.06, false, false);
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'story mode':
											//MusicBeatState.switchState(new StoryMenuState());
											strikinWeek();
											LoadingState.loadAndSwitchState(new PlayState(), true);
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										case 'awards':
											MusicBeatState.switchState(new AchievementsMenuState());
										case 'credits':
											MusicBeatState.switchState(new CreditsState());
										case 'options':
											MusicBeatState.switchState(new OptionsState());
									}
								});
							}
						});
						//white bg ver
						menuItemsWhite.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false);
							}
						});
					}
				}
				else
				{
					FlxG.sound.play(Paths.sound('fns/dialogueclose'));
					strikinWeek();
					LoadingState.loadAndSwitchState(new PlayState(), true);
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID) 
			{
				case 0: //story mode
					sizeOffset = 35;

					px = -828;
					py = -370;
				case 1: //freeplay
					sizeOffset = 45;

					px = -788;
					py = -251;
				case 2: //awards
					sizeOffset = 35;

					px = -832;
					py = -159;
				case 3: //credits
					sizeOffset = 35;

					px = -826;
					py = -59;
				case 4: //joe nuts club
					sizeOffset = 60;

					px = -737;
					py = 23;
				case 5: //options
					sizeOffset = 45;

					px = -778;
					py = 164;
			}
			spr.setGraphicSize(Std.int(0.88 * (spr.width - 0.88 + sizeOffset)));	
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				effect.setGraphicSize(Std.int(spr.width), Std.int(spr.height/2));
				effect.setPosition(px, py);
			}
		});
		//white bg ver
		menuItemsWhite.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID) 
			{
				case 0: //story mode
					sizeOffset = 35;
				case 1: //freeplay
					sizeOffset = 45;
				case 2: //awards
					sizeOffset = 35;
				case 3: //credits
					sizeOffset = 35;
				case 4: //joe nuts club
					sizeOffset = 60;
				case 5: //options
					sizeOffset = 45;
			}
			spr.setGraphicSize(Std.int(0.88 * (spr.width - 0.88 + sizeOffset)));	
			spr.updateHitbox();
		});

		#if debug
		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.1;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.1;

		var sprite:FlxSprite = effect;
		var multiplier:Int;
		
		if (FlxG.keys.pressed.SHIFT)
			multiplier = 19;
		else
			multiplier = 0;

		if (FlxG.keys.justPressed.I)					
			sprite.y -= 1 + multiplier;
		if (FlxG.keys.justPressed.K)
			sprite.y += 1 + multiplier;
		if (FlxG.keys.justPressed.J)
			sprite.x -= 1 + multiplier;
		if (FlxG.keys.justPressed.L)
			sprite.x += 1 + multiplier;

		FlxG.watch.addQuick("effect.x", sprite.x);
		FlxG.watch.addQuick("effect.y", sprite.y);
		#end
	}

	function strikinWeek() {
		WeekData.reloadWeekFiles(true);
		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		var curWeek:Int = 0;
		//var curDifficulty:Int = 2;

		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;

		var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
		if(diffic == null) diffic = '';

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.animation.play('idle');
			//spr.offset.y = 0;
			//spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				//spr.animation.play('selected');
				//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				//spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				//spr.offset.y = 0.15 * spr.frameHeight;
				//FlxG.log.add(spr.frameWidth);
				spr.setGraphicSize(Std.int(spr.width + 30));
				spr.updateHitbox();
			}
		});
		//white ver
		menuItemsWhite.forEach(function(spr:FlxSprite)
		{
			//spr.animation.play('selected');

			if (spr.ID == curSelected)
			{
				spr.setGraphicSize(Std.int(spr.width + 30));
				spr.updateHitbox();
			}
		});
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = difficultyItems.length - 1;
		if (curDifficulty >= difficultyItems.length)
			curDifficulty = 0;

		daChoices.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curDifficulty)
			{
				spr.animation.play('selected');
			}
			spr.updateHitbox();
		});
	}

	function difficultyChoice(str:String):Void
	{
		if (str == 'open')
		{
			daChoices.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {x: 850}, 0.5, {ease: FlxEase.circOut, startDelay: 0 + (0.1 * spr.ID)});
			});
		}
		else if (str == 'close')
		{
			daChoices.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {x: 1500}, 0.5, {ease: FlxEase.circOut, startDelay: 0 + (0.1 * spr.ID)});
			});
		}
	}
}
