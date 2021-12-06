package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Portrait extends FlxSprite
{
	private var character:String = "";
	private var animSuffix:String = "bf0";
	public var canMove:Bool = true;
	private var animNames:Array<Dynamic> = [
		['normal', 0],
		['alt', 1],
		['happy', 1],
		['mad', 2],
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
				frames = Paths.getSparrowAtlas('dialogue/portraits', 'strikin');
				animation.addByIndices('talk dad0', 'dad talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop dad0', 'dad talk0', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby dad0', 'dad talk0', [4, 5, 6, 7], "", 24, true);
				//dad alt
				animation.addByIndices('initial talk dad1', 'dad talk1', [0, 1, 2, 3, 4, 5], "", 24, false);
				animation.addByIndices('talk dad1', 'dad talk1', [6, 7, 8, 9, 4, 5], "", 24, true);
				animation.addByIndices('stop dad1', 'dad talk1', [6, 7, 8, 9], "", 24, false);
				animation.addByIndices('standby dad1', 'dad talk1', [8, 9, 10, 11], "", 24, true);

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

			case 'morgana':
				frames = Paths.getSparrowAtlas('dialogue/portraits', 'strikin');
				//normal
				animation.addByIndices('talk morgana0', 'morgana talk0', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop morgana0', 'morgana talk0', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby morgana0', 'morgana talk0', [4, 5], "", 24, false);
				animation.addByIndices('blink morgana0', 'morgana talk0', [6, 7], "", 24, false);
				//happy
				animation.addByIndices('talk morgana1', 'morgana talk1', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop morgana1', 'morgana talk1', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby morgana1', 'morgana talk1', [4, 5], "", 24, false);
				//mad
				animation.addByIndices('talk morgana2', 'morgana talk2', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop morgana2', 'morgana talk2', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby morgana2', 'morgana talk2', [4, 5], "", 24, false);
				animation.addByIndices('blink morgana2', 'morgana talk2', [6, 7], "", 24, false);
				//sad
				animation.addByIndices('talk morgana3', 'morgana talk3', [0, 1, 2, 3, 4, 5], "", 24, true);
				animation.addByIndices('stop morgana3', 'morgana talk3', [2, 3, 4, 5], "", 24, false);
				animation.addByIndices('standby morgana3', 'morgana talk3', [4, 5], "", 24, false);
				animation.addByIndices('blink morgana3', 'morgana talk3', [6, 7], "", 24, false);
		}
	}

	public function playAnim(name:String)
	{
		var num:Int = 0;
		var prefix:String = 'talk ';

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

	public function getName():String {
		return character;
	}

	public function getAnimSuffix():String {
		return animSuffix;
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

				if (character == 'morgana')
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
