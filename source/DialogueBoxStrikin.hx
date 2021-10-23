package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;

using StringTools;

class DialogueBoxStrikin extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var curPortrait:String = '';
	var sameChar:String = '';
	var dupeChar:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var otherThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var charPortrait:FlxSprite;
	var charShadow:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var bgBARS:FlxSprite;

	public static var dialogueFunctions:Bool = false;
	public static var canKill:Bool = false;
	var playOnce:Bool = true;

	//sfx
	var clickSound:FlxSound = FlxG.sound.load(Paths.sound('fns/personaClick'));

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'you-are-stronger':
				FlxG.sound.playMusic(Paths.music('Strikers', 'strikin'), 0.3);
			case 'what-you-wish-for':
				FlxG.sound.playMusic(Paths.music('TokyoEmergency', 'strikin'), 0.3);
				
		}

		clickSound.volume = 1;

		//preloading choice spritesheet
		var choices:FlxSprite = new FlxSprite(0, 0);
		choices.frames = Paths.getSparrowAtlas('dialogue/dialoguechoice', 'strikin');

		bgBARS = new FlxSprite(0, 0);
		bgBARS.frames = Paths.getSparrowAtlas('dialogue/dialogue_bars', 'strikin');
		bgBARS.animation.addByPrefix('idle', 'thesquares', 60, true);
		bgBARS.setGraphicSize(Std.int(bgBARS.width * 0.7));
		bgBARS.updateHitbox();
		bgBARS.animation.play('idle');
		bgBARS.scrollFactor.set();
		bgBARS.screenCenter(X);
		bgBARS.screenCenter(Y);
		bgBARS.alpha = 0;
		//add(bgBARS);

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			bgBARS.alpha += (1 / 5) * 1;
			if (bgBARS.alpha > 1)
				bgBARS.alpha = 1;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				/* hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375; */

				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogue/dialoguebox', 'strikin');
				box.animation.addByIndices('normalOpen', 'dialoguebox', [0], "", 60, false);
				box.animation.addByPrefix('normal', 'dialoguebox', 120);
				//box.setGraphicSize(Std.int(box.width * 1));
				//box.updateHitbox();
				//box.screenCenter(X);
				box.width = 300;
				box.height = 300;
				//box.screenCenter(Y);
				box.x = 225;
				box.y = -200;
				box.antialiasing = true;
				box.alpha = 0.9;

		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

		//SHADOWS---------------------------------------------------------------------------------------------------------------------------------------------
		charShadow = new FlxSprite(0, 0);
		charShadow.frames = Paths.getSparrowAtlas('dialogue/portraits', 'strikin');
		//bf
		charShadow.animation.addByIndices('talk bf0', 'bf talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
		charShadow.animation.addByIndices('stop bf0', 'bf talk0', [2, 3, 4, 5], "", 24, false);
		charShadow.animation.addByIndices('standby bf0', 'bf talk0', [4, 5], "", 24, false);
		//bf alt
		charShadow.animation.addByIndices('initial talk bf1', 'bf talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
		charShadow.animation.addByIndices('talk bf1', 'bf talk1', [6, 7, 8, 9, 4, 5], "", 24, true);
		charShadow.animation.addByIndices('stop bf1', 'bf talk1', [6, 7, 8, 9], "", 24, false);
		charShadow.animation.addByIndices('standby bf1', 'bf talk1', [8, 9], "", 24, false);
		//dad
		charShadow.animation.addByIndices('talk dad0', 'dad talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
		charShadow.animation.addByIndices('stop dad0', 'dad talk0', [2, 3, 4, 5], "", 24, false);
		charShadow.animation.addByIndices('standby dad0', 'dad talk0', [4, 5, 6, 7], "", 24, true);
		//dad alt
		charShadow.animation.addByIndices('initial talk dad1', 'dad talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
		charShadow.animation.addByIndices('talk dad1', 'dad talk1', [6, 7, 8, 9, 4, 5], "", 24, true);
		charShadow.animation.addByIndices('stop dad1', 'dad talk1', [6, 7, 8, 9], "", 24, false);
		charShadow.animation.addByIndices('standby dad1', 'dad talk1', [8, 9, 10, 11], "", 24, true);
		//pico
		charShadow.animation.addByIndices('talk pico0', 'pico talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
		charShadow.animation.addByIndices('stop pico0', 'pico talk0', [2, 3, 4, 5], "", 24, false);
		charShadow.animation.addByIndices('standby pico0', 'pico talk0', [4, 5], "", 24, false);
		//pico alt
		charShadow.animation.addByIndices('initial talk pico1', 'pico talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
		charShadow.animation.addByIndices('talk pico1', 'pico talk1', [6, 7, 8, 9, 10, 11], "", 24, true);
		charShadow.animation.addByIndices('stop pico1', 'pico talk1', [8, 9, 10, 11], "", 24, false);
		charShadow.animation.addByIndices('standby pico1', 'pico talk1', [10, 11], "", 24, false);

		charShadow.visible = false;
		charShadow.antialiasing = ClientPrefs.globalAntialiasing;
		charShadow.color = 0xFF000000;
		add(charShadow);	
		//SHADOWS---------------------------------------------------------------------------------------------------------------------------------------------

		charPortrait = new FlxSprite(0, 0);
		charPortrait.frames = Paths.getSparrowAtlas('dialogue/portraits', 'strikin');
		//bf
		charPortrait.animation.addByIndices('talk bf0', 'bf talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
		charPortrait.animation.addByIndices('stop bf0', 'bf talk0', [2, 3, 4, 5], "", 24, false);
		charPortrait.animation.addByIndices('standby bf0', 'bf talk0', [4, 5], "", 24, false);
		//bf alt
		charPortrait.animation.addByIndices('initial talk bf1', 'bf talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
		charPortrait.animation.addByIndices('talk bf1', 'bf talk1', [6, 7, 8, 9, 4, 5], "", 24, true);
		charPortrait.animation.addByIndices('stop bf1', 'bf talk1', [6, 7, 8, 9], "", 24, false);
		charPortrait.animation.addByIndices('standby bf1', 'bf talk1', [8, 9], "", 24, false);
		//dad
		charPortrait.animation.addByIndices('talk dad0', 'dad talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
		charPortrait.animation.addByIndices('stop dad0', 'dad talk0', [2, 3, 4, 5], "", 24, false);
		charPortrait.animation.addByIndices('standby dad0', 'dad talk0', [4, 5, 6, 7], "", 24, true);
		//dad alt
		charPortrait.animation.addByIndices('initial talk dad1', 'dad talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
		charPortrait.animation.addByIndices('talk dad1', 'dad talk1', [6, 7, 8, 9, 4, 5], "", 24, true);
		charPortrait.animation.addByIndices('stop dad1', 'dad talk1', [6, 7, 8, 9], "", 24, false);
		charPortrait.animation.addByIndices('standby dad1', 'dad talk1', [8, 9, 10, 11], "", 24, true);
		//pico
		charPortrait.animation.addByIndices('talk pico0', 'pico talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
		charPortrait.animation.addByIndices('stop pico0', 'pico talk0', [2, 3, 4, 5], "", 24, false);
		charPortrait.animation.addByIndices('standby pico0', 'pico talk0', [4, 5], "", 24, false);
		//pico alt
		charPortrait.animation.addByIndices('initial talk pico1', 'pico talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
		charPortrait.animation.addByIndices('talk pico1', 'pico talk1', [6, 7, 8, 9, 10, 11], "", 24, true);
		charPortrait.animation.addByIndices('stop pico1', 'pico talk1', [8, 9, 10, 11], "", 24, false);
		charPortrait.animation.addByIndices('standby pico1', 'pico talk1', [10, 11], "", 24, false);	

		charPortrait.visible = false;
		charPortrait.antialiasing = ClientPrefs.globalAntialiasing;
		add(charPortrait);	
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

			/* dropText = new FlxText(410, 525, Std.int(FlxG.width * 0.45), "", 32);
			dropText.setFormat(Paths.font("personaaccurate.otf"), 28);
			dropText.color = FlxColor.WHITE;
			add(dropText); */
			
			swagDialogue = new FlxTypeText(410, 525, Std.int(FlxG.width * 0.45), "", 32);
			swagDialogue.setFormat(Paths.font("personaaccurate.otf"), 28);
			swagDialogue.color = FlxColor.WHITE;
			add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (canKill)
		{
			canKill = false;
			kill();
		}
		// HARD CODING CUZ IM STUPDI
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

       /*  if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{}
		else
		{
		if (box.animation.curAnim != null)
			{
				if (box.animation.curAnim.name == 'normal' && box.animation.curAnim.finished)
				{
					box.animation.play('normalback', false, true);
				}
				if (box.animation.curAnim.name == 'normalback' && box.animation.curAnim.finished)
				{
					box.animation.play('normal');
				}
			}
		} */
				
		//PORTRAIT EDITING
		if (charPortrait.animation.curAnim != null)
		{
			if (charPortrait.animation.curAnim.name.startsWith('initial') && charPortrait.animation.curAnim.finished)
			{
				charPortrait.animation.play('talk ' + curPortrait);
			}
			if (charPortrait.animation.curAnim.name.startsWith('stop') && charPortrait.animation.curAnim.finished)
			{
				charPortrait.animation.play('standby ' + curPortrait);
			}
		}
		if (charShadow.animation.curAnim != null)
		{
			if (charShadow.animation.curAnim.name.startsWith('initial') && charShadow.animation.curAnim.finished)
			{
				charShadow.animation.play('talk ' + curPortrait);
			}
			if (charShadow.animation.curAnim.name.startsWith('stop') && charShadow.animation.curAnim.finished)
			{
				charShadow.animation.play('standby ' + curPortrait);
			}
		}









		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{
			remove(dialogue);

			clickSound.play();

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (FlxG.sound.music != null && dialogueFunctions)
						FlxG.sound.music.fadeOut(2.3, 0);

					clickSound.volume = 0;
					clickSound.kill();

					if (!dialogueFunctions)
						{
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
							{
								FlxTween.tween(charPortrait, {x: charPortrait.x - 100}, 0.3, {ease: FlxEase.quintOut});
								FlxTween.tween(charShadow, {x: charShadow.x - 100}, 0.3, {ease: FlxEase.quintOut});
								FlxTween.tween(box, {x: box.x - 150}, 0.3, {ease: FlxEase.quintOut});
								FlxTween.tween(swagDialogue, {x: swagDialogue.x - 150}, 0.3, {ease: FlxEase.quintOut});
								box.animation.pause();
								charPortrait.animation.pause();
								finishThing();
							});
						}

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
								if (dialogueFunctions)
									{
										box.alpha -= 1 / 5;
										//bgBARS.alpha -= 1 / 5 * 0.7;

										charPortrait.visible = false;
										charShadow.visible = false;

										swagDialogue.alpha -= 1 / 5;

										if (playOnce)
										{
											otherThing();
											playOnce = false;
										}
							}
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						if (dialogueFunctions)
						{
							finishThing();
							kill();
						}

						playOnce = true;
						dialogueFunctions = false;
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	var isOpponent:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true, false, [], waitstop);

			switch (curCharacter)
			{
				case 'bf':
					curPortrait = 'bf0';
					charPortrait.visible = true;
					charPortrait.animation.play('talk bf0');
					charShadow.animation.play('talk bf0');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/bfText'), 0.6)];

				case 'bf-alt':
					curPortrait = 'bf1';
					charPortrait.visible = true;
					charPortrait.animation.play('initial talk bf1');
					charShadow.animation.play('initial talk bf1');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/bfText'), 0.6)];

				case 'dad':
					curPortrait = 'dad0';
					charPortrait.visible = true;
					charPortrait.animation.play('talk dad0');
					charShadow.animation.play('talk dad0');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/dadText'), 0.6)];

				case 'dad-alt':
					curPortrait = 'dad1';
					charPortrait.visible = true;
					charPortrait.animation.play('initial talk dad1');
					charShadow.animation.play('initial talk dad1');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/dadText'), 0.6)];
				
				case 'pico':
					curPortrait = 'pico0';
					charPortrait.visible = true;
					charPortrait.animation.play('talk pico0');
					charShadow.animation.play('talk pico0');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/picoText'), 0.6)];
				
				case 'pico-alt':
					curPortrait = 'pico1';
					charPortrait.visible = true;
					charPortrait.animation.play('initial talk pico1');
					charShadow.animation.play('initial talk pico1');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/picoText'), 0.6)];
			}
			
			var b:String = "";
			for(i in 0...curCharacter.length){
				var a:String = curCharacter.substring(i, i+1);
				b += a;
				if (a == '-') break;
				sameChar = b;
			}
			//trace(sameChar);

			if (sameChar != dupeChar)
			{
				dupeChar = sameChar;
				charShadow.visible = false;
				portraitFadeIn();
			}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}

	function waitstop():Void
	{
		if (charPortrait.animation.curAnim != null)
		{
			if (charPortrait.animation.curAnim.name.startsWith('talk') || charPortrait.animation.curAnim.name.startsWith('initial'))
			{
				charPortrait.animation.play('stop ' + curPortrait);
			}
		}
		if (charShadow.animation.curAnim != null)
		{
			if (charShadow.animation.curAnim.name.startsWith('talk') || charShadow.animation.curAnim.name.startsWith('initial'))
			{
				charShadow.animation.play('stop ' + curPortrait);
			}
		}
	}

	function portraitFadeIn():Void
	{
		var moveVal:Int = 20;
		charPortrait.alpha = 0;
		charPortrait.x -= moveVal;

		FlxTween.tween(charPortrait, {alpha: 1}, 0.1, {ease: FlxEase.quintOut});
		FlxTween.tween(charPortrait, {x: charPortrait.x + moveVal}, 0.3, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween)
		{
			charShadow.x = charPortrait.x;
			charShadow.y = charPortrait.y;
			charShadow.visible = true;

			FlxTween.tween(charShadow, {x: charShadow.x - 5}, 0.2, {ease: FlxEase.quintOut});
			FlxTween.tween(charShadow, {y: charShadow.y + 5}, 0.2, {ease: FlxEase.quintOut});
		}});
	}
}
