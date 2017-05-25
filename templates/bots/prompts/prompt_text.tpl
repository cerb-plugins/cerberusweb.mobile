{$msg_id = uniqid()}
<div class="bot-chat-object" data-delay-ms="{$delay_ms|default:0}" id="{$msg_id}" style="text-align:center;">
	<input type="text" class="bot-chat-input" placeholder="{$placeholder}" autocomplete="off" autofocus="autofocus">

	<script type="text/javascript">
	$(function() {
		var $msg = $('#{$msg_id}');
		var $chat_window_input_form = $msg.closest('form');
		var $convo = $chat_window_input_form.find('.bot-chat-window-convo');
		var $chat_input = $chat_window_input_form.find('input[name=message]');
		
		var $txt = $msg.find('input:text')
			.blur()
			.focus()
			.on('keyup', function(e) {
				if(13 != e.keyCode)
					return;
				
				$chat_input.val($txt.val());
				$convo.trigger('cerb-send-message');
				$msg.remove();
			})
			;
		;
	});
	</script>
</div>

