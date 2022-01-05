package;

#if cpp
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.graphics.frames.FlxAtlasFrames;

class ChoiceSubState extends MusicBeatSubstate
{
	//var grpMenuShit:FlxTypedGroup<Alphabet>;

	var daChoices:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = ['box top', 'box mid', 'box bot'];
	var curSelected:Int = 0;

	var bf:FlxSprite;
	var tempNum:Float = 1;

	public var iSpoke:Void->Void;
	public var stateClose:Void->Void;

	public static var chosenValue:Int = 0;

	//var blinkOffset:Int = 1;


	public function new(x:Float, y:Float)
	{
		super();

		FlxG.sound.play(Paths.sound('fns/dialogueopen'));

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.3;
		bg.scrollFactor.set();
		add(bg);

		var gray:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('dialogue/gray', 'strikin'));
		gray.setGraphicSize(Std.int(gray.width * 0.7));
		gray.screenCenter(X);
		gray.screenCenter(Y);
		gray.antialiasing = ClientPrefs.globalAntialiasing;
		gray.alpha = 0.8;
		add(gray);

		bf = new FlxSprite(910, 267);
		bf.frames = Paths.getSparrowAtlas('dialogue/bf thinkin', 'strikin');
		bf.animation.addByIndices('idle', "bf blink", [0], "", 24, false);
		bf.animation.addByPrefix('blink', "bf blink", 24, false);
		bf.animation.play('idle');
		bf.antialiasing = ClientPrefs.globalAntialiasing;
		bf.setGraphicSize(Std.int(bf.width * 1.12));
		bf.updateHitbox();
		add(bf);

		var lines:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('dialogue/dialogued', 'strikin'));
		lines.setGraphicSize(Std.int(lines.width * 0.7));
		lines.screenCenter(X);
		lines.screenCenter(Y);
		lines.antialiasing = ClientPrefs.globalAntialiasing;
		add(lines);

		/* grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit); */

		daChoices = new FlxTypedGroup<FlxSprite>();
		add(daChoices);

		for (i in 0...menuItems.length)
		{
			/* var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText); */

			var daChoice:FlxSprite = new FlxSprite(0, 60 + (i * 140));
			daChoice.frames = Paths.getSparrowAtlas('dialogue/dialoguechoice', 'strikin');
			daChoice.animation.addByPrefix('idle', menuItems[i] + " basic", 24);
			daChoice.animation.addByPrefix('selected', menuItems[i] + " select", 24);
			daChoice.animation.play('idle');
			/* daChoice.setGraphicSize(Std.int(daChoice.width * 0.9));
			daChoice.updateHitbox(); */
			daChoice.ID = i;
			daChoice.screenCenter(X);
			daChoices.add(daChoice);
			//daChoice.scrollFactor.set();
			daChoice.antialiasing = ClientPrefs.globalAntialiasing;
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (FlxG.random.bool(1))
				bf.animation.play('blink');

		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
			FlxG.sound.play(Paths.sound('fns/dialogueselect'));
		}
		else if (controls.UI_DOWN_P)
		{
			changeSelection(1);
			FlxG.sound.play(Paths.sound('fns/dialogueselect'));
		}

		if (controls.ACCEPT)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "box top":
					chosenValue = 1;
				case "box mid":
					chosenValue = 2;
				case "box bot":
					chosenValue = 3;
			}

			stateClose();
			close();
				FlxG.sound.play(Paths.sound('fns/dialogueclose'));

				new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						iSpoke();
					});
		}

		#if debug
		var sprite:FlxSprite = bf;
		var multiplier:Int;

		if (FlxG.keys.pressed.SHIFT)
			multiplier = 40;
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

		if (FlxG.keys.justPressed.NUMPADFOUR)
		{
			tempNum -= 0.01;
			sprite.setGraphicSize(Std.int(sprite.width * tempNum));
		}

		if (FlxG.keys.justPressed.NUMPADSIX)
		{
			tempNum += 0.01;
			sprite.setGraphicSize(Std.int(sprite.width * tempNum));
		}

		if (sprite != null)
		{
			FlxG.watch.addQuick("sprite.x", sprite.x);
			FlxG.watch.addQuick("sprite.y", sprite.y);
			FlxG.watch.addQuick("tempNum", tempNum);
		}
		#end
	}

	override function destroy()
	{
		super.kill();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		daChoices.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');
	
				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
				}
				spr.updateHitbox();
			});

		var bullShit:Int = 0;

		/* for (item in daChoice.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				//item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
				daChoice.animation.play('selected');
			}
		} */
	}
}
