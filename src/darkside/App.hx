package darkside;

import darkside.gui.ColorPicker;
import electron.renderer.IpcRenderer;

class App {

	/** Updates per second sent to Main */
	static inline var UPS = 120;

	static var timeStart : Float;
	static var timer : Timer;
	static var index = 0;
	static var rgb : RGB;
	static var dirty = false;

	static function update() {

		/*
		if( ++index >= 256 ) index = 0;
		var rgb = ColorUtil.wheel( index );
		rgb.push(255);
		buffer = rgb;
		*/

		//var elapsed = Time.now() - timeStart;

		//trace(buffer);

		if( dirty ) {
			var msg = Json.stringify( { type: 'setColor', value: [rgb[0],rgb[1],rgb[2]] } );
			IpcRenderer.send( 'asynchronous-message', msg );
			//rgb = null;
			dirty = false;
		}

		document.body.style.background = rgb.toCSS3();
	}

	static function handleWindowResize(e) {
		//picker
	}

	static function main() {

		var element = document.querySelector( '.darkside' );

		var info = document.createDivElement();
		info.classList.add( 'info' );
		info.textContent = 'DARKSIDE';
		element.appendChild( info );

		var color = document.createDivElement();
		color.classList.add( 'color' );
		color.textContent = '-';
		element.appendChild( color );

		/*
		var picker = new ColorPicker( Std.int( window.innerWidth - 20 ), Std.int( window.innerHeight - 20 ) );
		picker.onSelect = function(c) {
			buffer = c;
			var rgb : RGB = buffer;
			var hsv : HSV = rgb;
			info.textContent = rgb.toString() +'--'+hsv.toString();
		}
		element.appendChild( picker.element );
		*/

		rgb = 0xff0000;
		dirty = true;

		var input = document.createInputElement();
		input.type = 'range';
		input.min = Std.string( 0 );
		input.max = Std.string( 359 );
		input.step = '1';
		element.appendChild( input );
		input.addEventListener( 'input', function(e){
			var v = Std.int( Std.parseFloat( input.value ) );
			rgb = (rgb:HSV).withHue( v ).toRGB();
			dirty = true;
		});

		var input = document.createInputElement();
		input.type = 'range';
		input.min = Std.string( 0.0 );
		input.max = Std.string( 1.0 );
		input.step = '0.01';
		element.appendChild( input );
		input.addEventListener( 'input', function(e){
			var v = Std.parseFloat( input.value );
			rgb = (rgb:HSV).withSaturation( v ).toRGB();
			dirty = true;
		});

		var input = document.createInputElement();
		input.type = 'range';
		input.min = Std.string( 0.0 );
		input.max = Std.string( 1.0 );
		input.step = '0.01';
		element.appendChild( input );
		input.addEventListener( 'input', function(e){
			var v = Std.parseFloat( input.value );
			rgb = (rgb:HSV).withValue( v ).toRGB();
			dirty = true;
		});

		//var control = new darkside.gui.ColorControl( 0x00ff00 );
		//element.appendChild( control );
		//control.setColor( '#00ff00' );

		//var html = haxe.Resource.getString( 'colorpicker.html' );
		//element.innerHTML = html;

		//var color = document.createInputElement();
		//color.type = 'color';
		//element.appendChild( color );

		Timer.delay( function(){
			timer = new Timer( Std.int( 1000/UPS ) );
			timer.run = update;
		}, 500 );

		window.addEventListener( 'resize', handleWindowResize,false );

		IpcRenderer.on( 'data', function(e,m) {

			var msg : { type : String, data : Dynamic };
			try {
				msg = Json.parse( m );
			} catch(e:Dynamic) {
				console.error(e);
				return;
			}

			var data : Dynamic = msg.data;
			trace( msg );

			switch msg.type {

			case 'color':
				trace( msg );
				//picker
				//color.textContent = data;

			case 'controller':
				info.textContent = data.port;

			case 'error':
				//info.textContent = data;
			}
		});

		/*
		IpcRenderer.on( 'asynchronous-reply', function(e,a) {
			trace(e,a);
		});
		*/

	}

}
