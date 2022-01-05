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
	var animName:String = '';
	var dupeChar:String = '';

	var dialogue:Alphabet;
	public var dialogueList:Array<String> = [];
	var skipList:String = '';

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	public var finishThing:Void->Void;
	public var otherThing:Void->Void;

	var charText:FlxText;

	var bf:Portrait = new Portrait(0, 0, 'bf');
	var dad:Portrait = new Portrait(-68, 238, 'dad');
	var pico:Portrait = new Portrait(0, 0, 'pico');
	var morgana:Portrait = new Portrait(-122, 230, 'morgana');
	var spooky:Portrait = new Portrait(-180, 133, 'spooky kids');

	var portArray:Array<Portrait>;

	var curPortrait:Portrait;
	var curShadow:Portrait;

	var bgFade:FlxSprite;
	var bgBARS:FlxSprite;

	var black:FlxSprite = new FlxSprite();
	var load:FlxSprite = new FlxSprite();
	var transitionLoaded:Bool = false;
	var transType:String;

	var bg1Exists:Bool = false;
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var curBG:FlxSprite;
	var transitionSpeed:Float = 0.7;

	var tempNum:Float = 1.0;

	public var lastDialogue:Bool = false;

	var skipDialogue:Bool = false;
	var canAdvance:Bool = true;

	//sfx
	var clickSound:FlxSound = FlxG.sound.load(Paths.sound('fns/personaClick'));
	var sound:FlxSound;

	public function new(lastDialogue:Bool = false, ?dialogueList:Array<String>)
	{
		super();
		this.lastDialogue = lastDialogue;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'you-are-stronger' | 'daredevil':
				FlxG.sound.playMusic(Paths.music('beneath the mask', 'strikin'), 0.3);
		}

		clickSound.volume = 0.4;

		//preloading choice spritesheet
		var choices:FlxSprite = new FlxSprite();
		choices.frames = Paths.getSparrowAtlas('dialogue/dialoguechoice', 'strikin');
		var bfb:FlxSprite = new FlxSprite();
		bfb.frames = Paths.getSparrowAtlas('dialogue/BFBLINK', 'strikin');
		var b:FlxSprite = new FlxSprite();
		b.frames = Paths.getSparrowAtlas('coolmechanics/bf transition', 'strikin');

		box = new FlxSprite();
		
		var hasDialog = false;

		hasDialog = true;
		box.frames = Paths.getSparrowAtlas('dialogue/dialoguebox', 'strikin');
		box.animation.addByIndices('normalOpen', 'normal box', [0], "", 24, false);
		box.animation.addByPrefix('normal', 'normal box', 24);
		box.animation.addByPrefix('special', 'special box', 24);
		box.antialiasing = ClientPrefs.globalAntialiasing; 


		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

		bg1 = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscenes/leblanc', 'strikin'));
		bg1.setGraphicSize(Std.int(bg1.width = FlxG.width*1.79));
		bg1.setGraphicSize(Std.int(bg1.height = FlxG.height*1.79));
		bg1.antialiasing = ClientPrefs.globalAntialiasing;
		bg1.alpha = 0;
		add(bg1);

		bg2 = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscenes/leblanc', 'strikin'));
		bg2.setGraphicSize(Std.int(bg2.width = FlxG.width*1.79));
		bg2.setGraphicSize(Std.int(bg2.height = FlxG.height*1.79));
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		bg2.alpha = 0;
		add(bg2);

		bgBARS = new FlxSprite(-52, -52);
		bgBARS.frames = Paths.getSparrowAtlas('dialogue/dialogue_bars', 'strikin');
		bgBARS.animation.addByPrefix('idle', 'thesquares', 60, true);
		bgBARS.setGraphicSize(Std.int(bgBARS.width * 0.72));
		bgBARS.updateHitbox();
		bgBARS.animation.play('idle');
		bgBARS.scrollFactor.set();
		//bgBARS.screenCenter(X);
		//bgBARS.screenCenter(Y);
		bgBARS.alpha = 0;
		add(bgBARS);

		curBG = bg1;

		curPortrait = bf;
		curShadow = new Portrait(0, 0, "bf");
		curShadow.visible = false;
		curShadow.color = FlxColor.BLACK;
		add(curShadow);
		
		portArray = [bf, dad, pico, morgana, spooky];

		for(i in 0...portArray.length) {
			portArray[i].visible = false;
			add(portArray[i]);
		}
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * 0.75));
		box.updateHitbox();
		box.setPosition(280, 405);
		add(box);

		//box.screenCenter(X);
			
		swagDialogue = new FlxTypeText(440, 545, Std.int(FlxG.width * 0.40), "", 21);
		swagDialogue.setFormat(Paths.font("personaaccurate.otf"), 21);
		swagDialogue.color = FlxColor.WHITE;
		add(swagDialogue);

		charText = new FlxText(482, 463, Std.int(FlxG.width * 0.40), '', 21);
		charText.setFormat(Paths.font("personaaccurate.otf"), 21);
		charText.color = FlxColor.BLACK;
		charText.angle = -5;
		charText.antialiasing = ClientPrefs.globalAntialiasing;
		add(charText);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		#if debug
		var sprite = charText;
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

		if (FlxG.keys.justPressed.NUMPADSIX)
		{
			tempNum++;
		}
		if (FlxG.keys.justPressed.NUMPADFOUR)
		{
			tempNum--;
		}

		if (tempNum > 2)
			tempNum = 0;
		if (tempNum < 0)
			tempNum = 2;

		if (sprite != null)
		{
			FlxG.watch.addQuick("sprite.x", sprite.x);
			FlxG.watch.addQuick("sprite.y", sprite.y);
		}
		FlxG.watch.addQuick("tempNum", tempNum);
		/* FlxG.watch.addQuick("swagDialogue.x", swagDialogue.x);
		FlxG.watch.addQuick("swagDialogue.y", swagDialogue.y);
		FlxG.watch.addQuick("charText.x", charText.x);
		FlxG.watch.addQuick("charText.y", charText.y);
		FlxG.watch.addQuick("sprite.x", sprite.x);
		FlxG.watch.addQuick("sprite.y", sprite.y); */
		#end

		// HARD CODING CUZ IM STUPDI
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (box.animation.curAnim.name == 'special')
		{
			box.setPosition(292, 424);
			swagDialogue.setPosition(387, 570);
		}
		else
		{
			box.setPosition(280, 405);
			swagDialogue.setPosition(440, 545);
		}
				
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true && canAdvance) //come back to change later
		{
			if (dialogueEnded)
			{
				remove(dialogue);

				clickSound.play();

				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;

						if (FlxG.sound.music != null && lastDialogue)
							FlxG.sound.music.fadeOut(2.3, 0);

						clickSound.volume = 0;
						clickSound.kill();

						if (!lastDialogue)
							{
							new FlxTimer().start(0.2, function(tmr:FlxTimer)
								{
									FlxTween.tween(curPortrait, {x: curPortrait.x - 100}, 0.3, {ease: FlxEase.quintOut});
									FlxTween.tween(curShadow, {x: curShadow.x - 100}, 0.3, {ease: FlxEase.quintOut});
									FlxTween.tween(box, {x: box.x - 150}, 0.3, {ease: FlxEase.quintOut});
									FlxTween.tween(swagDialogue, {x: swagDialogue.x - 150}, 0.3, {ease: FlxEase.quintOut});
									FlxTween.tween(charText, {x: charText.x - 150}, 0.3, {ease: FlxEase.quintOut});
									swagDialogue.skip();
									box.animation.pause();
									curPortrait.canMove = false;
									curPortrait.animation.pause();
									finishThing();
								});
							}

						if (lastDialogue && otherThing != null)
							otherThing();
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
									if (lastDialogue)
										{
											box.alpha -= 1 / 5;
											//bgBARS.alpha -= 1 / 5 * 0.7;

											curPortrait.visible = false;
											curShadow.visible = false;

											swagDialogue.alpha -= 1 / 5;
											charText.alpha -= 1 / 5;
								}
						}, 5);

						new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{
							if (lastDialogue)
							{
								finishThing();
								kill();
							}

							lastDialogue = false;
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
				}
			}
			else if (dialogueStarted)
			{
				clickSound.play();
				swagDialogue.skip();
			}
		}
			
			super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		var pauseDialogue:Bool = false;
		var lastChar:String = '';
		var skipThese:Array<String> = ['bg', 'audio', 'transition'];

		for (i in 0...skipThese.length)
		{
			if (curCharacter != skipThese[i])
				lastChar = curCharacter.toString();
		}
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		skipDialogue = false;
		dialogueEnded = false;

		for(i in 0...portArray.length) {
			portArray[i].visible = false;
		}

		box.animation.play('normal');

		switch (curCharacter)
		{
			case 'bg':
				skipDialogue = true;
				if (skipList == "") {
					FlxTween.tween(PlayState.bg1, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
					FlxTween.tween(PlayState.bg2, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
					bg1Exists = false;
					//FlxTween.tween(bgBARS, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
				}
				else {
					switchBG();
					//FlxTween.tween(bgBARS, {alpha: 1}, transitionSpeed, {ease: FlxEase.linear});
				}

			case 'audio':
				skipDialogue = true;
				if (sound != null)
					sound.stop();
				sound = FlxG.sound.load(Paths.sound("fns/" + dialogueList[0]));
				sound.volume = Std.parseFloat(animName);
				sound.play();

			case 'transition':
				var dontDoIt:Bool = false;
				var speed:Float = 0.2;

				switch (animName)
				{
					case 'black':
						transType = animName.toString();
						pauseDialogue = true;

						if (curPortrait != null)
							curPortrait.visible = true;

						swagDialogue.sounds = null;
						canAdvance = false;

						if (lastChar == 'crowd' || lastChar == 'metaverse')
							box.animation.play('special');						
						curCharacter = lastChar;
						setCharName();

						FlxTween.tween(curPortrait, {alpha: 0}, speed, {ease: FlxEase.linear});
						FlxTween.tween(curShadow, {alpha: 0}, speed, {ease: FlxEase.linear});
						FlxTween.tween(swagDialogue, {alpha: 0}, speed, {ease: FlxEase.linear});
						FlxTween.tween(box, {alpha: 0}, speed, {ease: FlxEase.linear});
						FlxTween.tween(charText, {alpha: 0}, speed, {ease: FlxEase.linear});

						black = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						black.alpha = 0;
						add(black);

						new FlxTimer().start(0.3, function(tmr:FlxTimer)
						{
							FlxTween.tween(black, {alpha: 1}, speed, {ease: FlxEase.linear});
							FlxG.sound.music.fadeOut(1, 0);
						});

					case 'bf':
						transType = animName.toString();
						pauseDialogue = true;

						if (curPortrait != null)
							curPortrait.visible = true;

						swagDialogue.sounds = null;
						canAdvance = false;

						if (lastChar == 'crowd' || lastChar == 'metaverse')
							box.animation.play('special');
						curCharacter = lastChar;
						setCharName();

						black = new FlxSprite();
						black.frames = Paths.getSparrowAtlas('coolmechanics/bf transition', 'strikin');
						black.antialiasing = ClientPrefs.globalAntialiasing;
						black.setGraphicSize(FlxG.width + 10, FlxG.height + 10);
						black.screenCenter();
						black.animation.addByPrefix('go', 'bf transition', 30, false);
						add(black);

						new FlxTimer().start(0.3, function(tmr:FlxTimer)
						{
							black.animation.play('go');
							FlxG.sound.music.fadeOut(2, 0);
						});
					case 'remove':
						dontDoIt = true;
						if (transitionLoaded)
						{
							new FlxTimer().start(Std.parseFloat(dialogueList[0]), function(tmr:FlxTimer)
							{
								var del:Float = 0;
								if (load != null)
								{
									load.kill();
									del = 0.5;
								}

								new FlxTimer().start(del, function(tmr:FlxTimer)
								{
									removeTransitions();
									transitionLoaded = false;
								});
							});
						}
						else
						{
							dialogueList.remove(dialogueList[0]);
							startDialogue();
							trace('no transition, so remove');
						}
				}

				if (!dontDoIt)
				{
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						if (curPortrait != null)
						{
							curPortrait.alpha = 0;
							curShadow.alpha = 0;
						}
						swagDialogue.alpha = 0;
						box.alpha = 0;
						charText.alpha = 0;
						trace('hide everything');
					});

					if (dialogueList[0] == "")
					{
						new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							transitionLoaded = true;
							dialogueList.remove(dialogueList[0]);
							startDialogue();

							if (dialogueList[1] == null && dialogueList[0] != null)
								finishThing();
							trace('no loading set');
						});
					}
					else
					{
						load = new FlxSprite(956, 350);
						load.frames = Paths.getSparrowAtlas('coolmechanics/bf load', 'strikin');
						load.setGraphicSize(Std.int(load.width * 0.7));
						load.antialiasing = ClientPrefs.globalAntialiasing;
						load.animation.addByPrefix('idle', 'bf load', 30, true);

						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							load.animation.play('idle');
							add(load);
							transitionLoaded = true;
							dialogueList.remove(dialogueList[0]);
							startDialogue();

							if (dialogueList[1] == null && dialogueList[0] != null)
								finishThing();
							trace('loading set');
						});
					}
				}
			case 'crowd' | 'metaverse':
				box.animation.play('special');
				swagDialogue.sounds = null;
				curPortrait = null;
				curShadow.visible = false;
				dialogueList[0] = animName;
				charText.setPosition(439, 492);

			case 'bf':
				curPortrait = bf;
				bf.visible = true;
				bf.playAnim(animName);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/bfText'), 0.6)];
				//changePosition(0, 0);

			case 'dad':
				curPortrait = dad;
				dad.visible = true;
				dad.playAnim(animName);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/dadText'), 0.6)];
				charText.setPosition(469, 465);

			case 'pico':
				curPortrait = pico;
				pico.visible = true;
				pico.playAnim(animName);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/picoText'), 0.6)];
				//changePosition(-10, 310);
			case 'spooky kids':
				curPortrait = spooky;
				spooky.visible = true;
				spooky.playAnim(animName);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/spookyText'), 0.6)];

			case 'morgana':
				curPortrait = morgana;
				morgana.visible = true;
				morgana.playAnim(animName);
				swagDialogue.sounds = null;
				charText.setPosition(482, 463);
			
		}

		if (skipDialogue || curCharacter == "") {
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
		else {
			if (!pauseDialogue) {//only used for transitions
				swagDialogue.resetText(dialogueList[0]);
				swagDialogue.start(0.04, true, false, [], waitStop);
			}

			if (curPortrait != null)
			{
				curShadow.setChar(curPortrait.character);
				curShadow.playAnim(animName);
			}
		}

		if (curCharacter != dupeChar)
		{
			dupeChar = curCharacter;
			setCharName();

			if (curPortrait != null)
				portraitFadeIn();
		}
						
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		animName = splitName[2];
		skipList = dialogueList[0].substr(splitName[1].length + 2).trim(); //for special events
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
	}

	function removeTransitions():Void
	{
		var speed:Float = 0.7;
		var delay:Float = 0;

		switch (transType)
		{
			case 'black':
				FlxTween.tween(black, {alpha: 0}, speed, {ease: FlxEase.linear});
			case 'bf':
				black.animation.play('go', false, true);
				delay = 0.5;
		}

		FlxG.sound.music.fadeIn(1, 0, 0.3);

		new FlxTimer().start(1 + delay, function(tmr:FlxTimer)
			{
				black.kill();
				dialogueList.remove(dialogueList[0]);
				startDialogue();
				canAdvance = true;

				FlxTween.tween(swagDialogue, {alpha: 1}, speed, {ease: FlxEase.linear});
				FlxTween.tween(box, {alpha: 1}, speed, {ease: FlxEase.linear});
				FlxTween.tween(charText, {alpha: 1}, speed, {ease: FlxEase.linear});
				curShadow.alpha = 1;

				if (curPortrait != null)
					portraitFadeIn();
				trace('removed using method');
			});
	}

	function waitStop():Void
	{
		dialogueEnded = true;
		if (curPortrait != null && curPortrait.animation.curAnim != null)
		{
			if (curPortrait.animation.curAnim.name.startsWith('talk') || curPortrait.animation.curAnim.name.startsWith('initial'))
			{
				curPortrait.animation.play('stop ' + curPortrait.animSuffix);
				curShadow.animation.play('stop ' + curPortrait.animSuffix);
			}
		}
	}

	function portraitFadeIn():Void
	{
		if (curPortrait != null)
		{
			curShadow.visible = false;

			var moveVal:Int = 20;
			curPortrait.alpha = 0;
			curPortrait.x -= moveVal;

			FlxTween.tween(curPortrait, {alpha: 1}, 0.1, {ease: FlxEase.quintOut});
			FlxTween.tween(curPortrait, {x: curPortrait.x + moveVal}, 0.1, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween)
			{
				curShadow.x = curPortrait.x;
				curShadow.y = curPortrait.y;
				curShadow.visible = true;

				FlxTween.tween(curShadow, {x: curShadow.x - 9, y: curShadow.y + 9}, 0.1, {ease: FlxEase.linear});
			}});
		}
	}

	function setCharName() {
		var tempName:String = '';
		var canCap:Bool = true;
		var charClone = curCharacter.toString();

		if (charClone == 'dad')
			charClone = 'daddy dearest'; //change dad's name

		for (i in 0...charClone.length) { 
			var temp:String = '';
			
			if (charClone.substring(i-1, i) == ' ')
				canCap = true;
			
			if (canCap)
			{
				temp = charClone.substring(i, i+1).toUpperCase();
				canCap = false;
			}
			else 
				temp = charClone.substring(i, i+1).toLowerCase();

			tempName += temp;
		}
		//trace(tempName);
		
		charText.text = tempName;
	}

	function switchBG() 
	{
		if (!bg1Exists)
		{
			bg1Exists = true;
			PlayState.bg1.loadGraphic(Paths.image('cutscenes/' + skipList, 'strikin'));
			FlxTween.tween(PlayState.bg1, {alpha: 1}, transitionSpeed, {ease: FlxEase.linear});

			curBG = PlayState.bg2;
		}
		else
		{
			if (curBG == PlayState.bg2)
			{
				PlayState.bg2.loadGraphic(Paths.image('cutscenes/' + skipList, 'strikin'));
				FlxTween.tween(PlayState.bg2, {alpha: 1}, transitionSpeed, {ease: FlxEase.linear});
				curBG = PlayState.bg1;
			}
			else
			{
				PlayState.bg1.loadGraphic(Paths.image('cutscenes/' + skipList, 'strikin'));
				FlxTween.tween(PlayState.bg2, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
				curBG = PlayState.bg2;
			}
		}
	}
}
