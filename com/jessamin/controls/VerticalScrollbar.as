package com.jessamin.controls {
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import com.greensock.TweenLite;
	
	public class VerticalScrollbar extends EventDispatcher {
		public static const PRESSED:String = "pressed";
		public static const RELEASED:String = "released";
		public static const SCROLLING:String = "scrolling";
		
		private var stage:Stage;
		private var thumb:InteractiveObject;
		private var track:DisplayObject;
		private var window:DisplayObject;
		private var content:DisplayObject;
		private var up:InteractiveObject;
		private var down:InteractiveObject;
		
		private var yOffset:Number;
		private var topLimit:Number;
		private var thumbRange:Number;
		private var bottomLimit:Number;
		private var _scrollPercent:Number;
		private var contentRange:Number;
		private var speed:Number
		private var wheelSpeed:Number;
		
		public function VerticalScrollbar(  stage:Stage, 
											thumb:InteractiveObject, 
											track:InteractiveObject, 
											window:DisplayObject = null,
											content:DisplayObject = null,
											up:InteractiveObject = null, 
											down:InteractiveObject = null  ) {
			this.stage    = stage;
			this.thumb    = thumb;
			this.track    = track;
			this.window   = window;
			this.content  = content;
			this.up       = up;
			this.down     = down;
			
			yOffset = 0;
			topLimit = this.track.y;
			thumbRange = track.height - thumb.height -3;
			bottomLimit = track.y + thumbRange;
			if(content && window) contentRange = content.height - window.height;
			_scrollPercent = 0;
			speed = 0.01;
			wheelSpeed = 0.02;
			
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_onMouseDown);
			if(down) down.addEventListener(MouseEvent.MOUSE_DOWN, down_onMouseDown);
			if (up) up.addEventListener(MouseEvent.MOUSE_DOWN, up_onMouseDown);
			//turn on mouse wheel by default (calls the class's public setter method, below)
			this.wheelEnabled = true; 
		}
		private function stage_onMouseWheel(event:MouseEvent):void {
			_scrollPercent -= event.delta * wheelSpeed;
			//set boundaries:
			if (_scrollPercent > 1) _scrollPercent = 1;
			if (_scrollPercent < 0) _scrollPercent = 0;
			moveContent();
			thumb.y = _scrollPercent * thumbRange + track.y;
			dispatchEvent(new Event(VerticalScrollbar.SCROLLING));
		}
		private function thumb_onMouseDown(event:MouseEvent):void {
			yOffset = thumb.parent.mouseY - thumb.y;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
			dispatchEvent(new Event(VerticalScrollbar.PRESSED));
		}
		private function stage_onMouseMove(event:MouseEvent):void {
			thumb.y = thumb.parent.mouseY - yOffset;
			//restrict the movement of the thumb:
			if (thumb.y < topLimit) thumb.y = topLimit;
			if (thumb.y > bottomLimit) thumb.y = bottomLimit;
			//calculate scrollPercent and make it do stuff:
			_scrollPercent = (thumb.y - track.y) / thumbRange;
			moveContent();
			event.updateAfterEvent();
			dispatchEvent(new Event(VerticalScrollbar.SCROLLING));
		}
		private function stage_onMouseUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
			dispatchEvent(new Event(VerticalScrollbar.RELEASED));
		}
		private function down_onMouseDown(event:MouseEvent):void {
			stage.addEventListener(Event.ENTER_FRAME, scrollDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScrollingDown);
			dispatchEvent(new Event(VerticalScrollbar.PRESSED));
		}
		private function scrollDown(event:Event):void {
			_scrollPercent += speed;
			if(_scrollPercent > 1) _scrollPercent = 1;
			moveContent();
			thumb.y = _scrollPercent * thumbRange + track.y;
			dispatchEvent(new Event(VerticalScrollbar.SCROLLING));
		}
		private function stopScrollingDown(event:MouseEvent):void {
			stage.removeEventListener(Event.ENTER_FRAME, scrollDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScrollingDown);
			dispatchEvent(new Event(VerticalScrollbar.RELEASED));
		}
		private function up_onMouseDown(event:MouseEvent):void {
			stage.addEventListener(Event.ENTER_FRAME, scrollUp)
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScrollingUp);
			dispatchEvent(new Event(VerticalScrollbar.PRESSED));
		}
		private function scrollUp(event:Event):void {
			_scrollPercent -= speed;
			if(_scrollPercent < 0)_scrollPercent = 0;
			moveContent();
			thumb.y = _scrollPercent * thumbRange + track.y;
			dispatchEvent(new Event(VerticalScrollbar.SCROLLING));
		}
		private function stopScrollingUp(event:MouseEvent):void {
			stage.removeEventListener(Event.ENTER_FRAME, scrollUp)
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScrollingUp);
			dispatchEvent(new Event(VerticalScrollbar.RELEASED));
		}
		private function moveContent():void {
			if (content && window) TweenLite.to(content, 0.5, { y:window.y - (_scrollPercent * contentRange) } );
		}
		public function get scrollPercent():Number {
			return _scrollPercent;
		}
		public function set visible(value:Boolean):void {
			thumb.visible = value;
			track.visible = value;
			if (up) up.visible = value;
			if (down) down.visible = value;
		}
		public function get visible():Boolean {
			return (track.visible && thumb.visible);
		}
		public function reset():void {
			thumb.y = track.y;
			if (content && window) content.y = window.y;
			_scrollPercent = 0;
		}
		public function set wheelEnabled(value:Boolean):void {
			if (value == true) {
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_onMouseWheel);
			} else {
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL, stage_onMouseWheel);
			}
		}
	}
}