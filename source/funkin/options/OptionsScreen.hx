package funkin.options;

import funkin.options.type.OptionType;
import mobile.objects.MobileControls;

class OptionsScreen extends FlxTypedSpriteGroup<OptionType> {
	public static var optionHeight:Float = 120;

	public var parent:OptionsTree;

	public var curSelected:Int = 0;
	public var id:Int = 0;

	private var __firstFrame:Bool = true;

	public var name:String;
	public var desc:String;

	public var dpadMode:String = 'NONE';
	public var actionMode:String = 'NONE';
	public var prevVPadModes:Array<Dynamic> = [];

	public function new(name:String, desc:String, ?options:Array<OptionType>, dpadMode:String = 'NONE', actionMode:String = 'NONE') {
		super();
		this.name = name;
		this.desc = desc;
		if (options != null) for(o in options) add(o);
		if(MusicBeatState.instance.virtualPad != null)
			prevVPadModes = [MusicBeatState.instance.virtualPad.curDPadMode, MusicBeatState.instance.virtualPad.curActionMode];
		this.dpadMode = dpadMode;
		this.actionMode = actionMode;
		MusicBeatState.instance.removeVirtualPad();
		MusicBeatState.instance.addVirtualPad(dpadMode, actionMode);
		MusicBeatState.instance.addVirtualPadCamera(false);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		var controls = PlayerSettings.solo.controls;
		var wheel = MobileControls.mobileC ? 0 : FlxG.mouse.wheel;
		changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - wheel);
		x = id * FlxG.width;
		for(k=>option in members) {
			if(option == null) continue;

			var y:Float = ((FlxG.height - optionHeight) / 2) + ((k - curSelected) * optionHeight);

			option.selected = false;
			option.y = __firstFrame ? y : CoolUtil.fpsLerp(option.y, y, 0.25);
			option.x = x + (-50 + (Math.abs(Math.cos((option.y + (optionHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150));
		}
		if (__firstFrame) {
			__firstFrame = false;
			return;
		}

		if (members.length > 0) {
			members[curSelected].selected = true;
			if (controls.ACCEPT || (FlxG.mouse.justReleased && !MobileControls.mobileC))
				members[curSelected].onSelect();
			if (controls.LEFT_P)
				members[curSelected].onChangeSelection(-1);
			if (controls.RIGHT_P)
				members[curSelected].onChangeSelection(1);
		}
		if (controls.BACK || (FlxG.mouse.justReleasedRight && !MobileControls.mobileC))
			close();
	}

	public function close() {
		onClose(this);
		if(prevVPadModes != []){
			MusicBeatState.instance.removeVirtualPad();
			MusicBeatState.instance.addVirtualPad(prevVPadModes[0], prevVPadModes[1]);
			MusicBeatState.instance.addVirtualPadCamera(false);
		}
	}

	public function changeSelection(sel:Int, force:Bool = false) {
		if (members.length <= 0 || (sel == 0 && !force)) return;

		CoolUtil.playMenuSFX(SCROLL);
		curSelected = FlxMath.wrap(curSelected + sel, 0, members.length-1);
		members[curSelected].selected = true;
		updateMenuDesc();
	}

	public function updateMenuDesc(?customTxt:String) {
		if (parent == null || parent.treeParent == null) return;
		parent.treeParent.updateDesc(customTxt != null ? customTxt : members[curSelected].desc);
	}

	public dynamic function onClose(o:OptionsScreen) {}
}
