package;

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
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		["Friday Night Strikin' Team"],
		['Arctic',				'fns/arctic',		'Project Co-Leader, Composer, Charter',				'https://twitter.com/arcticbluyt',		0xFFDEC371],
		['rblox',				'fns/rblox',		'Project Co-Leader\nProgrammer, Artist, Animator, Charter',	'',								0xFFED003D],
		['derpling',			'fns/derpling',		'Artist, Animator',									'',										0xFF46A348],
		['avioid',				'fns/avioid',		'Artist, Animator',									'https://twitter.com/avioid1',			0xFF706474],
		['LiterallyNoOne',		'fns/literallynoone',	'Composer',										'https://twitter.com/L_No_One1',		0xFF555A7A],
		['tictacto',			'fns/tictacto',		'Composer',											'https://twitter.com/tictactuh_/',		0xFF626889],
		['Plutonium',			'fns/plutonium',	'Charter',											'',										0xFFFFFFFF],
		['ItoSaihara',			'fns/ito',			'Artist',											'https://twitter.com/ItoSaihara_',		0xFFEC428E],
		['spacepatrolhana',		'fns/hana',			'Artist, Animator',									'https://twitter.com/spacepatrolhana',	0xFFFFC64C],
		['ItzRoger',			'fns/roger',		'Charter',											'https://twitter.com/ItzRogerOficia1',	0xFF282A34],
		['Ninkey',				'fns/ninkey',		'Artist',											'https://twitter.com/NinKey69',			0xFFFF0967],
		['JonTheWhis',			'fns/jonthewhis',	'Composer',											'https://twitter.com/JonTheWhis',		0xFF71F280],
		['HenrySL',				'fns/henrysl',		'Translator',										'https://twitter.com/SakataLouis',		0xFF9FCAFF],
		['Kryptos',				'fns/kryptos',		'Artist, Animator',									'https://twitter.com/KryptosWasTaken',	0xFF61F9FF],
		['DiscWraith',			'fns/discwraith',	'Charter, Artist',									'https://twitter.com/DiscWraith',		0xFFB94C7D],
		['Faye',				'fns/faye',			'Artist',											'https://twitter.com/JusttFaye',		0xFFF7B7F3],
		['RatFloppa',			'fns/ratfloppa',	'Artist',											'https://twitter.com/transfloppa',		0xFFE16666],
		['mewow',				'fns/mewow',		'Artist',											'',										0xFFBE2D2D],
		['Erin Lefe',			'fns/erin',			'Voice of Morgana',									'https://twitter.com/eri_lefeva',		0xFF6B24C2],
		['mercurie',			'fns/mercurie',		'Artist',											'https://twitter.com/_liquidmercury',	0xFF2A2424],
		['Spadowic',			'fns/spadowic',		'Translator',										'',										0xFFF9D93E],
		['soma',				'fns/soma',			'Musician, Voice Actor',							'',										0xFF719076],
		[''],
		['Special Thanks'],
		['Baesik',				'fns/baesik',		'',													'https://twitter.com/Baesik2',			0xFF731879],
		['JobaTheHut',			'fns/joba',			'Voice Actor',										'https://twitter.com/JobaDeHut?s=20',	0xFF8AB5DD],
		['maple',				'fns/maple',		'',													'https://twitter.com/EchoesLofii',		0xFFD2735B],
		['Octo',				'fns/octo',			'',													'https://twitter.com/YaBoiOctoooo',		0xFFB1005F],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',	0xFFFFDD33],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',		0xFFC30085],
		[''],
		['Engine Contributors'],
		['shubs',				'shubs',			'New Input System Programmer',						'https://twitter.com/yoshubs',			0xFF4494E6],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',						'https://twitter.com/polybiusproxy',	0xFFE01F32],
		['gedehari',			'gedehari',			'Chart Editor\'s Sound Waveform base',				'https://twitter.com/gedehari',			0xFFFF9300],
		['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',			0xFFFFFFFF],
		['bubba',				'bubba',			'Guest Composer for "Hot Dilf"',	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw',	0xFF61536A],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFF73838],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFFFBB1B],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFF53E52C],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFF6475F3]
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			if (creditsStuff[curSelected][3] != '')
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
