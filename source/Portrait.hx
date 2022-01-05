package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Portrait extends FlxSprite
{
	public var character:String = "";
	public var animSuffix:String = "bf0";
	public var canMove:Bool = true;
	private var animNames:Array<Dynamic> = [
		['normal', 0], ['skid', 0],
		['alt', 1], ['happy', 1], ['pump', 1],
		['mad', 2], ['both', 2],
		['sad', 3],
	];

	public function new(x:Float, y:Float, character:String = 'bf')
	{
		super(x, y);
		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;

		setAnimNames();
	}

	public function setAnimNames() {
		flipX = false;
		switch (character)
		{
			case 'bf':
				frames = Paths.getSparrowAtlas('dialogue/portraits', 'strikin');
				animation.addByIndices('talk bf0', 'bf talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop bf0', 'bf talk0', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby bf0', 'bf talk0', [4, 5], "", 24, false);
				//bf alt
				animation.addByIndices('initial talk bf1', 'bf talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
				animation.addByIndices('talk bf1', 'bf talk1', [6, 7, 8, 9, 4, 5], "", 24, true);
				animation.addByIndices('stop bf1', 'bf talk1', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby bf1', 'bf talk1', [8, 9], "", 24, false);

			case 'dad':
				frames = Paths.getSparrowAtlas('dialogue/dad_portrait', 'strikin');
				animation.addByIndices('talk dad0', 'dad1', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, true);
				animation.addByIndices('stop dad0', 'dad1', [1, 2, 3, 4, 5, 6, 7], "", 24, false);
				animation.addByIndices('standby dad0', 'dad1', [5, 5, 6, 7], "", 24, true);

				setGraphicSize(Std.int(width * 0.9));
				flipX = true;

			case 'pico':
				frames = Paths.getSparrowAtlas('dialogue/portraits', 'strikin');
				animation.addByIndices('talk pico0', 'pico talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop pico0', 'pico talk0', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby pico0', 'pico talk0', [4, 5], "", 24, false);
				//pico alt
				animation.addByIndices('initial talk pico1', 'pico talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
				animation.addByIndices('talk pico1', 'pico talk1', [6, 7, 8, 9, 10, 11], "", 24, true);
				animation.addByIndices('stop pico1', 'pico talk1', [8, 9, 10, 11], "", 24, false);
				animation.addByIndices('standby pico1', 'pico talk1', [10, 11], "", 24, false);

			case 'spooky kids':
				frames = Paths.getSparrowAtlas('dialogue/spooky_kids_portraits', 'strikin');
				//both
				animation.addByIndices('talk spooky kids2', 'both_portraits', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop spooky kids2', 'both_portraits', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby spooky kids2', 'both_portraits', [8, 9], "", 24, false);
				//skid
				animation.addByIndices('talk spooky kids0', 'skid_portraits', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop spooky kids0', 'skid_portraits', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby spooky kids0', 'skid_portraits', [8, 9], "", 24, false);
				//pump
				animation.addByIndices('talk spooky kids1', 'pump_portrait', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop spooky kids1', 'pump_portrait', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby spooky kids1', 'pump_portrait', [8, 9], "", 24, false);

			case 'morgana':
				frames = Paths.getSparrowAtlas('dialogue/Morgana_Portraits', 'strikin');
				//normal
				animation.addByIndices('talk morgana0', 'morgana_normal', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop morgana0', 'morgana_normal', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby morgana0', 'morgana_normal', [8, 9], "", 24, false);
				//happy
				animation.addByIndices('talk morgana1', 'morgana_happy', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop morgana1', 'morgana_happy', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby morgana1', 'morgana_happy', [8, 9], "", 24, false);
				//mad
				animation.addByIndices('talk morgana2', 'morgana_angry', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop morgana2', 'morgana_angry', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby morgana2', 'morgana_angry', [8, 9], "", 24, false);
				//sad
				animation.addByIndices('talk morgana3', 'morgana_worried', [4, 5, 6, 7, 8, 9], "", 24, true);
				animation.addByIndices('stop morgana3', 'morgana_worried', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby morgana3', 'morgana_worried', [8, 9], "", 24, false);

				setGraphicSize(Std.int(width * 0.85));
		}
	}

	public function playAnim(name:String)
	{
		var num:Int = 0;
		var prefix:String = 'talk ';

		canMove = true;

		if (name == 'alt')
			prefix = 'initial talk ';
		
		for (i in 0...animNames.length)
		{
			if (name == animNames[i][0])
			{
				num = animNames[i][1];
				break;
			}
		}

		animSuffix = character + num;
		name = prefix + animSuffix;
		
		animation.play(name);
	}

	public function setChar(newChar:String):Void {//just for the character shadows
		character = newChar;

		setAnimNames();
	}

	override function update(elapsed:Float)
	{
		if (canMove)
		{
			//PORTRAIT EDITING
			if (animation.curAnim != null)
			{
				if (animation.curAnim.name.startsWith('initial') && animation.curAnim.finished)
				{
					animation.play('talk ' + animSuffix);
				}
				if (animation.curAnim.name.startsWith('stop') && animation.curAnim.finished)
				{
					animation.play('standby ' + animSuffix);
				}

				if (character == 'no one blinks anymore lol, maybe soon')
				{
					if (animation.curAnim.name == 'standby ' + animSuffix && FlxG.random.bool(1))
						animation.play('blink ' + animSuffix);

					if (animation.curAnim.name == 'blink ' + animSuffix && animation.curAnim.finished)
					{
						animation.play('standby ' + animSuffix);
					}
				}
			}
		}

		super.update(elapsed);
	}
}
