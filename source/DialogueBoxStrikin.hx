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
	var dialogueList:Array<String> = [];
	var skipList:String = '';

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var otherThing:Void->Void;

	var charText:FlxText;

	var bf:Portrait = new Portrait(0, 0, 'bf');
	var dad:Portrait = new Portrait(0, 0, 'dad');
	var pico:Portrait = new Portrait(0, 0, 'pico');
	var morgana:Portrait = new Portrait(-40, 230, 'morgana');

	var portArray:Array<Portrait>;

	var curPortrait:Portrait;
	var curShadow:Portrait;

	var bgFade:FlxSprite;
	var bgBARS:FlxSprite;

	var bg1Exists:Bool = false;
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var curBG:FlxSprite;
	var transitionSpeed:Float = 0.7;

	public static var dialogueFunctions:Bool = false;
	public static var canKill:Bool = false;

	var skipDialogue:Bool = false;

	//sfx
	var clickSound:FlxSound = FlxG.sound.load(Paths.sound('fns/personaClick'));
	var sound:FlxSound;

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

		clickSound.volume = 0.4;

		//preloading choice spritesheet
		var choices:FlxSprite = new FlxSprite(0, 0);
		choices.frames = Paths.getSparrowAtlas('dialogue/dialoguechoice', 'strikin');
		var bfb:FlxSprite = new FlxSprite(0, 0);
		bfb.frames = Paths.getSparrowAtlas('dialogue/BFBLINK', 'strikin');

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
		//bg1.screenCenter(X);
		//bg1.screenCenter(Y);
		bg1.alpha = 0;
		add(bg1);

		bg2 = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscenes/leblanc', 'strikin'));
		bg2.setGraphicSize(Std.int(bg2.width = FlxG.width*1.79));
		bg2.setGraphicSize(Std.int(bg2.height = FlxG.height*1.79));
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		//bg2.screenCenter(X);
		//bg2.screenCenter(Y);
		bg2.alpha = 0;
		add(bg2);

		curBG = bg1;

		curPortrait = bf;
		curShadow = new Portrait(0, 0, "bf");
		curShadow.visible = false;
		curShadow.color = FlxColor.BLACK;
		add(curShadow);
		
		portArray = [bf, dad, pico, morgana];

		for(i in 0...portArray.length) {
			portArray[i].visible = false;
		}

		add(bf);
		add(dad);
		add(pico);
		add(morgana);
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * 0.75));
		box.updateHitbox();
		box.x = 280;
		box.y = 405;
		add(box);

		//box.screenCenter(X);


		if (!talkingRight)
		{
			// box.flipX = true;
		}
			
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

	override function update(elapsed:Float)
	{
		#if debug
		FlxG.watch.addQuick("curPortrait.x", curPortrait.x);
		FlxG.watch.addQuick("curPortrait.y", curPortrait.y);
		FlxG.watch.addQuick("swagDialogue.x", swagDialogue.x);
		FlxG.watch.addQuick("swagDialogue.y", swagDialogue.y);
		FlxG.watch.addQuick("charText.x", charText.x);
		FlxG.watch.addQuick("charText.y", charText.y);
		FlxG.watch.addQuick("box.x", box.x);
		FlxG.watch.addQuick("box.y", box.y);
		var multiplier:Int;

		if (FlxG.keys.pressed.SHIFT)
			multiplier = 40;
		else
			multiplier = 0;

		if (FlxG.keys.justPressed.I)
		{					
			charText.y -= 1 + multiplier;
			//curShadow.y -= 10 + multiplier;
		}
		if (FlxG.keys.justPressed.K)
		{
			charText.y += 1 + multiplier;
			//curShadow.y += 10 + multiplier;
		}
		if (FlxG.keys.justPressed.J)
		{
			charText.x -= 1 + multiplier;
			//curShadow.x -= 10 + multiplier;
		}
		if (FlxG.keys.justPressed.L)
		{
			charText.x += 1 + multiplier;
			//curShadow.x += 10 + multiplier;
		}
		#end

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
				
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.S  && dialogueStarted == true) //come back to change later
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

					if (dialogueFunctions)
						otherThing();
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
								if (dialogueFunctions)
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
						if (dialogueFunctions)
						{
							finishThing();
							kill();
						}

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

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		skipDialogue = false;

		for(i in 0...portArray.length) {
			portArray[i].visible = false;
		}

		switch (curCharacter)
		{
			case 'bg':
				skipDialogue = true;
				if (skipList == "") {
					FlxTween.tween(bg1, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
					FlxTween.tween(bg2, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
					bg1Exists = false;
				}
				else {
					switchBG();
				}

			case 'audio':
				skipDialogue = true;
				if (sound != null)
					sound.stop();
				sound = FlxG.sound.load(Paths.sound("fns/" + dialogueList[0]));
				sound.volume = Std.parseFloat(animName);
				sound.play();

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
				charText.x = 469; charText.y = 465;

			case 'pico':
				curPortrait = pico;
				pico.visible = true;
				pico.playAnim(animName);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('fns/picoText'), 0.6)];
				//changePosition(-10, 310);

			case 'morgana':
				curPortrait = morgana;
				morgana.visible = true;
				morgana.playAnim(animName);
				swagDialogue.sounds = null;
				charText.x = 482; charText.y = 463;
			
		}

		if (skipDialogue || curCharacter == "") {
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
		else {
			swagDialogue.resetText(dialogueList[0]);
			swagDialogue.start(0.04, true, false, [], waitStop);

			curShadow.setChar(curPortrait.getName());
			curShadow.playAnim(animName);
		}

		if (curCharacter != dupeChar)
		{
			dupeChar = curCharacter;
			setCharName();
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

	function waitStop():Void
	{
		if (curPortrait.animation.curAnim != null)
		{
			if (curPortrait.animation.curAnim.name.startsWith('talk') || curPortrait.animation.curAnim.name.startsWith('initial'))
			{
				curPortrait.animation.play('stop ' + curPortrait.getAnimSuffix());
				curShadow.animation.play('stop ' + curPortrait.getAnimSuffix());
			}
		}
	}

	function portraitFadeIn():Void
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

			FlxTween.tween(curShadow, {x: curShadow.x - 5, y: curShadow.y + 5}, 0.1, {ease: FlxEase.linear});
		}});
	}

	function changePosition(x:Int, y:Int)
	{
		curPortrait.x = x;
		curPortrait.y = y;
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
		trace(tempName);
		
		charText.text = tempName;
	}

	function switchBG() 
	{
		if (!bg1Exists)
		{
			bg1Exists = true;
			bg1.loadGraphic(Paths.image('cutscenes/' + skipList, 'strikin'));
			FlxTween.tween(bg1, {alpha: 1}, transitionSpeed, {ease: FlxEase.linear});

			curBG = bg2;
		}
		else
		{
			if (curBG == bg2)
			{
				bg2.loadGraphic(Paths.image('cutscenes/' + skipList, 'strikin'));
				FlxTween.tween(bg2, {alpha: 1}, transitionSpeed, {ease: FlxEase.linear});
				curBG = bg1;
			}
			else
			{
				bg1.loadGraphic(Paths.image('cutscenes/' + skipList, 'strikin'));
				FlxTween.tween(bg2, {alpha: 0}, transitionSpeed, {ease: FlxEase.linear});
				curBG = bg2;
			}
		}
	}
}
