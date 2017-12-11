package darkside;

import electron.NativeImage;
import electron.main.BrowserWindow;
import electron.main.IpcMain;
import electron.main.WebContents;
import hxargs.Args;
import js.node.Fs;
import js.node.Http;

@:require(haxe_ver>=4.0,electron)
class Main {

	static var allowedDevices = [
		'74034313938351717211' // Arduino Mega
	];

	static var controllers = new Array<Controller>();
	static var win : BrowserWindow;
	//static var color : Int;
	//static var web : js.node.http.Server;

	/*
	static function setColor( color : Int ) {
		Main.color = color;
		for( ctrl in controllers ) {
			if( ctrl.connected ) {
				ctrl.setColor( color );
			}
		}
		sendToWindow( 'color', color );
	}
	*/

	static function openWindow() {
		if( win != null )
			return;

		win = new BrowserWindow( {
			//width: 320, height: 480,
			width: 620, height: 880,
			//frame: false,
			//useContentSize: true,
			backgroundColor: '#101010',
			show: false
		} );
		win.on( closed, function() {
			win = null;
			//if( js.Node.process.platform != 'darwin' ) electron.main.App.quit();
		});
		win.on( ready_to_show, function() {
			win.setMenu( null );
			win.show();
		});
		win.webContents.on( did_finish_load, function() {
			for( c in controllers ) {
				sendToWindow( 'controller', { port: c.port, baudRate: c.baudRate, connected: c.connected } );
			}
			#if debug
			win.webContents.openDevTools();
			#end
		});
		win.loadURL( 'file://' + Node.__dirname + '/app.html' );
	}

	static function updateControllers( ?callback : Error->Void ) {
		Controller.searchDevices( allowedDevices, function(e,devices){
			if( e != null ) callback( e ) else {
				for( dev in devices ) {
					var already = false;
					for( controller in controllers ) {
						if( controller.port == dev.comName ){
	                        already = true;
	                        break;
	                    }
					}
					if( !already ) {
						var controller = new Controller( dev.comName, 115200 );
						controllers.push( controller );
					}
				}
				callback( null );
			}
		});
	}

	static function sendToWindow( type : String, data : Dynamic ) {
		if( win != null && win.webContents != null ) {
			//Reflect.setField( data, 'type', type );
			win.webContents.send( 'data', Json.stringify( { type: type, data: data } ) );
		}
	}

	static function handleAppMessage( e, a ) {
		var msg = Json.parse( a );
		switch msg.type {
		case 'setColor':
			var arr : Array<Int> = msg.value;
			var rgb : RGB = arr;
			for( ctrl in controllers ) {
				if( ctrl.connected ) {
					ctrl.setColor( rgb );
				}
			}
		default:
			trace( 'Unknown app message: '+msg );
		}
	}

	static function handleError( e : Error ) {

		Sys.println( '[ERROR] '+e.message );

		var notification = new electron.main.Notification( {
			title: 'Darkside',
			body: e.message,
			icon: electron.NativeImage.createFromPath('icon/dsotm-512.png')
		});
		notification.show();

		sendToWindow( 'error', e.message );
	}

	static function main() {

		//Sys.println( '\x1B[41m \x1B[42m \x1B[44m \x1B[0m' );

		#if !debug
		electron.CrashReporter.start({
			companyName : "disktree",
			submitURL : "https://github.com/rrreal/dark-side-of-the-monitor"
		});
		#end

		var gui = false;

		electron.main.App.on( 'ready', function(e) {

			updateControllers( function(e){
				if( e != null ) {
					handleError( e );
					electron.main.App.quit();
				} else {
					if( controllers.length == 0 ) {
						Sys.println( '0 controllers found' );
					} else {
						for( ctrl in controllers ) {
							println( 'Connecting to '+ctrl.port );
							ctrl.connect( function(e){
								if( e != null ) {
									handleError( e );
								} else {
									/*
									Timer.delay( function(){
										ctrl.setColor( color );
									}, 500 );
									*/

								}
							});
						}
					}
				}
			});

			IpcMain.on( 'asynchronous-message', handleAppMessage );

			/// Readline
			/*
			var rl = js.node.Readline.createInterface({
				input: process.stdin,
				output: process.stdout,
				prompt: 'DARKSIDE> '
			});
			rl.on( 'line', line -> {
				trace(line);
			});
			rl.prompt();
			*/

			/*
			/// Read from named pipe
			function readPipe() {
				var pipe = Fs.createReadStream( 'pipe', { flags: 'r' } );
				pipe.on( 'data', function(buf){
					var str = buf.toString().trim();
					var expr = ~/(#|0x)([0-9a-f]{6})/i;
					if( expr.match( str ) ) {
						var color = Std.parseInt( '0x'+expr.matched(2) );
						setColor( color );
					} else {
						Sys.println( 'Invalid input' );
					}
					readPipe();
				} );
			};
			readPipe();
			*/

			/*
			web = js.node.Http.createServer( (req,res) -> {
				res.writeHead( 200, {'Content-Type': 'text/plain'} );
	            res.end( 'Hello World\n' );
			});
			web.listen( 1100, '127.0.0.1' );
			*/

			if( gui ) {
				openWindow();
			}
		});

		/*
		electron.main.App.on( 'before-quit', function(e) {
			trace("before-quit");
			for( ctrl in controllers ) ctrl.disconnect();
			if( win != null ) win.close();
		});
		*/

		var argHandler : ArgHandler;

		function usage() {
			println( 'Usage : darkside [-g]' );
			var doc = argHandler.getDoc();
			var lines = doc.split('\n').map( l -> return '  $l' );
			println( lines.join( '\n' ) );
		}

		argHandler = hxargs.Args.generate([

			/*
			@doc("initial color")
			["-c","--color"] => function(color:String) {
				//TODO check input format
				if( !color.startsWith('0x') ) color = '0x'+color; //color.substr(2);
				var i = try Std.parseInt( color ) catch(e:Dynamic) {
					trace(e);
					return;
				}
				//Main.color = i;
			},
			*/

			/*
			@doc("")
			["-q","--quiet"] => () -> {
			},

			@doc("provide web interface")
			["-w","--web"] => (port:Int,host:String) -> {
			},
			*/

			@doc("open graphical user interface")
			["-g","--gui"] => () -> gui = true,

			@doc("show help")
			["-h","--help"] => () -> {
				usage();
				electron.main.App.quit();
			},

			_ => (arg:String) -> {
				println( 'Unknown command: $arg' );
				electron.main.App.quit();
			}
		]);
		argHandler.parse( Sys.args() );
	}

}
