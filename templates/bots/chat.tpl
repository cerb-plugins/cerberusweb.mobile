<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-bot-chat{$session_id}" data-dom-cache="true" data-theme="a" class="cerb-page-bots-chat">

{include file="devblocks:cerberusweb.mobile::header.tpl" header_title="{$bot_name}" header_icon="{$bot_image_url}"}

<div data-role="content">
	<form action="javascript:;" method="post" onsubmit="return false;">
	<input type="hidden" name="session_id" value="{$session_id}">
	<textarea name="message" style="display:none;"></textarea>
	<input type="hidden" name="_csrf_token" value="{$session.csrf_token}">

	<div class="bot-chat-window">
		<div class="bot-chat-window-convo"></div>
	</div>
	
	</form>
</div>

<script type="text/javascript">
var $page = $('#page-bot-chat{$session_id}');

var $spinner = $('<img>')
	.attr('src', '{devblocks_url}c=resource&p=cerberusweb.core&f=css/ajax-spinner.gif{/devblocks_url}')
	.hide()
;

$page.on('pageshow', function(e) {
	var $convo = $page.find('div.bot-chat-window-convo');
	var $input = $page.find('textarea[name=message]');
	$input.focus();
	$convo.trigger('update');
});

$page.one('pageinit', function(e) {
	var $frm = $page.find('form');
	var $input = $page.find('textarea[name=message]');
	var $session = $frm.find('input:hidden[name=session_id]');
	var $convo = $page.find('div.bot-chat-window-convo');
	
	$convo.on('update', function(e) {
		$.mobile.silentScroll($convo.height());
	});
	
	$convo.on('cerb-send-message', function(e) {
		$spinner.appendTo($convo).show();
		
		var txt = $input.val();
		
		if(txt.length > 0) {
			// Create outgoing message in log
			var $msg = $('<div class="bot-chat-message bot-chat-right"></div>');
			var $bubble = $('<div class="bot-chat-message-bubble"></div>');
			
			$bubble.text(txt).appendTo($msg.appendTo($convo));
			
			$('<br clear="all">').insertAfter($msg);
			$convo.trigger('update');
		}
		
		$.post(
			'{devblocks_url}ajax.php?c=m&a=botSendMessage{/devblocks_url}',
			$frm.serialize(),
			function(html) {
				var $response = $(html);
				var delay_ms = 0;
				
				if(0 == $response.length) {
					$spinner.detach();
					return;
				}
				
				$response.each(function(i) {
					var $object = $(this);
					var delay = 0;
					var is_typing = false;
					
					if($object.is('.bot-chat-object')) {
						delay = $object.attr('data-delay-ms');
						is_typing = $object.attr('data-typing-indicator');
						
						if(isNaN(delay))
							delay = 0;
					}
					
					if(is_typing) {
						var func = function() {
							//$.mobile.loading('show');
							$spinner.appendTo($convo).show();
							$convo.trigger('update');
						}
						
						setTimeout(func, delay_ms);
					}
					
					delay_ms += parseInt(delay);
					
					var func = function() {
						$spinner.detach();
						$object.appendTo($convo).hide().fadeIn();
						$convo.trigger('update');
					}
					
					setTimeout(func, delay_ms);
				});
			}
		);
	});
	
	$input.keyup(function(e) {
		e.stopPropagation();
		
		var keycode = e.keyCode || e.which;
		if(13 == keycode) {
			e.preventDefault();
			$convo.trigger('cerb-send-message');
		}
	});
	
	// Send a blank message to get the first chat response
	$convo.trigger('cerb-send-message');
});
</script>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>