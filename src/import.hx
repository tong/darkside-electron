
import haxe.Json;
import haxe.Timer;
import haxe.ds.Option;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.Error;
import js.Node;
import js.Node.process;
import js.Promise;
import js.html.ArrayBuffer;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.DivElement;
import js.html.InputElement;
import js.html.MouseEvent;
import js.html.Uint8Array;
import js.node.Buffer;

import om.Time;
import om.color.space.Grey;
import om.color.space.HSL;
import om.color.space.HSV;
import om.color.space.RGB;
import om.color.space.RGBA;

import Sys.print;
import Sys.println;

using om.ArrayTools;
using om.ColorTools;
using om.StringTools;

#if electron_renderer
using om.DOM;
#end
